#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
set -a; source .env.dev; set +a

TOKEN=$(curl -s -X POST "$SUPABASE_URL/auth/v1/token?grant_type=password" \
  -H "apikey: $SUPABASE_ANON_KEY" -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_ACCOUNT_EMAIL\",\"password\":\"$TEST_ACCOUNT_PASSWORD\"}" \
  | python3 -c "import json,sys;print(json.load(sys.stdin)['access_token'])")

auth=(-H "apikey: $SUPABASE_ANON_KEY" -H "Authorization: Bearer $TOKEN")
BABY_ID=$(curl -s "${auth[@]}" "$SUPABASE_URL/rest/v1/babies?select=id" \
  | python3 -c "import json,sys;d=json.load(sys.stdin);print(d[0]['id'] if d else '')")
[[ -n "$BABY_ID" ]] || { echo "no baby — run reseed.sh first"; exit 1; }

curl -s -X DELETE "${auth[@]}" "$SUPABASE_URL/rest/v1/allergen_logs?baby_id=eq.$BABY_ID" > /dev/null

ROWS=$(python3 - "$BABY_ID" <<'EOF'
import json, sys
baby = sys.argv[1]
safe = ["peanut","egg","dairy","tree_nuts","sesame","soy","wheat","fish"]
rows = []
day = 1
for key in safe:
    for i in range(3):
        rows.append({"baby_id": baby, "allergen_key": key, "had_reaction": False,
                     "log_date": f"2026-05-{day:02d}", "notes": None})
        day += 1
for i in range(2):
    rows.append({"baby_id": baby, "allergen_key": "shellfish", "had_reaction": False,
                 "log_date": f"2026-06-{8+i:02d}", "notes": None})
print(json.dumps(rows))
EOF
)

curl -s -X POST "${auth[@]}" -H "Content-Type: application/json" -H "Prefer: return=minimal" \
  "$SUPABASE_URL/rest/v1/allergen_logs" -d "$ROWS"

echo "seeded near-complete baby=$BABY_ID (8 safe, shellfish 2/3)"
