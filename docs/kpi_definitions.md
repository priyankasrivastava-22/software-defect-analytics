# Business KPI Definitions

**Project:** Software Bug & Defect Lifecycle Analytics  
**Data source:** PostgreSQL `defect_analytics.public.defects_clean`  
**Purpose:** Define consistent, interview-ready measures of defect volume, resolution efficiency, service performance, and release quality.

**Status:** Phase 9 KPI dictionary finalized using supplied pgAdmin results; items requiring additional source validation are explicitly identified below.

## Verified project snapshot

| Metric | Value | Evidence / interpretation |
|---|---:|---|
| Total cleaned defects | 12,000 | pgAdmin KPI validation |
| Current Open | 1,218 | pgAdmin KPI validation |
| Current Closed | 6,338 | pgAdmin KPI validation |
| Critical | 813 | pgAdmin KPI validation |
| Current Closed share | 52.82% | 6,338 / 12,000 |
| Critical defect share | 6.78% | 813 / 12,000, rounded |
| SLA Met | 3,846 | pgAdmin status-group output |
| SLA Breached | 5,143 | pgAdmin status-group output |
| SLA Not Applicable | 3,011 | Excluded from SLA denominator |
| Eligible SLA outcomes | 8,989 | 3,846 + 5,143 |
| SLA Compliance | 42.79% | 3,846 / 8,989 |
| SLA Breach | 57.21% | 5,143 / 8,989 |
| Ever reopened at least once | 1,632 | `reopened_count > 0`, user-reported pgAdmin output |
| Total reopen events | 2,022 | `SUM(reopened_count)`, user-reported pgAdmin output |
| Missing reopen counts | 0 | User-reported pgAdmin output |
| Ever-reopened defect share | 13.60% | 1,632 / 12,000 — **not** resolution-cohort reopen rate |
| Currently Resolved or Closed | 7,560 | User-reported pgAdmin output |
| Narrow active backlog | 2,998 | Open + In Progress + Reopened, previous query result |
| Average resolution / MTTR | 49.07 hours | Earlier analysis; final screenshot recheck recommended |

**Source scope:** User-provided pgAdmin query results and earlier phase analysis. Not a live database connection.


## 1. Measurement conventions

These definitions are the **business specification**, not a claim that every KPI has already been recalculated. Verify exact field names, status semantics, event history availability, and denominator rules against the database before building SQL or dashboards.

- **Reporting grain:** One distinct defect per row, keyed by the cleaned table's unique `record_id` (verify uniqueness before aggregating). Use `COUNT(DISTINCT record_id)` if joins can multiply rows.
- **Snapshot vs. period:** Current statuses describe the dataset *as of an extraction/snapshot time*. Created-in-month metrics use the defect creation date; closed-in-month metrics use the actual closure date. Do not mix stock and flow metrics.
- **Status groups:** Do not assume that only `Closed` is resolved, or that every non-Closed status is active. Document the seven standardized statuses and decide which count as open, resolved, and terminal. For this project, **Open Defects** can mean the literal `Open` status, while **Backlog** means *all actionable non-terminal defects*; they are not interchangeable.
- **Severity:** The label `Critical` must refer to the standardized severity value. Critical percentage needs a stated population (all defects or a time-bounded subset).
- **Valid durations:** Exclude invalid/negative or missing start–end timestamps from averages. Use the project's `resolution_hours` and data-quality flags; document the exact eligibility logic. Resolution duration and closure duration may have different endpoints.
- **SLA:** Use the existing `sla_status` derivation, but first verify which defects are eligible, how targets are assigned, and whether unresolved but overdue defects are breaches. Missing/unknown SLA outcomes are **not** automatically compliant or breached.
- **Reopened defects:** The verified `reopened_count` integer records number of reopen events per defect (0 missing values reported). `reopened_count > 0` identifies distinct ever-reopened defects. To calculate **reopened after resolution / all defects resolved at least once**, a historical resolved-eligible denominator is still necessary; current Resolved/Closed statuses are not equivalent.
- **Consistency:** Round for display only, guard against zero denominators (`NULLIF` in SQL), state timezone/date boundary, and make cohort/filter choices explicit.

## 2. KPI dictionary

### KPI 01 — Total Defects
- **Definition:** Distinct defects in the selected dataset or reporting cohort.
- **Formula:** `Total Defects = COUNT(DISTINCT defect_id)`.
- **Business meaning:** Overall recorded defect volume.
- **Why management cares:** Shows workload and provides a denominator for other quality metrics; trends help assess testing volume and quality when interpreted alongside release size and testing intensity.
- **Example / baseline:** **12,000** cleaned defects across the full dataset.
- **Caution:** Higher volume does not necessarily mean worse software if testing coverage or reporting increased.

