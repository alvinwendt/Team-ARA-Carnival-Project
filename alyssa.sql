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
