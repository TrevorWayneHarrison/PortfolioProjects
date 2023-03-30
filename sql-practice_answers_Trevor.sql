/*
My answers to all questions on sql-practice.com 
There are two sets of questions, dealing with two separate databases. 
The first is a Hospital database. The second is a database called "Northwind", dealing with a retailer.
For each database, there are three levels of questions: Easy, Medium, and Hard.
*/

/*----------------
HOSPITAL QUESTIONS
----------------*/

/*

Hospital Database schema:

----------------------
table: patients
patient_id	| INT
first_name	| TEXT
last_name	| TEXT
gender		| CHAR(1)
birth_date	| DATE
city		| TEXT
province_id	| CHAR(2)
allergies	| TEXT
height		| INT
weight		| INT
----------------------

---------------------------
table: admissions
patient_id		| INT
admission_date		| DATE
discharge_date		| DATE
diagnosis		|TEXT
attending_doctor_id	| INT
---------------------------

------------------
table: doctors
doctor_id	| INT
first_name	| TEXT
last_name	| TEXT
specialty	| TEXT
------------------

-------------------------
table: province_names
province_id	| CHAR(2)
province_name	| TEXT
-------------------------
*/


/*------------------
EASY-LEVEL QUESTIONS
------------------*/


-- Show first name, last name, and gender of patients who's gender is 'M'
SELECT
	first_name,
    	last_name,
    	gender
FROM
	patients
WHERE
	gender = 'M';
    


-- Show first name and last name of patients who does not have allergies. (null)
SELECT
	first_name,
    	last_name
FROM
	patients
WHERE
	allergies IS NULL;
    


-- Show first name of patients that start with the letter 'C'
SELECT
	first_name
FROM
	patients
WHERE
	first_name LIKE 'C%';



-- Show first name and last name of patients that weight within the range of 100 to 120 (inclusive)
SELECT
	first_name,
    	last_name
FROM
	patients
WHERE
	weight BETWEEN 100 AND 120;
    
    
    
-- Update the patients table for the allergies column. If the patient's allergies is null then replace it with 'NKA'
UPDATE patients
SET allergies = 'NKA'
WHERE
	allergies IS NULL;



-- Show first name and last name concatinated into one column to show their full name.
SELECT
	CONCAT(first_name, ' ', last_name) as full_name
FROM
	patients;



-- Show first name, last name, and the full province name of each patient.
SELECT
	p.first_name,
   	p.last_name,
    	pn.province_name
FROM
	patients p
    	JOIN
    	province_names pn ON p.province_id = pn.province_id;
    
    
    
-- Show how many patients have a birth_date with 2010 as the birth year.
SELECT
	COUNT(*)
FROM
	patients
WHERE
	birth_date BETWEEN '2010-01-01' AND '2010-12-31';
  
  
    
-- Show the first_name, last_name, and height of the patient with the greatest height.
SELECT
	first_name,
    	last_name,
    	MAX(height)
FROM
	patients;
    


-- Show all columns for patients who have one of the following patient_ids: 1,45,534,879,1000
SELECT *
FROM
	patients
WHERE
	patient_id IN (1, 45, 534, 879, 1000);



-- Show the total number of admissions
SELECT
	COUNT(*)
FROM
	admissions;
    
 
 
-- Show all the columns from admissions where the patient was admitted and discharged on the same day.
SELECT *
FROM
	admissions
WHERE
	admission_date = discharge_date;



-- Show the patient id and the total number of admissions for patient_id 579.
SELECT 
	patient_id,
    	COUNT(admission_date) AS number_of_admissions
FROM
	admissions
WHERE
	patient_id = 579;



-- Based on the cities that our patients live in, show unique cities that are in province_id 'NS'?
SELECT 
	DISTINCT city
FROM
	patients
WHERE
	province_id = 'NS';



-- Write a query to find the first_name, last name and birth date of patients who has height greater than 160 and weight greater than 70
SELECT 
	first_name,
    	last_name,
    	birth_date
FROM
	patients
WHERE
	height > 160 AND
    	weight > 70;



-- Write a query to find list of patients first_name, last_name, and allergies from Hamilton where allergies are not null
SELECT 
	first_name,
    	last_name,
    	allergies
FROM
	patients
