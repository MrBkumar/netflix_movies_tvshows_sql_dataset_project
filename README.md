# netflix_movies_tvshows_sql_dataset_project

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