### KPI 02 — Open Defects
- **Definition:** Defects whose **current status is exactly `Open`** at the reporting snapshot.
- **Formula:** `Open Defects = COUNT(DISTINCT defect_id WHERE status = 'Open')`.
- **Business meaning:** Newly or presently open issues, as represented by that particular workflow status.
- **Why management cares:** Shows issues awaiting progression through triage and remediation.
- **Example / baseline:** **1,218** defects in `Open` status (as previously calculated).
- **Caution:** Excludes issues in other active statuses (e.g., In Progress, In Testing, Reopened); use Backlog for all unresolved work.

### KPI 03 — Closed Defects
- **Definition:** Defects whose **current status is exactly `Closed`** at the snapshot.
- **Formula:** `Closed Defects = COUNT(DISTINCT defect_id WHERE status = 'Closed')`.
- **Business meaning:** Count of items formally completed in the workflow.
- **Why management cares:** Shows completion volume and helps evaluate throughput when time-scoped.
- **Example / baseline:** **6,338** in `Closed` status.
- **Caution:** Current Closed count is not the same as defects *closed during a month*; use the closure timestamp for monthly throughput.

### KPI 04 — Critical Defects
- **Example / baseline:** **813** Critical defects.
- **Definition:** Defects with standardized `severity = 'Critical'` in the selected cohort.
- **Formula:** `Critical Defects = COUNT(DISTINCT defect_id WHERE severity = 'Critical')`.
- **Business meaning:** High-impact defect burden.
- **Why management cares:** Helps direct engineering capacity and release go/no-go discussions.
- **Caution:** Consider tracking **unresolved Critical** defects separately from all Critical defects.

### KPI 05 — Average Resolution Time
- **Definition:** Average elapsed time from defect creation to first valid resolution event, among defects with a valid resolution duration.
- **Formula:** `Average Resolution Time (hours) = SUM(valid resolution_hours) / COUNT(defects with valid resolution_hours)`.
- **Business meaning:** Typical arithmetic-mean elapsed resolution time; includes waiting time if stored durations are wall-clock hours.
- **Why management cares:** Reveals response bottlenecks and aids resource planning.
- **Example / baseline:** **49.07 hours**, previously calculated for valid resolutions.
- **Caution:** Exclude flagged invalid dates; report median/p90 alongside the mean for skewed distributions.

### KPI 06 — Mean Time to Resolve (MTTR)
- **Definition:** Mean elapsed time to resolve a defect, using an explicitly defined start and end event and valid resolved-defect cohort.
- **Formula:** `MTTR = SUM(time_to_resolution for eligible resolved defects) / Number of eligible resolved defects`.
- **Business meaning:** Resolution efficiency.
- **Why management cares:** Tracks effectiveness of defect remediation and recovery commitments.
- **Relationship to KPI 05:** **MTTR equals Average Resolution Time** if both use the *same defects, start/end timestamps, units, and exclusions*. Do not present them as independent insights in that case. If MTTR uses incident detection→restoration while Average Resolution Time uses defect creation→resolution, they are different and must be labeled accordingly.
- **Caution:** Different teams use MTTR for *repair, recovery, respond,* or *resolve*; explicitly say **Mean Time to Resolve** in interviews.

### KPI 07 — SLA Compliance %
- **Definition:** Share of defects with a determinable SLA outcome that met their applicable resolution target.
- **Formula:** `SLA Compliance % = (SLA Met / SLA Eligible with Known Outcome) × 100`.
- **Business meaning:** Reliability of delivery against agreed targets.
- **Why management cares:** Highlights operational performance and potential customer or contractual risk.
- **Example / baseline:** **42.79%** = 3,846 Met / 8,989 eligible. Verified `sla_status` values: Met 3,846; Breached 5,143; Not Applicable 3,011.
- **Caution:** Explicitly document whether overdue unresolved defects are included and whether the clock is paused in specific states.

### KPI 08 — SLA Breach %
- **Example / baseline:** **57.21%** = 5,143 Breached / 8,989 eligible.
- **Definition:** Share of defects with a determinable SLA outcome that breached their applicable target.
- **Formula:** `SLA Breach % = (SLA Breached / SLA Eligible with Known Outcome) × 100`.
- **Business meaning:** Proportion of SLA-covered work failing time commitments.
- **Why management cares:** Identifies service risk and improvement priorities.
- **Caution:** `Breach % = 100 − Compliance %` **only** if both use identical eligible populations and each has exactly one of two outcomes (Met or Breached). Otherwise report unknown/pending outcomes separately.

