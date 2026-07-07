import { createClient } from "@supabase/supabase-js";
import { corsHeaders } from "../_shared/cors.ts";

interface RequestBody {
  reason?: unknown;
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
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !supabaseAnonKey || !serviceRoleKey) {
    return json({ error: "Server misconfigured." }, 500);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json({ error: "Missing authorization." }, 401);
  }

  // JWT-bound client — identifies the caller and enforces RLS on the reason
  // insert. It can only ever act as the caller, so the uid deleted below is
  // always the caller's own (never a uid taken from the request body).
  const userClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { persistSession: false },
  });

  const { data: userData, error: userError } = await userClient.auth.getUser();
  if (userError || !userData?.user) {
    return json({ error: "Invalid or expired session." }, 401);
  }
  const userId = userData.user.id;

  let body: RequestBody;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON body." }, 400);
  }

  const reason = typeof body.reason === "string" ? body.reason.trim() : "";
  if (!reason) {
    return json({ error: "reason is required." }, 400);
  }

  // Record the churn reason BEFORE deleting the user. account_deletion_requests
  // is ON DELETE SET NULL, so this audit row survives the auth-user deletion
  // (user_id → null). Best-effort: a failure here must not block the deletion
  // the user explicitly asked for.
  const { error: reasonError } = await userClient
    .from("account_deletion_requests")
    .insert({ user_id: userId, reason });
  if (reasonError) {
    console.error(`deletion reason insert failed: ${reasonError.message}`);
  }

  // Service-role client — deletes the auth user. auth.users ON DELETE CASCADE
  // removes babies and everything baby-scoped (allergen logs + reactions,
  // program state, meal plans + entries, shopping list) plus consents; feedback
  // and the reason row are ON DELETE SET NULL.
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });

  const { error: deleteError } = await adminClient.auth.admin.deleteUser(
    userId,
  );
  if (deleteError) {
    console.error(`admin.deleteUser failed: ${deleteError.message}`);
    return json({ error: "Could not delete account. Please try again." }, 500);
  }

  return json({ success: true }, 200);
});
