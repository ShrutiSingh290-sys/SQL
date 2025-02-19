select * from coffee_sales;
use coffee;
-- data cleaning process-- 
-- changing text to date/time( 1st step changing format of date/time then modifying it into date)-- 
set sql_safe_updates=0;
update coffee_sales set transaction_date = str_to_date(transaction_date,'%d-%m-%Y');
desc coffee_sales;

alter table coffee_sales modify column transaction_date date;
update coffee_sales set transaction_time = str_to_date(transaction_time,'%H:%i:%s');
alter table coffee_sales modify column transaction_time time;

select * from coffee_sales;
select * from coffee_sales where transaction_id is  null or transaction_id=' ';
select * from coffee_sales where transaction_id=' ';
select transaction_id, count(*) from coffee_sales group by transaction_id having count(*)>1;

-- KPIs requirement
-- 1.Total sales Analysis
-- calculate the sales for each respective months
-- determine the month on month increases or decreses in the sales
-- calculate the sales difference between the selected month and previous month

select round(sum(unit_price*transaction_qty),0) from coffee_sales;  -- total sales is 698812
select round(sum(unit_price*transaction_qty),0) from coffee_sales where 
month(transaction_date)= 1; -- total sales of jan is 81678

select * from coffee_sales;
-- determine the month on month increases or decreses in the sales-- 
SELECT 
    MONTH(transaction_date) AS month,    -- number of month
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,  -- total sales column
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)    -- month sales difference
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1)   -- divided by prev month sales
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage     -- percentage
FROM 
    coffee_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
-- Total order analysis-- 
-- calculate the order for each respective months
-- determine the month on month increases or decreses in the order
-- calculate the order difference between the selected month and previous month   

select count(transaction_id) as total_order from coffee_sales 
where month( transaction_date )= 3;  -- total order from march

use coffee;
select * from coffee_sales;
select count(transaction_id) as total_order from coffee_sales
where month(transaction_date)= 5;

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) 
FROM 
    coffee_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
-- Total Quantity sold analysis-- 
-- calculate the Quantity sold for each respective months
-- determine the month on month increases or decreses in the quantity sold 
-- calculate the quantity sold difference between the selected month and previous month   
    
select * from coffee_sales;
select sum(transaction_qty) as total_qty from coffee_sales
where month(transaction_date)= 1;  -- total quantity sold

select month(transaction_date) as months, sum(transaction_qty) as qty_sold ,
sum(transaction_qty) - lag(sum(transaction_qty),1) over(order by month(transaction_date)) as qty_sold_diff from coffee_sales
where month(transaction_date) in (3,4)
group by month(transaction_date)
order by month( transaction_date);

  SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
    
-- calender-- 

select * from coffee_sales;
select day(transaction_date) as date, round(sum(transaction_qty*unit_price))as sales,
count(transaction_id) as orders,
sum(transaction_qty) as quantity from coffee_sales 
where transaction_date= '2023-05-18' ; 

select 
   day(transaction_date) as date, 
concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as sales,
concat(round(count(transaction_id)/1000,1),'k') as orders,
concat(round(sum(transaction_qty)/1000,1),'K') as quantity 
from 
  coffee_sales 
where 
 month(transaction_date )= 5
 group by transaction_date;

-- find the reports of weekdays and weekend 
-- this query is for one perticular day

select dayofweek(transaction_date ) as days,
round(sum(transaction_qty* unit_price)) as sales,
count(transaction_id) as orders,
sum(transaction_qty) as quantity from coffee_sales 
where transaction_date= '2023-03-20';  -- weekdays

-- query for complete month weekends and weekdays sales for perticular month 

select 
	case when dayofweek(transaction_date) in (1,7) then 'Weekends'
	else 'weekday' 
	end as day_type,
	concat(round(sum(transaction_qty*unit_price)/1000),'k')  as sales
from 
	coffee_sales 
where 
	month(transaction_date)= 5
group by
	day_type;

-- sales value by store location

select store_location,count(*) from coffee_sales group by store_location;
select store_location,concat(round(sum(transaction_qty*unit_price)/1000,1),'k') as total_sales 
from coffee_sales 
where month(transaction_date)= 5
group by store_location 
order by total_sales desc;

	
-- query for daily sales average line

select concat(round(avg(total_sales)/1000,1),'k')as avg_sales from
 (select round(sum(transaction_qty*unit_price),1)as total_sales
 from 
	coffee_sales
where
	month(transaction_date)= 6
group by
	transaction_date) as result; 

-- daily sales for perticular month selected
select
	round(sum(transaction_qty*unit_price)) as sales 
from
		coffee_sales
where
	month(transaction_date)=5
group by
	transaction_date;
    
select day(transaction_date) as days,
	round(sum(transaction_qty*unit_price)) as sales 
from
		coffee_sales
where
	month(transaction_date)=5
group by
	transaction_date;
  
--   write a query to check daily sales day wise are above or below of daily avg sales

