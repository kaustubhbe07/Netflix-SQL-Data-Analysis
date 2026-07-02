/* NETFLIX DATASET - EXPLORATORY DATA ANALYSIS (EDA)
   Description: Initial exploration to understand structure, quality, and patterns in the Netflix titles dataset */

-- ============================
-- 1. BASIC DATA OVERVIEW
-- ============================

-- 1.1 Total number of records
SELECT COUNT(*) AS total_records FROM netflix_titles;

-- 1.2 Preview the data
SELECT * FROM netflix LIMIT 10;

-- 1.3 Column names and data types
DESCRIBE netflix_titles;


-- ===============================
-- 2. NULL / MISSING VALUE CHECKS
-- ===============================

-- 2.1 Count NULLs per column
SELECT 
SUM(CASE WHEN show_id IS NULL OR show_id = '' THEN 1 ELSE 0 END) AS missing_show_ids,
SUM(CASE WHEN director IS NULL OR director = '' THEN 1 ELSE 0 END) AS missing_directors,
SUM(CASE WHEN cast IS NULL OR cast = '' THEN 1 ELSE 0 END) AS missing_cast,
SUM(CASE WHEN country IS NULL OR country = '' THEN 1 ELSE 0 END) AS missing_countries,
SUM(CASE WHEN date_added IS NULL OR date_added = '' THEN 1 ELSE 0 END) AS missing_dates,
SUM(CASE WHEN rating IS NULL OR rating = '' THEN 1 ELSE 0 END) AS missing_ratings,
SUM(CASE WHEN duration IS NULL OR duration = '' THEN 1 ELSE 0 END) AS missing_durations
FROM netflix_titles; 

-- 2.2 Check for duplicate show_ids
SELECT show_id, COUNT(*) 
FROM netflix 
GROUP BY show_id 
HAVING COUNT(*) > 1;


-- ============================
-- 3. UNIVARIATE EXPLORATION
-- ============================

-- 3.1 Movies vs TV Shows coun
SELECT type, COUNT(*) AS count, 
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles), 2) AS percentage
FROM netflix_titles
GROUP BY type;

-- 3.2 Distribution of ratings
SELECT type, rating, COUNT(*) AS rating_count
FROM netflix_titles
WHERE rating IS NOT NULL AND rating != ''
GROUP BY type, rating
ORDER BY type, rating_count DESC;

-- 3.4 Top 10 countries producing content
WITH RECURSIVE Numbers AS (
SELECT 1 AS n
UNION ALL
SELECT n + 1 FROM Numbers WHERE n < 15
),
SplitCountries AS (
   SELECT 
   show_id,
   TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', Numbers.n), ',', -1)) AS single_country
   FROM netflix_titles
   JOIN Numbers 
   ON CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) + 1>= Numbers.n 
   WHERE country IS NOT NULL AND country != ''
)
SELECT single_country, COUNT(*) AS content_count
FROM SplitCountries
GROUP BY single_country
ORDER BY content_count DESC
LIMIT 10;

-- ============================
-- 4. TEMPORAL TRENDS
-- ============================

--4.1 Production Year Trends vs. Platform Upload Trends
SELECT 
release_year,type
COUNT(*) AS produced_count,
SUM(CASE WHEN date_added IS NOT NULL THEN 1 ELSE 0 END) AS added_count
FROM netflix_titles
GROUP BY release_year,type
ORDER BY release_year DESC;

--4.2 Platform Seasonality Drops
SELECT MONTHNAME(date_added) AS drop_month, COUNT(*) AS total_drops
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY MONTHNAME(date_added)
ORDER BY total_drops DESC;


-- ============================
-- 6. DURATION ANALYSIS
-- ============================

--6.1 Movie Runtime Summary Statistics
WITH MovieLengths AS (
   SELECT CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS mins
   FROM netflix_titles
   WHERE type = 'Movie' AND duration IS NOT NULL
)
SELECT 
MIN(mins) AS shortest_movie_mins,
MAX(mins) AS longest_movie_mins,
ROUND(AVG(mins), 2) AS average_movie_mins
FROM MovieLengths;

--6.2 TV Show Season Lifespans
SELECT duration AS season_count, COUNT(*) AS series_count
FROM netflix_titles
WHERE type = 'TV Show'
GROUP BY duration
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;