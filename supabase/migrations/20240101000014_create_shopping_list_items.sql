CREATE TABLE IF NOT EXISTS public.shopping_list_items (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id    uuid        NOT NULL REFERENCES public.babies(id) ON DELETE CASCADE,
  name       text        NOT NULL,
  is_checked boolean     NOT NULL DEFAULT false,
  source     text        NOT NULL DEFAULT 'manual',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.shopping_list_items ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS shopping_list_items_baby_idx
  ON public.shopping_list_items (baby_id);

CREATE POLICY "Users can manage shopping list for their own babies"
  ON public.shopping_list_items FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.babies
      WHERE babies.id = shopping_list_items.baby_id
        AND babies.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.babies
      WHERE babies.id = shopping_list_items.baby_id
        AND babies.user_id = auth.uid()
    )
  );
