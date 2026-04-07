-- Create private storage bucket for allergen photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('allergen-photos', 'allergen-photos', false)
ON CONFLICT (id) DO NOTHING;

-- RLS: users can upload photos for their own babies
CREATE POLICY "Users can upload allergen photos for own babies"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'allergen-photos'
  AND (storage.foldername(name))[1] IN (
    SELECT id::text FROM public.babies WHERE user_id = auth.uid()
  )
);

-- RLS: users can view photos for their own babies
CREATE POLICY "Users can view allergen photos for own babies"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'allergen-photos'
  AND (storage.foldername(name))[1] IN (
    SELECT id::text FROM public.babies WHERE user_id = auth.uid()
  )
);

-- RLS: users can delete photos for their own babies
CREATE POLICY "Users can delete allergen photos for own babies"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'allergen-photos'
  AND (storage.foldername(name))[1] IN (
    SELECT id::text FROM public.babies WHERE user_id = auth.uid()
  )
);
