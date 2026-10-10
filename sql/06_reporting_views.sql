-- SQL REPORTING VIEWS
-- Database: defect_analytics

-- VIEW 1: Defect Details
-- Purpose: Prepare cleaned defect-level data for Power BI reporting and analysis.

CREATE OR REPLACE VIEW public.vw_defect_details AS
SELECT
    defect_id,
    project,
    application,
    module,
    defect_type,
    severity,
    priority,
    status,
    created_date,
    resolution_hours,
    sla_status,
    reopened_count
FROM public.defects_clean;


-- VIEW 2: SLA Performance
-- Purpose: Analyze SLA compliance and breaches across applications.

CREATE OR REPLACE VIEW public.vw_sla_performance AS
SELECT
    application,

    COUNT(*) AS total_defects,

    COUNT(*) FILTER (
        WHERE sla_status = 'Met'
    ) AS sla_met,

    COUNT(*) FILTER (
        WHERE sla_status = 'Breached'
    ) AS sla_breached,

    COUNT(*) FILTER (
        WHERE sla_status = 'Not Applicable'
    ) AS sla_not_applicable,

    COUNT(*) FILTER (
        WHERE sla_status IN ('Met', 'Breached')
    ) AS sla_eligible,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE sla_status = 'Met'
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE sla_status IN ('Met', 'Breached')
            ), 0
        ),
        2
    ) AS sla_compliance_pct,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE sla_status = 'Breached'
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE sla_status IN ('Met', 'Breached')
            ), 0
        ),
        2
    ) AS sla_breach_pct

FROM public.defects_clean

GROUP BY application;

-- VIEW 3: Release Quality
-- Purpose: Analyze defect volume, severity, and closure performance across software releases.

CREATE OR REPLACE VIEW public.vw_release_quality AS
SELECT
    application,
    release,

    COUNT(*) AS total_defects,

    COUNT(*) FILTER (
        WHERE severity = 'Critical'
    ) AS critical_defects,

    COUNT(*) FILTER (
        WHERE status = 'Open'
    ) AS open_defects,

    COUNT(*) FILTER (
        WHERE status = 'Closed'
    ) AS closed_defects,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE severity = 'Critical'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS critical_defect_pct,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE status = 'Closed'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS closure_rate_pct

FROM public.defects_clean
GROUP BY application, release;

-- VIEW 4: Module Quality
-- Purpose: Analyze defect severity and closure performance across application modules.

CREATE OR REPLACE VIEW public.vw_module_quality AS
SELECT
    application,
    module,

    COUNT(*) AS total_defects,

    COUNT(*) FILTER (
        WHERE severity = 'Critical'
    ) AS critical_defects,

    COUNT(*) FILTER (
        WHERE status = 'Open'
    ) AS open_defects,

    COUNT(*) FILTER (
        WHERE status = 'Closed'
    ) AS closed_defects,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE severity = 'Critical'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS critical_defect_pct,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE status = 'Closed'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS closure_rate_pct

FROM public.defects_clean
GROUP BY application, module;