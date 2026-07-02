-- Netflix Data Analysis using SQL
-- Solutions of 20 business problems

--1)Count the total number of Movies vs. TV Shows.
--Objective: Establish the overall content mix of the platform.
SELECT type,COUNT(*) 
FROM netflix_titles
GROUP BY type;


--2)Find the most common content rating for Movies and TV Shows separately.
--Objective: Identify the dominant target audience/maturity level for each content type.
WITH rating_count AS (
    SELECT type,rating,COUNT(*) AS count 
    FROM netflix_titles
    GROUP BY type,rating 
    ),
    rank_counts AS(
        SELECT type, rating,count,
        RANK() OVER(PARTITION BY type ORDER BY count DESC) AS rank_position 
        FROM rating_count
    )
SELECT type,rating,count 
FROM rank_counts
WHERE rank_position=1;   


--3)List all movies released in a specific year (e.g., 2020).
--Objective: Support ad-hoc filtering of the catalog by release year.
SELECT * 
FROM netflix_titles
WHERE type='Movie' AND release_year=2020;


--4)Find the top 5 countries with the most overall content on Netflix.
--Objective: Measure Netflix's content concentration by country of origin.
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
LIMIT 5;


--5)Find all content where the director is missing (NULL values)
--Objective: Flag data quality gaps for downstream cleaning or enrichment.
SELECT * 
FROM netflix_titles 
WHERE director='' OR director IS NULL;


--6)Identify the longest movie.(NEW)
--Objective: Surface catalog outliers in runtime.
WITH MovieDuration AS (
    SELECT title, 
    CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS duration_mins
    FROM netflix_titles    
    WHERE type = 'Movie'
)  
SELECT title, duration_mins
FROM MovieDuration
ORDER BY duration_mins DESC
LIMIT 1;  


--7)List all TV shows with more than 5 seasons
--Objective: Identify long-running, binge-heavy series on the platform.
WITH TVShowSeasons AS (
    SELECT title, 
    CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS no_of_seasons
    FROM netflix_titles    
    WHERE type = 'TV Show')
SELECT title,no_of_seasons
FROM TVShowSeasons
WHERE no_of_seasons>5;   


--8)Find all the movies or TV shows directed by 'Rajiv Chilaka'
--Objective: Demonstrate director-level content lookup.
SELECT * FROM netflix_titles
WHERE director LIKE '%Rajiv Chilaka%';


--9)List all movies that are classified exactly as or include "Documentaries" in their genre list.
--Objective: Isolate a single genre segment for deeper analysis.
SELECT * FROM netflix_titles
WHERE type='Movie' AND listed_in LIKE '%Documentaries%';


--10)Identify the top 5 directors who have directed the most movies in the "Thrillers" or "TV Mysteries" genres.
--Objective: Find genre specialists by combining genre and director filters.
SELECT director,COUNT(*) AS no_of_movies
FROM netflix_titles
WHERE (director!='' AND director IS NOT NULL) AND type='Movie' AND (listed_in LIKE '%Thrillers%' OR listed_in LIKE '%TV Mysteries%') 
GROUP BY director
ORDER BY no_of_movies DESC
LIMIT 5;


--11)Categorize content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
--Objective: Perform basic content moderation tagging from unstructured text.
WITH CategorizeCntent AS (
    SELECT type,title,description,
    CASE 
    WHEN (description LIKE '%kill%' OR description LIKE '%violence%') THEN 'Bad'
    ELSE 'Good'
    END AS category
    FROM netflix_titles)
SELECT category,COUNT(*) AS count
FROM CategorizeCntent
GROUP BY category;


--12)Find the total number of content items added in the last 5 years.
--Because we permanently changed the date_added column into a true DATE format in data cleaning steps, we don't need a conversion function anymore
--Objective: Gauge how much of the catalog reflects recent platform activity.
SELECT COUNT(*)
FROM netflix_titles
WHERE date_added>=DATE_SUB((SELECT MAX(date_added) FROM netflix_titles),INTERVAL 5 YEAR);


