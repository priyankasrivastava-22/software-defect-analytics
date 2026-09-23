# Software Bug & Defect Lifecycle Analytics

## Project Objective

The objective of this project is to analyze software defect data and identify patterns in defect volume, severity, resolution time, SLA performance, reopened defects, release quality, and root causes.

The analysis will help software and QA teams understand where quality issues occur, which defects need attention, and whether defect resolution is improving over time.

## Business Problem

Software teams handle defects across multiple applications, modules, releases, and environments.

Tracking individual defects is useful for day-to-day work, but management also needs a larger view of software quality.

The main problems to understand are:

- which applications and modules generate the most defects;
- where critical and high-severity defects occur;
- how long defects take to resolve;
- how many defects breach SLA;
- how often resolved defects are reopened;
- which releases have higher defect volumes;
- which root causes appear repeatedly;
- whether the open defect backlog is increasing;
- whether software quality is improving over time.

## Stakeholders

The main users of the analysis are:

- Engineering Managers
- QA Managers
- Developers
- QA Engineers
- Release Managers
- Project Managers
- Application Support / Operations Teams

## Business Questions

The analysis should answer the following questions:

1. How many total defects have been reported?
2. How many defects are currently open or closed?
3. Which applications generate the most defects?
4. Which modules generate the most defects?
5. Which modules contain the most critical defects?
6. What is the average defect resolution time?
7. How does resolution time change by severity?
8. What percentage of defects are resolved within SLA?
9. Which applications or modules have the highest SLA breach rate?
10. How many resolved defects are reopened?
11. What is the defect reopen rate?
12. Which releases have the highest defect volume?
13. Which releases contain the most critical defects?
14. What are the most common defect root causes?
15. Which environments generate the most defects?
16. How large is the current open defect backlog?
17. How long have open defects remained unresolved?
18. Is defect volume increasing or decreasing month by month?
19. Are critical defects increasing or decreasing over time?
20. Is overall software quality improving across releases?

## Key Performance Indicators

The dashboard will track the following KPIs:

- Total Defects
- Open Defects
- Closed Defects
- Critical Defects
- Open Backlog
- Average Resolution Time
- Mean Time to Resolve (MTTR)
- SLA Compliance %
- SLA Breach %
- Reopen Rate %
- Closure Rate %
- Critical Defect %
- Month-over-Month Defect Change

For example:

Total Defects = total number of defects recorded

Open Defects = bugs that have not yet been resolved/closed

SLA Compliance % = percentage of applicable defects resolved within their SLA target

Reopen Rate % = percentage of resolved defects that had to be reopened

## Project Scope

The project will analyze software defects across:

- applications;
- modules;
- releases;
- environments;
- severity and priority levels;
- defect lifecycle status;
- defect creation and resolution dates;
- SLA performance;
- reopened defects;
- root causes;
- resolution types.

The project will focus on historical defect analysis and dashboard reporting.

## Assumptions

- The dataset represents a realistic software defect lifecycle similar to data that may be exported from a defect tracking system such as Jira.
- The dataset is synthetic and does not contain confidential company information.
- Each defect has a unique defect ID.
- Open defects may not have a resolved or closed date.
- Closed defects are expected to have lifecycle dates available.
- SLA targets may vary based on severity or priority.
- Reopened defects can have a reopened count greater than zero.
- Missing and inconsistent values may exist in the raw dataset and will be handled during data cleaning.