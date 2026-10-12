# Self Q&A — Design Decisions & Limitations

### Why use CALCULATE + variables instead of SAMEPERIODLASTYEAR?
Power BI's built-in time intelligence functions (`SAMEPERIODLASTYEAR`, `DATEADD`, etc.) 
require a continuous calendar table with a proper Date column. `Dim_Year` here only holds 
discrete census survey years (2002–2024), not a continuous calendar — so those functions 
don't apply cleanly. Instead, each measure manually computes "current year − 1" as a 
variable and uses `CALCULATE` to override the filter context onto that prior year, 
reproducing the same year-over-year logic without needing a full date table.

### Why clean and aggregate in SQL instead of Power Query?
Power Query can technically do all of this equally well — this wasn't a technical 
necessity, it was a deliberate choice for a few reasons:
- Most data analyst job descriptions ask for SQL directly; drag-and-drop cleaning in 
  Power Query doesn't demonstrate that skill.
- Cleaned data sitting in a real MySQL database is reusable by any tool (Power BI, 
  Tableau, Python), not locked inside one `.pbix` file.
- SQL scripts are plain text — easy to version, diff, and review step by step on 
  GitHub, unlike Power Query steps hidden inside a binary `.pbix` file.
- Writing JOINs by hand forces an explicit understanding of keys and join grain, 
  rather than relying on a drag-and-drop Merge button.

### What if the data turns out to be wrong?
This happened during development, not hypothetically. A full verification pass against 
live Power BI tables caught several errors before publishing:
- Parkville's establishment-count rank was originally stated as 9th of 13 areas; 
  the verified rank table showed it was actually 10th.
- The COVID-era establishment drop was originally estimated at "~18%"; after 
  identifying that 2017 (not 2019) was the true establishment peak, the correct 
  figure recalculated from verified raw data was ~15%.
Every headline number in the final dashboard was re-derived from a filtered table 
of raw values (not read off a chart by eye) before being locked in.

### Why only 2 insights, not more charts?
Several additional charts were explored during EDA (YoY % change, absolute 
variance, a ranking table, a scatter of establishments vs. jobs) but were dropped 
because they either duplicated a story already told by the two chosen insights, 
or didn't hold up as a genuinely surprising, actionable finding. A dashboard with 
more charts isn't automatically more informative — each one included has to earn 
its place by adding a distinct, non-redundant story.
