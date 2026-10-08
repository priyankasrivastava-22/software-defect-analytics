-- Software Bug & Defect Lifecycle Analytics
-- PostgreSQL Database Setup

-- Create the project database once from the default postgres database:
-- CREATE DATABASE defect_analytics;

-- Connect to defect_analytics before creating the raw table.

CREATE TABLE public.defects_raw (
    defect_id VARCHAR(20),
    project VARCHAR(100),
    application VARCHAR(100),
    module VARCHAR(100),
    defect_type VARCHAR(50),
    severity VARCHAR(30),
    priority VARCHAR(10),
    status VARCHAR(50),
    environment VARCHAR(20),
    created_date TIMESTAMP,
    assigned_date TIMESTAMP,
    resolved_date TIMESTAMP,
    closed_date TIMESTAMP,
    developer VARCHAR(30),
    tester VARCHAR(30),
    sprint VARCHAR(30),
    release VARCHAR(30),
    root_cause VARCHAR(100),
    resolution_type VARCHAR(100),
    reopened_count INTEGER,
    sla_target_hours INTEGER
);

-- Preview imported records
SELECT *
FROM public.defects_raw
LIMIT 10;

-- Verify total imported records
SELECT COUNT(*) AS total_rows
FROM public.defects_raw;