create database  pizza_store ; 
use pizza_store ;  

-- here we are laoding dataset for project >> 

-- creating table for orders explicitly 

create table orders ( 
order_id int primary key , 
od_date date , 
od_time time ) ; 

select * from orders ;  

SET GLOBAL local_infile = 1; 
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'D:/SQL practise set/My Sql projects/pizza_sales project 8/orders.csv'
INTO TABLE orders 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 



-- taking overview of whole data or reading that data >> 

select * from pizzas ; 
select * from pizza_types ;
select * from orders ; 
select * from order_details ; 


# FROM HERE OUR INSIGHT HUNT BEGAINS >> 

# Part 1 : 
-- 1. Retrieve the total number of orders placed. 

select count(*) as total_orders 
from orders ; 

-- 2. Calculate the total revenue generated from pizza sales.  

select 
round(sum((price * quantity)),3) as total_revenue 
from pizzas pz 
join order_details od 
on pz.pizza_id = od.pizza_id ;  


-- 3. Identify the highest-priced pizza.

select pizza_id 
from pizzas 
order by price desc 
limit 1 ;  


-- 4. Identify the most common pizza size ordered.

select  size , 
count(order_id) as total_ordered 
from pizzas pz 
join order_details od 
on pz.pizza_id = od.pizza_id 
group by size 
order by total_ordered desc 
limit 1 ; 


-- 5. List the top 5 most ordered pizza types along with their quantities. 

select  pizza_type_id , 
count(order_id) as total_orders  ,
sum(quantity) as total_quntity
from pizzas pz 
join order_details od 
on pz.pizza_id = od.pizza_id 
group by   pizza_type_id 
order by  total_quntity  desc 
limit 5 ; 



# PART TWO >> more valueble insights : 

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.


select  category , 
sum(quantity) as total_quntity_sold 
from pizzas pz 
left join pizza_types pzt 
on pz.pizza_type_id = pzt.pizza_type_id 
left join order_details od 
on pz.pizza_id = od.pizza_id 
group by category ; 
 

-- 7. Determine the distribution of orders by hour of the day. 

with day_hour_data as 
( select 
hour(od_time) as hour1 , 
count(order_id) as total_order_h_day 
from orders 
group by hour(od_time) 
order by hour1 ) ,

hour_total_od as 
(select  hour1 ,
total_order_h_Day , 
(select count(order_id) from orders ) as total_ord 
from day_hour_data ) 

select * , 
round(total_order_h_Day / total_ord * 100,2) as order_hour_distribution
from hour_total_od ;  


-- 8. Join relevant tables to find the category-wise distribution of pizzas. 

with ctg_orders as 
(select category ,
count(order_id)  cat_total_orders , 
(select count(order_id) from order_details) as total_orders -- new subqurry in order to get total pizza orders all accross data
from pizzas pz 
left join pizza_types pzt 
on pz.pizza_type_id = pzt.pizza_type_id  
left join order_details od 
on pz.pizza_id = od.pizza_id 
group by category  ) 

select * ,
(cat_total_orders / total_orders) * 100 as cat_pizza_distribution 
from  ctg_orders ;  


-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

select day(od_date) , 
avg(quantity) as avg_pizza_ordered 
from orders o
left join order_details od 
on o.order_id = od.order_id 
group by day(od_date) ;  


-- 10.  Determine the top 3 most ordered pizza types based on revenue. 

select  pizza_type_id , 
count(order_id) as total_orders ,
sum((price * quantity)) as revenue 
from pizzas pz 
left join order_details od 
on pz.pizza_id = od.pizza_id
group by  pizza_type_id 
order by revenue desc 
limit 3 ; -- most ordered based on revenue   




# part 3 : 

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

with pz_revenue as 
( select  pizza_type_id , 
sum((price * quantity)) as revenue , 
(select round(sum(price * quantity),2)  -- subqurry in select in order to get total revnue of all orders for finding contribution 
from pizzas pz 
left join order_details od 
on pz.pizza_id = od.pizza_id ) as total_revenue 
from pizzas pz 
left join order_details od 
on pz.pizza_id = od.pizza_id 
group by pizza_type_id ) 

select pizza_type_id , 
revenue , total_revenue  ,
round((revenue / total_revenue ) * 100,2) as pizza_type_contribution 
 from pz_revenue ;    
 
 
 -- 13 . Determine the top 3 most ordered pizza types based on revenue for each pizza category. 

with ctg_revenue as 
(select  category , pz.pizza_type_id as pizza_types ,
round(sum((price * quantity)),2) as revenue 
from pizzas pz 
join pizza_types pzt 
on pz.pizza_type_id = pzt.pizza_type_id 
join order_details od
on pz.pizza_id = od.pizza_id 
group by  category , pz.pizza_type_id   
order by  category ) ,
ctg_ranks as
( select * , 
dense_rank() over (partition by category order by revenue desc) as ctg_types_Rank 
from ctg_revenue ) 

select * from ctg_ranks 
where ctg_types_Rank <= 3 ; 


-- 14.  Analyze the cumulative revenue generated over time. 

with date_rev as
(select od_date , 
round(sum((price * quantity)),2) as revenue 
from pizzas pz 
join order_details od 
on pz.pizza_id = od.pizza_id 
join orders od1 
on od.order_id = od1.order_id  
group by od_date ) 

select * , 
round(sum(revenue) over (order by od_date),2) as comulative_revenue 
from date_rev ;  



# created by parveen jalwal 
# contect via : parveenjalwal8@gmail.com  
# thanks for being here >>>    





 
  


