# Phase 13 — DAX Measures and KPI Validation

**Project:** Software Bug & Defect Analytics  
**Database:** PostgreSQL — `defect_analytics`  
**BI Tool:** Microsoft Power BI Desktop  
**Data Model:** Star Schema  
**Fact Table:** `FactDefects`  
**Dimensions:** `DimDate`, `DimApplication`, `DimModule`, `DimRelease`, `DimEngineer`

---

## 1. Objective

The objective of Phase 13 was to implement dynamic business KPIs using Data Analysis Expressions (DAX) in Power BI.

The measures analyze:

- Defect volume and severity
- Defect resolution performance
- SLA compliance and breaches
- Defect reopening and closure performance
- Month-over-Month (MoM) defect growth
- Year-over-Year (YoY) defect growth
- Aging of unresolved defects

The calculations use the star schema developed in Phase 12 and respond dynamically to report filters.

## 2. DAX Fundamentals

### What is DAX?

DAX (Data Analysis Expressions) is a formula language used in Power BI for measures, calculated columns, and calculated tables.

### Measures vs Calculated Columns

| Measure | Calculated Column |
|---|---|
| Evaluated in the current filter context | Calculated for individual table rows |
| Responds dynamically to filters and slicers | Stored in the imported model |
| Used for aggregations and KPIs | Used for row-level attributes |
| Example: Total Defects | Example: Defect Age Days |

### Row Context

Row context allows a formula to evaluate individual records.

Example: `Defect Age Days` uses the current defect's status and creation date.

### Filter Context

Filter context determines which rows participate in a calculation.

For example, selecting Payment Platform filters `FactDefects` to the defects belonging to that application.

### CALCULATE

`CALCULATE()` evaluates an expression under a modified filter context.

It is one of the most important functions used in this phase.

---

## 3. Defect Count Measures

### 3.1 Total Defects

**Business definition:** Total number of defect records in the selected context.

```dax
Total Defects =
COUNTROWS(FactDefects)
```

`COUNTROWS()` counts the rows in the fact table.

**Validated result:** 12,000 defects.

Because the dataset contains 12,000 distinct defect IDs, this count represents the total number of defects.

### 3.2 Open Defects

**Business definition:** Number of defects whose current status is exactly Open.

```dax
Open Defects =
CALCULATE(
    [Total Defects],
    FactDefects[status] = "Open"
)
```

**Validated result:** 1,218.

This measure does not include In Progress, In Testing, or Reopened defects.

### 3.3 Closed Defects

**Business definition:** Number of defects whose current status is Closed.

```dax
Closed Defects =
CALCULATE(
    [Total Defects],
    FactDefects[status] = "Closed"
)
```

**Validated result:** 6,338.

### 3.4 Critical Defects

**Business definition:** Number of defects classified as Critical severity.

```dax
Critical Defects =
CALCULATE(
    [Total Defects],
    FactDefects[severity] = "Critical"
)
```

**Validated result:** 813.

These measures demonstrate how `CALCULATE()` modifies the filter context.

---

## 4. Resolution Performance

### 4.1 Average Resolution Time

**Business definition:** Average recorded resolution duration, measured in hours.

```dax
Average Resolution Time =
CALCULATE(
    AVERAGE(FactDefects[Resolution Hours]),
    FILTER(
        FactDefects,
        NOT ISBLANK(FactDefects[Resolution Hours])
            && FactDefects[Resolution Hours] >= 0
    )
)
```

**Validated Power BI result:** 49.07 hours.

### Explanation

- `AVERAGE()` calculates the arithmetic mean.
- `FILTER()` selects records meeting the validity criteria.
- `ISBLANK()` identifies missing resolution durations.
- `NOT` excludes missing values.
- `&&` requires both conditions to be true.
- `CALCULATE()` evaluates the average within the filtered context.

Blank and negative resolution durations are excluded. Zero-hour durations are retained.

The result was compared with the existing PostgreSQL KPI baseline. If future data introduces other invalid-resolution conditions, those rules must also be included.

---

## 5. SLA Performance Measures

### Business Definition

SLA Compliance measures how many eligible defects met their agreed resolution service levels.

Records classified as `Not Applicable` are excluded from the denominator.

### 5.1 SLA Met

```dax
SLA Met =
CALCULATE(
    [Total Defects],
    FactDefects[sla_status] = "Met"
)
```

**Validated result:** 3,846.

### 5.2 SLA Breached

```dax
SLA Breached =
CALCULATE(
    [Total Defects],
    FactDefects[sla_status] = "Breached"
)
```

**Validated result:** 5,143.

### 5.3 SLA Eligible

```dax
SLA Eligible =
[SLA Met] + [SLA Breached]
```

**Validated result:** 8,989.

### 5.4 SLA Compliance %

```dax
SLA Compliance % =
DIVIDE(
    [SLA Met],
    [SLA Eligible]
)
```

**Validated result:** 42.79%.

### 5.5 SLA Breach %

```dax
SLA Breach % =
DIVIDE(
    [SLA Breached],
    [SLA Eligible]
)
```

**Validated result:** 57.21%.

### Explanation

