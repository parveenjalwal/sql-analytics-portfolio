create database sql_mentor_user_performence ; 

use sql_mentor_user_performence ; 


# 10th project >> 
# project name : SQL Mentor User Performance Dataset 

# Project Overview ::  This project is designed to help beginners understand SQL querying and performance analysis 
#using real-time data from SQL Mentor datasets. In this project, you will analyze user performance by creating and querying a 
# table of user submissions. The goal is to solve a series of SQL problems to extract meaningful insights from user data.
 
 
# data overview >> 
select * from user_mentor ;  

-- 1. List All Distinct Users and Their Stats >> 

select username , 
count(user_id) as total_submission , 
sum(points) as total_points  
from user_mentor 
group by  username 
order by  count(user_id) desc ;  


-- 2. Calculate the Daily Average Points for Each User : 

select username , 
extract(day from submitted_at) as day1 , 
round(avg(points),2) as avg_points 
from user_mentor 
group by username , day1
order by username ;  

-- 3. Find the Top 3 Users with the Most Correct Submissions for Each Day : 


with user_daywise_points as
(select username , 
date(submitted_at) as submittion_day , 
sum(points) as total_points 
from user_mentor 
group by username , date(submitted_at) 
order by username ) , 
ranked_user as 
( select * , 
dense_rank() over (partition by submittion_day order by total_points) as user_ranks
from user_daywise_points ) 

select * from ranked_user  
where user_ranks <= 3 
order by submittion_day , user_ranks ;  


-- Q4: Find the Top 5 Users with the Highest Number of Incorrect Submissions : 

with user_submissions as
(select username , 
case 
when points > 0 then 1  # 1 repersents correct 
else 0 # 0 repersents incorrect 
end as submission_data 
from user_mentor ) 

select username , 
count(*) as incorrect_submission 
from user_submissions 
where submission_data  = 0 # only filter incorrect submission for each user 
group by username 
order by count(*) desc  # order based on total incorrect  submission 
limit 5 ;

-- 5. Find the Top 10 Performers for Each Week  

with user_weekwise_points as 
(select username , 
week(date(submitted_at)) as week1 ,
sum(points) as total_points 
from user_mentor 
group by username , week1 ) ,
ranked_cust as
(select * , 
dense_Rank() over (partition by week1 order by total_points desc ) as week_points_rank 
from user_weekwise_points ) 

select * from ranked_cust 
where week_points_rank  <= 10 
order by week1 ; 