WHERE
	city = 'Hamilton' AND
    	allergies IS NOT NULL;



-- Based on cities where our patient lives in, write a query to display the list of unique city starting with a vowel (a, e, i, o, u). Show the result order in ascending by city.
SELECT 
	DISTINCT city
FROM
	patients
WHERE
	city LIKE 'A%' or
    	city LIKE 'E%' or
    	city LIKE 'I%' or
    	city LIKE 'O%' or
    	city LIKE 'U%'
ORDER BY city ASC;



/*--------------------
MEDIUM-LEVEL QUESTIONS
--------------------*/


-- Show unique birth years from patients and order them by ascending.
SELECT 
	DISTINCT YEAR(birth_date) AS unique_birth_years
FROM
	patients
ORDER BY unique_birth_years ASC;



-- Show unique first names from the patients table which only occurs once in the list.
-- For example, if two or more people are named 'John' in the first_name column then don't include their name in the output list. If only 1 person is named 'Leo' then include them in the output.
SELECT 
	DISTINCT first_name
FROM
	patients
WHERE 
	first_name IN (SELECT first_name
                   FROM patients
                   GROUP BY first_name
                   HAVING COUNT(first_name) = 1);



-- Show patient_id and first_name from patients where their first_name start and ends with 's' and is at least 6 characters long.
SELECT 
	patient_id,
    	first_name
FROM
	patients
WHERE
	first_name LIKE 'S%s' AND
    	length(first_name) >= 6;
    


-- Show patient_id, first_name, last_name from patients whos diagnosis is 'Dementia'.
SELECT 
	p.patient_id,
    	p.first_name,
    	p.last_name
FROM
	patients p
    	JOIN
    	admissions a ON a.patient_id = p.patient_id
WHERE
	a.diagnosis = 'Dementia';



-- Display every patient's first_name. Order the list by the length of each name and then by alphbetically
SELECT
	first_name
FROm
	patients
ORDER BY
	length(first_name), first_name;



-- Show the total amount of male patients and the total amount of female patients in the patients table. Display the two results in the same row. 
SELECT
	SUM(
    	CASE
      		WHEN gender = 'M' THEN 1
      		ELSE 0
      	END
    	) AS male_total,
    	SUM(
    	CASE
      		WHEN gender = 'F' THEN 1
      		ELSE 0
      	END
    	) AS female_total
FROM
	patients;
    
  
  
-- Show first and last name, allergies from patients which have allergies to either 'Penicillin' or 'Morphine'. Show results ordered ascending by allergies then by first_name then by last_name.
SELECT
	first_name,
    	last_name,
    	allergies
FROM
	patients
WHERE
	allergies = 'Penicillin' or
    	allergies = 'Morphine'
ORDER BY
	allergies ASC, first_name, last_name;



-- Show patient_id, diagnosis from admissions. Find patients admitted multiple times for the same diagnosis.
SELECT
	patient_id,
    	diagnosis
FROM
	admissions
GROUP BY
	patient_id, diagnosis
HAVING
	COUNT(diagnosis) > 1;



-- Show the city and the total number of patients in the city. Order from most to least patients and then by city name ascending.
SELECT
	city,
    	COUNT(*) AS number_of_patients
FROM
	patients
GROUP BY
	city
ORDER BY
	number_of_patients DESC,
    	city ASC;



-- Show first name, last name and role of every person that is either patient or doctor. The roles are either "Patient" or "Doctor"
SELECT
	first_name,
    	last_name,
    	'Patient' AS role
FROM
	patients
UNION ALL
SELECT
	first_name,
    	last_name,
    	'Doctor' AS role
FROM
	doctors;



-- Show all allergies ordered by popularity. Remove NULL values from query.
SELECT
	allergies,
    	COUNT(allergies) AS total_allergies
FROM
	patients
WHERE
	allergies IS NOT NULL
GROUP BY 
	allergies
ORDER BY
	total_allergies DESC;



-- Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. Sort the list starting from the earliest birth_date.
SELECT
	first_name,
    	last_name,
    	birth_date
FROM
	patients
WHERE
	YEAR(birth_date) BETWEEN 1970 AND 1979
ORDER BY birth_date ASC;



