create database netflix_store ; 

use netflix_store ;
 

# this is our project 4 which is about netflix 
# 1. loadding and reviwing dataset : 

select * from netflix_titles ; 
-- changing dataset name  in order to write qurry qucikly further :: 
alter table netflix_titles rename to netflix ; 
-- updated view : 
select * from netflix ; 



# Objectives
-- Analyze the distribution of content types (movies vs TV shows).
-- Identify the most common ratings for movies and TV shows.
-- List and analyze content based on release years, countries, and durations.
-- Explore and categorize content based on specific criteria and keywords. 


# Business Problems and Solutions 

# qustion 1 :  Count the Number of Movies vs TV Shows
 
 select count(*) as total_Show -- total all type of content 
from netflix ;  

select count(*) as tv_show -- total tv show 
from netflix 
where type = "TV Show"; 

select count(*) as total_movie -- total movie 
from netflix 
where type = "Movie" ; 


# qustion 2. Find the Most Common Rating for Movies and TV Shows

select * from netflix ; 
with shows_rating as
( select  -- aproach one total of rach rating for both tv and movies sepratly 
type , rating , 
count(*) as total_Rating 
from netflix 
group by type , rating  
order by  type , total_Rating desc ) ,
shows_rating_Ranks as
(select type , rating , total_rating ,
dense_rank() over (partition by type order by total_rating desc ) as rating_rank_showise
from shows_rating ) 

select * from 
shows_rating_Ranks
where rating_rank_showise = 1 ;


# qustion 3. List All Movies Released in a Specific Year (e.g., 2020)

select * from netflix 
where release_year = 2021 ;



# qustion 4 : Find the Top 5 Countries with the Most Content on Netflix 

select country , 
count(*) as total_movies_shows 
from netflix 
where country != "" -- remoing empty cells from country 
group by country  
order by total_movies_shows  desc 
limit 5 ;  


# qustion 5 :  dentify the Longest Movie 
 
select * , 
round(substring_index(duration," ",1) / 60,2)as durtion_hour
from netflix 
where type = "movie" 
and round(substring_index(duration," ",1) / 60,2) = (select max(round(substring_index(duration," ",1) / 60,2)) as longest_movie 
from netflix 
where type = "movie" ) ; 


# qustion 6 : 6. Find Content Added in the Last 5 Years 
select * 
from 
(select * , 
extract(year from current_timestamp()) as current_year , -- current year 
right(date_added,4) as years -- it access the year from each cells of data added ,
from netflix ) as tt 
where years >= (current_year - 5);  


# qustion  7. Find All Movies/TV Shows by Director 'Rajiv Chilaka' 

select * 
from netflix 
where director = 'Rajiv Chilaka'  ; 


# qustion 8 : List All TV Shows with More Than 5 Seasons

select * , 
substring_index(duration," ",1) as duration_season -- in order to get proper numrical values for seasons from duration column 
from netflix 
where type = "TV Show" and 
 substring_index(duration," ",1) > 5 ; 
 
 
# qustion 9 . Count the Number of Content Items in Each Genre 


WITH RECURSIVE genre_split AS (
    SELECT show_id,
           TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
           SUBSTRING(listed_in, LENGTH(SUBSTRING_INDEX(listed_in, ',', 1)) + 2) AS rest
    FROM netflix
    UNION ALL
    SELECT show_id,
           TRIM(SUBSTRING_INDEX(rest, ',', 1)),
           SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM genre_split
    WHERE rest <> ''
)
SELECT genre, COUNT(*) AS total_items
FROM genre_split
WHERE genre IS NOT NULL AND genre <> ''
GROUP BY genre
ORDER BY total_items DESC; 
  


# qustion 10 : Find each year and the average numbers of content release in India on netflix.

with year_content as 
(select release_year , 
count(title) as total_Content 
from netflix 
where country = "india" 
group by release_year ) 

select * , 
round(avg(total_content) over (),2) as avg_content 
from year_content ;  


# qustion 11. List All Movies that are Documentaries
 
 select * from 
 netflix 
 where type = "movie"
 and listed_in like "%Documentaries" ;  
 
 # qustion 12.  Find All Content Without a Director
 
 select * 
 from netflix 
 where director is null or director = "" ; 
 
 
 # qustion  13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years 
 
 select count(*) as total_movies 
 from netflix 
 where cast like "%Salman khan %" or 
 director like "%Salman khan%" and 
release_year >= (extract(year from current_timestamp()) - 10) ; 
 

#qustion 14 : Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
-- instead of actor which is not parsent , we are looking for director and then 10 director 
select director , 
count(*) as total_movies 
from netflix 
where country = "india" and 
director != "" 
group by director 
order by total_movies 
limit 10 ; -- top 10  


# qustion 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords ... 

with content_type as 
(select  *,
case 
when description like  "%kill%"  or description like "%violence%"  then "bad"
else "good" 
end as content_catoegry 
from netflix ) 

select content_catoegry , 
count(*) as total_content_amount 
from content_type 
group by content_catoegry ;  


# created by parveen jalwal 
# contect via : parveenjalwal8@gmail.com 
# thanks for being here >>> 

