-- =============================================================
-- Competency Tracker - Supabase Schema
-- Run this in the Supabase SQL Editor (https://supabase.com/dashboard)
-- =============================================================

-- Drop existing tables if any (for clean setup)
DROP TABLE IF EXISTS training_nominations CASCADE;
DROP TABLE IF EXISTS training_programs CASCADE;
DROP TABLE IF EXISTS assessments CASCADE;
DROP TABLE IF EXISTS competencies CASCADE;
DROP TABLE IF EXISTS competency_categories CASCADE;
DROP TABLE IF EXISTS employees CASCADE;

-- Employees table
CREATE TABLE employees (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  level TEXT NOT NULL,
  team TEXT NOT NULL,
  department TEXT,
  reports_to TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Competency Categories
CREATE TABLE competency_categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  color TEXT DEFAULT '#1EA8E8',
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Competencies
CREATE TABLE competencies (
  id TEXT PRIMARY KEY,
  category_id TEXT REFERENCES competency_categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  threshold INTEGER DEFAULT 3,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Assessments (historical - one row per employee per competency per quarter)
CREATE TABLE assessments (
  id TEXT PRIMARY KEY,
  employee_id TEXT REFERENCES employees(id) ON DELETE CASCADE,
  competency_id TEXT REFERENCES competencies(id) ON DELETE CASCADE,
  self_score INTEGER CHECK (self_score BETWEEN 1 AND 5),
  manager_score INTEGER CHECK (manager_score BETWEEN 1 AND 5),
  quarter TEXT NOT NULL,
  year INTEGER NOT NULL,
  assessed_date TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(employee_id, competency_id, quarter, year)
);

-- Training Programs
CREATE TABLE training_programs (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  duration TEXT,
  competency_ids TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Training Nominations
CREATE TABLE training_nominations (
  id TEXT PRIMARY KEY,
  employee_id TEXT REFERENCES employees(id) ON DELETE CASCADE,
  training_id TEXT REFERENCES training_programs(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'Nominated' CHECK (status IN ('Nominated', 'Approved', 'In Progress', 'Completed', 'Cancelled')),
  nominated_by TEXT,
  nominated_date TIMESTAMPTZ DEFAULT NOW(),
  completion_date TIMESTAMPTZ,
  notes TEXT
);

-- Enable Row Level Security
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE competency_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE competencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_nominations ENABLE ROW LEVEL SECURITY;

-- Allow all operations with anon key (internal tool, no auth needed)
CREATE POLICY "Allow all" ON employees FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON competency_categories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON competencies FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON assessments FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON training_programs FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON training_nominations FOR ALL USING (true) WITH CHECK (true);
