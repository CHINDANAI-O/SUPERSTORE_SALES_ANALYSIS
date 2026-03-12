SELECT * FROM superstore_sales LIMIT 10;

-- 1. What are the total sales for each category?

SELECT
	category,
	round(sum(sales), 2) AS total_sales
FROM
	superstore_sales
GROUP BY
	category
ORDER BY
	total_sales DESC;
	
-- 2. What is the YoY growth rate of total sales for the technology category?

SELECT
    order_year,
    round(sum(sales), 2) AS total_sales,
    round((sum(sales) - LAG(sum(sales)) OVER (ORDER BY order_year ASC)) * 100 / LAG(sum(sales)) OVER (ORDER BY order_year ASC), 2) AS growth_rate
FROM
	superstore_sales
WHERE
	category = 'Technology'
GROUP BY
	order_year
ORDER BY
	order_year;
	
-- 3. What are the total sales for each sub-category?

SELECT
	sub_category,
	round(sum(sales), 2) AS total_sales
FROM
	superstore_sales
GROUP BY
	sub_category
ORDER BY
	total_sales DESC;
	
-- 4. What is the average chair quantity for orders purchasing a table?

SELECT
	round(avg(quantity), 2) AS avg_chair_quantity
FROM
	superstore_sales
WHERE
	order_id IN (SELECT order_id FROM superstore_sales WHERE sub_category = 'Tables')
AND
	sub_category = 'Chairs';
	
-- 5. How many orders have a total sales greater than average?

WITH ts AS(
	SELECT
		order_id,
		sum(sales) AS total_sales
	FROM
		superstore_sales
	GROUP BY
		order_id
)

SELECT
	count(*) AS num_of_order,
	round(count(*) * 100 / CAST((SELECT count(*) FROM ts) AS REAL), 2) AS percent_of_total
FROM
	ts
WHERE
	total_sales > (SELECT avg(total_sales) FROM ts);
	
-- 6. How many orders resulted in a loss after applying the discount?

WITH tp AS(
	SELECT
		order_id,
		sum(profit) AS total_profit,
		sum(discount) AS total_discount
 	FROM
		superstore_sales
	GROUP BY
		order_id
)

SELECT
	count(*) AS num_of_order,
	round(count(*) * 100 / CAST((SELECT count(*) FROM tp) AS REAL), 2) AS percent_of_total
FROM
	tp
WHERE
	total_discount > 0;

-- 7. What are the total sales for each month?

SELECT
	CONCAT(order_month, "/", order_year) AS month,
	round(sum(sales), 2) AS total_sales
FROM
	superstore_sales
GROUP BY
	month
ORDER BY
	order_year ASC,
	order_month ASC;
	
-- 8. What is the average shipping time for each ship mode?

SELECT
	ship_mode,
	round(avg(days_to_ship), 2) AS average_days_to_ship
FROM
	superstore_sales
GROUP BY
	ship_mode
ORDER By
	average_days_to_ship ASC;
	
-- 9. Which ship mode is most popular in each region?

SELECT
    region,
    ship_mode,
    count(DISTINCT order_id) AS total_orders
FROM
	superstore_sales
GROUP BY
	region,
	ship_mode
ORDER BY
	region,
	total_orders DESC;
	
-- 10. Who are the top 10 customers by repeat purchases and which state are they in?

SELECT
	customer_name,
	state,
	count(DISTINCT order_id) AS number_of_purchase
FROM
	superstore_sales
GROUP BY
	customer_name
ORDER BY
	number_of_purchase DESC,
	row_id DESC
LIMIT
	10;
