DROP TABLE IF EXISTS netflix_row;
Create Table netflix_row(
show_id TEXT,
show_type Text,
title Text,
director Text,
country TEXT,
date_added TEXT,
release_year INT,
rating VARCHAR(50),
duration TEXT,
listed_in TEXT

);

Select * from netflix_row;

----------------------
Create Table title as
Select 
	TRIM(show_id) as show_id,
	TRIM(show_type) as show_type,
	 INITCAP(TRIM(title)) as title,
	 NULLIF(TRIM(director), '') as director,
	 CASE
	 WHEN date_added ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$'
        THEN TO_DATE(date_added, 'Month DD, YYYY')
 WHEN date_added ~ '^[0-9]{2}-[A-Za-z]{3}-[0-9]{2}$'
        THEN TO_DATE(date_added, 'DD-Mon-YY')
		
	Else null 
	End as added_date
From netflix_row;
------------------------------------------
Select * from title;

Create Table genre as 
Select 
	Trim(show_id) as show_id,
	INITCAP(trim(genre)) as genre,
	release_year
	FROM netflix_row
CROSS JOIN LATERAL
    UNNEST(string_to_array(listed_in, ',')) AS genre

WHERE listed_in IS NOT NULL
  AND TRIM(genre) <> '';

Select * from genre;
----------------------
Create Table rating as 
Select 
 Trim(show_id)as show_id,
 Upper(Trim(rating)) as rating
from netflix_row
WHERE rating IS NOT NULL
  AND TRIM(rating) <> '';

Select * from rating;
----------------------------------
Create Table country as 
	Select 
	 Trim(show_id)as show_id,
INITCAP(trim(country)) as country_name
FROM netflix_row,
LATERAL UNNEST(string_to_array(country, ',')) AS country_name
WHERE country IS NOT NULL
  AND TRIM(country_name) <> '';

Select * from country;
-------------------------------------

------ Project questions start from here------------------------------

--Q1-----Count total number of titles in the database
	Select Count(title) as total_titles
			from title;
--or 
Select count(*) as total_titles 
from title;
	
---Q2----Count how many movies vs TV shows
Select 
		show_type,
	count(*) as count_movie_series
	from title
	group by show_type;

---Q3----List all unique ratings available
		Select
		Distinct(rating) as unique_rating
		from rating;

----Q4--- Find the top 10 most common genres
		Select 
		genre,
		Count(*) as common_genre 
		from genre 
		group by genre order by common_genre DESC
		Limit 10;
		
----Q5-----------Count titles added per year
		Select 
			Extract(Year from added_date) as year_,
			Count(title) as total_title
			from title
	where added_date is not null
			group by year_ order by total_title DESC;


-----Q6---- Find all titles directed by a specific director (example: 'Martin Scorsese')
Select 
	title,
	director
	from title 
	where director Ilike '%Martin Scorsese%';

---Q7--- Count total number of unique countries
		Select 
		Distinct(country_name) as unique_country,
		count(*) as total_country
		from country
		group by unique_country;

Select count (Distinct country_name) as unique_country
	from country;

-----Q8---Find the top 5 countries with most content
		select country_name,
				Count(*) as total_content
				from country 
			group by country_name
					order by total_content Desc
				Limit 5;

----Q9--List all titles added in 2021
	Select title,
		added_date
			from title
			where Extract(year from added_date) = 2021;
--or
Select title,
		added_date
			From title 
		Where added_date > '2021-01-01'
		And added_date < '2022-01-01';

----10---Count titles by rating category
		Select 
		COALESCE(r.rating, 'ALL RATINGS') as rating,
				COUNT(*) as total_title
				from rating r
				left join title t
				on r.show_id= t.show_id
				group by Rollup (r.rating)
			order by total_title DESC;

---Q11----Find all movies with 'TV-MA' rating
	select 
		r.rating,
			t.show_type,
		t. title
		from rating r
	 join title t
				on r.show_id= t.show_id
		where t. show_type = 'Movie'
			and r.rating ='TV-MA';
			
----Q12----List all content with its genre and country

	Select 
	t.title,
		g. genre,
		c. country_name
			from genre g
		join title t
			on g.show_id= t.show_id
		join country c
			on g.show_id= c.show_id;

----Or---- 