-- We want to display each patient's full name in a single column. Their last_name in all upper letters must appear first, then first_name in all lower case letters. Separate the last_name and first_name with a comma. Order the list by the first_name in decending order
-- EX: SMITH,jane
SELECT
	CONCAT(UPPER(last_name), ',', LOWER(first_name))
FROM
	patients
ORDER BY
	first_name DESC;



-- Show the province_id(s), sum of height; where the total sum of its patient's height is greater than or equal to 7,000.
SELECT
	province_id,
    	SUM(height) AS sum_of_height
FROM
	patients
GROUP BY 
	province_id
HAVING
	sum_of_height >= 7000;



-- Show the difference between the largest weight and smallest weight for patients with the last name 'Maroni'
SELECT
	MAX(weight) - MIN(weight)
FROM
	patients
WHERE
	last_name = 'Maroni';



-- Show all of the days of the month (1-31) and how many admission_dates occurred on that day. Sort by the day with most admissions to least admissions.
SELECT
	DISTINCT DAY(admission_date) AS day_number,
    	COUNT(admission_date) AS number_of_admissions
FROM
	admissions
GROUP BY
	day_number
ORDER BY
	number_of_admissions DESC;



-- Show all columns for patient_id 542's most recent admission_date.
SELECT *
FROM
	admissions
WHERE
	patient_id = 542
ORDER BY admission_date DESC
LIMIT 1;



-- Show patient_id, attending_doctor_id, and diagnosis for admissions that match one of the two criteria:
-- 1. patient_id is an odd number and attending_doctor_id is either 1, 5, or 19.
-- 2. attending_doctor_id contains a 2 and the length of patient_id is 3 characters.
SELECT
	patient_id,
	attending_doctor_id,
    	diagnosis
FROM
	admissions
WHERE
	((patient_id % 2) > 0 AND (attending_doctor_id IN (1, 5, 19)) )
    	OR
    	(cast(attending_doctor_id AS TEXT) LIKE '%2%' AND LENGTH(patient_id) = 3);
    


-- Show first_name, last_name, and the total number of admissions attended for each doctor.
-- Every admission has been attended by a doctor.
SELECT
	d.first_name,
    	d.last_name,
    	COUNT(attending_doctor_id)
FROM
	admissions a
    	JOIN
    	doctors d ON d.doctor_id = a.attending_doctor_id
GROUP BY
	d.first_name, d.last_name;
    
    
    
-- For each doctor, display their id, full name, and the first and last admission date they attended.
SELECT
	d.doctor_id,
    	CONCAT(d.first_name, ' ', d.last_name) AS full_name,
    	MIN(a.admission_date) AS first_admission_date,
    	MAX(a.admission_date) AS last_admission_date
FROM
	admissions a
    	JOIN
    	doctors d ON d.doctor_id = a.attending_doctor_id
GROUP BY
	d.doctor_id;



-- Display the total amount of patients for each province. Order by descending.
SELECT
	pn.province_name,
    	COUNT(patient_id) AS patient_count
FROM
	patients p
    	JOIN
    	province_names pn ON p.province_id = pn.province_id
GROUP BY
	pn.province_name
ORDER BY
	patient_count DESC;



-- For every admission, display the patient's full name, their admission diagnosis, and their doctor's full name who diagnosed their problem.
SELECT
	CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    	a.diagnosis AS diagnosis,
    	CONCAT(d.first_name, ' ', d.last_name) AS doctor_name
FROM
	patients p
    	JOIN
    	admissions a ON a.patient_id = p.patient_id
    	JOIN
    	doctors d ON d.doctor_id = a.attending_doctor_id;



-- display the number of duplicate patients based on their first_name and last_name.
SELECT
	first_name,
    	last_name,
    	COUNT(*) AS duplicates
FROM
	patients
GROUP BY 
	first_name, last_name
HAVING
	duplicates > 1;
    
    

-- Display patient's full name, height in the units feet rounded to 1 decimal, weight in the unit pounds rounded to 0 decimals, birth_date, gender non abbreviated.
-- Convert CM to feet by dividing by 30.48.
-- Convert KG to pounds by multiplying by 2.205.
SELECT
	CONCAT(first_name, ' ', last_name) AS full_name,
    	ROUND(height/30.48, 1) AS height,
    	ROUND(weight*2.205, 0) AS weight,
    	birth_date,
    	CASE
    		WHEN gender = 'M' THEN 'Male'
        	WHEN gender = 'F' THEN 'Female'
        	ELSE 'Other'
    	END AS gender
