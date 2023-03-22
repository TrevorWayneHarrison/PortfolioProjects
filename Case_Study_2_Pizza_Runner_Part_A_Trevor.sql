/* 
A. Pizza Metrics
*/

-- 1. How many pizzas were ordered?



SELECT
	COUNT(customer_orders.pizza_id) AS number_of_pizzas
FROM
	pizza_runner.customer_orders;



-- 2. How many unique customer orders were made?



SELECT
	COUNT(DISTINCT customer_orders.customer_id) AS number_of_customers
FROM
	pizza_runner.customer_orders;



-- 3. How many successful orders were delivered by each runner?



SELECT
	runner_orders.runner_id AS runner,
	COUNT(*) AS number_of_deliveries
FROM
	pizza_runner.runner_orders
WHERE
	runner_orders.cancellation NOT ILIKE '%cancellation%'
GROUP BY 
	runner
ORDER BY 
	runner;



-- 4. How many of each type of pizza was delivered?


SELECT
	pn.pizza_name AS pizza_name,
	COUNT(co.pizza_id) AS successful_deliveries
FROM
	pizza_runner.runner_orders ro
	JOIN
	pizza_runner.customer_orders co ON co.order_id = ro.order_id
	JOIN
	pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
WHERE
	ro.cancellation NOT ILIKE '%cancellation%'
GROUP BY 
	pn.pizza_name;


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?


SELECT
	customer_orders.customer_id,
    	SUM(CASE
          	WHEN customer_orders.pizza_id = 1 THEN 1
          	ELSE 0
	END) AS meatlovers,
    	SUM(CASE
          	WHEN customer_orders.pizza_id = 2 THEN 1
          	ELSE 0
	END) AS vegetarian
FROM
	pizza_runner.customer_orders
GROUP BY 
	customer_orders.customer_id
ORDER BY 
	customer_orders.customer_id;


-- 6. What was the maximum number of pizzas delivered in a single order?


WITH successful_deliveries AS(
SELECT
	co.order_id AS order_id,
    	ro.cancellation AS cancellation
FROM
	pizza_runner.customer_orders co
   	JOIN
    	pizza_runner.runner_orders ro ON ro.order_id = co.order_id
)

SELECT 
	order_id,
	COUNT(*) AS number_of_pizzas
FROM 
	successful_deliveries
WHERE
	cancellation NOT ILIKE '%cancellation%' OR
    	cancellation IS NULL
GROUP BY 
	order_id
ORDER BY 
	number_of_pizzas DESC
LIMIT 1;



-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?



WITH completed_orders AS (
SELECT
	co.order_id AS order,
    	co.customer_id AS customer,
    	co.exclusions AS exclusions,
    	co.extras AS extras,
    	ro.cancellation AS cancellation
FROM
	pizza_runner.customer_orders co
    	JOIN
    	pizza_runner.runner_orders ro ON ro.order_id = co.order_id
WHERE 
	ro.cancellation NOT ILIKE '%cancellation%' OR
    	ro.cancellation IS NULL
)

SELECT
	customer,
    SUM(
      	CASE
      		WHEN 	exclusions ILIKE ANY(ARRAY['%1%', '%2%', '%3%', '%4%', '%5%', '%6%', '%7%', '%8%', '%9%', '%10%', '%11%', '%12%']) OR 
      				extras ILIKE ANY(ARRAY['%1%', '%2%', '%3%', '%4%', '%5%', '%6%', '%7%', '%8%', '%9%', '%10%', '%11%', '%12%'])
      				THEN 1
      				ELSE 0
      	END
      ) AS pizzas_with_changes,
    SUM(
      	CASE
      		WHEN	(exclusions IS NULL OR exclusions = 'null' OR exclusions = '') AND (extras IS NULL OR extras = 'null' OR extras = '')
      				THEN 1
      				ELSE 0
      	END
      ) AS pizzas_with_no_changes
FROM
	completed_orders
GROUP BY 
	customer
ORDER BY 
	customer;



-- 8. How many pizzas were delivered that had both exclusions and extras?



WITH completed_orders AS (
SELECT
	co.order_id AS order,
    	co.customer_id AS customer,
    	co.exclusions AS exclusions,
    	co.extras AS extras,
    	ro.cancellation AS cancellation
FROM
	pizza_runner.customer_orders co
    	JOIN
    	pizza_runner.runner_orders ro ON ro.order_id = co.order_id
WHERE 
	ro.cancellation NOT ILIKE '%cancellation%' OR
    	ro.cancellation IS NULL
)

SELECT
	COUNT(*) AS deliveries_with_extras_and_exclusions
FROM
	completed_orders
WHERE
	(exclusions <> 'null' AND exclusions <> '' AND exclusions IS NOT NULL) AND
    	(extras <> 'null' AND extras <> '' AND extras IS NOT NULL);



-- 9. What was the total volume of pizzas ordered for each hour of the day?



SELECT
	EXTRACT(HOUR FROM customer_orders.order_time::TIMESTAMP) AS hours,
	COUNT(*) AS number_of_orders
FROM
	pizza_runner.customer_orders
GROUP BY
	hours
ORDER BY
	hours;



-- 10. What was the volume of orders for each day of the week?



SELECT
	CASE
		WHEN EXTRACT(DOW FROM customer_orders.order_time::TIMESTAMP) = 1 THEN 'Monday'
        	WHEN EXTRACT(DOW FROM customer_orders.order_time::TIMESTAMP) = 2 THEN 'Tuesday'
        	WHEN EXTRACT(DOW FROM customer_orders.order_time::TIMESTAMP) = 3 THEN 'Wednesday'
        	WHEN EXTRACT(DOW FROM customer_orders.order_time::TIMESTAMP) = 4 THEN 'Thursday'
        	WHEN EXTRACT(DOW FROM customer_orders.order_time::TIMESTAMP) = 5 THEN 'Friday'
        	WHEN EXTRACT(DOW FROM customer_orders.order_time::TIMESTAMP) = 6 THEN 'Saturday'
        ELSE 'Sunday'
    END AS day_of_week,
    COUNT(*) AS number_of_orders
FROM
	pizza_runner.customer_orders
GROUP BY
	day_of_week
ORDER BY
	day_of_week;