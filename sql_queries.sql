-- Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT * FROM netflix;

SELECT COUNT(*) AS total_content FROM netflix;

SELECT DISTINCT type FROM netflix;

--1 Count the Number of Movies vs TV Shows

SELECT type, COUNT(*) AS total_content FROM netflix GROUP BY type;

-- SELECT DISTINCT ls_in, UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS ls_in FROM netflix;
--2 Find the Most Common Rating for Movies and TV Shows

SELECT 
	type, rating 
FROM(
	SELECT 
		type, rating, 
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY 1,2
) WHERE ranking = 1;

--2.1 Find the Least Common Rating for Movies and TV Shows
SELECT 
	type, rating
FROM(
	SELECT
		type, rating, COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*)) AS RANKING
	FROM netflix
	GROUP BY 1,2
) WHERE ranking = 1;

--3 List All Movies Released in a Specific Year (e.g., 2020)
SELECT
	*
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;

--4 Find the Top 5 Countries with the Most Content on Netflix
SELECT 
	TRIM(BOTH ' ' FROM UNNEST(STRING_TO_ARRAY(country, ','))) AS country, COUNT(show_id) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5;

--5 Identify the Longest Movie
SELECT
	title,  REPLACE(duration, ' min', '')::int AS duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY 2 DESC
LIMIT 1;

-- 7 Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT
	*
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

--8. List All TV Shows with More Than 5 Seasons
SELECT
	title, duration
FROM netflix
WHERE type ILIKE 'TV Show' AND SPLIT_PART(duration, ' ', 1)::int > 5

--9. Count the Number of Content Items in Each Genre
SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')), COUNT(*)
FROM netflix
GROUP BY 1;

-- 9.1 Get the director with number of TV Shows and Movies
WITH Director_Counts AS (
    SELECT
        TRIM(BOTH ' ' FROM UNNEST(STRING_TO_ARRAY(director, ','))) AS Director,
        SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS Movie_Count,
        SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS Show_Count
    FROM netflix
    WHERE director IS NOT NULL
    GROUP BY Director
)
SELECT *
FROM Director_Counts
ORDER BY Movie_Count DESC;

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
SELECT
		release_year, COUNT(*) AS release_count,
		ROUND((COUNT(*)::numeric / (SELECT COUNT(*) FROM netflix WHERE country = 'India' AND country IS NOT NULL)::numeric * 100), 2)
FROM netflix
WHERE country = 'India' AND country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 11. List All Movies that are Documentaries
SELECT title, listed_in
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';

--12 Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT title, release_year, casts
FROM netflix
WHERE casts ILIKE '%Salman Khan%' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 20;

--13. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT
	TRIM(BOTH ' ' FROM UNNEST(STRING_TO_ARRAY(casts, ','))) AS cast_name, COUNT(*) AS number_of_appreance
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 14. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT category, COUNT(*)
FROM(
	SELECT
	title,
	CASE
		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
		ELSE 'Good'
		END AS category
	FROM netflix
)
GROUP BY 1;

-- 15. Top Directors by Genre
SELECT director, genre, content_count
FROM(
    SELECT 
        TRIM(BOTH ' ' FROM UNNEST(STRING_TO_ARRAY(director, ','))) AS director, 
        TRIM(BOTH ' ' FROM UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
        COUNT(*) AS content_count,
		ROW_NUMBER() OVER (PARTITION BY TRIM(BOTH ' ' FROM UNNEST(STRING_TO_ARRAY(listed_in, ','))) ORDER BY COUNT(*) DESC) AS rank
    FROM netflix
    WHERE director IS NOT NULL
    GROUP BY director, genre
)
WHERE rank = 1
ORDER BY content_count DESC;

--16. Director Who Released Most Content in a Single Year
SELECT
    TRIM(BOTH ' ' FROM UNNEST(STRING_TO_ARRAY(director, ','))) AS director,
    release_year,
    COUNT(*) AS content_count,
    RANK() OVER (PARTITION BY release_year ORDER BY COUNT(*) DESC) AS year_rank
FROM netflix
WHERE director IS NOT NULL
GROUP BY director, release_year
ORDER BY year_rank;
