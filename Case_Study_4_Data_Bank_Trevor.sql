/*

SCHEMA: data_bank

Table: regions
region_id	INTEGER
region_name	VARCHAR(9)


Table: customer_nodes
customer_id	INTEGER
region_id	INTEGER
node_id	INTEGER
start_date	DATE
end_date	DATE


Table: customer_transactions
customer_id	INTEGER
txn_date	DATE
txn_type	VARCHAR(10)
txn_amount	INTEGER

*/



/*---------------------------
A. Customer Nodes Exploration
*/---------------------------




--	How many unique nodes are there on the Data Bank system?


SELECT
	COUNT(DISTINCT node_id)
FROM
	data_bank.customer_nodes;


--	What is the number of nodes per region?


SELECT
	r.region_name,
	COUNT(DISTINCT cn.node_id) AS num_of_nodes
FROM
	data_bank.customer_nodes cn
	JOIN
	data_bank.regions r ON r.region_id = cn.region_id
GROUP BY
	r.region_name;


--	How many customers are allocated to each region?


SELECT
	r.region_name,
	COUNT(DISTINCT cn.customer_id) AS num_of_customers
FROM
	data_bank.customer_nodes cn
	JOIN
	data_bank.regions r ON r.region_id = cn.region_id
GROUP BY
	r.region_name;


--	How many days on average are customers reallocated to a different node?


SELECT
	ROUND(AVG(end_date - start_date), 1) AS avg_reallocation_time
FROM
	data_bank.customer_nodes
WHERE
	DATE_PART('YEAR', end_date) <> 9999;


--	What is the median, 80th and 95th percentile for this same reallocation days metric for each region?


SELECT
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY end_date - start_date) AS median,
	PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY end_date - start_date) AS percentile80,
	PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY end_date - start_date) AS percentile95
FROM
	data_bank.customer_nodes
WHERE
	DATE_PART('year', end_date) <> 9999;


/*---------------------------
B. Customer Transactions
*/---------------------------




--	What is the unique count and total amount for each transaction type?


SELECT
	txn_type,
	COUNT(*),
	SUM(txn_amount) AS total_amount
FROM
	data_bank.customer_transactions
GROUP BY
	txn_type;


--	What is the average total historical deposit counts and amounts for all customers?

WITH cte AS(
SELECT
	customer_id,
	COUNT(*) AS num_of_deposits,
	SUM(txn_amount) AS total
FROM
	data_bank.customer_transactions
WHERE
	txn_type = 'deposit'
GROUP BY
	customer_id
ORDER BY
	customer_id
)

SELECT
	ROUND(AVG(num_of_deposits), 2) AS avg_num_of_deposits,
	ROUND(AVG(total), 2) AS avg_deposits_total
FROM
	cte;


--	For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH cte AS(
SELECT
	customer_id,
	DATE_PART('year', txn_date) AS year,
	DATE_PART('month', txn_date) AS month,
	COUNT(CASE WHEN txn_type = 'deposit' THEN 1 ELSE NULL END) AS deposits,
	COUNT(CASE WHEN txn_type = 'withdrawal' OR txn_type = 'purchase' THEN 1 ELSE NULL END) AS withdrawals_purchases
FROM
	data_bank.customer_transactions
GROUP BY
	customer_id,
	DATE_PART('year', txn_date),
	DATE_PART('month', txn_date)
ORDER BY
	customer_id,
	DATE_PART('year', txn_date),
	DATE_PART('month', txn_date)
)

SELECT
	year,
	month,
	COUNT(*)
FROM
	cte
WHERE
	deposits > 1 AND
	withdrawals_purchases >= 1
GROUP BY
	year, month
ORDER BY
	year, month;
	
 
--	What is the closing balance for each customer at the end of the month?

WITH cte AS(
SELECT
	customer_id,
	DATE_PART('year', txn_date) AS year,
	DATE_PART('month', txn_date) AS month,
	SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE 0 END) AS deposits,
	SUM(CASE WHEN txn_type <> 'deposit' THEN txn_amount ELSE 0 END) AS withdrawals
FROM
	data_bank.customer_transactions
GROUP BY
	customer_id,
	DATE_PART('year', txn_date),
	DATE_PART('month', txn_date)
ORDER BY
	customer_id,
	DATE_PART('year', txn_date),
	DATE_PART('month', txn_date)
)

SELECT
	customer_id,
	year,
	month,
	deposits - withdrawals
FROM
	cte
ORDER BY
	customer_id,
	year,
	month;







