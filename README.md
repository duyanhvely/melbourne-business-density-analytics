# Melbourne Business Density Dashboard

## Project Overview
A portfolio project analyzing business establishment and employment density across the City of Melbourne (2002–2024), built with MySQL for data cleaning/aggregation and Power BI for modeling, DAX, and a storytelling dashboard.

## Business Question
Which areas of Melbourne have the highest business density, how has it changed over time, and how does each area compare to the city-wide average?

## Tools Used
- MySQL / MySQL Workbench — data cleaning and aggregation
- Power BI Desktop — data modeling, DAX, dashboard
- Power Query — data type validation and model prep

## Dataset
City of Melbourne CLUE (Census of Land Use and Employment) open data, via DataVic:
- [Business establishments and jobs data by business size and ANZSIC in small areas](https://discover.data.vic.gov.au/en_AU/dataset/business-establishments-and-jobs-data-by-business-size-and-anzsic-in-small-areas) (2002–2024)
- [Floor space per space use for blocks](https://discover.data.vic.gov.au/en_AU/dataset/floor-space-per-space-use-for-blocks) (joined via `clue_small_area` + `census_year`)

## Data Model
Star schema with one fact table and two dimension tables:
- `Fact_BusinessDensity` — establishments, jobs, floor space, by area and year
- `Dim_Area` — 13 CLUE small areas
- `Dim_Year` — census years, 2002–2024

Single-direction relationships (1-to-many), no circular references.

<img width="855" height="303" alt="Ảnh màn hình 2026-10-12 lúc 14 53 41" src="https://github.com/user-attachments/assets/7b2941b9-3bcd-4f38-8d96-fc3d3563ab95" />

## SQL Data Processing
Full script: [`cleaning_aggregation.sql`](./cleaning_aggregation.sql)

**Cleaning**
- Fixed a mistyped column name (`anzsic_indusrty` → `anzsic_industry`)
- Converted empty-string values (`''`) to proper `NULL` before type casting, to preserve intentionally suppressed/missing data rather than imputing it
- Cast numeric columns from TEXT to INT/DECIMAL
- Checked for duplicate rows and inconsistent category values (extra whitespace, typos) across `clue_small_area`, `business_size`, `anzsic_industry`

**Aggregation**
- Grouped the business table and the floor space table down to one row per area/year (resolving a many-to-many grain mismatch before joining)
- Joined both aggregated tables into `agg_business_density`, with two derived density metrics (establishments and jobs per 1,000 sqm)

## Power BI Dashboard
Built around a DAR (Descriptive–Analytical–Reporting) storytelling structure: Hook → Rising Insight → Aha Moment → Recommendation.

<img width="848" height="541" alt="Ảnh màn hình 2026-10-12 lúc 14 55 47" src="https://github.com/user-attachments/assets/a373254d-5247-43ca-b481-930c1fdd82a5" />


## Key DAX Measures

| Measure | Technique | Purpose |
|---|---|---|
| `Total Establishments` / `Total Jobs` | Base | Core aggregates from the fact table |
| `Jobs per Establishment` | Ratio | Average jobs generated per business |
| `Establishments YoY % Change` | % Change | Year-over-year growth rate per area |
| `Establishments Variance vs Prev Year` | Variance | Absolute year-over-year change |
| `Establishments vs City Avg (Same Year)` | Benchmark | Area value relative to the city-wide average for that year |
| `Area Rank by Establishments` | Rank | Area's rank among all 13 areas |

## Key Insights

**1. Melbourne CBD's business base still hasn't recovered its pre-COVID peak.**
Establishments peaked at 9,467 in 2017, dipped slightly to 9,444 by 2019, then fell further during 2020–2021 to a trough of 8,074 (roughly 15% below the 2017 peak). By 2024 the count has only recovered to 7,883 — still about 17% below the 2017 peak.

**2. Parkville has almost the fewest businesses in the city — and by far the most jobs per business.**
Parkville ranks 10th of 13 areas by total establishment count, yet leads every area in jobs per establishment, a lead that has widened over time (gap over the second-highest area grew from 11 in 2010 to 24 in 2023). The pattern points to a handful of very large institutions (hospitals, university campus) rather than a broad base of small businesses.

## Business Recommendation
Direct CBD recovery support broadly, prioritizing the segments most likely to re-establish quickly, since overall establishment count remains well below the 2017 peak. Treat Parkville's jobs-per-business figure as an institutional signature, not a small-business benchmark, when comparing areas.

## Limitations
- Jobs data is only complete through 2023; establishment counts extend to 2024, so some comparisons use different reference years for each metric.
- Some establishment/job values are suppressed for confidentiality (kept as `NULL`, not imputed with 0 or an average), which may understate totals for small subgroups.
- The dataset includes a business-size breakdown (small/medium/large) that was not explored in this dashboard; the CBD recovery insight describes aggregate establishment counts only, not which business sizes drove the change.

## How to Use
1. Run `cleaning_aggregation.sql` in MySQL (MySQL Workbench) against the two raw CLUE CSV files to reproduce `agg_business_density`.
2. Open `DAR_Dashboard_Elio.pbix` in Power BI Desktop to view the full data model, DAX measures, and dashboard.

## About
Built by Elio Nguyen as a personal portfolio project. [Add LinkedIn/GitHub/contact link here]
