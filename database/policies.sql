-- ============================================
-- BrgyPulse Row Level Security Policies
-- Run AFTER schema.sql
-- ============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE officials ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE broadcasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;

-- ──────────────────────────────────────────────
-- PROFILES
-- ──────────────────────────────────────────────

-- Anyone can read profiles
CREATE POLICY "Profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- ──────────────────────────────────────────────
-- OFFICIALS
-- ──────────────────────────────────────────────

-- Anyone can read officials
CREATE POLICY "Officials are viewable by everyone"
  ON officials FOR SELECT
  USING (true);

-- Only admins/officials can update
CREATE POLICY "Officials can update own record"
  ON officials FOR UPDATE
  USING (auth.uid() = id);

-- ──────────────────────────────────────────────
-- REPORTS
-- ──────────────────────────────────────────────

-- Everyone can read all reports
CREATE POLICY "Reports are viewable by everyone"
  ON reports FOR SELECT
  USING (true);

-- Authenticated users can create reports
CREATE POLICY "Authenticated users can create reports"
  ON reports FOR INSERT
  WITH CHECK (auth.uid() = reported_by);

-- Report creators can update their own
CREATE POLICY "Users can update own reports"
  ON reports FOR UPDATE
  USING (auth.uid() = reported_by);

-- Officials can update any report (claim, resolve, add notes)
CREATE POLICY "Officials can update any report"
  ON reports FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM officials WHERE id = auth.uid()
    )
  );

-- ──────────────────────────────────────────────
-- ANNOUNCEMENTS
-- ──────────────────────────────────────────────

-- Everyone can read announcements
CREATE POLICY "Announcements are viewable by everyone"
  ON announcements FOR SELECT
  USING (true);

-- Only officials can create
CREATE POLICY "Officials can create announcements"
  ON announcements FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM officials WHERE id = auth.uid()
    )
  );

-- Officials can delete their own
CREATE POLICY "Officials can delete own announcements"
  ON announcements FOR DELETE
  USING (posted_by = auth.uid());

-- ──────────────────────────────────────────────
-- BROADCASTS
-- ──────────────────────────────────────────────

-- Everyone can read broadcasts
CREATE POLICY "Broadcasts are viewable by everyone"
  ON broadcasts FOR SELECT
  USING (true);

-- Only officials can create
CREATE POLICY "Officials can create broadcasts"
  ON broadcasts FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM officials WHERE id = auth.uid()
    )
  );

-- ──────────────────────────────────────────────
-- RATINGS
-- ──────────────────────────────────────────────

-- Anyone can read ratings
CREATE POLICY "Ratings are viewable by everyone"
  ON ratings FOR SELECT
  USING (true);

-- Authenticated users can rate
CREATE POLICY "Authenticated users can rate"
  ON ratings FOR INSERT
  WITH CHECK (auth.uid() = rated_by);

-- Users can update their own rating
CREATE POLICY "Users can update own rating"
  ON ratings FOR UPDATE
  USING (auth.uid() = rated_by);

-- ──────────────────────────────────────────────
-- STORAGE (for proof photos & report images)
-- ──────────────────────────────────────────────

-- Create storage bucket (run in Supabase Dashboard or via API)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('report-photos', 'report-photos', true);

-- Storage policies would be configured in the Supabase Dashboard:
-- - Authenticated users can upload to report-photos/
-- - Public read access for all files
