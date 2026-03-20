## NIB-xx — [Ticket title]

## What changed
-

## Architecture check
- [ ] No Supabase calls above Repository layer
- [ ] All async ops return `Result<T>` — no raw throws
- [ ] No DTOs exposed above Repository layer
- [ ] JWT not stored in Hive or SharedPreferences
- [ ] Hive: only `recipes`, `allergens`, `local_flags` boxes used
- [ ] Zero linting warnings (`flutter analyze` clean)

## Error handling
- [ ] Correct error level used (P0/P1/P2/P3) per CLAUDE.md error table
- [ ] UI error messages match the spec exactly

## Tests
- [ ] Unit tests written / updated for changed services/repos
- [ ] Widget tests written / updated for changed screens

## Manual steps required after merge
-
