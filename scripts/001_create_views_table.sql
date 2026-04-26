-- Create a table to track page views
CREATE TABLE IF NOT EXISTS page_views (
  id TEXT PRIMARY KEY DEFAULT 'homepage',
  view_count BIGINT NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert the initial row for homepage
INSERT INTO page_views (id, view_count) 
VALUES ('homepage', 0)
ON CONFLICT (id) DO NOTHING;

-- Disable RLS for this table since it's just a public counter
ALTER TABLE page_views DISABLE ROW LEVEL SECURITY;
