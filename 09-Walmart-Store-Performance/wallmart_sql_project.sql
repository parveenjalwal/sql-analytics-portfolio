create database wallmart_database ; 

use wallmart_database ; 

-- now loading and reviewing dataset : 

select * from walwallmart ; 
-- changing dataset names for each qurrying and reading >> 
alter table walwallmart  rename to wallmart ; 
select * from wallmart ; 

#1. **Data Wrangling:** This is the first step where inspection of data is done to make sure **NULL** values and 
# missing values are detected and data replacement methods are used to replace, missing or **NULL** values.

#> 1. Build a database
#> 2. Create table and insert the data.
#> 3. Select columns with null values in them. There are no null values in our database as in creating the tables, we set **NOT NULL** for each field, 
#     hence null values are filtered out.


#2. **Feature Engineering:** This will help use generate some new columns from existing ones. 

#> 1. Add a new column named `time_of_day` to give insight of sales in the Morning, Afternoon and Evening. 
#     This will help answer the question on which part of the day most sales are made.

alter table wallmart add column daytime varchar(15) ; 

update wallmart 
set daytime = case
when hour(Time) >= 17 then "evening" 
when hour(Time) > 8 then "afternoon" 
else "morning"
end ; 


#> 2. Add a new column named `day_name` that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). 
#     This will help answer the question on which week of the day each branch is busiest. 

alter table wallmart add column day_name varchar(15) ; 

update wallmart 
set day_name = dayname(date) ; 


#> 3. Add a new column named `month_name` that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). 
#     Help determine which month of the year has the most sales and profit.

alter table wallmart add column month_name varchar(20) ; 

update wallmart 
set month_name = monthname(date) ; 


#2. **Exploratory Data Analysis (EDA):** Exploratory data analysis is done to answer the listed questions and aims of this project.
#3. **Conclusion:**

select * from wallmart ; 



# Business Questions To Answer 
## Genric qustion >> 

-- 1. How many unique cities does the data have? 

select count(distinct City) as total_city 
from wallmart ;

-- 2. In which city is each branch? 
 
select   city , 
count(distinct branch ) as all_branch 
from wallmart
group by city  
having all_branch = (select count(distinct branch ) from wallmart) ;  
 


#Product
-- 1. How many unique product lines does the data have?

select count(distinct `Product line`) as product_lines 
from wallmart ; 


-- 2 . What is the most common payment method? 

select Payment as most_commen_pay_method 
from wallmart
group by Payment 
order by count(`Invoice ID`) desc 
limit 1 ; 

-- 3. What is the most selling product line? 

select `Product line` ,
sum(Quantity) as total_sold 
from wallmart 
group by `Product line` 
order by total_sold  desc 
limit 1 ; 


-- 4. What is the total revenue by month? 

select month_name , 
round(sum(total),2) as total_revenue 
from wallmart 
group by month_name ; 


-- 5. What month had the largest COGS? 

select month_name , 
round(sum(cogs),2) as total_cogs 
from wallmart 
group by month_name 
order by total_cogs desc 
limit 1 ; 


-- 6. What product line had the largest revenue? 

select `Product line` ,
round(sum(total),2) as total_revenue 
from wallmart 
group by `Product line` 
order by  total_revenue  desc 
limit 1 ; 


-- 7. What is the city with the largest revenue? 

select city , 
round(sum(total),2) as total_revenue 
from wallmart 
group by city 
order by total_revenue desc 
limit 1 ; 


-- 8. What product line had the largest VAT? 

select `Product line` , 
round(sum(`Tax 5%`),2) as total_vat
from wallmart 
group by `Product line` 
order by total_vat desc 
limit 1 ;  


-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

with products_sales as 
( select `Product line` , 
total , 
(select round(avg(total),2) from wallmart ) as avg_sales
from wallmart ) 

select * ,
case 
when total > avg_sales then "Good"
else "bad" 
end as sales_status 
 from  products_sales ; 
 
 
-- 10. Which branch sold more products than average product sold? 

select Branch , 
avg(Quantity) as avg_sold
from wallmart 
group by Branch 
having avg_sold > (
select avg(Quantity) from wallmart ) ;   


