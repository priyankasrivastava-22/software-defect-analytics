-- Software Bug & Defect Lifecycle Analytics
-- Advanced SQL Analysis

-- 1. Module defect count by application using a CTE
WITH module_counts AS (
    SELECT
        application,
        module,
        COUNT(*) AS defect_count
    FROM public.defects_clean
    GROUP BY application, module
)
SELECT
    application,
    module,
    defect_count
FROM module_counts
ORDER BY application, defect_count DESC;


-- 2. Top 3 modules by defect count within each application
WITH module_counts AS (
    SELECT
        application,
        module,
        COUNT(*) AS defect_count
    FROM public.defects_clean
    GROUP BY application, module
),
ranked_modules AS (
    SELECT
        application,
        module,
        defect_count,
        RANK() OVER (
            PARTITION BY application
            ORDER BY defect_count DESC
        ) AS module_rank
    FROM module_counts
)
SELECT
    application,
    module,
    defect_count,
    module_rank
FROM ranked_modules
WHERE module_rank <= 3
ORDER BY application, module_rank, module;

-- 3. Compare ROW_NUMBER, RANK and DENSE_RANK
WITH module_counts AS (
    SELECT
        application,
        module,
        COUNT(*) AS defect_count
    FROM public.defects_clean
    GROUP BY application, module
)
SELECT
    application,
    module,
    defect_count,
    ROW_NUMBER() OVER (
        PARTITION BY application
        ORDER BY defect_count DESC, module
    ) AS row_number_rank,
    RANK() OVER (
        PARTITION BY application
        ORDER BY defect_count DESC
    ) AS rank_value,
    DENSE_RANK() OVER (
        PARTITION BY application
        ORDER BY defect_count DESC
    ) AS dense_rank_value
FROM module_counts
WHERE application = 'Authentication'
ORDER BY defect_count DESC, module;


-- 4. Compare monthly defects with the previous month
WITH monthly_defects AS (
    SELECT
        created_month,
        COUNT(*) AS defect_count
    FROM public.defects_clean
    GROUP BY created_month
),
monthly_comparison AS (
    SELECT
        created_month,
        defect_count AS current_month_defects,
        LAG(defect_count) OVER (
            ORDER BY created_month
        ) AS previous_month_defects
    FROM monthly_defects
)
SELECT
    created_month,
    current_month_defects,
    previous_month_defects,
    current_month_defects - previous_month_defects AS defect_change
FROM monthly_comparison
ORDER BY created_month;


-- 5. Monthly defect growth percentage
WITH monthly_defects AS (
    SELECT
        created_month,
        COUNT(*) AS defect_count
    FROM public.defects_clean
    GROUP BY created_month
),
monthly_comparison AS (
    SELECT
        created_month,
        defect_count AS current_month_defects,
        LAG(defect_count) OVER (
            ORDER BY created_month
        ) AS previous_month_defects
    FROM monthly_defects
)
SELECT
    created_month,
    current_month_defects,
    previous_month_defects,
    current_month_defects - previous_month_defects AS defect_change,
    ROUND(
        100.0 * (
            current_month_defects - previous_month_defects
        ) / NULLIF(previous_month_defects, 0),
        2
    ) AS monthly_growth_pct
FROM monthly_comparison
ORDER BY created_month;


-- 6. Compare current month with the next month
WITH monthly_defects AS (
    SELECT
        created_month,
        COUNT(*) AS defect_count
    FROM public.defects_clean
    GROUP BY created_month
)
SELECT
    created_month,
    defect_count AS current_month_defects,
    LEAD(defect_count) OVER (
        ORDER BY created_month
    ) AS next_month_defects
FROM monthly_defects
ORDER BY created_month;


