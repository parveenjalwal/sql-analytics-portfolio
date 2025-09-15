create database coffee ; 

use coffee ; 

-- mapping all tables data set for pre understending 

select * from city ;
select * from customers ;
select * from products ; 
select * from sales ; 

# Objective : The goal of this project is to analyze the sales data of Monday Coffee, a company that has been selling its products online since January 2023, 
-- and to recommend the top three major cities in India for opening new coffee shop locations based on consumer demand and sales performance.


# key qustion 

# qustion 1. Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does ? 

select city_name , 
population , 
(population * 0.25) as est_consumer  -- 25 % of popultion in each city 
from city ; 

# qustion 2. Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023? 

with city_revnues as 
( select city_name , customer_name  , total  
from city ct 
left join customers cs 
on ct.city_id = cs.city_id 
left join sales s 
on cs.customer_id = s.customer_id 
where month(sale_date) between 10 and 12
and year(sale_date) = "2023" ) 


select sum(total) as total_revenue 
 from city_revnues ;  -- all across all cities in last quarter of 2023 
 
 
# qustion 3 :  Sales Count for Each Product > How many units of each coffee product have been sold?

 
 select p.product_id , 
 count(sale_id) as total_sold 
 from products p 
 left join sales s 
 on p.product_id  = s.product_id  
 group by p.product_id ;  
 
 
 # qustion 4 : Average Sales Amount per City
-- What is the average sales amount per customer in each city? 

select city_name , 
round(avg(sale_amount),2) as avg_city_amount -- ( here this price is mentioned in front of each product , there is not another specific price is given ) 
from 
(select  city_name , cs.customer_id , 
sum(price)as sale_amount 
from sales s 
right join products pr 
on s.product_id = pr.product_id 
right join customers cs 
on s.customer_id = cs.customer_id 
right join city ct 
on cs.city_id = ct.city_id 
group by city_name ,cs.customer_id ) as city_sales 
group by city_name ; 

# qustion 5 : City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.


select city_name , population , estimated_rent , 
round((population * 0.10),0) as estimated_consumer 
from city ;  

# 6. Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume? 

select * 
from 
(select city_name , total as total_volume , product_id , 
row_number() over (partition by city_name  order by total)  as city_pd_rank 
from city ct  
left join customers cs 
on ct.city_id = cs.city_id 
left join sales ss
on cs.customer_id  = ss.customer_id ) as ct_pds 
where city_pd_Rank <= 3 ;  


# 7. qustion >>  Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products? 

select city_name ,  
count(distinct customer_name) as total_unq_cust 
from city ct 
left join customers cs 
on ct.city_id = cs.city_id 
right join sales ss -- in order to make sure only cust who made purhcases 
on cs.customer_id = ss.customer_id 
group by city_name ;   


# qustion 8. Market Potential Analysis
# Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

with city_Data as 
(select ct.city_id , 
count(cs.customer_id) as total_customer ,  
sum(total) as total_sales 
from city ct 
left join customers cs 
on ct.city_id = cs.city_id 
left join sales ss 
on cs.customer_id = ss.customer_id 
group by city_id ) 
-- estimated rent is persent once for each city in city table therefor i joind city again with above grouped data to get estimed rent 
select  city_name , estimated_rent , total_customer ,  total_sales 
from city ct 
left join city_Data ctd 
on ct.city_id = ctd.city_id ;  

 