FROM
	patients;


/*------------------
HARD-LEVEL QUESTIONS
------------------*/



-- Show all of the patients grouped into weight groups. Show the total amount of patients in each weight group. Order the list by the weight group decending.
-- For example, if they weight 100 to 109 they are placed in the 100 weight group, 110-119 = 110 weight group, etc.
SELECT
	COUNT(*),
	CASE
    	WHEN weight BETWEEN 0 AND 9 THEN 0
        WHEN weight BETWEEN 10 AND 19 THEN 10
        WHEN weight BETWEEN 20 AND 29 THEN 20
        WHEN weight BETWEEN 30 AND 39 THEN 30
        WHEN weight BETWEEN 40 AND 49 THEN 40
        WHEN weight BETWEEN 50 AND 59 THEN 50
        WHEN weight BETWEEN 60 AND 69 THEN 60
        WHEN weight BETWEEN 70 AND 79 THEN 70
        WHEN weight BETWEEN 80 AND 89 THEN 80
        WHEN weight BETWEEN 90 AND 99 THEN 90
        WHEN weight BETWEEN 100 AND 109 THEN 100
        WHEN weight BETWEEN 110 AND 119 THEN 110
        WHEN weight BETWEEN 120 AND 129 THEN 120
        WHEN weight BETWEEN 130 AND 139 THEN 130
        ELSE 140
    END AS weight_group
FROM
	patients
GROUP BY 
	weight_group
ORDER BY weight_group DESC;



-- Show patient_id, weight, height, isObese from the patients table.
-- Display isObese as a boolean 0 or 1.
-- Obese is defined as weight(kg)/(height(m)2) >= 30.
-- weight is in units kg.
-- height is in units cm.
SELECT
	patient_id,
    	weight,
    	height,
    	CASE
    		WHEN weight / (POWER(height*0.01, 2)) >= 30 THEN 1
        ELSE 0
    	END AS isObese
FROM
	patients;



-- Show patient_id, first_name, last_name, and attending doctor's specialty.
-- Show only the patients who has a diagnosis as 'Epilepsy' and the doctor's first name is 'Lisa'
-- Check patients, admissions, and doctors tables for required information. 
SELECT
	p.patient_id,
    	p.first_name,
    	p.last_name,
    	d.specialty
FROM
	patients p
    	JOIN
    	admissions a ON a.patient_id = p.patient_id
    	JOIN
    	doctors d ON d.doctor_id = a.attending_doctor_id
WHERE
	a.diagnosis = 'Epilepsy' AND
    	d.first_name = 'Lisa';



-- All patients who have gone through admissions, can see their medical documents on our site. Those patients are given a temporary password after their first admission. Show the patient_id and temp_password.
-- The password must be the following, in order:
-- 1. patient_id
-- 2. the numerical length of patient's last_name
-- 3. year of patient's birth_date
SELECT
	DISTINCT p.patient_id,
    	CONCAT(p.patient_id, LENGTH(p.last_name), YEAR(p.birth_date)) AS temp_password
FROM
	patients p
    	JOIN
    	admissions a ON p.patient_id = a.patient_id;



-- Each admission costs $50 for patients without insurance, and $10 for patients with insurance. All patients with an even patient_id have insurance.
-- Give each patient a 'Yes' if they have insurance, and a 'No' if they don't have insurance. Add up the admission_total cost for each has_insurance group.
SELECt
	CASE
    		WHEN patient_id % 2 = 0 THEN 'Yes'
        ELSE 'No'
    	END as has_insurance,
    SUM(CASE
        	WHEN patient_id % 2 = 0 THEN 10
        ELSE 50
        END) AS cost_after_insurance
FROM
	admissions
GROUP BY has_insurance;



-- Show the provinces that has more patients identified as 'M' than 'F'. Must only show full province_name
SELECT
	province_name
FROM
	province_names pn
    	JOIN
    	patients p ON p.province_id = pn.province_id
GROUP BY
	province_name
HAVING
	SUM(CASE WHEN p.gender = 'M' THEN 1 ELSE 0 END) > SUM(CASE WHEN p.gender = 'F' THEN 1 ELSE 0 END);