Select 
	t.title,
	String_AGG(Distinct g.genre,',') as genre,
	string_AGG(Distinct c. country_name, ',' ) as country_name
	From title t
	Join genre g
		On t. show_id = g. show_id
	Join country c
			On t.show_id = c.show_id
			group by t.title;
	

-------Q13---Find titles released in the 2020s (2020 onwards)
	Select DISTInCT
	t.title,
		g. release_year
			From title t
		join genre g
			on t.show_id = g.show_id
		where g.release_year >= 2020;

----Q14====Count content by genre and show type
		Select g. genre,
		t. show_type,
	Count(*) as total_content
		from title t
				join genre g
	On t.show_id= g.show_id
	Group by g.genre, t.show_type
	Order by total_content DESC;

-------Or=====-----------------------
	Select g. genre,
		t. show_type,
	Count(*) as total_content,
	ROUND(Count(*) * 100.0 / SUM(count(*)) over (), 2) as percentage_of_total
from title t
				join genre g
	On t.show_id= g.show_id
	Group by g.genre, t.show_type
	Order by total_content DESC;

-----15-----Find all content from India
		Select t.title,
				c.country_name
							From title t
						join country c
								On t.show_id = c. show_id
								where c.country_name ='India';
				
----Q16--List all Horror movies
Select t.title,
			g.genre
		From title t
	join genre g
		on t.show_id = g. show_id
	where g.genre ILIKE '%Horror%'
		And t.show_type= 'Movie';

----Q17---Find content with rating 'PG-13' from United States
		Select t.title,
	r.rating,
	c.country_name
	from title t
	join rating r 
		On t.show_id= r. show_id
	Join country c 
		On t.show_id = c. show_id
		where r.rating = 'PG-13'
		And c.country_name = 'United States'
	Order by t.title;

----Q18--- Count movies vs TV shows by country (top 10 countries)
		Select 
		c. country_name,
		t. show_type,
		Count(*) as total_movie_series
			from title t
				join country c
					On t.show_id= c.show_id
				Group by c.country_name, t.show_type
					Order by total_movie_series
					Limit 10;


------------or------
WITH country_totals AS (
    SELECT
        c.country_name,
        COUNT(*) AS total_content
    FROM title t
    JOIN country c ON t.show_id = c.show_id
    GROUP BY c.country_name
)
SELECT *
FROM country_totals
ORDER BY total_content DESC
LIMIT 10;

----Q19---Find all documentaries added after 2020
Select 
	t.title, 
		g. genre,
		t. added_date
		From genre g
			join title t
	On g.show_id= t.show_id 
where g.genre ILike '%documentaries%'
And t. added_date >= '2021-01-01'
order by t.added_date DESC;

----Q20----Top 10 directors with most movies (not TV shows)
Select 
	COALESCE(director, 'Unknown') as director_name,
		count(*) as total_movies 
from title 
		where show_type = 'Movie'
group by director
		order by total_movies DESC
	Limit 10;
		
---with percentage

Select 
	COALESCE(director, 'Unknown') as director_name,
		count(*) as total_movies,
ROUND(Count(*) * 100.0 / SUM(count(*)) over (), 2) as percentage_of_total
from title 
		where show_type = 'Movie'
group by director
		order by total_movies DESC
	Limit 10;
	
------Q21---- Count titles added each month in 2021
		Select 
		To_Char(added_date, 'Month') as month_name,
		EXTRACT(Month from added_date) as month_number,
		Count(*) as total_title
		from title
		where added_date >='2021-01-01' 
		And added_date <= '2022-01-01'
		group by month_name, month_number
		order by total_title DESC;

----Q22---Find genres with more than 500 titles
	Select 
		genre,
		count(*) as total_title
		from genre 
		group by genre
			Having count(*) >500
	Order by total_title DESC;
		
---Q23----Calculate average release year by genre
		Select genre,
		ROUND(AVG(release_year),2) as average_total
		from genre
			group by genre
		Order by average_total DESC;

----Q24--- Find countries that have both movies and TV shows
SELECT
    c.country_name
FROM country c
JOIN title t
    ON c.show_id = t.show_id
GROUP BY c.country_name
HAVING 
    SUM(CASE WHEN t.show_type = 'Movie' THEN 1 ELSE 0 END) > 0
AND SUM(CASE WHEN t.show_type = 'TV Show' THEN 1 ELSE 0 END) > 0
ORDER BY c.country_name;

