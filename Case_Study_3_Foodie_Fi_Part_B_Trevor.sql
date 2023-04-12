/*SCHEMA:
Table: subscriptions
customer_id 	INT
plan_id		INT
start_date	DATE

Table: plans
plan_id		INT
plan_name	VARCHAR(13)
price		DECIMAL(5,2)

plans:
0	trial		0
1	basic monthly	9.90
2	pro monthly	19.90
3	pro annual	199
4	churn		null
*/

--	How many customers has Foodie-Fi ever had?


SELECT
	COUNT(DISTINCT customer_id) AS num_of_customers
FROM
	foodie_fi.subscriptions;


--	 What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value


SELECT
	DATE_PART('MONTH', start_date) AS start_month,
	COUNT(start_date)
FROM
	foodie_fi.subscriptions
WHERE
	plan_id = 0
GROUP BY
	DATE_PART('MONTH', start_date);


--	 What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name


SELECT
	p.plan_name,
	COUNT(*) AS num_of_starts_after_2020
FROM
	foodie_fi.subscriptions s
	JOIN
	foodie_fi.plans p ON p.plan_id = s.plan_id
WHERE
	DATE_PART('year', s.start_date) > 2020
GROUP BY 
	p.plan_name
ORDER BY 
	num_of_starts_after_2020 DESC;



--	 What is the customer count and percentage of customers who have churned rounded to 1 decimal place?


SELECT
	COUNT(DISTINCT customer_id) AS customer_count,
	ROUND(CAST((SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions WHERE plan_id = 4) AS NUMERIC)
		/
	CAST(COUNT(DISTINCT customer_id) AS NUMERIC)
	* 100, 1)
	AS churned_percentage
FROM
	foodie_fi.subscriptions;


--	 How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

WITH cte AS (
SELECT
	customer_id,
	plan_id,
	LAG(plan_id, 1) OVER (PARTITION BY customer_id ORDER BY start_date) AS last_plan,
	start_date
FROM
	foodie_fi.subscriptions
)

SELECT
	COUNT(DISTINCT customer_id) AS churned_customers,
	ROUND(CAST((SELECT COUNT(DISTINCT customer_id) FROM cte WHERE last_plan = 0 AND plan_id = 4) AS NUMERIC)
	/
	CAST((SELECT COUNT(DISTINCT customer_id) FROM cte) AS NUMERIC)
	* 100, 1)
	AS churned_percentage
FROM
	cte
WHERE
	last_plan = 0 AND plan_id = 4;


--	 What is the number and percentage of customer plans after their initial free trial?


SELECT
	p.plan_name,
	COUNT(s.plan_id) AS num_of_plans,
	ROUND(CAST((COUNT(s.plan_id)) AS NUMERIC)
	/
	CAST((SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions) AS NUMERIC)
	* 100, 1)
	AS percentage
FROM
	foodie_fi.subscriptions s
	JOIN
	foodie_fi.plans p ON p.plan_id = s.plan_id
WHERE
	s.plan_id <> 0 AND s.plan_id <> 4
GROUP BY
	p.plan_name;


--	 What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?


SELECT
	p.plan_name,
	COUNT(s.plan_id) AS num_of_plans,
	ROUND(CAST((COUNT(s.plan_id)) AS NUMERIC)
	/
	CAST((SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions) AS NUMERIC)
	* 100, 1)
	AS percentage
FROM
	foodie_fi.subscriptions s
	JOIN
	foodie_fi.plans p ON p.plan_id = s.plan_id
WHERE
	start_date <= '2020-12-31'
GROUP BY
	p.plan_name;


--	 How many customers have upgraded to an annual plan in 2020?


SELECT
	COUNT(DISTINCT customer_id)
FROM
	foodie_fi.subscriptions
WHERE
	EXTRACT(YEAR FROM start_date) = 2020
	AND plan_id = 3;


--	 How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?


WITH cte AS (
SELECT
	customer_id,
	MIN(start_date) AS join_date,
	MAX(start_date) AS upgrade_date
FROM
	foodie_fi.subscriptions
WHERE
	plan_id = 0 OR plan_id = 3
GROUP BY
	customer_id
ORDER BY
	customer_id
)

SELECT
	ROUND(AVG(upgrade_date - join_date), 1) AS avg_upgrade_time
FROM
	cte
WHERE
	join_date <> upgrade_date;


--	 Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)


WITH cte AS (
SELECT
	customer_id,
	MIN(start_date) AS join_date,
	MAX(start_date) AS upgrade_date
FROM
	foodie_fi.subscriptions
WHERE
	plan_id = 0 OR plan_id = 3
GROUP BY
	customer_id
ORDER BY
	customer_id
),

cte1 AS (
SELECT
	*,
	upgrade_date - join_date AS days_between_upgrade,
	CASE
		WHEN upgrade_date - join_date >=0 AND upgrade_date - join_date <= 30 THEN '0-30'
		WHEN upgrade_date - join_date >=31 AND upgrade_date - join_date <= 60 THEN '31-60'
		WHEN upgrade_date - join_date >=61 AND upgrade_date - join_date <= 90 THEN '61-90'
		WHEN upgrade_date - join_date >=91 AND upgrade_date - join_date <= 120 THEN '91-120'
		WHEN upgrade_date - join_date >=121 AND upgrade_date - join_date <= 150 THEN '121-150'
		WHEN upgrade_date - join_date >=151 AND upgrade_date - join_date <= 180 THEN '151-180'
		WHEN upgrade_date - join_date >=181 AND upgrade_date - join_date <= 210 THEN '181-210'
		WHEN upgrade_date - join_date >=211 AND upgrade_date - join_date <= 240 THEN '211-240'
		WHEN upgrade_date - join_date >=241 AND upgrade_date - join_date <= 270 THEN '0-30'
		WHEN upgrade_date - join_date >=271 AND upgrade_date - join_date <= 300 THEN '31-60'
		WHEN upgrade_date - join_date > 300 THEN '300+'
	END AS category
FROM
	cte
)

SELECT
	category,
	ROUND(AVG(days_between_upgrade), 1) AS avg_days
FROM
	cte1
WHERE
	upgrade_date <> join_date
GROUP BY
	category
ORDER BY
	avg_days;


--	 How many customers downgraded from a pro monthly to a basic monthly plan in 2020?


WITH basic AS(
SELECT
	customer_id,
	start_date AS basic_start
FROM
	foodie_fi.subscriptions
WHERE
	EXTRACT(YEAR FROM start_date) = 2020
	AND plan_id = 1
),
pro AS(
SELECT
	customer_id,
	start_date AS pro_start
FROM
	foodie_fi.subscriptions
WHERE
	EXTRACT(YEAR FROM start_date) = 2020
	AND plan_id = 2
)

SELECT
	COUNT(*)
FROM
	pro
	JOIN
	basic ON basic.customer_id = pro.customer_id
WHERE
	basic.basic_start > pro.pro_start;