-- We are looking for a specific patient. Pull all columns for the patient who matches the following criteria:
-- - First_name contains an 'r' after the first two letters.
-- - Identifies their gender as 'F'
-- - Born in February, May, or December
-- - Their weight would be between 60kg and 80kg
-- - Their patient_id is an odd number
-- - They are from the city 'Kingston'
SELECT *
FROM
	patients
WHERE
	first_name LIKE '__r%' AND
    	gender = 'F' AND
    	MONTH(birth_date) IN (02, 05, 12) AND
    	weight BETWEEN 60 AND 80 AND
    	patient_id % 2 > 0 AND
    	city = 'Kingston';



-- Show the percent of patients that have 'M' as their gender. Round the answer to the nearest hundreth number and in percent form.
SELECT
      	CONCAT(ROUND(CAST(
          	SUM(CASE WHEN gender = 'M' Then 1 ELSE 0 END) AS FLOAT)
        	/ CAST(COUNT(*) AS FLOAT)
            *100, 2), '%') AS percent_of_males
FROM
	patients;



-- For each day display the total amount of admissions on that day. Display the amount changed from the previous date.
SELECT
	admission_date,
    	COUNT(*) AS admissions_on_day,
    	COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY admission_date) AS admissions_change
FROM
	admissions
GROUP BY
	admission_date
ORDER BY admission_date;



-- Sort the province names in ascending order in such a way that the province 'Ontario' is always on top.
SELECT
	province_name
FROM
	province_names
ORDER BY
	CASE
    	WHEN province_name = 'Ontario' THEN 1
        ELSE 2
    END ASC;



/*-----------------
NORTHWIND QUESTIONS
-----------------*/

/*

Northwind Database Schema:

-----------------------
table: categories
category_id 	| INT
category_name 	| TEXT
description 	| TEXT
-----------------------

-----------------------
table: customers
customer_id 	| TEXT
company_name 	| TEXT
contact_name 	| TEXT
contact_title 	| TEXT
address 	| TEXT
city 		| TEXT
region 		| TEXT
postal_code 	| TEXT
country 	| TEXT
phone 		| TEXT
fax 		| TEXT
-----------------------

---------------------------
table: employees
employee_id 		| INT
last_name 		| TEXT
first_name 		| TEXT
title 			| TEXT
title_of_courtesy 	| TEXT
birth_date 		| DATE
hire_date 		| DATE
address 		| TEXT
city 			| TEXT
region 			| TEXT
postal_code 		| TEXT
country 		| TEXT
home_phone 		| TEXT
extension 		| TEXT
reports_to 		| INT
---------------------------

---------------------------
table: employee_territories
employee_id	| INT
territory_id	| TEXT
---------------------------

---------------------
table: order_details
order_id 	| INT
product_id 	| INT
unit_price 	| DECIMAL
quantity 	| INT
discount 	| DECIMAL
---------------------

-----------------------------
table: orders
order_id 		| INT
customer_id 		| TEXT
employee_id 		| INT
order_date 		| DATE
required_date 		| DATE
shipped_date 		| DATE
ship_via 		| INT
freight 		| DECIMAL
ship_name 		| TEXT
ship_address 		| TEXT
ship_city 		| TEXT
ship_region 		| TEXT
ship_postal_code 	| TEXT
ship_country 		| TEXT
----------------------------

---------------------------------
table: products
product_id 		| INT
product_name 		| TEXT
supplier_id 		| INT
category_id 		| INT
quantity_per_unit 	| TEXT
unit_price 		| DECIMAL
units_in_stock 		| INT
units_on_order 		| INT
reorder_level 		| INT
discontinued 		| INT
--------------------------------

--------------------------
table: regions
region_id		| INT
region_description	| TEXT
--------------------------

----------------------
table: shipppers
shipper_id	| INT
company_name	| TEXT
phone		| TEXT
----------------------

----------------------
table: suppliers
supplier_id 	| INT
company_name 	| TEXT
contact_name 	| TEXT
contact_title 	| TEXT
address 	| TEXT
city 		| TEXT
region 		| TEXT
postal_code 	| TEXT
country 	| TEXT
phone 		| TEXT
fax 		| TEXT
home_page 	| TEXT
----------------------

------------------------------
table: territories
territory_id		| TEXT
territory_description	| TEXT
region_id		| INT
------------------------------

*/

