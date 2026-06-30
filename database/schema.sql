-- ============================================
-- BrgyPulse Database Schema
-- Supabase (PostgreSQL)
-- ============================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ──────────────────────────────────────────────
-- 1. PROFILES (linked to Supabase Auth)
-- ──────────────────────────────────────────────

CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  zone TEXT,
  role TEXT NOT NULL DEFAULT 'civilian' CHECK (role IN ('civilian', 'official', 'admin')),
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_profiles_role ON profiles(role);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
    COALESCE(NEW.raw_user_meta_data->>'role', 'civilian')
  );
  
  IF COALESCE(NEW.raw_user_meta_data->>'role', 'civilian') = 'admin' THEN
    INSERT INTO officials (id, role_title, points, missions_completed, is_active)
    VALUES (NEW.id, 'Barangay Admin', 0, 0, true);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ──────────────────────────────────────────────
-- 2. OFFICIALS (extends profiles)
-- ──────────────────────────────────────────────

CREATE TABLE officials (
  id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  role_title TEXT NOT NULL DEFAULT 'Barangay Tanod',
  points INTEGER NOT NULL DEFAULT 0,
  missions_completed INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_officials_points ON officials(points DESC);

-- ──────────────────────────────────────────────
-- 3. REPORTS
-- ──────────────────────────────────────────────

CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  description TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN (
    'trash', 'parking', 'noise', 'curfew', 'flood', 'sos', 'safeZone'
  )),
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'resolved')),
  reported_by UUID REFERENCES profiles(id),
  flood_severity TEXT CHECK (flood_severity IN ('Low', 'Medium', 'High')),
  image_url TEXT,
  admin_notes TEXT,
  claimed_by UUID REFERENCES officials(id),
  claimed_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ,
  proof_photo_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_category ON reports(category);
CREATE INDEX idx_reports_reported_by ON reports(reported_by);
CREATE INDEX idx_reports_claimed_by ON reports(claimed_by);
CREATE INDEX idx_reports_created_at ON reports(created_at DESC);
CREATE INDEX idx_reports_location ON reports(latitude, longitude);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reports_updated_at
  BEFORE UPDATE ON reports
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ──────────────────────────────────────────────
-- 4. ANNOUNCEMENTS
-- ──────────────────────────────────────────────

CREATE TABLE announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  posted_by UUID REFERENCES officials(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_announcements_created_at ON announcements(created_at DESC);

-- ──────────────────────────────────────────────
-- 5. BROADCASTS
-- ──────────────────────────────────────────────

CREATE TABLE broadcasts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message TEXT NOT NULL,
  severity TEXT NOT NULL CHECK (severity IN ('Advisory', 'Warning', 'Critical Evacuation')),
  zone TEXT NOT NULL DEFAULT 'All Zones',
  posted_by UUID REFERENCES officials(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_broadcasts_created_at ON broadcasts(created_at DESC);

-- ──────────────────────────────────────────────
-- 6. RATINGS
-- ──────────────────────────────────────────────

CREATE TABLE ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  official_id UUID NOT NULL REFERENCES officials(id) ON DELETE CASCADE,
  rated_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  rating SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(official_id, rated_by)
);

CREATE INDEX idx_ratings_official ON ratings(official_id);

-- View: Average rating per official
CREATE OR REPLACE VIEW official_ratings AS
SELECT
  o.id,
  p.full_name,
  o.role_title,
  o.points,
  o.missions_completed,
  o.is_active,
  COALESCE(AVG(r.rating), 0)::NUMERIC(3,2) AS average_rating,
  COUNT(r.id)::INTEGER AS ratings_count
FROM officials o
JOIN profiles p ON p.id = o.id
LEFT JOIN ratings r ON r.official_id = o.id
GROUP BY o.id, p.full_name, o.role_title, o.points, o.missions_completed, o.is_active;
