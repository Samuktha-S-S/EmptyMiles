-- Adds the optional package and schedule fields used by the step-by-step Send Goods page.
-- Run this once on an existing emptymiles database (pgAdmin 4 > Query Tool > F5).
-- A fresh install does not need it: schema.sql already has these columns. Safe to run twice.

ALTER TABLE shipments ADD COLUMN IF NOT EXISTS length_cm            NUMERIC(8, 2);
ALTER TABLE shipments ADD COLUMN IF NOT EXISTS width_cm             NUMERIC(8, 2);
ALTER TABLE shipments ADD COLUMN IF NOT EXISTS height_cm            NUMERIC(8, 2);
ALTER TABLE shipments ADD COLUMN IF NOT EXISTS special_requirements VARCHAR(255);
ALTER TABLE shipments ADD COLUMN IF NOT EXISTS pickup_date          DATE;
ALTER TABLE shipments ADD COLUMN IF NOT EXISTS pickup_time_slot     VARCHAR(20);
ALTER TABLE shipments ADD COLUMN IF NOT EXISTS special_instructions VARCHAR(500);
