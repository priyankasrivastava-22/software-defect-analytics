# Software Bug & Defect Analytics

A data analytics project that transforms software defect records into actionable insights using **SQL, PostgreSQL, and Power BI**. The project examines defect trends, severity, SLA compliance, resolution performance, reopening patterns, application and module quality, release quality, and root causes.

## Overview

Software teams generate defect data throughout the development and testing lifecycle. Without structured analysis, it can be difficult to identify quality hotspots, monitor resolution performance, and prioritize improvements.

This project analyzes **12,000 software defect records** to explore defect distribution, lifecycle performance, service-level agreement (SLA) compliance, and quality trends. SQL is used to clean, aggregate, and organize the data, while Power BI provides an interactive reporting layer for monitoring key metrics and exploring patterns.

## Objectives

- Analyze defect volume, severity, status, and trends over time.
- Measure SLA compliance and identify SLA breach patterns.
- Examine resolution time and defect reopening behavior.
- Compare defect quality across applications, modules, and releases.
- Explore root-cause and environment distributions.
- Build a structured Power BI data model with reusable DAX measures.
- Translate analytical results into practical, data-driven recommendations.

## Technology Stack

| Technology | Purpose |
|---|---|
| PostgreSQL | Relational data storage and SQL analysis |
| SQL | Data validation, aggregation, reporting views, and KPI analysis |
| Power BI Desktop | Interactive dashboards and data exploration |
| Power Query | Data connection and transformation |
| DAX | KPI calculations and analytical measures |
| Git and GitHub | Version control and project documentation |

## Dataset

The project uses a dataset containing **12,000 software defect records**. The analysis covers fields related to:

- Defect identification and project
- Application and module
- Defect type, severity, and priority
- Status and lifecycle dates
- Development and testing assignments
- Sprint and release
- Root cause and resolution type
- Reopening count
- Resolution duration and SLA status
- Environment

The dataset supports analysis of defect distribution, resolution performance, quality trends, and operational patterns.

## Analytical Workflow

1. **Data preparation and validation** — prepare the defect data and check record consistency.
2. **SQL analysis** — aggregate defect metrics and investigate quality, lifecycle, and SLA patterns.
3. **Reporting views** — organize reusable analytical outputs for defect details, SLA performance, release quality, and module quality.
4. **Data modeling** — structure the Power BI model around a fact table and supporting dimensions.
5. **DAX measures** — calculate key performance indicators and lifecycle metrics.
6. **Dashboard development** — present the results through interactive report pages.
7. **Business interpretation** — identify areas for further investigation and recommend practical improvements.

## Data Model

The Power BI model uses a star-schema approach with a central `FactDefects` table and supporting dimension tables:

- `DimDate`
- `DimApplication`
- `DimModule`
- `DimRelease`
- `DimEngineer`

The model supports analysis across dates, applications, modules, releases, and engineers.

The SQL reporting layer includes:

- `vw_defect_details`
- `vw_sla_performance`
- `vw_release_quality`
- `vw_module_quality`

These views organize defect-level information and aggregated quality metrics for reporting and analysis.

## Power BI Dashboards

The report contains the following analytical pages:

### Executive Overview

Provides a high-level summary of defect volume, open and critical defects, SLA compliance, average resolution time, and reopening metrics. Supporting visuals show trends over time, severity and status distributions, and module-level defect counts.

### KPI Validation

Provides a dedicated view for examining key performance indicators and year-over-year measures.

### SLA & Lifecycle

Examines SLA compliance and breaches, resolution time, and open defects, with breakdowns by application and severity.

### Module & Release Quality

Compares defect volume and critical-defect counts across modules to help identify areas that warrant further quality investigation.

### Defect Explorer

Provides a detailed defect-level view with filters for severity, status, application, and module, allowing users to investigate individual records and patterns.

## Key Metrics

The following values represent the project's validated KPI baseline:

| Metric | Result |
|---|---:|
| Total defects | 12,000 |
| Open defects | 1,218 |
| Closed defects | 6,338 |
| Critical defects | 813 |
| Average resolution time | 49.07 hours |
| SLA-eligible defects | 8,989 |
| SLA met | 3,846 |
| SLA breached | 5,143 |
| SLA compliance | 42.79% |
| SLA breach rate | 57.21% |
| Ever-reopened defects | 1,632 |
| Reopen rate | 21.59% |
| Resolved-or-closed defects | 7,560 |

Metric definitions and denominators should be considered when comparing results across reports. In particular, the project's reopen-rate measure should not be interpreted as the percentage of all records that have ever been reopened unless its denominator is changed accordingly.

## Selected Business Findings

The analysis identified several areas worth investigating:

- **SLA performance:** Application-level SLA breach rates range from 56.66% to 57.99% in the analyzed results, indicating that SLA breaches are not confined to a single application.
- **Module quality:** Refunds has 47 critical defects among 483 records, representing 9.73% in the supplied module results.
- **Release quality:** Payment Platform REL-06 has 21 critical defects among 199 records, representing 10.55% in the supplied release results.
- **Root-cause classification:** Code Defect is the largest named root-cause category, with 3,174 records. Another 2,814 records have a blank root-cause value, limiting the completeness of root-cause comparisons.
- **Environment distribution:** QA has the largest number of recorded defects, followed by PROD. These counts describe where defects were recorded; they do not, by themselves, establish testing effectiveness or production escape rates.
- **Reopening behavior:** Of the 12,000 records, 1,632 have been reopened at least once. Most of these were reopened once, while a smaller group experienced repeated reopening.

These findings identify priorities for investigation rather than proving causal relationships.

## Recommendations

Based on the analysis, practical improvement opportunities include:

1. Improve the completeness of root-cause classifications.
2. Investigate recurring code defects and modules with elevated critical-defect percentages.
3. Analyze SLA breaches by application, severity, priority, and resolution time.
4. Compare defect types across QA, UAT, and production to investigate potential production escapes.
5. Review repeatedly reopened defects and strengthen fix verification and regression testing.

## Limitations

- Missing root-cause values limit the completeness of root-cause analysis.
- Environment-level defect counts do not independently measure defect escape rates or testing effectiveness.
- Module and release observations depend on the scope of the aggregate results examined.
- The findings highlight associations and areas for investigation; they do not establish causation.

## Project Documentation

Additional documentation is available in the `docs/` directory, including:

- `dax_measures.md` — documentation of analytical measures.
- `bussiness_insights.md` — business findings and recommendations.

## Getting Started

To explore the project:

1. Clone or download this repository.
2. Review the SQL scripts and project documentation.
3. Open the Power BI report in Power BI Desktop.
4. If refreshing the report, configure a PostgreSQL connection to the appropriate dataset and database environment.
5. Explore the report pages, KPI measures, and available slicers.

Database connection details and credentials are environment-specific and should be configured locally. Do not commit passwords, connection secrets, or other sensitive configuration values to the repository.

## Future Improvements

Potential extensions include automated data refresh, additional data-quality checks, deeper root-cause analysis, and monitoring of defect trends over time.

## Author

**Priyanka Srivastava**

GitHub: [priyankasrivastava-22](https://github.com/priyankasrivastava-22)

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.