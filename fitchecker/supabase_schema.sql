-- ============================================
-- FitChecker Supabase Database Schema
-- ============================================
-- Run this SQL in the Supabase SQL Editor
-- (Dashboard → SQL Editor → New Query)
-- ============================================

-- Enable UUID extension (should already be enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PROFILES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  gender TEXT NOT NULL CHECK (gender IN ('Female', 'Male')),
  height NUMERIC NOT NULL, -- in cm
  weight NUMERIC NOT NULL, -- in kg
  profile_image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster user lookups
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);

-- ============================================
-- MEASUREMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS measurements (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  gender TEXT NOT NULL CHECK (gender IN ('Female', 'Male')),
  -- Female measurements (cm)
  bust NUMERIC,
  waist NUMERIC,
  hip NUMERIC,
  -- Male measurements (cm)
  chest NUMERIC,
  shoulder NUMERIC,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  -- One measurement set per profile
  UNIQUE(profile_id)
);

-- Index for faster profile lookups
CREATE INDEX IF NOT EXISTS idx_measurements_profile_id ON measurements(profile_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can only see their own profiles
CREATE POLICY "Users can view own profiles"
  ON profiles FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own profiles
CREATE POLICY "Users can insert own profiles"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own profiles
CREATE POLICY "Users can update own profiles"
  ON profiles FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own profiles
CREATE POLICY "Users can delete own profiles"
  ON profiles FOR DELETE
  USING (auth.uid() = user_id);

-- Enable RLS on measurements
ALTER TABLE measurements ENABLE ROW LEVEL SECURITY;

-- Users can view measurements for their own profiles
CREATE POLICY "Users can view own measurements"
  ON measurements FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = measurements.profile_id
      AND profiles.user_id = auth.uid()
    )
  );

-- Users can insert measurements for their own profiles
CREATE POLICY "Users can insert own measurements"
  ON measurements FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = measurements.profile_id
      AND profiles.user_id = auth.uid()
    )
  );

-- Users can update measurements for their own profiles
CREATE POLICY "Users can update own measurements"
  ON measurements FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = measurements.profile_id
      AND profiles.user_id = auth.uid()
    )
  );

-- Users can delete measurements for their own profiles
CREATE POLICY "Users can delete own measurements"
  ON measurements FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = measurements.profile_id
      AND profiles.user_id = auth.uid()
    )
  );

-- ============================================
-- AUTO-UPDATE updated_at TRIGGER
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_measurements_updated_at
  BEFORE UPDATE ON measurements
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- STORAGE BUCKETS
-- ============================================
-- Run these in the SQL editor as well.
-- They create the storage buckets for images.

INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('clothing-images', 'clothing-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for profile-images bucket
CREATE POLICY "Users can upload profile images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'profile-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update own profile images"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'profile-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own profile images"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'profile-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Anyone can view profile images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profile-images');

-- Storage policies for clothing-images bucket
CREATE POLICY "Users can upload clothing images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'clothing-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update own clothing images"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'clothing-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own clothing images"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'clothing-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Anyone can view clothing images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'clothing-images');
