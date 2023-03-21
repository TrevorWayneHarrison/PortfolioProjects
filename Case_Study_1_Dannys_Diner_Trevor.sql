/* --------------------
   Case Study Questions
   --------------------*/


-- 1. What is the total amount each customer spent at the restaurant?



SELECT
	sales.customer_id AS customer_id,
	SUM(CAST(menu.price AS money)) AS total_spent
FROM
	dannys_diner.sales sales
    	JOIN
    	dannys_diner.menu menu ON menu.product_id = sales.product_id
GROUP BY 
	customer_id
ORDER BY 
	customer_id;



-- 2. How many days has each customer visited the restaurant?



SELECT
	sales.customer_id AS customer_id,
     	COUNT(DISTINCT sales.order_date) AS days_visited
FROM
	dannys_diner.sales sales
    	JOIN
    	dannys_diner.menu menu ON menu.product_id = sales.product_id
GROUP BY 
	customer_id
ORDER BY 
	customer_id;



-- 3. What was the first item from the menu purchased by each customer?



WITH ordered_orders AS (
  SELECT *,
  	ROW_NUMBER() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) as row_numbers
  FROM
  	dannys_diner.sales sales
 	JOIN
  	dannys_diner.menu menu ON sales.product_id = menu.product_id
)

SELECT
	customer_id,
    	product_name AS first_order
FROM
	ordered_orders
WHERE
	row_numbers = 1;



-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?



WITH most_common_item AS (
SELECT
	sales.product_id product,
	COUNT(sales.product_id) product_sales
FROM
	dannys_diner.sales sales
GROUP BY 
	product
ORDER BY 
	product_sales DESC
LIMIT 1
)

SELECT
	sales.customer_id customer_id,
    	menu.product_name product,
    	COUNT(menu.product_name) product_orders
FROM
	dannys_diner.sales sales
    	JOIN
    	dannys_diner.menu menu ON menu.product_id = sales.product_id
WHERE
	sales.product_id IN (SELECT product FROM most_common_item)
GROUP BY 
	customer_id, product
ORDER BY 
	customer_id;


-- 5. Which item was the most popular for each customer?



WITH most_popular_items AS (
SELECT
	sales.customer_id customer,
    	menu.product_name product_name,
    	COUNT(sales.product_id) number_purchased,
    	RANK() OVER (PARTITION BY sales.customer_id ORDER BY COUNT(sales.product_id) DESC) ranks
FROM
	dannys_diner.sales sales
    	JOIN
    	dannys_diner.menu menu ON sales.product_id = menu.product_id
GROUP BY 
	customer, product_name
ORDER BY 
	customer, number_purchased DESC
)

SELECT 
	customer,
    	product_name,
    	number_purchased
FROM
	most_popular_items
WHERE
	ranks = 1;



-- 6. Which item was purchased first by the customer after they became a member?



WITH orders_after_membership AS(
SELECT
	members.customer_id AS customer_id,
    	menu.product_name AS product_name,
  	sales.order_date AS order_date,
  	members.join_date AS join_date,
  	RANK() OVER (PARTITION BY members.customer_id ORDER BY sales.order_date) AS ranks
FROM
	dannys_diner.members members
    	JOIN
    	dannys_diner.sales sales ON sales.customer_id = members.customer_id
    	JOIN
    	dannys_diner.menu menu ON menu.product_id = sales.product_id
WHERE
  	order_date >= join_date
ORDER BY
  	customer_id, order_date
)

SELECT 
	customer_id,
    	product_name AS first_order_after_membership
FROM
	orders_after_membership
WHERE
	ranks = 1;
    

    
-- 7. Which item was purchased just before the customer became a member?



WITH orders_before_membership AS(
SELECT
	members.customer_id AS customer_id,
    	menu.product_name AS product_name,
  	sales.order_date AS order_date,
  	members.join_date AS join_date,
  	ROW_NUMBER() OVER (PARTITION BY members.customer_id ORDER BY sales.order_date DESC) AS ranks
FROM
	dannys_diner.members members
    	JOIN
    	dannys_diner.sales sales ON sales.customer_id = members.customer_id
    	JOIN
    	dannys_diner.menu menu ON menu.product_id = sales.product_id
WHERE
  	order_date < join_date
ORDER BY
  	customer_id, order_date DESC
)

SELECT
	customer_id,
    	product_name AS last_order_before_membership
FROM
	orders_before_membership
WHERE
	ranks = 1;



-- 8. What is the total items and amount spent for each member before they became a member?


SELECT
	members.customer_id,
    	COUNT(*) AS total_items,
    	SUM(CAST(menu.price AS money)) AS total_spent
FROM
	dannys_diner.members members
    	JOIN
    	dannys_diner.sales sales ON sales.customer_id = members.customer_id
    	JOIN
    	dannys_diner.menu menu ON menu.product_id = sales.product_id
WHERE 
	members.join_date > sales.order_date
GROUP BY 
	members.customer_id
ORDER BY 
	members.customer_id;



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?



SELECT
	sales.customer_id,
    	SUM(
      	CASE
      		WHEN sales.product_id = 1 THEN menu.price * 20
      		ELSE menu.price * 10
      	END
      	) AS points
FROM
	dannys_diner.sales sales
    	JOIN
    	dannys_diner.menu menu ON menu.product_id = sales.product_id
GROUP BY 
	sales.customer_id
ORDER BY 
	sales.customer_id;



-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?



SELECT
	members.customer_id AS member,
    	SUM(
      	CASE
      		WHEN sales.order_date - members.join_date BETWEEN 0 AND 7 OR sales.product_id = 1 THEN menu.price * 20
      		ELSE menu.price * 10
      	END
      	) AS points
FROM
	dannys_diner.members members
    	JOIN
    	dannys_diner.sales sales ON sales.customer_id = members.customer_id
    	JOIN
    	dannys_diner.menu menu ON menu.product_id = sales.product_id
WHERE 
	sales.order_date < '20210201'
GROUP BY 
	members.customer_id
ORDER BY 
	members.customer_id;
