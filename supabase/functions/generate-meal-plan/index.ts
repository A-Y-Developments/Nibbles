import { createClient } from "@supabase/supabase-js";
import { corsHeaders } from "../_shared/cors.ts";

const OPENAI_URL = "https://api.openai.com/v1/chat/completions";
const DEFAULT_MODEL = "gpt-4o-mini";

const kAllergenKeys = [
  "peanut",
  "egg",
  "dairy",
  "tree_nuts",
  "sesame",
  "soy",
  "wheat",
  "fish",
  "shellfish",
] as const;

type AllergenStatus = "notStarted" | "inProgress" | "safe" | "flagged";

interface AllergenLogRow {
  allergen_key: string;
  had_reaction: boolean;
  log_date: string;
}

interface RecipeRow {
  id: string;
  title: string;
  age_range: string | null;
  allergen_tags: string[] | null;
  nutrition_tags: string[] | null;
  category: string | null;
}

interface RequestBody {
  babyId?: unknown;
  startDate?: unknown;
  endDate?: unknown;
  preferences?: unknown;
  notes?: unknown;
}

interface Assignment {
  recipeId: string;
  dayOffset: number;
}

const STAGE_TEXTURE: Record<number, { label: string; texture: string }> = {
  0: { label: "Stage 0", texture: "Milk only — not on solids yet" },
  1: { label: "Stage 1", texture: "Smooth, thin single-ingredient purées" },
  2: { label: "Stage 2", texture: "Thicker purées and soft mashes" },
  3: { label: "Stage 3", texture: "Lumpy mashes and soft finger foods" },
  4: { label: "Stage 4", texture: "Soft chopped foods and finger foods" },
  5: { label: "Stage 5", texture: "Soft family foods" },
};

// Whole-month age, mirroring lib/src/utils/age_in_months.dart.
function ageInMonths(dob: Date, now: Date): number {
  if (now <= dob) return 0;
  let months = (now.getUTCFullYear() - dob.getUTCFullYear()) * 12 +
    (now.getUTCMonth() - dob.getUTCMonth());
  if (now.getUTCDate() < dob.getUTCDate()) months -= 1;
  return months < 0 ? 0 : months;
}

// Mirrors the plan's meal_stage rule: <5→s0, 5→s1, 6→s2, 7-8→s3, 9-11→s4, >=12→s5.
function mealStageForAge(ageMonths: number): number {
  if (ageMonths < 5) return 0;
  if (ageMonths === 5) return 1;
  if (ageMonths === 6) return 2;
  if (ageMonths <= 8) return 3;
  if (ageMonths <= 11) return 4;
  return 5;
}

// s0=1,s1=1,s2=2,s3=2,s4=3,s5=3 — clamped [1,3].
function mealsPerDayForAge(ageMonths: number): number {
  const perStage = [1, 1, 2, 2, 3, 3];
  const meals = perStage[mealStageForAge(ageMonths)];
  return Math.min(3, Math.max(1, meals));
}

// Mirrors deriveStatusForLogs (lib/src/common/services/helpers/derive_allergen_status.dart).
function deriveStatusForLogs(logs: AllergenLogRow[]): AllergenStatus {
  if (logs.length === 0) return "notStarted";
  if (logs.some((l) => l.had_reaction)) return "flagged";
  if (logs.length >= 3) return "safe";
  return "inProgress";
}