`DIVIDE()` safely handles zero denominators and returns BLANK by default if division cannot be performed.

The two percentage measures are formatted as Percentage with two decimal places.

Neither formula is multiplied by 100 because Power BI applies percentage formatting automatically.

### Validation

| Metric | Result |
|---|---:|
| SLA Met | 3,846 |
| SLA Breached | 5,143 |
| SLA Not Applicable | 3,011 |
| SLA Eligible | 8,989 |
| SLA Compliance | 42.79% |
| SLA Breach | 57.21% |

---

## 6. Defect Reopening and Closure

### 6.1 Ever Reopened Defects

**Business definition:** Number of distinct defect records with at least one reopening.

```dax
Ever Reopened Defects =
CALCULATE(
    [Total Defects],
    FactDefects[reopened_count] > 0
)
```

**Validated result:** 1,632.

This counts defects, not individual reopen events.

The previously validated number of reopen events was 2,022.

### 6.2 Resolved or Closed Defects

```dax
Resolved or Closed Defects =
CALCULATE(
    [Total Defects],
    FactDefects[status] IN {"Resolved", "Closed"}
)
```

**Validated result:** 7,560.

### 6.3 Reopen Rate %

```dax
Reopen Rate % =
DIVIDE(
    [Ever Reopened Defects],
    [Resolved or Closed Defects]
)
```

**Validated result:** 21.59%.

**Definition limitation:** This is a snapshot-based ratio using all ever-reopened defects over the currently Resolved or Closed population. It is not a true historical transition-based reopening rate, and the numerator is not necessarily a subset of the denominator.

For comparisons requiring a mathematically aligned population, a separate measure or historical status-transition data would be necessary.

### 6.4 Closure Rate %

```dax
Closure Rate % =
DIVIDE(
    [Closed Defects],
    [Total Defects]
)
```

**Validated result:** 52.82%.

This calculates the proportion of records currently marked Closed, not the number of defects resolved during a particular period.

---

## 7. Month-over-Month Defect Growth

### Business Definition

Month-over-Month (MoM) growth measures the percentage change in recorded defect volume compared with the previous calendar month.

### 7.1 Previous Month Defects

```dax
Previous Month Defects =
CALCULATE(
    [Total Defects],
    DATEADD(
        DimDate[Date],
        -1,
        MONTH
    )
)
```

`DATEADD()` shifts the selected dates backward by one month.

### 7.2 Defect Growth %

```dax
Defect Growth % =
VAR CurrentDefects = [Total Defects]
VAR PriorDefects = [Previous Month Defects]
RETURN
    IF(
        ISBLANK(PriorDefects) || PriorDefects = 0,
        BLANK(),
        DIVIDE(
            CurrentDefects - PriorDefects,
            PriorDefects
        )
    )
```

### Explanation

- `VAR` defines reusable intermediate values.
- `RETURN` provides the final calculation.
- `ISBLANK()` detects unavailable comparison values.
- `DIVIDE()` calculates the percentage change safely.

### Reference Validation

| Month | Total Defects | Previous Month | Growth |
|---|---:|---:|---:|
| January 2025 | 620 | — | — |
| February 2025 | 503 | 620 | -18.87% |
| March 2025 | 634 | 503 | +26.04% |
| April 2025 | 642 | 634 | +1.26% |

These are reference values from the monthly defect data. MoM percentage measures must be validated in a monthly date context.

---

## 8. Year-over-Year Defect Growth

### Business Definition

Year-over-Year (YoY) growth measures the percentage change in defect volume compared with the same period of the previous year.

### 8.1 Previous Year Defects

```dax
Previous Year Defects =
CALCULATE(
    [Total Defects],
    SAMEPERIODLASTYEAR(DimDate[Date])
)
```

`SAMEPERIODLASTYEAR()` shifts the current date selection back by one year.

### 8.2 YoY Defect Growth %

```dax
YoY Defect Growth % =
VAR CurrentDefects = [Total Defects]
VAR PriorYearDefects = [Previous Year Defects]
RETURN
    IF(
        ISBLANK(PriorYearDefects) || PriorYearDefects = 0,
        BLANK(),
        DIVIDE(
            CurrentDefects - PriorYearDefects,
            PriorYearDefects
        )
    )
```

### Validated Comparisons

| Month | Current Year | Previous Year | YoY Growth |
|---|---:|---:|---:|
| January 2026 | 616 | 620 | -0.65% |
| February 2026 | 550 | 503 | +9.34% |
| March 2026 | 590 | 634 | -6.94% |
| April 2026 | 619 | 642 | -3.58% |
| May 2026 | 612 | 662 | -7.55% |
| June 2026 | 575 | 586 | -1.88% |
| July 2026 | 605 | 614 | -1.47% |
| August 2026 | 649 | 600 | +8.17% |

The 2025 previous-year values are blank because the dataset does not contain 2024 records.

The YoY visual's Total row was disabled to avoid presenting an overall-period calculation as if it were a monthly growth figure.

---

## 9. Defect Aging Using DATEDIFF

### Business Definition

Defect aging measures the number of days an unresolved defect has remained in the system since creation.