---Q25---- Count titles by rating and show type combination
SELECT
    r.rating,
    t.show_type,
    COUNT(*) AS total_titles
FROM rating r
JOIN title t
    ON r.show_id = t.show_id
GROUP BY r.rating, t.show_type
ORDER BY total_titles DESC;

----Q26--- Find the most prolific year (most content released)
SELECT
    g.release_year,
    COUNT(DISTINCT g.show_id) AS total_titles
FROM genre g
JOIN title t
    ON g.show_id = t.show_id
GROUP BY g.release_year
ORDER BY total_titles DESC
LIMIT 1;

----Q27--- Count content by decade
SELECT
    (FLOOR(release_year / 10) * 10) AS decade,
    COUNT(DISTINCT show_id) AS total_content
FROM genre
GROUP BY decade
ORDER BY decade;

---Q28--Find directors who have worked in multiple genres
SELECT
    t.director,
    COUNT(DISTINCT g.genre) AS total_genres
FROM title t
JOIN genre g
    ON t.show_id = g.show_id
WHERE t.director IS NOT NULL
GROUP BY t.director
HAVING COUNT(DISTINCT g.genre) > 1
ORDER BY total_genres DESC;

----Q29-- Calculate the percentage of Movies vs TV Shows
SELECT
    t.show_type,
    COUNT(DISTINCT t.show_id) AS total_titles,
    ROUND(
        COUNT(DISTINCT t.show_id) * 100.0 / SUM(COUNT(DISTINCT t.show_id)) OVER (),
        2
    ) AS percentage_of_total
FROM title t
GROUP BY t.show_type
ORDER BY percentage_of_total DESC;

----30-- Find how many titles were added each quarter of 2020
		Select 
			Extract (year from added_date) as yar,
			Extract(Quarter from added_date) quarter_,
			Count(Distinct show_id) as total_title
			From title
			where Extract (year from added_date) = 2020
			group by Extract (year from added_date), Extract(Quarter from added_date)
			order by quarter_;

---Q31--Find titles with multiple genres (more than 2 genres)
		Select t.title,
			Count(Distinct g.genre) as multiple_genre
			from title t
			join genre g
		On t.show_id = g. show_id 	
		Group by t.title
		Having
	Count(Distinct g.genre) > 2
			Order by multiple_genre DESC;

----Q32--Find titles that appear in multiple countries
	Select 
	t.show_id,
		t.title,
		Count(Distinct Trim(country)) as total_country
		from title t
		join country c
	On t.show_id = c.show_id 
	Join Lateral UNNEST(STRING_TO_ARRAY(c.country_name, ','))  as country On True
	Group by t.show_id,t.title 
	order by total_country DESC;
	
---Q33---- Find the top 3 most popular genres per country
	Select c.country_name,
			g.genre ,
			count(Distinct t.show_id) as total_genre
			From country c
		join title t
	On c.show_id = t.show_id 
	join genre g
		on t.show_id = g. show_id
	Group by c.country_name, g.genre
	order by c. country_name, total_genre DESC;

-- with window function 
	with genre_count as (

			Select 
			c.country_name,
			g. genre,
			Count(Distinct t.show_id ) as total_title,
			Row_number() over (Partition by c.country_name Order by Count(Distinct t.show_id) DESC)as ran 
	
	from country c
		join title t 
			On c.show_id = t. show_id 
			Join genre g
		On t.show_id = g. show_id 
		Group by c.country_name, g.genre
	
	)  
		 Select 
		 	country_name,genre, total_title
	from genre_count
where ran <= 3
	Order by country_name, total_title;

-----Q34---Find movies that were released and added to Netflix in the same year
		Select Distinct
		t.show_id,
		t.title,
				Extract(Year from t.added_date) as year_,
				g. release_year
			From title t
				Join genre g
			On t.show_id = g. show_id 
			where t.show_type ='Movie'
			And Extract(Year from t.added_date)= g. release_year;

-----Q35--- Calculate the time gap between release and Netflix addition
	Select 
	t.show_id,
		t.title,
		g. release_year,
		EXTract (YEar from t.added_date ) as added_year,
		EXTract (YEar from t.added_date) - g.release_year as time_gaf
		from title t
		join genre g
			On t.show_id = g.show_id
		where t.added_date is not null 
			and g.release_year is not null
			Group by 
		t.show_id,
		t.title,
		g. release_year,
		t. added_date
			Order by time_gaf DESC;
		