### KPI 09 — Reopen Rate % / Ever-Reopened Defect Share
- **Definition (available verified measure):** Proportion of distinct recorded defects that have been reopened **at least once** across their recorded history.
- **Actual validated formula:** `Ever-Reopened Defect Share % = COUNT(*) FILTER (WHERE reopened_count > 0) / COUNT(*) × 100`.
- **Example / baseline:** **13.60%** = **1,632 / 12,000 × 100**. `SUM(reopened_count) = 2,022` counts reopening **events** rather than distinct defects. No missing reopen counts were reported.
- **Business meaning:** How common repeat work is within the recorded defect population.
- **Why management cares:** Flags possible fix-quality, testing, configuration or requirement issues to investigate.
- **Distinct alternative (not verified):** `Resolution-Cohort Reopen Rate = Distinct defects reopened at least once / Distinct defects ever resolved (eligible to be reopened) × 100`. We **cannot** derive the historical denominator merely from `status IN ('Resolved', 'Closed')`, even though its current count is 7,560; reopened defects can now be in any status.
- **Caution:** Call the project's 13.60% metric **Ever-Reopened Defect Share**, not a rate among resolved defects. The previous shorthand “Reopen Rate” is ambiguous unless the denominator is explicitly stated.

### KPI 10 — Closure Rate %
- **Definition:** Share of a **defined defect cohort** that reached formal Closed status by the observation cutoff.
- **Formula (cohort):** `Closure Rate % = (Defects from the cohort Closed by cutoff / All defects in the cohort) × 100`.
- **Business meaning:** Completion of reported defect work.
- **Why management cares:** Measures remediation progress, particularly for a release or a cohort of defects created during a period.
- **Verified snapshot metric:** `Current Closed Share % = 6,338 / 12,000 × 100 = 52.82%` (not equivalent to monthly closure throughput).
- **Caution:** Do not calculate “monthly closure rate” by mixing closures from old cohorts with only defects created that same month, unless explicitly naming and interpreting that ratio.

### KPI 11 — Critical Defect %
- **Example / baseline:** **6.78%** = 813 / 12,000 × 100, rounded.
- **Definition:** Portion of defects in the cohort classified Critical.
- **Formula:** `Critical Defect % = (Critical Defects / Total Defects in same cohort) × 100`.
- **Business meaning:** Severity mix of observed defects.
- **Why management cares:** Tracks high-impact quality exposure over releases, modules, or months.
- **Caution:** This measures **severity distribution**, not defect density; density requires a size/exposure denominator.

### KPI 12 — Backlog Size
- **Definition:** Number of actionable defects not yet in a terminal workflow status at a specified snapshot.
- **Formula:** `Backlog Size = COUNT(DISTINCT defect_id WHERE status IN (agreed non-terminal statuses))`.
- **Business meaning:** Outstanding work across all active statuses.
- **Why management cares:** Supports capacity, prioritization, sprint planning, and release risk decisions.
- **Verified workflow counts:** Closed 6,338; Resolved 1,222; Open 1,218; In Progress 1,214; In Testing 852; Deferred 590; Reopened 566 (last count inferred by reconciliation and should be visually reconfirmed).
- **Narrow active backlog:** Open + In Progress + Reopened = **2,998**, per executed SQL.
- **Broader pending-work backlog:** Open + In Progress + Reopened + In Testing + Deferred = **4,440**, *if* Deferred is actionable. Classify In Testing as QA work, Deferred as postponed work, and Resolved as pending formal closure separately.
- **Caution:** Choose ONE primary definition with stakeholders; the broad count is dependent on workflow semantics.

### KPI 13 — Defect Aging
- **Definition:** Time that each still-unresolved defect has been open, evaluated at a chosen snapshot time.
- **Formula:** `Age (days) = reporting_date − created_date`, converted to days, for non-terminal defects.
- **Suggested outputs:** Average/median unresolved age, age buckets (`0–7`, `8–15`, `16–30`, `>30` days), oldest unresolved defects, and Critical backlog older than SLA.
- **Business meaning:** Measures how long work has waited without final completion.
- **Why management cares:** Uncovers neglected, stuck, or escalating defects and helps prioritize backlog reduction.
- **Observed query result:** **2,998** defects in `Over 30 Days` when measured against `CURRENT_DATE`, using narrow active statuses. This is a current-date age for a historical dataset, not evidence of 2,998 live overdue defects.
- **Caution:** Use a consistent *dataset snapshot/reporting date* rather than TODAY for historical reporting; a defect's age is not the same as its eventual resolution duration.

