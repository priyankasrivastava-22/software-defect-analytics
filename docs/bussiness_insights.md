# Business Insights — Software Bug & Defect Analytics

## 1. Project Overview

This project analyzes 12,000 software defect records using SQL, PostgreSQL, and Power BI. The goal is to identify patterns in defect severity, resolution, SLA compliance, application and module quality, release quality, root causes, environments, and reopened defects.

## 2. Key Findings

### SLA Performance
SLA breach rates range from 56.66% to 57.99% across the six applications analyzed. Reporting has the highest breach rate at 57.99%, while Payment Platform has the lowest at 56.66%. The narrow range suggests that SLA breaches are a cross-application concern rather than an issue confined to one application.

### Module Quality

Among the ten module rows examined, Refunds has 47 critical defects out of 483 total defects, giving it a critical-defect percentage of 9.73%. This module warrants further investigation and prioritization.

### Release Quality
Among the ten release rows examined, Payment Platform REL-06 has the highest critical-defect percentage at 10.55%, with 21 critical defects out of 199. This release is a useful candidate for reviewing defect patterns and validation practices.

### Closure Performance
Customer Portal REL-09 has a closure percentage of 45.90%, while Notifications REL-02 has 46.57% in the supplied release results. These combinations warrant investigation to understand their lower closure percentages.

### Root-Cause Distribution
Code Defect is the largest named root-cause category, with 3,174 records. However, 2,814 records have a blank root cause, representing approximately 23.45% of all records. Missing classifications limit the reliability of root-cause comparisons.

### Environment Distribution
QA contains 3,547 defects, followed by PROD with 2,762, DEV with 2,171, UAT1 with 2,064, and UAT2 with 1,456. These counts show where defects were recorded, but do not independently measure the effectiveness of each environment or the rate at which defects escaped to production.

### Reopened Defects
A total of 1,632 defects were reopened at least once, equivalent to 13.6% of the 12,000 records. Of these, 1,312 were reopened once, 254 twice, 62 three times, and 4 four times. Most reopened defects returned once, while a smaller group experienced repeated reopening.

## 3. Recommendations

1. Improve root-cause data completeness by reviewing blank classifications and strengthening classification practices.
2. Investigate recurring Code Defect patterns and prioritize modules with high critical-defect percentages.
3. Compare defect types and severity across QA, UAT, and PROD to investigate potential production escapes.
4. Analyze SLA breaches by application, severity, priority, and resolution time to identify practical improvement opportunities.
5. Review repeatedly reopened defects and strengthen fix verification and regression testing.

## 4. Limitations

- Module and release rankings in this analysis are based on the supplied top-ten query results, not a complete comparison of every module or release.
- Environment counts alone do not establish defect escape rates or testing effectiveness.
- Missing root-cause values affect the completeness of root-cause analysis.
- These findings identify areas for investigation; they do not establish causal relationships.

## 5. Conclusion

The analysis highlights cross-application SLA breaches, modules and releases with elevated critical-defect percentages, incomplete root-cause classification, and defects that are reopened after resolution. These findings can help teams prioritize defect prevention, improve resolution quality, and strengthen reporting and testing practices.