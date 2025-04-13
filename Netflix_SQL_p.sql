-- 14 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows
SELECT type, COUNT(*) AS total_content 
FROM netflix 
group by type;

-- 2. Find the most common rating for movies and TV shows
select 
	type, 
	rating
from (
	select 
	type, 
	rating, 
	count(*),
rank() over(partition by type order by count(*) desc) as ranking
from netflix
group by type, rating ) as t1
where ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
select * 
from netflix 
where release_year = '2020' and type = 'Movie';

-- 4. Find the top 5 countries with the most content on Netflix
select 
trim(unnest(string_to_array(country,','))) as new_country,
count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5;

-- 5. Identify the longest movie
with cte as
(select 
	title,
	cast(split_part(duration,' ',1) as INTEGER) as duration
from netflix
where type='Movie')
select title,duration
from cte
where duration=(select max(duration)
from cte);

-- 6. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from ( 
SELECT *, unnest(string_to_array(director, ',')) as director_name
FROM netflix ) as t
where director_name = 'Rajiv Chilaka';

-- 7. List all TV shows with more than 5 seasons
select *
from netflix
where type = 'TV Show' and 
split_part(duration, ' ',1)::numeric >5

-- 8. Count the number of content items in each genre
select unnest(string_to_array(listed_in, ',')) as genre, count(show_id) as total_content
from netflix
group by genre

-- 9.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 10. List all movies that are documentaries
select *
from netflix
where listed_in like '%Documentaries%'

-- 11. Find all content without a director
select *
from netflix
where director is null

-- 12. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * 
from netflix 
where casts Ilike '%Salman Khan%'
and release_year > extract(year from current_date) - 10

-- 13. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select unnest(string_to_array(casts, ',')) as actors,
count(*) as total_content
from netflix
where country ILike '%India%'
group by actors
order by 2 desc
limit 10

/*14. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field.
Label content containing these keywords as 'Bad' and all other content as 'Good'. 
Count how many items fall into each category.*/
with new_table as 
(
select *,
   case
     when description ILike '%kill%' or description ILike '%violence%' then 'bad_content'
	 else 'good_content'
   end as category
from netflix
)
select category, count(*) as total_c0ntent
from new_table
group by category