-- 7. Running monthly defect total
WITH monthly_defects AS (
    SELECT
        created_month,
        COUNT(*) AS defect_count
    FROM public.defects_clean
    GROUP BY created_month
)
SELECT
    created_month,
    defect_count,
    SUM(defect_count) OVER (
        ORDER BY created_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_defect_total
FROM monthly_defects
ORDER BY created_month;


-- 8. Three-month moving average of defect volume
WITH monthly_defects AS (
    SELECT
        created_month,
        COUNT(*) AS defect_count
    FROM public.defects_clean
    GROUP BY created_month
)
SELECT
    created_month,
    defect_count,
    ROUND(
        AVG(defect_count) OVER (
            ORDER BY created_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_avg
FROM monthly_defects
ORDER BY created_month;


-- 9. Rank releases by Critical defect count
WITH release_critical_counts AS (
    SELECT
        release,
        COUNT(*) AS critical_defects
    FROM public.defects_clean
    WHERE severity = 'Critical'
    GROUP BY release
)
SELECT
    release,
    critical_defects,
    DENSE_RANK() OVER (
        ORDER BY critical_defects DESC
    ) AS critical_defect_rank
FROM release_critical_counts
ORDER BY critical_defect_rank, release;


-- 10. Rank developers by resolved defect count
WITH developer_resolution_counts AS (
    SELECT
        developer,
        COUNT(*) AS resolved_defects
    FROM public.defects_clean
    WHERE resolution_hours IS NOT NULL
      AND developer IS NOT NULL
    GROUP BY developer
)
SELECT
    developer,
    resolved_defects,
    DENSE_RANK() OVER (
        ORDER BY resolved_defects DESC
    ) AS developer_rank
FROM developer_resolution_counts
ORDER BY developer_rank, developer;


-- 11. Compare individual resolution time with severity average
SELECT
    defect_id,
    severity,
    resolution_hours,
    ROUND(
        AVG(resolution_hours) OVER (
            PARTITION BY severity
        ),
        2
    ) AS severity_avg_resolution_hours
FROM public.defects_clean
WHERE resolution_hours IS NOT NULL
ORDER BY severity, resolution_hours DESC
LIMIT 30;


-- 12. Defects exceeding their severity average resolution time
SELECT
    defect_id,
    severity,
    resolution_hours,
    severity_avg_resolution_hours,
    ROUND(
        resolution_hours - severity_avg_resolution_hours,
        2
    ) AS hours_above_average
FROM (
    SELECT
        defect_id,
        severity,
        resolution_hours,
        AVG(resolution_hours) OVER (
            PARTITION BY severity
        ) AS severity_avg_resolution_hours
    FROM public.defects_clean
    WHERE resolution_hours IS NOT NULL
) AS resolution_comparison
WHERE resolution_hours > severity_avg_resolution_hours
ORDER BY hours_above_average DESC
LIMIT 20;


-- 13. Oldest unresolved defects
SELECT
    defect_id,
    application,
    module,
    severity,
    priority,
    status,
    created_date,
    CURRENT_DATE - CAST(created_date AS DATE) AS age_days
FROM public.defects_clean
WHERE status NOT IN ('Closed', 'Resolved')
  AND resolved_date IS NULL
ORDER BY age_days DESC
LIMIT 20;


-- 14. Compare total and Critical defects by application using INNER JOIN
WITH application_totals AS (
    SELECT
        application,
        COUNT(*) AS total_defects
    FROM public.defects_clean
    GROUP BY application
),
application_critical AS (
    SELECT
        application,
        COUNT(*) AS critical_defects
    FROM public.defects_clean
    WHERE severity = 'Critical'
    GROUP BY application
)
SELECT
    t.application,
    t.total_defects,
    c.critical_defects
FROM application_totals AS t
INNER JOIN application_critical AS c
    ON t.application = c.application
ORDER BY c.critical_defects DESC;


-- 15. Preserve all applications using LEFT JOIN
WITH application_totals AS (
    SELECT
        application,
        COUNT(*) AS total_defects
    FROM public.defects_clean
    GROUP BY application
),
application_critical AS (
    SELECT
        application,
        COUNT(*) AS critical_defects
    FROM public.defects_clean
    WHERE severity = 'Critical'
    GROUP BY application
)
SELECT
    t.application,
    t.total_defects,
    COALESCE(c.critical_defects, 0) AS critical_defects
FROM application_totals AS t
LEFT JOIN application_critical AS c
    ON t.application = c.application
ORDER BY critical_defects DESC;