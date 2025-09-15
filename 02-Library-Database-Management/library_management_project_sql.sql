create database library_db ; 

use library_db  ;

# Section 1 : 
-- 1. Here we have created 6 tables in order to draw our library managment system : 

select * from books ; 
select * from branch ; 
select * from employees ;
select * from members ; 
select * from return_status ; 
select * from issued_status ; 


-- 2. inserting/updating records into tables 
 
 -- task 2 :  Update an Existing Member's Address
 update members 
 set member_address = "250 main st parveen" 
 where member_name = "john" ; 
 
 -- task 3 : Delete a Record from the Issued Status Table 
 -- Objective: Delete the record with issued_id 
 -- = 'IS121' from the issued_status table. 
 
 delete from issued_status 
 where issued_id = "IS121" ; 
 
 -- task 4. : Retrieve All Books Issued by a Specific Employee 
 -- Objective: Select all books issued by the employee with emp_id = 'E101' : 
 
select * from 
issued_status 
where issued_emp_id = "E101" ;  

-- task 5 : List Members Who Have Issued More Than One Book -- 
-- Objective: Use GROUP BY to find members who have issued more than one book : 

select issued_member_id , 
count(issued_book_name) as total_issued_books 
from issued_status 
group by issued_member_id 
having total_issued_books  > 1 
order by count(issued_book_name) desc ;



# Section 2 : CTAS (Create Table As Select) 

-- task 1 : Create Summary Tables: Used CTAS to generate new tables 
-- based on query results - each book and total book_issued_cnt**
-- CREATE TABLE book_issued_cnt AS ? 

# firslty we have qurry to do it 
select distinct issued_book_name as book ,
(select count(*) 
from issued_status isb1
where isb1.issued_book_isbn = isb.issued_book_isbn 
 ) as total_issued_books 
from issued_status isb  ;  

# now for new table creation : 

create table issued_book_count (
select bk.isbn , bk.book_title , count(issued_id) as total_issued 
from books bk 
join issued_status isb 
on bk.isbn = isb.issued_book_isbn 
group by isbn , bk.book_title ) ;  

select * from  issued_book_count ;
 


# section 3 : Data Analysis & Findings
-- task 1 : Retrieve All Books in a Specific Category : 

select * 
from books 
where category = "Horror" ; 

-- task 2 : Find Total Rental Income by Category:

select category , 
sum(rental_price) as total_rental_pr 
from books 
group by category ; 

-- task 3 : List Members Who Registered in the Last 180 Days : 
 

select  member_name , issued_book_name  , 
datediff(issued_date,reg_date) as days 
from members m 
left join issued_status isb 
on m.member_id = isb.issued_member_id  
where datediff(issued_date,reg_date) <= 800 ; 


-- task 4 : List Employees with Their Branch Manager's Name and their branch details :

select emp_name , manager_id , branch_address 
from employees e 
join branch b 
on  e.branch_id = b.branch_id ;  


-- task 5  Create a Table of Books with Rental Price Above a Certain Threshold:  

create table expensive_books ( 
select book_title , rental_price 
from books 
where  rental_price >= 5 ) ;  

select * from  expensive_books ; 


-- task 6. Retrieve the List of Books Not Yet Returned 

select iss.issued_id , issued_book_name , rs.return_id 
from issued_status iss 
left join return_status rs
on iss.issued_id = rs.issued_id 
where rs.issued_id  is null ;   


-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.


with memb_books as
(select member_id , member_name , issued_book_name , 
datediff(return_Date,issued_date) as total_days_dur 
from members mb
join issued_status iss 
on  mb.member_id = iss.issued_member_id 
join return_status rst 
on iss. issued_id = rst.issued_id ) ,
book_return_Status as
( select * , 
total_days_dur  - 30 as days_overdue 
from memb_books ) 

select * from book_return_Status 
where days_overdue > 30 ;   


-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

update books b 
left join (
select iss.issued_id ,  issued_book_name , issued_book_isbn , return_id , 
if(return_id is null,"no","yes") as return_status 
from issued_status iss 
left join return_status rst 
on iss.issued_id = rst.issued_id ) as upd_books 
on b.isbn = upd_books.issued_book_isbn 
set status = 
case 
when  upd_books.return_status = "no" or status is null then "no" 
else "yes" 
end ;
select * from  books ; -- updated data 

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, 
-- and the total revenue generated from book rentals.

 
  with br_books_info as 
  (select bn.branch_id , emp_id , issued_book_isbn , iss.issued_id , issued_emp_id , isbn , rental_price 
  from branch bn 
  left join employees emp 
  on bn.branch_id = emp.branch_id   
  left join issued_status iss 
  on emp.emp_id = iss.issued_emp_id  
  left join books bk 
  on   iss.issued_book_isbn = bk.isbn ) ,
  br_data as 
  (select branch_id , emp_id , issued_book_isbn , bbi.issued_id , issued_emp_id , isbn , rental_price , return_id  , 
  case when return_id is not null then 1 -- mean returned 
  else 0 -- did not retunred 
  end as return_status 
  from br_books_info bbi 
  left join return_status rst 
  on bbi.issued_id = rst.issued_id )  
  