--13)Count the total number of content items in each individual genre.(NEW)
--Objective: Break multi-genre tags into individual genres to measure true genre popularity.
WITH RECURSIVE Numbers AS(
    SELECT 1 AS n
    UNION ALL
    SELECT n+1 FROM Numbers WHERE n<=10
),
SplitGenres AS(
    SELECT
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in,',',Numbers.n),',',-1)) AS individual_genre
    FROM netflix_titles 
    JOIN Numbers
    ON CHAR_LENGTH(listed_in)-CHAR_LENGTH(REPLACE(listed_in,',',''))+1>=Numbers.n
)
SELECT individual_genre,COUNT(*)
FROM SplitGenres
GROUP BY individual_genre;


--14)Calculate the total yearly content release count for India and return the top 5 years with the highest volume of releases.
--Objective: Track India-specific content output by release year, not upload date.
SELECT release_year,COUNT(*) AS no_of_releases
FROM netflix_titles
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY no_of_releases DESC
LIMIT 5;


--15)Find how many movies actor 'Salman Khan' appeared in over the last 10 years.
--Objective: Demonstrate actor-level filtering combined with a rolling time window.
SELECT COUNT(*)
FROM netflix_titles
WHERE type='Movie' AND cast LIKE '%Salman Khan%' 
AND release_year>=YEAR((SELECT MAX(date_added) FROM netflix_titles))-10;


--16) Find the top 10 actors who have appeared in the highest number of movies produced in India.
--Objective: Identify India's most prolific on-screen talent within the catalog.
WITH RECURSIVE Numbers AS(
    SELECT 1 AS n
    UNION ALL
    SELECT n+1 FROM Numbers WHERE n<30
),SplitCast AS(
    SELECT
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast,',',Numbers.n),',',-1)) AS individual_actor
    FROM netflix_titles
    JOIN Numbers
    ON CHAR_LENGTH(cast)-CHAR_LENGTH(REPLACE(cast,',',''))+1>=Numbers.n
    WHERE type = 'Movie' 
    AND country LIKE '%India%' 
    AND cast IS NOT NULL 
    AND cast != ''
)
SELECT individual_actor,COUNT(*)
FROM SplitCast
GROUP BY individual_actor
ORDER BY COUNT(*) DESC
LIMIT 10;


--17)Find all titles where the release_year and the year it was date_added to Netflix are more than 10 years apart (identifying classic movies added to the platform recently).
--Objective: Spot older "classic" titles that were added to the platform long after their original release.
SELECT title
FROM netflix_titles
WHERE YEAR(date_added)-release_year>10;


--18)Identify the pair of actors who have appeared in the most movies together.
--Objective: Reveal frequent on-screen collaborations via a self-join on split cast lists.
WITH RECURSIVE Numbers AS(
    SELECT 1 AS n
    UNION ALL
    SELECT n+1 FROM Numbers WHERE n<30
),SplitCast AS(
    SELECT
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast,',',Numbers.n),',',-1)) AS individual_actor
    FROM netflix_titles
    JOIN Numbers
    ON CHAR_LENGTH(cast)-CHAR_LENGTH(REPLACE(cast,',',''))+1>=Numbers.n
    WHERE type = 'Movie'  
    AND cast IS NOT NULL 
    AND cast != ''
)
SELECT t1.individual_actor,t2.individual_actor,COUNT(*)
FROM SplitCast t1
JOIN SplitCast t2
ON t1.show_id=t2.show_id AND t1.individual_actor<t2.individual_actor
GROUP BY t1.individual_actor,t2.individual_actor
ORDER BY COUNT(*) DESC
LIMIT 1;


--19)Identify the most popular month for adding new content to the platform globally.
--Objective: Detect seasonality in Netflix's content release strategy.
SELECT MONTHNAME(date_added),COUNT(*)
FROM netflix_titles
GROUP BY MONTHNAME(date_added)
ORDER BY COUNT(*) DESC
LIMIT 1;


--20)Calculate the rolling cumulative total of content added to Netflix month-by-month over the dataset's timeline using Window Functions.
--Objective: Visualize platform growth trends using a running total.
WITH MonthlyCounts AS (
    SELECT 
    YEAR(date_added) AS add_year,
    MONTH(date_added) AS add_month,
    COUNT(*) AS monthly_total
    FROM netflix_titles
    WHERE date_added IS NOT NULL
    GROUP BY YEAR(date_added), MONTH(date_added)
)
SELECT add_year,add_month,monthly_total,
SUM(monthly_total) OVER (ORDER BY add_year, add_month) AS cumulative_total
FROM MonthlyCounts
ORDER BY add_year, add_month;