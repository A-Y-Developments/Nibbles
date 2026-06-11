#!/bin/zsh
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

if [[ -z "$BABY_ID" ]]; then
  BABY_ID=$(curl -s -X POST "${auth[@]}" -H "Content-Type: application/json" \
    "$SUPABASE_URL/rest/v1/rpc/create_baby_with_program" \
    -d '{"p_name":"Testy","p_date_of_birth":"2025-11-15","p_gender":"female"}' \
    | python3 -c "import json,sys;print(json.load(sys.stdin)['id'])")
fi

for table in shopping_list_items meal_plan_entries allergen_logs; do
  curl -s -X DELETE "${auth[@]}" "$SUPABASE_URL/rest/v1/$table?baby_id=eq.$BABY_ID" > /dev/null
done

curl -s -X POST "${auth[@]}" -H "Content-Type: application/json" -H "Prefer: return=minimal" \
  "$SUPABASE_URL/rest/v1/allergen_logs" -d "[
{\"baby_id\":\"$BABY_ID\",\"allergen_key\":\"peanut\",\"had_reaction\":false,\"log_date\":\"2026-06-05\",\"notes\":\"seed: first taste\"},
{\"baby_id\":\"$BABY_ID\",\"allergen_key\":\"peanut\",\"had_reaction\":false,\"log_date\":\"2026-06-07\",\"notes\":null},
{\"baby_id\":\"$BABY_ID\",\"allergen_key\":\"peanut\",\"had_reaction\":false,\"log_date\":\"2026-06-09\",\"notes\":null},
{\"baby_id\":\"$BABY_ID\",\"allergen_key\":\"egg\",\"had_reaction\":false,\"log_date\":\"2026-06-10\",\"notes\":\"seed: in progress\"}
]"

echo "reseeded baby=$BABY_ID"