---Q36--Find the oldest and newest content by genre
		Select 
		genre,
		MIN(release_year) as oldest,
		MAX(release_year) as newest
		from genre
		where release_year is not null
		Group by genre
		Order by genre;

---Q37-- Find titles with the word "Love" in the title
		Select 
			title 
			from title 
		where title Ilike '%love%';

----Q38--Count how many titles each director has by show type
SELECT
    director,
    show_type,
    COUNT(DISTINCT show_id) AS titles_count
FROM title
WHERE director IS NOT NULL
GROUP BY
    director,
    show_type
ORDER BY
    titles_count DESC;

--Or
SELECT
    director,
Count (DISTINCT Case
					when show_type = 'Movie' 
					Then show_id end ) as movie_count,
Count(	Distinct Case
					when show_type = 'TV Show '
					then show_id end ) as series_count

FROM title
WHERE director IS NOT NULL
GROUP BY director
		Order by movie_count DESC, series_count DESC;

-----Q39---Find content added in the last quarter of each year
		Select title,
			Extract(Year from added_date) as added_year,
			Extract(MOnth from added_date ) as month_,
			Extract(Quarter from added_date) as quarter_
			From title
		Where Extract(Quarter from added_date) =4
		Order by
			added_year,
			month_;
		
----Q40---- Create a content catalog with all information
		Select
	 t.show_id,
		t.title,
		t.show_type,
			t. director,
			g. genre,
			r. rating,
			g.release_year,
			c. country_name
		From title t
	Join genre g
		On t.show_id = g. show_id
	Join rating r
		On t.show_id = r. show_id 
	Join country c
		On t.show_id = c.show_id
		Order by
		t.title;

----Q41----Rank countries by total content, showing cumulative count		
Select 
	c. country_name,
		Count(distinct t.show_id) as total_content,
	RANK () over (order by Count(distinct t.show_id)DESC) as rank_,
	SUM(Count(distinct t.show_id)) over (order by Count(distinct t.show_id) DESC) as comulative_count
From country c
			Join title t
		On c.show_id = t. show_id 
		Group by c.country_name
			order by total_content DESC;

---- using with subqueries 
with country_content as(
			select 
			c. country_name,	
		COunt(distinct t.show_id) as totaL_content
	From country c
			Join title t
		On c.show_id = t. show_id 
		Group by c.country_name
)
		Select 
			country_name,
			totaL_content,
		Rank() over (order by total_content desc) as country_rank,
		Sum(total_content) over (order by total_content desc) comulative_rank
		From country_content
		Order by total_content DESC;

-----Q42---- Find directors who have content in multiple countries
		Select t.director,
			Count(distinct TRIM (country)) as total_country
			From title t
				Join country c
			On t.show_id = c. show_id  
			CROSS JOin Lateral Unnest (STRING_TO_ARRAY(c.country_name, ',')) as country
			where director is not null
			group by t. director
			Having Count(distinct TRim (country)) >= 2
		Order by total_country DESC;

----Q43-- Year-over-year growth in content additions		
With yearly_count as (
				Select 
				Extract (year from added_date) as added_year,
				Count(*) as total_titles
				From title 
			where added_date is not null
			Group by 
			Extract (year from added_date)

)	Select 
	added_year,
	total_titles ,
	Lag(total_titles) over ( order by added_year ) as previous_added_year,
	total_titles - Lag(total_titles) over ( order by added_year ) as growth_count
	From yearly_count
	Order by added_year;
	
----- Q44---Find the most common genre combination (titles with multiple genres)
with common_genre as (
		Select t.show_id,
			t.title,
Trim(g.genre) as genre_
		From title t
		Join genre g
	On t.show_id = g. show_id,
Lateral Unnest(String_To_Array(g.genre,',')) as common_genre
)
		Select
			show_id,
			title,
			Count(Distinct genre_) as total_genres
			From common_genre
		Group by show_id,title
	Order by total_genres DESC;


-----Q45----Create a content diversity score by country
		Select c.country_name,
		Count(Distinct g.genre ) as uniques_genre,
		Count(Distinct t.show_id) as total_content 
		From country c 
			Join title t
		On c.show_id = t. show_id 
		Join genre g
			On c.show_id = g. show_id 
		Group by c.country_name
Order by uniques_genre DESC;


-------------- Finish Here-------
---- I took some help from Claude--------
