-- Enable RLS on all user-owned tables
ALTER TABLE babies ENABLE ROW LEVEL SECURITY;
ALTER TABLE allergen_program_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE allergen_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE reaction_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_plan_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list_items ENABLE ROW LEVEL SECURITY;

-- Enable RLS on public read-only tables
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE allergens ENABLE ROW LEVEL SECURITY;

-- babies: owner access only
CREATE POLICY "Users can manage their own baby" ON babies
  FOR ALL USING (user_id = auth.uid());

-- allergen_program_state: via baby ownership
CREATE POLICY "Users can manage their own program state" ON allergen_program_state
  FOR ALL USING (
    baby_id IN (SELECT id FROM babies WHERE user_id = auth.uid())
  );

-- allergen_logs: via baby ownership
CREATE POLICY "Users can manage their own allergen logs" ON allergen_logs
  FOR ALL USING (
    baby_id IN (SELECT id FROM babies WHERE user_id = auth.uid())
  );

-- reaction_details: via allergen_log → baby ownership
CREATE POLICY "Users can manage their own reaction details" ON reaction_details
  FOR ALL USING (
    log_id IN (
      SELECT id FROM allergen_logs
      WHERE baby_id IN (SELECT id FROM babies WHERE user_id = auth.uid())
    )
  );

-- meal_plan_entries: via baby ownership
CREATE POLICY "Users can manage their own meal plan" ON meal_plan_entries
  FOR ALL USING (
    baby_id IN (SELECT id FROM babies WHERE user_id = auth.uid())
  );

-- shopping_list_items: via baby ownership
CREATE POLICY "Users can manage their own shopping list" ON shopping_list_items
  FOR ALL USING (
    baby_id IN (SELECT id FROM babies WHERE user_id = auth.uid())
  );

-- recipes: public read, no user writes (admin-managed seed data)
CREATE POLICY "Recipes are public read" ON recipes
  FOR SELECT USING (true);

-- allergens: public read, no user writes (admin-managed seed data)
CREATE POLICY "Allergens are public read" ON allergens
  FOR SELECT USING (true);