### Calculated Column — Defect Age Days

```dax
Defect Age Days =
IF(
    FactDefects[status] IN {
        "Open",
        "In Progress",
        "In Testing",
        "Reopened"
    },
    DATEDIFF(
        FactDefects[Created Date],
        TODAY(),
        DAY
    ),
    BLANK()
)
```

### Explanation

- `IF()` applies the calculation only to specified unresolved statuses.
- `IN` checks membership in a set of statuses.
- `DATEDIFF()` counts day boundaries between the creation timestamp and the current date.
- `TODAY()` returns the current date.
- `BLANK()` avoids calculating active aging for excluded statuses.

### Important Considerations

This is a calculated column, not a measure.

In Power BI Import mode, its value changes when the model recalculates or refreshes.

The metric should not be summed across defects. In the report, the column should use **Don't summarize**.

Future creation dates can yield negative values. If such dates are possible, additional handling is required.

The dataset's reporting cutoff date should be distinguished from the actual Power BI refresh date.

---

## 10. Star Schema and Filter Context

The Power BI model contains:

| Table | Purpose |
|---|---|
| FactDefects | Individual defect records |
| DimDate | Calendar-based analysis |
| DimApplication | Application filtering |
| DimModule | Application-module filtering |
| DimRelease | Application-release filtering |
| DimEngineer | Developer filtering |

The dimensions connect to `FactDefects` using active many-to-one relationships with single-direction filtering.

When an application, month, module, release, or developer is selected, the measures recalculate within the corresponding filter context.

### Example — Payment Platform

| KPI | Overall | Payment Platform |
|---|---:|---:|
| Total Defects | 12,000 | 2,047 |
| Open Defects | 1,218 | 220 |
| Closed Defects | 6,338 | 1,089 |
| Critical Defects | 813 | 139 |

This was tested using a Power BI slicer and a Matrix visual.

---

## 11. Important DAX Functions Learned

| Function | Purpose |
|---|---|
| `COUNTROWS` | Count table rows |
| `CALCULATE` | Modify filter context |
| `FILTER` | Return rows matching conditions |
| `DIVIDE` | Perform safe division |
| `DISTINCTCOUNT` | Count unique values |
| `SUM` | Add numeric values |
| `AVERAGE` | Calculate arithmetic mean |
| `DATEDIFF` | Count boundaries between dates |
| `DATEADD` | Shift the date context by a specified interval |
| `SAMEPERIODLASTYEAR` | Shift the selected period back one year |
| `ISBLANK` | Detect blank values |
| `IF` | Apply conditional logic |
| `VAR` | Define a reusable variable |
| `RETURN` | Return a variable-based expression |

`DISTINCTCOUNT` and `SUM` were included in the learning scope; the validated core KPIs primarily use `COUNTROWS`, `CALCULATE`, `AVERAGE`, and `DIVIDE`.

---

## 12. Validation Strategy

The Power BI calculations were compared with previously validated PostgreSQL queries and reporting views.

Key validation checks included:

1. Total fact rows equal 12,000.
2. Distinct defect IDs equal 12,000.
3. Application-level results match PostgreSQL counts.
4. SLA-eligible records exclude Not Applicable.
5. Ever-reopened defects are distinguished from total reopen events.
6. Average resolution time matches the reference result.
7. MoM calculations use the preceding calendar month.
8. YoY calculations use the corresponding previous-year period.
9. Slicer selections update related measures.
10. DAX percentage measures use the appropriate formatting.

The final validation was performed on a separate Power BI report page named `KPI Validation`.

---

## 13. Problems Encountered and Solutions

### Issue 1 — Application slicer displayed unexpected counts

**Cause:** An application was selected in the slicer or Matrix visual.

**Solution:** Clear the selection and verify that Total Defects returns to 12,000.

### Issue 2 — Measures displayed 2K instead of 2,047

**Cause:** Power BI automatically abbreviated the Card's display units.

**Solution:** Change Display units to None or validate using a Table visual.

### Issue 3 — Defect Growth DAX syntax error

**Cause:** The formula was initially entered as a calculated column, and the variable name `PreviousMonth` conflicted with a DAX time-intelligence function name.

**Solution:** Create a measure and use `PriorDefects` as the variable name.

### Issue 4 — Previous Year Defects appeared blank

**Cause:** The selected month belonged to 2025, while no 2024 data existed.

**Solution:** Validate on 2026 rows and confirm that January 2026 references January 2025.

### Issue 5 — Unwanted YoY total

**Cause:** The measure was evaluated in the overall date context, producing a different calculation from an individual month's growth.

**Solution:** Disable Totals for the YoY table.

### Issue 6 — Defect Age Days was summed

**Cause:** Power BI treated the numeric calculated column as aggregatable.

**Solution:** Use Don't summarize and disable irrelevant totals.

---

## 14. Deliverables

- Power BI file containing the Phase 13 DAX measures and validation visuals.
- `docs/dax_measures.md` containing KPI formulas, explanations, and validation results.
- SQL and Power BI cross-checks.
- Practice with row context, filter context, time intelligence, and calculated columns.
- GitHub commit preserving Phase 13 work.

---