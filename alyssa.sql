------- Section 1: Sales Performance Analysis ------
-- 1.1 Who are our top 5 employees generating the most sales revenue?
with cte as (select 
    e.first_name ||', '|| e.last_name AS employee_name,
    sum(s.price) AS total_sales_revenue,
    count(*) AS number_of_sales,
    avg(s.price) AS average_sale_value,
    min(s.pickup_date )as first_sale_date,
    max(s.pickup_date )as last_sale_date
from sales s
join employees e 
    ON s.employee_id = e.employee_id
where s.sale_returned ='false'
group by e.employee_id, e.first_name, e.last_name
order by total_sales_revenue desc
limit 5)
select employee_name as "Employee Name",
to_char(total_sales_revenue,'FM$999,999,990') as "Total Sales Revenue",
number_of_sales as "Number of Sales",
to_char(average_sale_value,'FM$999,999,990')"Average Sale Value",
last_sale_date - first_sale_date as "Tenure(days)"
from cte

-- 1.2 Which 5 dealerships generate the most sales income?
select
	d.business_name "Dealership Name",
	d.city as "Location",
	to_char(sum(s.price), 'FM$999,999,990') "Total Sales Revenue",
	count(s.dealership_id) as "Number of Sales"
from
	sales s
join dealerships d on
	s.dealership_id = d.dealership_id
where
	s.sale_returned = 'false'
group by
	d.business_name,
	d.city
order by
	"Total Sales Revenue" desc
limit 5
	
--1.3  Which vehicle model generated the most total sales income?
with cte2 as(
select
	vt.make,
	vt.model,
	sum(s.price) total_revenue ,
	count(s.vehicle_id),
	avg(s.price) avg_revenue
from
	sales s
join vehicles v on
	s.vehicle_id = v.vehicle_id
join vehicletypes vt on
	v.vehicle_type_id = vt.vehicle_type_id
where
	s.sale_returned = 'false'
group by vt.make , vt.model 
order by total_revenue desc
limit 5)
select
	make as "Make",
	model "Model",
	to_char(total_revenue , 'FM$999,999,990') "Total Revenue",
	count as "Units Sold",
	to_char(avg_revenue , 'FM$999,999,990') "Avg Sale Price"
from
	cte2
	
-- 1.4 Which employees generate the most income per dealership?
with employee_sales as (
select
	dealership_id,
	employee_id,
	sum(price) as total_sales
from
	sales
group by
	dealership_id,
	employee_id
)
select
	d.business_name as "Dealership",
	e.first_name || ', '|| e.last_name as "Employee Name",
	es.total_sales as "Total Sales",
	rank() over(partition by es.dealership_id order by total_sales desc) as "Rank at Dealership"
from
	employee_sales es
join employees e on
	es.employee_id = e.employee_id
join dealerships d on
	es.dealership_id = d.dealership_id 
	
-- 4.2 Show employee sales rankings with running totals throughout the year.
with monthly_sales as (
select
	s.employee_id,
	sum(s.price) as monthly_revenue,
	date_trunc('month', s.purchase_date ) as month
from
	sales s
where
	s.sale_returned = 'false'
group by
	s.employee_id,
	date_trunc('month', s.purchase_date )
),
sales_rank as(
select
	*,
	sum(monthly_revenue)over(partition by employee_id order by month)as running_total,
	rank() over (partition by month
order by
	monthly_revenue desc) as employee_rank
from
	monthly_sales
)
select
	e.first_name || ', ' || e.last_name as "Employee Name",
	cast(sr.month as Date) as "Month",
	to_char(sr.monthly_revenue , 'FM$999,999,990') "Monthly Sales",
	sr.running_total as "Running Total",
	employee_rank as "Rank this month"
from
	sales_rank sr
join employees e on
	sr.employee_id = e.employee_id
order by
	"Employee Name",
	month


------- Section 2: Inventory Intelligence ------

-- 2.1 Inventory Count by Model (also include make, oldest vehicle, newest vehicle)
	-- via window fx:
SELECT
	DISTINCT vt.make,
	vt.model,
	count(*) OVER(PARTITION BY vt.make, vt.model) AS count_in_stock,
	MIN(v.year_of_car) OVER(PARTITION BY vt.make, vt.model) AS oldest_vehicle,
	Max(v.year_of_car) OVER(PARTITION BY vt.make, vt.model) AS newest_vehicle
FROM
	vehicles v
JOIN vehicletypes vt ON
	v.vehicle_type_id = vt.vehicle_type_id
WHERE
	v.is_sold = FALSE
ORDER BY
	count_in_stock ASC
	
	-- via group by:	
SELECT
	vt.make,
	vt.model,
	COUNT(*) AS count_in_stock,
	MIN(v.year_of_car) AS oldest_vehicle_year,
	MAX(v.year_of_car) AS newest_vehicle_year
FROM
	vehicles v
JOIN vehicletypes vt
    ON
	v.vehicle_type_id = vt.vehicle_type_id
WHERE
	v.is_sold = FALSE
GROUP BY
	vt.make,
	vt.model
ORDER BY
	count_in_stock ASC

-- 2.2 Inventory Count by Make
SELECT
	vt.make,
	count(*) AS count_in_stock,
	sum(v.msr_price) AS total_value
FROM
	vehicles v
JOIN vehicletypes vt ON
	vt.vehicle_type_id = v.vehicle_type_id
WHERE
	v.is_sold = FALSE
GROUP BY vt.make
ORDER BY count_in_stock ASC

-- 2.3 Inventory Count by Body Type
SELECT
	DISTINCT 
	vt.body_type,
	count(*) OVER(PARTITION BY vt.body_type) AS quantity,
	count(*) OVER(PARTITION BY vt.body_type)*100/count(*) OVER() AS percentage_of_inventory
FROM
	vehicletypes vt
JOIN vehicles v ON
	v.vehicle_type_id = vt.vehicle_type_id
WHERE
	is_sold = FALSE
ORDER BY
	quantity DESC

-- 2.4 Slow-Moving Inventory & 4.3 Vehicle Turnover Rate
-- Database doesn’t store dates when vehicles join/leave inventory. But I think in the real world this might be accomplished with a separate Inventory History table storing date_in and date_out (null if still in stock). See presentation for screenshot