function isoDateOnly(value: string): Date | null {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return null;
  const date = new Date(`${value}T00:00:00Z`);
  return Number.isNaN(date.getTime()) ? null : date;
}

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const openAiKey = Deno.env.get("OPENAI_API_KEY");
  const model = Deno.env.get("OPENAI_MODEL") ?? DEFAULT_MODEL;

  if (!supabaseUrl || !supabaseAnonKey) {
    return json({ error: "Server misconfigured." }, 500);
  }
  if (!openAiKey) {
    return json({ error: "AI service unavailable." }, 500);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json({ error: "Missing authorization." }, 401);
  }

  // JWT-bound client: RLS enforces that reads are limited to the caller's own
  // babies / allergen logs. recipes are public-read, so no service role needed.
  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { persistSession: false },
  });

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData?.user) {
    return json({ error: "Invalid or expired session." }, 401);
  }

  let body: RequestBody;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON body." }, 400);
  }

  const babyId = typeof body.babyId === "string" ? body.babyId.trim() : "";
  const startRaw = typeof body.startDate === "string" ? body.startDate : "";
  const endRaw = typeof body.endDate === "string" ? body.endDate : "";
  const preferences = Array.isArray(body.preferences)
    ? body.preferences.filter((p): p is string => typeof p === "string")
    : [];
  const notes = typeof body.notes === "string" ? body.notes.trim() : "";

  if (!babyId) return json({ error: "babyId is required." }, 400);

  const startDate = isoDateOnly(startRaw);
  const endDate = isoDateOnly(endRaw);
  if (!startDate || !endDate) {
    return json({ error: "startDate and endDate must be yyyy-MM-dd." }, 400);
  }
  if (endDate < startDate) {
    return json({ error: "endDate must be on or after startDate." }, 400);
  }

  const msPerDay = 24 * 60 * 60 * 1000;
  const dayCount =
    Math.round((endDate.getTime() - startDate.getTime()) / msPerDay) + 1;
  if (dayCount < 1 || dayCount > 60) {
    return json({ error: "Date range out of bounds." }, 400);
  }

  // ── Server-side reads ──────────────────────────────────────────────────────
  const { data: baby, error: babyError } = await supabase
    .from("babies")
    .select("name, date_of_birth")
    .eq("id", babyId)
    .maybeSingle();

  if (babyError) {
    return json({ error: "Could not load baby profile." }, 500);
  }
  if (!baby) {
    return json({ error: "Baby not found." }, 404);
  }

  const dob = isoDateOnly(String(baby.date_of_birth).slice(0, 10));
  const ageMonths = dob ? ageInMonths(dob, new Date()) : 0;
  const stage = mealStageForAge(ageMonths);
  const mealsPerDay = mealsPerDayForAge(ageMonths);
  const stageInfo = STAGE_TEXTURE[stage];

  const { data: logRows, error: logsError } = await supabase
    .from("allergen_logs")
    .select("allergen_key, had_reaction, log_date")
    .eq("baby_id", babyId);

  if (logsError) {
    return json({ error: "Could not load allergen history." }, 500);
  }

  const logsByKey = new Map<string, AllergenLogRow[]>();
  for (const row of (logRows ?? []) as AllergenLogRow[]) {
    const list = logsByKey.get(row.allergen_key) ?? [];
    list.push(row);
    logsByKey.set(row.allergen_key, list);
  }

  const statusByKey: Record<string, AllergenStatus> = {};
  for (const key of kAllergenKeys) {
    statusByKey[key] = deriveStatusForLogs(logsByKey.get(key) ?? []);
  }
  const flaggedKeys = new Set<string>(
    kAllergenKeys.filter((k) => statusByKey[k] === "flagged"),
  );

  const { data: recipeRows, error: recipesError } = await supabase
    .from("recipes")
    .select("id, title, age_range, allergen_tags, nutrition_tags, category");

  if (recipesError) {
    return json({ error: "Could not load recipes." }, 500);
  }

  const pool = ((recipeRows ?? []) as RecipeRow[]).map((r) => ({
    id: r.id,
    title: r.title,
    ageRange: r.age_range ?? "",
    allergenTags: r.allergen_tags ?? [],
    nutritionTags: r.nutrition_tags ?? [],
    category: r.category ?? "Other",
  }));

  const poolById = new Map(pool.map((r) => [r.id, r]));

  if (pool.length === 0) {
    return json({ error: "No recipes available to plan from." }, 502);
  }

  // ── Prompt ─────────────────────────────────────────────────────────────────
  const statusLines = kAllergenKeys
    .map((k) => `- ${k}: ${statusByKey[k]}`)
    .join("\n");

  const poolLines = pool
    .map((r) => {
      const contains = r.allergenTags.length
        ? r.allergenTags.join(", ")
        : "none";
      const nutrition = r.nutritionTags.length
        ? r.nutritionTags.join(", ")
        : "none";
      return `- id="${r.id}" | "${r.title}" | age ${
        r.ageRange || "n/a"
      } | category ${r.category} | contains allergens: [${contains}] | nutrition: [${nutrition}]`;
    })
    .join("\n");

  const systemPrompt =
    "You are a paediatric-nutrition-aware meal planning assistant for a baby " +
    "solids app. You ONLY select from the provided recipe pool and you return " +
    "STRICT JSON. Never invent recipe ids. Prioritise safety: never assign a " +
    "recipe that contains an allergen the baby has reacted to (flagged).";

  const userPrompt = [
    `Baby: ${baby.name}, age ${ageMonths} months.`,
    `Meal stage: ${stageInfo.label} — texture rule: ${stageInfo.texture}.`,
    `Target meals per day: ${mealsPerDay} (soft target, fill up to this many per day when good options exist).`,
    `Plan spans ${dayCount} day(s), dayOffset 0..${dayCount - 1} inclusive.`,
    "",
    "Per-allergen status (safe = tolerated, flagged = reacted/AVOID, inProgress = currently being introduced, notStarted = not yet introduced):",
    statusLines,
    "",
    "Rules:",
    `- NEVER pick a recipe whose "contains allergens" intersects any FLAGGED allergen.`,
    `- Prefer recipes whose minimum age is <= ${ageMonths} months (age-appropriate).`,
    "- Honor the caregiver's preferences and notes below when choosing recipes.",
    "- Variety across days is preferable; repeats are acceptable if the pool is small.",
    "",
    `Caregiver preferences: ${
      preferences.length ? preferences.join(", ") : "none"
    }.`,
    `Caregiver notes: ${notes || "none"}.`,
    "",
    "Recipe pool:",
    poolLines,
    "",
    'Return ONLY JSON of the form: {"assignments":[{"recipeId":"<id from pool>","dayOffset":<int>}]}.',
    `Fill each day (dayOffset 0..${
      dayCount - 1
    }) with up to ${mealsPerDay} assignment(s).`,
  ].join("\n");

  // ── OpenAI call ──────────────────────────────────────────────────────────────
  let aiResponse: Response;
  try {
    aiResponse = await fetch(OPENAI_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${openAiKey}`,
      },
      body: JSON.stringify({
        model,
        temperature: 0.4,
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt },
        ],
      }),
    });
  } catch (_err) {
    return json({ error: "AI request failed." }, 502);
  }

  if (!aiResponse.ok) {
    // Do not surface the provider body — it can echo request context.
    console.error(`OpenAI error status ${aiResponse.status}`);
    return json({ error: "AI generation failed." }, 502);
  }

  let content: string;
  try {
    const payload = await aiResponse.json();
    content = payload?.choices?.[0]?.message?.content ?? "";
  } catch {
    return json({ error: "AI returned an unreadable response." }, 502);
  }

  let parsed: { assignments?: unknown };
  try {
    parsed = JSON.parse(content);
  } catch {
    return json({ error: "AI returned malformed JSON." }, 502);
  }

  const rawAssignments = Array.isArray(parsed?.assignments)
    ? parsed.assignments
    : [];

  // ── Server-side validation ───────────────────────────────────────────────────
  const assignments: Assignment[] = [];
  for (const item of rawAssignments) {
    if (typeof item !== "object" || item === null) continue;
    const recipeId = (item as Record<string, unknown>).recipeId;
    const dayOffset = (item as Record<string, unknown>).dayOffset;
    if (typeof recipeId !== "string") continue;
    if (typeof dayOffset !== "number" || !Number.isInteger(dayOffset)) continue;
    if (dayOffset < 0 || dayOffset > dayCount - 1) continue;

    const recipe = poolById.get(recipeId);
    if (!recipe) continue;
    if (recipe.allergenTags.some((tag) => flaggedKeys.has(tag))) continue;

    assignments.push({ recipeId, dayOffset });
  }

  if (assignments.length === 0) {
    return json(
      { error: "AI did not produce any valid meal assignments." },
      502,
    );
  }

  return json({ assignments }, 200);
});
