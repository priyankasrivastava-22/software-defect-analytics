-- Software Bug & Defect Lifecycle Analytics
-- SQL Exploratory Data Analysis

-- 1. Total defects
SELECT COUNT(*) AS total_defects
FROM public.defects_clean;

-- 2. Open defects
SELECT COUNT(*) AS open_defects
FROM public.defects_clean
WHERE status = 'Open';

-- 3. Closed defects
SELECT COUNT(*) AS closed_defects
FROM public.defects_clean
WHERE status = 'Closed';

-- 4. Defects by status
SELECT
    status,
    COUNT(*) AS defect_count
FROM public.defects_clean
GROUP BY status
ORDER BY defect_count DESC;

-- 5. Severity distribution
SELECT
    severity,
    COUNT(*) AS defect_count
FROM public.defects_clean
GROUP BY severity
ORDER BY defect_count DESC;

-- 6. Severity distribution with percentage
SELECT
    severity,
    COUNT(*) AS defect_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_total
FROM public.defects_clean
GROUP BY severity
ORDER BY defect_count DESC;

-- 7. Top 10 modules by defect volume
SELECT
    module,
    COUNT(*) AS defect_count
FROM public.defects_clean
GROUP BY module
ORDER BY defect_count DESC
LIMIT 10;

-- 8. Top 10 modules by Critical defects
SELECT
    module,
    COUNT(*) AS critical_defects
FROM public.defects_clean
WHERE severity = 'Critical'
GROUP BY module
ORDER BY critical_defects DESC
LIMIT 10;

-- 9. Top 10 releases by defect volume
SELECT
    release,
    COUNT(*) AS defect_count
FROM public.defects_clean
GROUP BY release
ORDER BY defect_count DESC
LIMIT 10;

-- 10. Top 10 releases by Critical defects
SELECT
    release,
    COUNT(*) AS critical_defects
FROM public.defects_clean
WHERE severity = 'Critical'
GROUP BY release
ORDER BY critical_defects DESC
LIMIT 10;

-- 11. Defect distribution by environment
SELECT
    environment,
    COUNT(*) AS defect_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_total
FROM public.defects_clean
GROUP BY environment
ORDER BY defect_count DESC;

-- 12. Defect distribution by root cause
SELECT
    COALESCE(root_cause, 'Not Provided') AS root_cause,
    COUNT(*) AS defect_count
FROM public.defects_clean
GROUP BY COALESCE(root_cause, 'Not Provided')
ORDER BY defect_count DESC;


-- 13. Root cause distribution with percentage
SELECT
    COALESCE(root_cause, 'Not Provided') AS root_cause,
    COUNT(*) AS defect_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_total
FROM public.defects_clean
GROUP BY COALESCE(root_cause, 'Not Provided')
ORDER BY defect_count DESC;

-- 14. Overall resolution-time statistics
SELECT
    ROUND(MIN(resolution_hours), 2) AS min_resolution_hours,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours,
    ROUND(MAX(resolution_hours), 2) AS max_resolution_hours
FROM public.defects_clean
WHERE resolution_hours IS NOT NULL;

-- 15. Resolution performance by severity
SELECT
    severity,
    COUNT(resolution_hours) AS resolved_defects,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours,
    ROUND(MIN(resolution_hours), 2) AS min_resolution_hours,
    ROUND(MAX(resolution_hours), 2) AS max_resolution_hours
FROM public.defects_clean
WHERE resolution_hours IS NOT NULL
GROUP BY severity
ORDER BY avg_resolution_hours DESC;

-- 16. Overall SLA performance
SELECT
    SUM(CASE WHEN sla_status = 'Met' THEN 1 ELSE 0 END) AS sla_met,
    SUM(CASE WHEN sla_status = 'Breached' THEN 1 ELSE 0 END) AS sla_breached,
    SUM(CASE WHEN sla_status = 'Not Applicable' THEN 1 ELSE 0 END) AS not_applicable,
    ROUND(
        100.0 * SUM(CASE WHEN sla_status = 'Met' THEN 1 ELSE 0 END)
        / NULLIF(
            SUM(CASE WHEN sla_status IN ('Met', 'Breached') THEN 1 ELSE 0 END),
            0
        ),
        2
    ) AS sla_compliance_pct,
    ROUND(
        100.0 * SUM(CASE WHEN sla_status = 'Breached' THEN 1 ELSE 0 END)
        / NULLIF(
            SUM(CASE WHEN sla_status IN ('Met', 'Breached') THEN 1 ELSE 0 END),
            0
        ),
        2
    ) AS sla_breach_pct
FROM public.defects_clean;

-- 17. SLA performance by severity
SELECT
    severity,
    SUM(CASE WHEN sla_status = 'Met' THEN 1 ELSE 0 END) AS sla_met,
    SUM(CASE WHEN sla_status = 'Breached' THEN 1 ELSE 0 END) AS sla_breached,
    ROUND(
        100.0 * SUM(CASE WHEN sla_status = 'Met' THEN 1 ELSE 0 END)
        / NULLIF(
            SUM(CASE WHEN sla_status IN ('Met', 'Breached') THEN 1 ELSE 0 END),
            0
        ),
        2
    ) AS sla_compliance_pct
FROM public.defects_clean
GROUP BY severity
ORDER BY sla_compliance_pct DESC;

-- 18. Overall reopen rate
SELECT
    COUNT(*) FILTER (WHERE reopened_count > 0) AS reopened_defects,
    COUNT(*) AS total_defects,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE reopened_count > 0)
        / COUNT(*),
        2
    ) AS reopen_rate_pct
FROM public.defects_clean;

-- 19. Reopen-event statistics
SELECT
    SUM(reopened_count) AS total_reopen_events,
    ROUND(AVG(reopened_count), 2) AS avg_reopen_count
FROM public.defects_clean;

-- 20. Reopen rate by severity
SELECT
    severity,
    COUNT(*) AS total_defects,
    COUNT(*) FILTER (WHERE reopened_count > 0) AS reopened_defects,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE reopened_count > 0)
        / COUNT(*),
        2
    ) AS reopen_rate_pct
FROM public.defects_clean
GROUP BY severity
ORDER BY reopen_rate_pct DESC;

-- 21. Monthly defect trend
SELECT
    created_month,
    COUNT(*) AS defect_count
FROM public.defects_clean
GROUP BY created_month
ORDER BY created_month;

-- 22. Monthly Critical-defect trend
SELECT
    created_month,
    COUNT(*) AS critical_defects
FROM public.defects_clean
WHERE severity = 'Critical'
GROUP BY created_month
ORDER BY created_month;

-- 23. Modules with more than 500 defects
SELECT
    module,
    COUNT(*) AS defect_count
FROM public.defects_clean
GROUP BY module
HAVING COUNT(*) > 500
ORDER BY defect_count DESC;