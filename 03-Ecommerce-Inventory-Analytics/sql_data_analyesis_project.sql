create database zepto_v2 ; 

use zepto_v2 ; 

select * from zepto ; 

-- this is out zepto porject 
-- task overview : 

#  1. Data Exploration : 

-- Counted the total number of records in the dataset
select count(*) from zepto ; 

-- Viewed a sample of the dataset to understand structure and content 
-- reading first twenty rows of all cols 
select *
from zepto 
limit 20 ;   


-- Checked for null values across all columns 
select * 
from zepto 
where category is null 
or name is null 
or mrp is null 
or discountPercent is  null 
or availableQuantity is null 
or discountedSellingPrice is null 
or weightInGms is null 
or outOfStock is null 
or quantity is null ;   


-- Identified distinct product categories available in the dataset
select distinct category as unique_category
from zepto ; 

-- Compared in-stock vs out-of-stock product counts 
select outOfStock , count(*) as total_stock_Count 
from zepto 
group by outOfStock ; 

-- Detected products present multiple times, representing different SKUs 
-- a. products who is persent more then once twice in data 
select name 
 from zepto 
 group by name 
 having count(*) > 1 ; 
 
-- B. repersenting all unique projects 
select distinct name 
from zepto ; 


#  2. Data Cleaning

-- 1. Identified and removed rows where MRP or discounted selling price was zero 

delete from zepto 
where mrp = 0 and discountedSellingPrice = 0 ; 
 
-- 2. Converted mrp and discountedSellingPrice from paise to rupees for consistency and readability 

alter table zepto  add column upd_mrp int ; 
alter table zepto  add column upd_disprice int ; 

UPDATE zepto 
SET 
    upd_mrp = ROUND((mrp / 100), 0),
    upd_disprice = ROUND((discountedSellingPrice / 100), 0) ; 



#  3. Business Insights
-- 1 . Found top 10 best-value products based on discount percentage 

select * from zepto 
order by discountPercent desc 
limit 10 ; 

-- 2. Identified high-MRP products that are currently out of stock 

select category , mrp , discountPercent , outOFstock 
from zepto 
where  outOFstock = "TRUE" 
order by  mrp desc 
limit 20 ; -- top 20 product where mrp is higher and who is out of stock ; 


-- 3. Estimated potential revenue for each product category 

select Category , 
round(sum((upd_mrp - ( upd_mrp * (discountPercent / 100))) *  quantity ),2) as Estimated_potential_revenue
from zepto 
group by Category ; 

-- 4. Filtered expensive products (MRP > ₹500) with minimal discount 

select * from zepto 
where mrp > 500 
and discountPercent = ( 
select min(discountPercent) 
from zepto 
where mrp > 500 ) ; 


-- 5.  Ranked top 5 categories offering highest average discounts 

with cat_avg as -- cte 
(select Category , 
round(avg(discountPercent),2) as avg_dis 
from zepto 
group by Category ) ,
ranked_cat as -- nested cte 
( select row_number() over (order by avg_dis desc) as category_rank , -- in order to parvent repitation 
Category, avg_dis
from cat_avg ) 

select * from ranked_cat 
where category_rank <= 5 ; 


-- 6.  Calculated price per gram to identify value-for-money products 

select category , name , weightInGms ,
(upd_mrp / weightInGms ) as price_per_gram 
from zepto ;   

-- 7. Grouped products based on weight into Low, Medium, and Bulk categories 
-- A  apporach one 

with wgt_cat as 
(select * ,  -- main cte ( spliting them into 3 parts ) using ntile 
Ntile(3) over (order by  weightInGms) as weight_category 
from zepto ) , 
wgt_labels as 
(select * , -- nested cte who give each ntile vlaue lable 
case 
when weight_category  = 3 then "Bulk"
when weight_category  = 2 then "Medium"
else "Small" 
end weight_cat 
from wgt_cat ) 

-- main qurry finding all min / max and total into each wight category 
select weight_cat  , min(weightInGms) as min_w  , 
max( weightInGms) as max_w , 
count(*) as total_products 
from wgt_labels
group by  weight_cat  ;  

-- B . approach two 
with wgt_cat_labled as 
(select * ,
case 
when weightInGms < 500  then "Small" 
when weightInGms between 500 and  2000 then "Medium" 
else "Bulk" 
end as wgt_cat 
from zepto ) 

select wgt_cat , 
min(weightInGms) as min_w  , 
max( weightInGms) as max_w , 
count(*) as total_products 
from wgt_cat_labled 
group by wgt_cat 
order by wgt_cat desc ;  


-- Measured total inventory weight per product category 

select Category , 
sum(weightInGms) as total_weight 
from zepto 
group by Category ;   


# creator : parveen 
# contect for any suggestion : parveenjalwal8@gmail.com . 
# Thanks for being here 

