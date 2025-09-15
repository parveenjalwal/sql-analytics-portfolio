create database spotify_bucket ; 

use spotify_bucket ; 


-- create table

DROP TABLE IF EXISTS spotify;   
CREATE TABLE spotify (
    ID int not null ,
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed varchar(10),
    official_video  varchar(10), 
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);  

select * from spotify ; 

-- inserting data >> 

SET GLOBAL local_infile = 1; 

SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'D:/SQL practise set/My Sql projects/spotify project data/cleaned_dataset.csv'
INTO TABLE spotify
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

select count(*) as total_data 
from spotify ;  

select * from spotify ; 


#1. Data Exploration
# Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:

# Artist: The performer of the track.
# Track: The name of the song.
# Album: The album to which the track belongs.
# Album_type: The type of album (e.g., single or album).
# Various metrics such as danceability, energy, loudness, tempo, and more. 



# solving problems or finding insights : 
-- 1. Retrieve the names of all tracks that have more than 1 billion streams ? 

select * 
from spotify 
where stream > 1000000000 ; 


-- 2. List all albums along with their respective artists.

select album , artist 
from spotify ; 


-- 3. Get the total number of comments for tracks where licensed = TRUE.

select licensed ,
count(*) as totals  
from spotify 
group by licensed 
having licensed = "TRUE" ; 


-- 4. Find all tracks that belong to the album type single.

select * 
from spotify 
where album_type = "single" ; 


-- 5. Count the total number of tracks by each artist.

select artist , 
count(track) as total_track 
from spotify 
group by artist 
order by count(track) ;  


# 2nd part qustions >> 

-- 6 . Calculate the average danceability of tracks in each album.

select  album , 
round(avg(danceability),4) as avg_densiblity 
from spotify 
group by album ; 


-- 7. Find the top 5 tracks with the highest energy values.

select track ,
round(sum(energy),4) as energy_values 
from spotify 
group by track 
order by round(sum(energy),4) desc 
limit 5 ;  


-- 8.  List all tracks along with their views and likes where official_video = TRUE.

select track , views , likes , official_video
from spotify 
where official_video = "TRUE" ; 


-- 9. For each album, calculate the total views of all associated tracks.  

select album , 
sum(views) as total_views
from spotify 
group by album ;  


-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube. 
 
-- note here why i use like along with "% %" becuse normal = sign opratoer was not working even any cell in column does not have values then youtube and spotify 
-- so look into my qurry from this perspective 
with track_spot as
(select track , 
count(track) as total_Spotify_playtime 
from spotify s 
where most_played_on like '%Spotify%' 
group by track ) , 
track_yt as 
( select track , 
count(track) as total_yt_playtime 
from spotify s 
where most_played_on like '%Youtube%' 
group by track ) 

select ts.track , total_Spotify_playtime  , total_yt_playtime  
from track_spot ts 
join track_yt ty 
on ts.track = ty.track 
where total_Spotify_playtime  > total_yt_playtime   ; 



# 3rd part >> 

-- 11 . Find the top 3 most-viewed tracks for each artist using window functions. 

select * 
from 
( select artist , track , views , 
dense_rank() over (partition by artist order by views desc) as artist_track_view_Rank 
from spotify ) art_tracks
where artist_track_view_Rank <= 3 ; 


-- 12. Write a query to find tracks where the liveness score is above the average. 


with track_liveness as 
( select track ,
sum(liveness) as liveness_score 
from spotify 
group by track 
having liveness_score  > (select avg(liveness) from spotify ) ) 

select track ,
round(liveness_Score,4) as liveness_score -- in order to remove some extra zero , making numircal more readble  
from 
track_liveness ;  


-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album. 

with alb_enrgy_levels as
(select album , 
min(energy) as album_min_energy ,
max(energy) as album_max_energy 
from spotify 
group by album ) 

select  album ,
round((album_max_energy -  album_min_energy),4) as energy_max_min_diff 
from alb_enrgy_levels ;  



# created by parveen jalwal 
# contect via : parveenjalwal8@gmail.com  
# thanks for being here >>> 


 