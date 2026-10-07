-- Software Bug & Defect Lifecycle Analytics
-- Phase 5: Raw Data Validation

-- 1. Total row count
SELECT COUNT(*) AS total_rows
FROM public.defects_raw;

-- 2. Distinct status values
SELECT DISTINCT status
FROM public.defects_raw
ORDER BY status;

-- 3. Distinct severity values
SELECT DISTINCT severity
FROM public.defects_raw
ORDER BY severity;

-- 4. Record distribution by status
SELECT
    status,
    COUNT(*) AS defect_count
FROM public.defects_raw
GROUP BY status
ORDER BY defect_count DESC;

-- 5. Record distribution by severity
SELECT
    severity,
    COUNT(*) AS defect_count
FROM public.defects_raw
GROUP BY severity
ORDER BY defect_count DESC;

-- 6. NULL value checks
SELECT COUNT(*) AS assigned_date_nulls
FROM public.defects_raw
WHERE assigned_date IS NULL;

SELECT COUNT(*) AS resolved_date_nulls
FROM public.defects_raw
WHERE resolved_date IS NULL;

SELECT COUNT(*) AS closed_date_nulls
FROM public.defects_raw
WHERE closed_date IS NULL;

SELECT COUNT(*) AS root_cause_nulls
FROM public.defects_raw
WHERE root_cause IS NULL;

SELECT COUNT(*) AS resolution_type_nulls
FROM public.defects_raw
WHERE resolution_type IS NULL;

-- 7. Duplicate defect IDs
SELECT
    defect_id,
    COUNT(*) AS duplicate_count
FROM public.defects_raw
GROUP BY defect_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, defect_id;

SELECT COUNT(*) AS duplicated_defect_ids
FROM (
    SELECT defect_id
    FROM public.defects_raw
    GROUP BY defect_id
    HAVING COUNT(*) > 1
) AS duplicate_ids;

-- 8. Exact duplicate rows
SELECT
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
    sla_target_hours,
    COUNT(*) AS row_count
FROM public.defects_raw
GROUP BY
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
HAVING COUNT(*) > 1
ORDER BY row_count DESC, defect_id;

SELECT SUM(row_count - 1) AS extra_duplicate_rows
FROM (
    SELECT COUNT(*) AS row_count
    FROM public.defects_raw
    GROUP BY
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
    HAVING COUNT(*) > 1
) AS duplicate_rows;

-- 9. Date range validation
SELECT
    MIN(created_date) AS earliest_created_date,
    MAX(created_date) AS latest_created_date
FROM public.defects_raw;

SELECT
    MIN(resolved_date) AS earliest_resolved_date,
    MAX(resolved_date) AS latest_resolved_date
FROM public.defects_raw;

-- 10. Invalid lifecycle dates
SELECT
    defect_id,
    status,
    created_date,
    resolved_date
FROM public.defects_raw
WHERE resolved_date IS NOT NULL
  AND resolved_date < created_date
ORDER BY created_date
LIMIT 20;

SELECT COUNT(*) AS invalid_resolution_dates
FROM public.defects_raw
WHERE resolved_date IS NOT NULL
  AND resolved_date < created_date;

-- 11. Closed defects without a closed date
SELECT
    defect_id,
    status,
    created_date,
    resolved_date,
    closed_date
FROM public.defects_raw
WHERE LOWER(TRIM(status)) = 'closed'
  AND closed_date IS NULL
LIMIT 20;

SELECT COUNT(*) AS closed_missing_closed_date
FROM public.defects_raw
WHERE LOWER(TRIM(status)) = 'closed'
  AND closed_date IS NULL;

-- 12. Open or in-progress defects with a resolved date
SELECT
    defect_id,
    status,
    created_date,
    resolved_date
FROM public.defects_raw
WHERE LOWER(TRIM(status)) IN ('open', 'in progress')
  AND resolved_date IS NOT NULL
LIMIT 20;

SELECT COUNT(*) AS unresolved_status_with_resolved_date
FROM public.defects_raw
WHERE LOWER(TRIM(status)) IN ('open', 'in progress')
  AND resolved_date IS NOT NULL;

-- 13. Resolution-time outliers
SELECT
    defect_id,
    severity,
    status,
    created_date,
    resolved_date,
    ROUND(
        EXTRACT(EPOCH FROM (resolved_date - created_date)) / 3600.0,
        2
    ) AS resolution_hours
FROM public.defects_raw
WHERE resolved_date IS NOT NULL
  AND resolved_date >= created_date
ORDER BY resolution_hours DESC
LIMIT 20;

SELECT
    ROUND(
        MIN(EXTRACT(EPOCH FROM (resolved_date - created_date)) / 3600.0),
        2
    ) AS minimum_resolution_hours,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (resolved_date - created_date)) / 3600.0),
        2
    ) AS average_resolution_hours,
    ROUND(
        MAX(EXTRACT(EPOCH FROM (resolved_date - created_date)) / 3600.0),
        2
    ) AS maximum_resolution_hours
FROM public.defects_raw
WHERE resolved_date IS NOT NULL
  AND resolved_date >= created_date;