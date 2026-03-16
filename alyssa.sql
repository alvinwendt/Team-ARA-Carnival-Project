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
