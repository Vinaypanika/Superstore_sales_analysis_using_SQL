--                         Basic And Intermediate Questions

-- Que-1. What are total sales and total profits of each year?

select year(orderdate) as year,round(sum(sales),2) as Total_sales,
round(sum(profit),2) as Total_profit from dbo.superstore
group by year(orderdate)
order by year(orderdate) asc;



-- Que-2. What are the total profits and total sales per quarter?
select datepart(year,orderdate) as year,
datepart(quarter,orderdate) as quarter,
round(sum(sales),2) as Total_sales,
round(sum(profit),2) as total_profit
from superstore
group by datepart(year,orderdate),datepart(quarter,orderdate)
order by datepart(year,orderdate),datepart(quarter,orderdate);


-- Que-3. What region generates the highest sales and profits ?

select region,sum(sales) as Total_sales,sum(profit) as Total_profit
from superstore
group by region
order by sum(sales) desc, sum(profit) desc;

--Que-4. What state  brings in the highest sales and profits ?

select state,sum(sales) as Total_sales,sum(profit) as Total_profit
from superstore
group by state
order by sum(sales) desc, sum(profit) desc;

--Que-5. What city  brings in the highest sales and profits ?

select city,sum(sales) as Total_sales,sum(profit) as Total_profit
from superstore
group by city
order by sum(sales) desc, sum(profit) desc;

-- Que-6.Find the Most discounted Categories;

select category,sum(discount) as Total_discount
from superstore
group by category
order by sum(discount) desc;


-- Que-7.Find the Most discounted SubCategories;
select category,subcategory,sum(discount) as Total_discount
from superstore
group by subcategory,category
order by sum(discount) desc;

-- Que-8. What category generates the highest sales and profits in each region and state ?

select category,region,state,sum(sales) as Total_sales,sum(profit) as Total_profit
from superstore
group by region,state,Category
order by sum(profit) desc,sum(sales) desc;

-- Que-9 What subcategory generates the highest sales and profits in each region and state ?
select subcategory,region,state,sum(sales) as Total_sales,sum(profit) as Total_profit
from superstore
group by region,state,subCategory
order by sum(profit) desc,sum(sales) desc;

-- Que-10 What are the names of the products that are the most and least profitable to us?
-- most profitable
select top 1 productname,sum(profit) as Total_profit
from superstore
group by productname
order by sum(profit) desc;

-- least profitable
select top 1 productname,sum(profit) as Total_profit
from superstore
group by productname
order by sum(profit) asc;

-- Que-11. What segment makes the most of our profits and sales ?

select segment,sum(profit) as Total_profit,sum(sales) as Total_sales
from superstore
group by segment
order by sum(profit) desc;

-- Que-12. How many customers do we have (unique customer IDs) in total and how much per region and state?
-- state wise
select state,count(distinct customerid)  as no_of_customer
from superstore
group by state
order by count(distinct customerid) desc ;

--region wise
select region,count(distinct customerid)  as no_of_customer
from superstore
group by region
order by count(distinct customerid) desc ;

-- Que-13. Average shipping time per class and in total
SELECT shipmode,AVG(datediff(day,orderdate,shipdate)) AS avg_shipping_time
FROM superstore
GROUP BY shipmode
ORDER BY avg_shipping_time;

--                                   Advanced Questions


/* Que-14 .Calculate the Year-over-Year (YoY) percentage growth 
in total sales and profit for each year. */

with salesdata as 
	(select datepart(year, orderdate) as year, 
	sum(sales) as total_sales, 
	sum(profit) as total_profit from superstore 
	group by datepart(year, orderdate)) 
select year, total_sales, total_profit, 
	lag(total_sales) over (order by year) as previous_year_sales,
	lag(total_profit) over (order by year) as previous_year_profit,
	round((total_sales - lag(total_sales) over (order by year)) * 100.0 / nullif(lag(total_sales) over (order by year), 0), 2) as sales_growth_percentage,
	round((total_profit - lag(total_profit) over (order by year)) * 100.0 / nullif(lag(total_profit) over (order by year), 0), 2) as profit_growth_percentage
		from salesdata;

/* Que-15.Identify the top 5 most profitable products in each region. */

with product_ranking as 
	(select region, productname, sum(profit) as total_profit,
	rank() over (partition by region order by sum(profit) desc) as rank 
	from superstore group by region, productname) 
select region, productname, total_profit 
	from product_ranking 
	where rank <= 5 
	order by region, rank;


/* Que-16.Find customers who placed more than one order and calculate the average 
days between their orders. */

with customerorders as 
	(select customerid, orderid, orderdate,
	lead(orderdate) over (partition by customerid order by orderdate) as next_order_date 
	from superstore) 
select 
	customerid, count(orderid) as total_orders,
	avg(datediff(day, orderdate, next_order_date)) as avg_days_between_orders 
	from customerorders 
	where next_order_date is not null 
	group by customerid 
	order by total_orders desc;