-- main cte 
select branch_id , 
count(issued_id ) as total_issued , 
sum(rental_price) as  total_revenue , 
sum(return_status) as total_return -- it would only sum 1 mean who were retunred not 0 . therefor only one from each branch will be summed up who refer to returned books 
from br_data 
group by branch_id ; 



-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

-- here instead of last two months we tooks delibratly members under last 1000/30 days for expriment becuase there were no member who did issue 
-- book in last two month , your job is to check logic not numbers and date 
create table member_bk_data ( 
with mem_bk as 
( select member_id , reg_date , issued_id , issued_date , 
datediff(issued_date,reg_date) as book_issued_time  
from members mb 
left join issued_status iss 
on mb.member_id = iss.issued_member_id 
where datediff(issued_date,reg_date) <=  1000 ) 
 
select member_id , 
count(issued_id) as total_book_issued 
from mem_bk 
group by member_id 
having total_book_issued  > 1 )  ;  

select * from member_bk_data ; 


-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.


select branch_id , emp_bks.emp_name , total_issued_bk
from employees ep 
right join 
(select emp_name , 
count(issued_id) as total_issued_bk  
from 
(select  emp_name , issued_id  
from employees emp 
left join 
(select issued_emp_id , issued_id 
from issued_status ) as iss 
on emp.emp_id  = iss.issued_emp_id ) as tt 
group by emp_name 
order by total_issued_bk  desc 
limit 3 ) as emp_bks 
on ep.emp_name = emp_bks.emp_name ; 


select * from members ; 
select * from issued_status ;
select * from books ; 


-- Task 18: Identify Members Issuing  Books from classic category 
-- Write a query to identify members who have issued books from classic in the books table. Display the member name, book title, 
-- and the number of times they've issued classic books. 

select  member_name , issued_book_name , 
count(category) over (partition by member_name) as total_bk_issued
from members mb 
left join issued_status iss 
on mb.member_id = iss.issued_member_id 
left join books bk 
on iss.issued_book_isbn  = bk.isbn  
where bk.category = "classic" ; 


# task 19 :  Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
-- Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
-- The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. 
-- The resulting table should show: Member ID Number of overdue books Total fines 

create table member_overdue_books (
with memb_bk_data as 
(select member_id , iss.issued_id , issued_date , return_id , return_date , 
datediff(return_Date,issued_date) as duration 
from members mb 
left join issued_status iss 
on mb.member_id = iss.issued_member_id 
left join return_status rst 
on iss.issued_id = rst.issued_id ) ,
 memb_due_bk as
( select member_id , issued_id , return_id , -- null means books were never returned 
(duration - 30) as overdue_Days , -- checking duration of delay after 30 days 
((duration - 30) * 0.50) as total_fine , 
case 
when duration >= 30 then "overdue" 
else "On time" 
end as is_book_overdue 
from 
memb_bk_data 
where case 
when duration >= 30 then "overdue" 
else "On time" 
end   = "overdue" ) 

select member_id , 
count(is_book_overdue) as total_overdue_bks , 
count(issued_id) as total_books_issued ,
sum(ifnull(total_fine,0)) as total_fine -- null entry were replaced by 0 
from  memb_due_bk 
group by    member_id ) ; 


select * from member_overdue_books ;   


-- task :

select * from books ; 

with bk_status as
(select isbn , book_title , status , 
case 
when status = "yes" then "has been issued" 
else "book is out of stock" 
end issue_status  
from books ) 

select * , 
case 
when issue_status = "has been issued" then "yes"
else "no" 
end upd_status 
from bk_status ; 

select * from books ;  



DELIMITER $$

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10), 
    IN p_issued_member_id VARCHAR(30), 
    IN p_issued_book_isbn VARCHAR(30), 
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    DECLARE v_status VARCHAR(10);

    -- Check if book is available
    SELECT status 
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        -- Insert issue record
        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        -- Update book status
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        SELECT CONCAT('Book records added successfully for book isbn: ', p_issued_book_isbn) AS message;

    ELSE
        SELECT CONCAT('Sorry, the book is unavailable. ISBN: ', p_issued_book_isbn) AS message;
    END IF;
END$$

DELIMITER ; 


# created by parveen jalwal 
# contect via : parveenjalwal8@gmail.com 
# thanks for being here >>> 


