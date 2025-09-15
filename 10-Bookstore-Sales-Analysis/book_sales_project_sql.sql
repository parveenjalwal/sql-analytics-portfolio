create database project_10th ; 

use project_10th ; 


-- now loading and overviewing all datasets >> 
-- its has three datasets which includes books , orders , customers : 

select * from books ; 
select * from customers ; 
select * from orders ;   


# part 1 : It inclues basic qustion >> 


-- 1) Retrieve all books in the "Fiction" genre:
select * from 
books 
where Genre = "Fiction" ; 


-- 2) Find books published after the year 1950: 

select * 
from books 
where Published_year > 1950 ; 


-- 3) List all customers from the Canada:

select *
from customers 
where country = "Canada" ;


-- 4) Show orders placed in November 2023: 

select * 
from orders  
where order_Date between "2023-11-01" and "2023-11-31" ; 
-- its access all orders placed in november 2023 


-- 5) Retrieve the total stock of books available:

select sum(Stock) as total_stock 
from books 
where stock >= 0 ; 


-- 6) Find the details of the most expensive book:

select * 
from books 
where price = (select max(price) from books) ;  



-- 7) Show all customers who ordered more than 1 quantity of a book: 

select name , 
sum(quantity) as total_quantity 
from customers cs 
left join orders od 
on cs.customer_id = od.customer_id 
group by name 
having total_quantity  > 1 ;  


-- 8) Retrieve all orders where the total amount exceeds $20:

select * 
from orders 
where total_Amount > 20 ; 


-- 9) List all genres available in the Books table:

select distinct Genre 
from books ; 


-- 10) Find the book with the lowest stock: 

select * 
from books 
where Stock = (select min(Stock) from books where Stock > 0) ; 
-- i am here outlookgs stock 0 becuase these stock can not be considered avilable stock , is my approach right  


-- 11) Calculate the total revenue generated from all orders: 

select 
round(sum(total_amount),2) as total_revenue_genrated 
from  orders ; 





# part B : It contains advance qurries >> 

-- 1) Retrieve the total number of books sold for each genre: 

select   genre , 
sum(quantity) as total_bk_sold -- total quntity 
from books bk  
left join orders od 
on bk.book_id = od.book_id 
where quantity is not null 
group by Genre ;   



-- 2) Find the average price of books in the "Fantasy" genre: 

select 
round(avg(price),2) as avg_price 
from books 
where genre = "Fantasy" ;


-- 3) List customers who have placed at least 2 orders: 

select name , 
count(distinct order_id) as total_orders 
from customers cs 
join orders od 
on cs.customer_id = od.customer_id 
group by name 
having total_orders >= 2 ; 


-- 4) Find the most frequently ordered book: 
 
select * 
from books 
where book_id in 
(select book_id 
from orders 
group by book_id
having count(order_id)   = ( 
select max(total_orders) 
from
(select 
count(order_id) as total_orders 
from orders 
group by book_id ) as total_od ) ) ;   


-- 5) Show the top 3 most expensive books of 'Fantasy' Genre  ; 

select * from 
books 
where Genre = "Fantasy" 
order by price desc 
limit 3 ;  


-- 6) Retrieve the total quantity of books sold by each author: 

select  Author , 
sum(quantity) as total_quantity 
from books bk 
left join orders od 
on bk.book_id = od.book_id  
where quantity is not null   
group by  Author 
order by  total_quantity  desc ;  


-- 7) List the cities where customers who spent over $30 are located: 

select city 
from customers 
where customer_id in 
(select customer_id
from 
( select cs.customer_id ,
round(sum(total_amount),2) as total_spent 
from customers cs 
join orders od 
on cs.customer_id = od.customer_id 
group by cs.customer_id 
having total_spent > 30 ) as cs_tspent ) ;   



-- 8) Find the customer who spent the most on orders:  

select * 
from customers 
where customer_id in (
select customer_id
from  orders 
group by customer_id  
having round(sum(total_Amount),0) = ( 
select max(total_spent) 
from 
(select
round(sum(total_Amount),0) as total_spent 
from  orders 
group by customer_id ) as tt ) ) ; 



-- 9) Calculate the stock remaining after fulfilling all orders:   

with bk_data as 
(select bk.book_id , title , stock ,  
ifnull(total_quantity,0) as total_quantity  
from books bk 
left join  ( select book_id , 
sum(quantity) as total_quantity 
from orders 
group by book_id ) bk_qunt 
on bk.book_id = bk_qunt.book_id ) 

select * , 
case 
when (stock - total_quantity ) = stock then "Not ordered" 
else (stock - total_quantity ) 
end as remining_stock 
from bk_data ; 


# created by parveen jalwal 
# contect via : parveenjalwal8@gmail.com  
# thanks for being here >>>  