/*------------------
EASY-LEVEL QUESTIONS
------------------*/ 



-- Show the category_name and description from the categories table sorted by category_name.
SELECT
	category_name,
    	description
FROM
	categories
ORDER BY
	category_name;



-- Show all the contact_name, address, city of all customers which are not from 'Germany', 'Mexico', 'Spain'
SELECT
	contact_name,
    	address,
    	city
FROM
	customers
WHERE
	COUNTRY NOT IN ('Germany', 'Spain', 'Mexico');



-- Show order_date, shipped_date, customer_id, Freight of all orders placed on 2018 Feb 26
SELECT
	order_date,
    	shipped_date,
    	customer_id,
    	freight
FROM
	orders
WHERE 
	order_date = '2018-02-26';



-- Show the employee_id, order_id, customer_id, required_date, shipped_date from all orders shipped later than the required date
SELECT
	employee_id,
    	order_id,
    	customer_id,
    	required_date,
    	shipped_date
FROM
	orders
WHERe
	shipped_date > required_date;



-- Show all the even numbered Order_id from the orders table
SELECT
	order_id
FROM
	orders
WHERE
	order_id % 2 = 0;



-- Show the city, company_name, contact_name of all customers from cities which contains the letter 'L' in the city name, sorted by contact_name
SELECT
	city,
    	company_name,
    	contact_name
FROM
	customers
WHERE
	city LIKE '%L%'
ORDER BY
	contact_name;



-- Show the company_name, contact_name, fax number of all customers that has a fax number. (not null)
SELECT
	company_name,
    	contact_name,
    	fax
FROM
	customers
WHERE
	fax IS NOT NULL;



-- Show the first_name, last_name of the most recently hired employee.
SELECT
	first_name,
    	last_name,
    	hire_date
FROM
	employees
ORDER BY
	hire_date DESC
LIMIT 1;



-- Show the average unit price rounded to 2 decimal places, the total units in stock, total discontinued products from the products table.
SELECT
	ROUND(AVG(unit_price), 2) AS avg_unit_price,
    	SUM(units_in_stock) AS total_units_in_stock,
    	SUM(discontinued) AS total_discontinued
FROM
	products;



/*-------------------
MEDIUM-LEVEL QUESIONS
-------------------*/



-- Show the ProductName, CompanyName, CategoryName from the products, suppliers, and categories table
SELECT
	p.product_name,
    	s.company_name,
    	c.category_name
FROM
	categories c
    	JOIN
    	products p ON p.category_id = c.category_id
    	JOIN
    	suppliers s ON s.supplier_id = p.supplier_id;



-- Show the category_name and the average product unit price for each category rounded to 2 decimal places.
SELECT
	c.category_name,
    	ROUND(AVG(p.unit_price), 2) AS avg_unit_price
FROM
	products p 
    	JOIN
    	categories c ON c.category_id = p.category_id
GROUP BY
	c.category_name;



-- Show the city, company_name, contact_name from the customers and suppliers table merged together.
-- Create a column which contains 'customers' or 'suppliers' depending on the table it came from.
SELECT
	city,
    	company_name,
    	contact_name,
    	'customers' AS source
FROM
	customers
UNION
SELECT
	city,
    	company_name,
    	contact_name,
    	'suppliers' AS source
FROM
	suppliers;

/*------------------
HARD-LEVEL QUESTIONS
------------------*/

-- Show the employee's first_name and last_name, a "num_orders" column with a count of the orders taken, and a column called "Shipped" that displays "On Time" if the order shipped on time and "Late" if the order shipped late.
-- Order by employee last_name, then by first_name, and then descending by number of orders.
SELECT
	e.first_name,
   	e.last_name,
    	COUNT(o.order_id) AS num_orders,
    	CASE
    		WHEN o.shipped_date < o.required_date THEN 'On Time'
        ELSE 'Late'
   	END as Shipped
FROM
	employees e
    	JOIN
    	orders o ON o.employee_id = e.employee_id
GROUP BY
	e.first_name, e.last_name, Shipped
ORDER BY
	e.last_name, e.first_name, num_orders DESC;
