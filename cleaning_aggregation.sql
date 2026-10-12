-- CLEANING --

ALTER TABLE raw_business_establishments
CHANGE COLUMN anzsic_indusrty anzsic_industry VARCHAR(100);

DESCRIBE raw_business_establishments;
DESCRIBE raw_floor_space_by_block;

SET SQL_SAFE_UPDATES = 0;
UPDATE raw_business_establishments
SET total_jobs = NULL
WHERE total_jobs = '';

ALTER TABLE raw_business_establishments
MODIFY total_jobs INT NULL;

UPDATE raw_floor_space_by_block
SET total_floor_space_in_block = NULL
WHERE total_floor_space_in_block = '';

ALTER TABLE raw_floor_space_by_block
MODIFY total_floor_space_in_block DECIMAL(12,1) NULL;

SELECT census_year, clue_small_area, anzsic_industry, business_size, COUNT(*) AS so_lan
FROM raw_business_establishments
GROUP BY census_year, clue_small_area, anzsic_industry, business_size
HAVING COUNT(*) > 1;

SELECT census_year, clue_small_area, block_id, COUNT(*) AS so_lan
FROM raw_floor_space_by_block
GROUP BY census_year, clue_small_area, block_id
HAVING COUNT(*) > 1;

SELECT DISTINCT clue_small_area FROM raw_business_establishments ORDER BY 1;
SELECT DISTINCT business_size FROM raw_business_establishments ORDER BY 1;
SELECT DISTINCT anzsic_industry FROM raw_business_establishments ORDER BY 1 ;

-- AGGREGATION -- 

CREATE TABLE agg_floor_space_by_area_year AS
SELECT
    census_year,
    clue_small_area,
    SUM(total_floor_space_in_block) AS total_floor_space_sqm
FROM raw_floor_space_by_block
GROUP BY census_year, clue_small_area;

CREATE TABLE agg_business_by_area_year AS
SELECT
    census_year,
    clue_small_area,
    SUM(total_establishments) AS total_establishments,
    SUM(total_jobs) AS total_jobs
FROM raw_business_establishments
GROUP BY census_year, clue_small_area;

CREATE TABLE agg_business_density AS
SELECT
    b.census_year,
    b.clue_small_area,
    b.total_establishments,
    b.total_jobs,
    f.total_floor_space_sqm,
    ROUND(b.total_establishments / (f.total_floor_space_sqm / 1000), 2) AS establishments_per_1000sqm,
    ROUND(b.total_jobs / (f.total_floor_space_sqm / 1000), 2) AS jobs_per_1000sqm
FROM agg_business_by_area_year b
JOIN agg_floor_space_by_area_year f
    ON b.census_year = f.census_year
   AND b.clue_small_area = f.clue_small_area;

SELECT * FROM agg_business_density ORDER BY census_year, clue_small_area;


