# Netflix Movies TV Shows SQL Dataset Project

1. Question: What is the total number of content items available on Netflix?:

```sql
SELECT COUNT(*) AS total_content FROM netflix;
```
Explanation: This query counts all rows in the netflix table, giving the total number of movies and TV shows available on Netflix. It is useful for understanding the size of the content library.

2. How many movies and TV shows are available on Netflix?
```sql
SELECT type, COUNT(*) AS total_content FROM netflix GROUP BY type;
```
Explanation: This query groups the content by its type (movies and TV shows) and counts the number of items in each category. This helps in comparing the quantity of different content types.

3. What are the most common ratings for movies and TV shows on Netflix?
```sql
SELECT type, rating 
FROM(
    SELECT type, rating, 
           RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY 1,2
) AS ranked
WHERE ranking = 1;
```
Explanation: This query uses a subquery to rank ratings for each content type based on their frequency and retrieves the highest-ranked rating for each type. It is helpful for understanding audience reception.

4. What are the least common ratings for movies and TV shows on Netflix?
```sql
SELECT type, rating
FROM(
    SELECT type, rating, COUNT(*) AS count,
           RANK() OVER(PARTITION BY type ORDER BY COUNT(*)) AS ranking
    FROM netflix
    GROUP BY 1, 2
) AS ranked
WHERE ranking = 1;
```
Explanation: Similar to the previous query, this one ranks ratings but focuses on the least common ratings, providing insights into less favorable audience perceptions.

5. What movies were released on Netflix in 2020?
```sql
SELECT *
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;
```
Explanation: This query filters the records to show only movies released in 2020, providing a list of available titles for that year.

6.Which countries have the most content available on Netflix?
```sql
SELECT 
    TRIM(BOTH ' ' FROM UNNEST(STRING_TO_ARRAY(country, ','))) AS country, 
    COUNT(show_id) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5;
```
Explanation: This query counts the number of shows and movies for each country, identifying the top five countries with the largest Netflix libraries.

7. What is the longest movie available on Netflix?
```sql
SELECT title, REPLACE(duration, ' min', '')::int AS duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY duration DESC
LIMIT 1;
```
Explanation: This query extracts the duration of movies, converts it to an integer, and retrieves the title of the longest movie. It helps in identifying epic-length films.

8. What movies and TV shows has Tensai Okamura directed on Netflix?
```sql
SELECT *
FROM netflix
WHERE director ILIKE '%Tensai Okamura%';
```
Explanation: This query filters the records to show all content directed by Tensai Okamura, allowing users to explore his works.

9. Which TV shows on Netflix have more than 5 seasons?
```sql
SELECT title, duration
FROM netflix
WHERE type ILIKE 'TV Show' AND SPLIT_PART(duration, ' ', 1)::int > 5;
```
Explanation: This query retrieves titles of TV shows that have more than five seasons, helping users find long-running series.

10. How many content items are available in each genre on Netflix?
```sql
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')), COUNT(*)
FROM netflix
GROUP BY 1;
```
Explanation: This query counts the number of items in each genre, which provides insights into genre popularity and diversity.

11. How many movies and TV shows have each director produced on Netflix?
```sql
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
```
Explanation: This query aggregates the number of movies and TV shows directed by each director, which provides insights into their contributions to the Netflix library.

12. What is the average number of content items released in India per year on Netflix?
```sql
SELECT
    release_year, COUNT(*) AS release_count,
    ROUND((COUNT(*)::numeric / (SELECT COUNT(*) FROM netflix WHERE country = 'India' AND country IS NOT NULL)::numeric * 100), 2)
FROM netflix
WHERE country = 'India' AND country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```
Explanation: This query calculates the total number of releases per year for India and returns the top five years with the highest averages, showcasing trends in content production.

13. What documentaries are available on Netflix?
```sql
SELECT title, listed_in
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';
```
Explanation: This query filters the records to show all documentaries available, helping users find factual content.

14. How many movies has Salman Khan appeared in over the last 10 years on Netflix?
```sql
SELECT title, release_year, casts
FROM netflix
WHERE casts ILIKE '%Salman Khan%' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```
Explanation: This query filters the records to show movies featuring Salman Khan released in the last ten years, focusing on his recent contributions.

15. Who are the top 10 actors with the highest number of appearances in Indian movies on Netflix?
```sql
SELECT
    TRIM(BOTH ' ' FROM UNNEST(STRING_TO_ARRAY(casts, ','))) AS cast_name, 
    COUNT(*) AS number_of_appearance
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```
Explanation: This query counts the appearances of actors in Indian movies, helping to identify popular actors within that region.

16. How is Netflix content categorized based on violent themes?
```sql
SELECT category, COUNT(*)
FROM(
    SELECT
        title,
        CASE
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized
GROUP BY 1;
```
Explanation: This query categorizes content based on the presence of keywords related to violence in their descriptions, providing insights into the nature of the content.

17. Who are the top directors by genre on Netflix?
```sql
SELECT director, genre, content_count
FROM(
    SELECT 
        TRIM(BOTH ' ' FROM UNNEST(STRING_TO_ARRAY(director, ','))) AS director, 
        TRIM(BOTH ' ' FROM UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
        COUNT(*) AS content_count,
        ROW_NUMBER() OVER (PARTITION BY genre ORDER BY COUNT(*) DESC) AS rank
    FROM netflix
    WHERE director IS NOT NULL
    GROUP BY director, genre
) AS ranked
WHERE rank = 1
ORDER BY content_count DESC;
```
Explanation: This query identifies the director with the most content in each genre, helping to recognize influential figures in specific categories.

18. Which director released the most content in a single year on Netflix?
```sql
SELECT
    TRIM(BOTH ' ' FROM UNNEST(STRING_TO_ARRAY(director, ','))) AS director,
    release_year,
    COUNT(*) AS content_count,
    RANK() OVER (PARTITION BY release_year ORDER BY COUNT(*) DESC) AS year_rank
FROM netflix
WHERE director IS NOT NULL
GROUP BY director, release_year
ORDER BY year_rank;
```
Explanation: This query counts the number of content items released by each director per year and ranks them, helping to identify prolific directors in specific years.