### KPI 14 — Month-over-Month Defect Change
- **Validation:** The monthly SQL query was executed, but its row-level outputs were not provided. Do not invent percentages.
- **Definition:** Percentage change in defects **created** in the current month relative to the previous month.
- **Formula:** `MoM Change % = ((Current-month created defects − Previous-month created defects) / Previous-month created defects) × 100`.
- **Business meaning:** Rate of change in incoming defect volume.
- **Why management cares:** Supports early warning, release comparisons, test planning, and staffing.
- **Example:** 120 new defects vs 100 in the prior month → `+20%`.
- **Caution:** If the previous month had zero defects, the percentage is undefined; show counts and `N/A`. Compare complete months, or equal month-to-date cutoffs, and consider testing/release volume as context.

## 3. One-page interview quick reference

| KPI | What it answers | Key warning |
|---|---|---|
| Total Defects | How much defect volume exists? | Count distinct defect IDs |
| Open Defects | How many are literally in Open status? | Not the full backlog |
| Closed Defects | How many are currently Closed? | Snapshot ≠ monthly closures |
| Critical Defects | How many have Critical severity? | Show unresolved Critical separately |
| Average Resolution Time | How long does a valid resolution take on average? | Filter invalid durations |
| MTTR | How long does it take to resolve? | May duplicate average resolution time |
| SLA Compliance % | What share met the SLA? | Denominator must be eligible/known |
| SLA Breach % | What share missed the SLA? | Complements compliance only under identical scope |
| Ever-Reopened Share % | What share of recorded defects ever reopened? | 13.60% uses all 12,000, not resolved-only denominator |
| Closure Rate % | What share of a cohort is Closed? | Define cohort and cutoff |
| Critical Defect % | What fraction are Critical? | Same cohort numerator/denominator |
| Backlog Size | How much unresolved work remains? | Define non-terminal statuses |
| Defect Aging | How old is unfinished work? | Use fixed snapshot timestamp |
| MoM Defect Change | Is incoming defect volume rising or falling? | Use created dates and comparable periods |

## 4. SQL verification reference (read-only)

Use actual known column `created_date` rather than `created_at`.

```sql
-- Reopening: verified reported results 1,632 / 2,022 / 0
SELECT
    COUNT(*) FILTER (WHERE reopened_count > 0) AS ever_reopened_defects,
    COALESCE(SUM(reopened_count), 0) AS total_reopen_events,
    COUNT(*) FILTER (WHERE reopened_count IS NULL) AS missing_reopen_counts,
    ROUND(100.0 * COUNT(*) FILTER (WHERE reopened_count > 0)
         / NULLIF(COUNT(*), 0), 2) AS ever_reopened_share_pct
FROM public.defects_clean;

-- SLA denominator deliberately excludes Not Applicable
SELECT
    COUNT(*) FILTER (WHERE sla_status = 'Met') AS sla_met,
    COUNT(*) FILTER (WHERE sla_status = 'Breached') AS sla_breached,
    COUNT(*) FILTER (WHERE sla_status = 'Not Applicable') AS sla_not_applicable,
    ROUND(100.0 * COUNT(*) FILTER (WHERE sla_status = 'Met')
        / NULLIF(COUNT(*) FILTER (WHERE sla_status IN ('Met','Breached')), 0), 2)
        AS sla_compliance_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE sla_status = 'Breached')
        / NULLIF(COUNT(*) FILTER (WHERE sla_status IN ('Met','Breached')), 0), 2)
        AS sla_breach_pct
FROM public.defects_clean;

-- Explicit narrow backlog definition
SELECT COUNT(*) AS active_resolution_backlog
FROM public.defects_clean
WHERE status IN ('Open', 'In Progress', 'Reopened');

-- Monthly creations; missing months require a calendar series if present
WITH month_counts AS (
    SELECT DATE_TRUNC('month', created_date)::date AS month,
           COUNT(*) AS defects_reported
    FROM public.defects_clean
    WHERE created_date IS NOT NULL
    GROUP BY 1
), comparison AS (
    SELECT month, defects_reported,
           LAG(defects_reported) OVER (ORDER BY month) AS previous_month
    FROM month_counts
)
SELECT month, defects_reported, previous_month,
       ROUND(100.0 * (defects_reported - previous_month)
           / NULLIF(previous_month, 0), 2) AS mom_change_pct
FROM comparison
ORDER BY month;
```
