-- Software Bug & Defect Lifecycle Analytics
-- SQL Data Cleaning

-- 1. Create a working copy of the raw dataset
CREATE TABLE public.defects_clean AS
SELECT *
FROM public.defects_raw;

-- 2. Add an internal row identifier
ALTER TABLE public.defects_clean
ADD COLUMN record_id BIGINT GENERATED ALWAYS AS IDENTITY;

-- 3. Verify source and working-table row counts
SELECT COUNT(*) AS raw_rows
FROM public.defects_raw;

SELECT COUNT(*) AS clean_rows
FROM public.defects_clean;

-- 4. Preview the cleaning table
SELECT
    record_id,
    defect_id,
    status,
    severity
FROM public.defects_clean
LIMIT 10;


-- 5. Remove leading/trailing spaces and normalize blank text values
UPDATE public.defects_clean
SET
    defect_id = TRIM(defect_id),
    project = TRIM(project),
    application = TRIM(application),
    module = TRIM(module),
    defect_type = TRIM(defect_type),
    severity = TRIM(severity),
    priority = TRIM(priority),
    status = TRIM(status),
    environment = TRIM(environment),
    developer = TRIM(developer),
    tester = TRIM(tester),
    sprint = TRIM(sprint),
    release = TRIM(release),
    root_cause = NULLIF(TRIM(root_cause), ''),
    resolution_type = NULLIF(TRIM(resolution_type), '');


-- 6. Standardize categorical values
UPDATE public.defects_clean
SET severity =
    CASE LOWER(severity)
        WHEN 'critical' THEN 'Critical'
        WHEN 'high' THEN 'High'
        WHEN 'medium' THEN 'Medium'
        WHEN 'low' THEN 'Low'
        ELSE severity
    END;

UPDATE public.defects_clean
SET status =
    CASE LOWER(status)
        WHEN 'closed' THEN 'Closed'
        WHEN 'resolved' THEN 'Resolved'
        WHEN 'open' THEN 'Open'
        WHEN 'in progress' THEN 'In Progress'
        WHEN 'in testing' THEN 'In Testing'
        WHEN 'reopened' THEN 'Reopened'
        WHEN 'deferred' THEN 'Deferred'
        ELSE status
    END;

UPDATE public.defects_clean
SET
    environment = UPPER(environment),
    priority = UPPER(priority);


-- 7. Standardize root cause and resolution type
UPDATE public.defects_clean
SET root_cause =
    CASE LOWER(root_cause)
        WHEN 'code defect' THEN 'Code Defect'
        WHEN 'requirement gap' THEN 'Requirement Gap'
        WHEN 'configuration issue' THEN 'Configuration Issue'
        WHEN 'data issue' THEN 'Data Issue'
        WHEN 'integration issue' THEN 'Integration Issue'
        WHEN 'environment issue' THEN 'Environment Issue'
        WHEN 'design issue' THEN 'Design Issue'
        WHEN 'test data issue' THEN 'Test Data Issue'
        ELSE root_cause
    END;

UPDATE public.defects_clean
SET resolution_type =
    CASE LOWER(resolution_type)
        WHEN 'code fix' THEN 'Code Fix'
        WHEN 'configuration change' THEN 'Configuration Change'
        WHEN 'data fix' THEN 'Data Fix'
        WHEN 'requirement clarification' THEN 'Requirement Clarification'
        WHEN 'environment fix' THEN 'Environment Fix'
        WHEN 'workaround' THEN 'Workaround'
        WHEN 'duplicate / no fix' THEN 'Duplicate / No Fix'
        ELSE resolution_type
    END;


-- 8. Remove exact duplicate records
WITH ranked_duplicates AS (
    SELECT
        record_id,
        ROW_NUMBER() OVER (
            PARTITION BY
                defect_id,
                project,
                application,
                module,
                defect_type,
                severity,
                priority,
                status,
                environment,
                created_date,
                assigned_date,
                resolved_date,
                closed_date,
                developer,
                tester,
                sprint,
                release,
                root_cause,
                resolution_type,
                reopened_count,
                sla_target_hours
            ORDER BY record_id
        ) AS rn
    FROM public.defects_clean
)
DELETE FROM public.defects_clean AS d
USING ranked_duplicates AS r
WHERE d.record_id = r.record_id
  AND r.rn > 1;


-- 9. Flag lifecycle data-quality issues
ALTER TABLE public.defects_clean
ADD COLUMN invalid_resolution_date BOOLEAN DEFAULT FALSE,
ADD COLUMN closed_missing_closed_date BOOLEAN DEFAULT FALSE,
ADD COLUMN unresolved_with_resolved_date BOOLEAN DEFAULT FALSE;

UPDATE public.defects_clean
SET invalid_resolution_date = TRUE
WHERE resolved_date IS NOT NULL
  AND resolved_date < created_date;

UPDATE public.defects_clean
SET closed_missing_closed_date = TRUE
WHERE status = 'Closed'
  AND closed_date IS NULL;

UPDATE public.defects_clean
SET unresolved_with_resolved_date = TRUE
WHERE status IN ('Open', 'In Progress')
  AND resolved_date IS NOT NULL;  


-- 10. Preserve NULL values and provide reporting-friendly labels
SELECT
    defect_id,
    COALESCE(root_cause, 'Not Provided') AS root_cause_display,
    COALESCE(resolution_type, 'Not Provided') AS resolution_type_display
FROM public.defects_clean
LIMIT 20;


-- 11. Validate cleaned dataset
SELECT
    COUNT(*) AS total_clean_rows,
    COUNT(DISTINCT severity) AS severity_values,
    COUNT(DISTINCT status) AS status_values,
    COUNT(DISTINCT environment) AS environment_values,
    COUNT(DISTINCT priority) AS priority_values,
    COUNT(*) FILTER (WHERE invalid_resolution_date) AS invalid_resolution_dates,
    COUNT(*) FILTER (WHERE closed_missing_closed_date) AS closed_missing_dates,
    COUNT(*) FILTER (WHERE unresolved_with_resolved_date) AS unresolved_with_resolution
FROM public.defects_clean;

SELECT
    (SELECT COUNT(*) FROM public.defects_raw) AS raw_rows,
    (SELECT COUNT(*) FROM public.defects_clean) AS clean_rows;

SELECT
    sla_status,
    COUNT(*) AS defect_count
FROM public.defects_clean
GROUP BY sla_status
ORDER BY defect_count DESC;

SELECT
    MIN(resolution_hours) AS min_resolution_hours,
    AVG(resolution_hours) AS avg_resolution_hours,
    MAX(resolution_hours) AS max_resolution_hours,
    MIN(created_month) AS first_created_month,
    MAX(created_month) AS last_created_month
FROM public.defects_clean;