-- 11. What is the most common product line by gender? 

with pd_gender_data as
(select Gender , `Product line` , 
count(`Invoice ID`) as total_count 
from wallmart 
group by Gender , `Product line` 
order by Gender ) ,

 pd_data as 
(select * , 
rank() over (partition by Gender order by total_count desc) as genderwise_pd_rank 
from pd_gender_data ) 

select * 
from pd_data 
where genderwise_pd_rank  = 1 ; 


-- 12. What is the average rating of each product line? 

select `Product line` , 
round(avg(rating),4) as avg_rating 
from wallmart 
group by `Product line` ;  



# part 2 : Sales

-- 1. Number of sales made in each time of the day per weekday

select * from wallmart ; 

select day_name , daytime , 
count(`Invoice ID`) as total_sales 
from wallmart 
group by day_name , daytime 
order by day_name ;   


-- 2 . Which of the customer types brings the most revenue? 

select `customer type` ,
round(sum(total),2) as total_revenue 
from wallmart 
group by `customer type` 
order by total_revenue desc 
limit 1 ; 


-- adding a new column which has vat which gives total tax vlaues from total revenue 
alter table  wallmart add column Vat int ;  

update wallmart 
set Vat = cogs * 0.05 ;

set SQL_SAFE_UPDATES = 0 ;

select * from wallmart ; 



-- 3. Which city has the largest tax percent/ VAT (Value Added Tax ) ? 

select city , 
sum(Vat) as total_Vat 
from wallmart 
group by city 
order by total_Vat  
limit 1 ;


-- 4. Which customer type pays the most in VAT? 

select `customer type` , 
sum(Vat) as total_paid_vat
from wallmart 
group by `customer type` 
order by total_paid_vat desc 
limit 1 ; 



# Part C : Customers 

-- 1. How many unique customer types does the data have ? 

select count(distinct `customer type`) as total_cust 
from wallmart ; 


-- 2. How many unique payment methods does the data have? 

select count(distinct payment) as unq_pay_method 
from wallmart ; 


-- 3. What is the most common customer type? 

select `customer type` , 
count(*) as total_count 
from wallmart 
group by `customer type` 
order by total_count desc  
limit 1 ; 


-- 4. Which customer type buys the most?

select `customer type` ,  
round(sum(total),2) as total_bought_revenue -- here i am doing sum over revneue in order to see there buying power 
from wallmart 
group by `customer type` ; 



-- 5.  What is the gender of most of the customers? 

select Gender , 
count(Gender) as total_customer 
from wallmart 
group by Gender 
order by total_customer  desc 
limit 1; 


-- 6. What is the gender distribution per branch? 

select branch , gender , 
count(gender) as total_cust 
from wallmart 
group by  branch , gender 
order by branch ; 

-- 7. Which time of the day do customers give most ratings? 

select daytime , 
round(sum(rating),1) as rating 
from wallmart 
group by  daytime 
order by rating desc 
limit 1 ;  

-- 8. Which time of the day do customers give most ratings per branch?  

with branch_rat as 
(select Branch , daytime ,
round(sum(rating),1)  as rating , 
rank() over (partition by Branch order by round(sum(rating),1) desc ) as brach_time_Rating_Rank 
from wallmart 
group by Branch , daytime ) 

select * from branch_rat 
where brach_time_Rating_Rank = 1 ; 


-- 9 . Which day fo the week has the best avg ratings? 

select day_name , 
round(avg(rating),2) as avg_rating 
from wallmart 
group by day_name 
order by avg_rating desc  
limit 1 ; 


-- 10 . Which day of the week has the best average ratings per branch ? 

with daywise_avg_rat as 
(select Branch , day_name , 
round(avg(rating),2) as avg_rating , 
rank() over (partition by Branch order by round(avg(rating),2) desc ) as branch_day_rank 
from wallmart 
group by Branch , day_name  
order by Branch ) 

select * 
from  daywise_avg_rat 
where branch_day_rank = 1 ; 
 
# created by parveen jalwal 
# contect via : parveenjalwal8@gmail.com  
# thanks for being here >>>      








