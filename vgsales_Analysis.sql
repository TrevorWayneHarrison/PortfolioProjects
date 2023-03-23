-- dataset: https://www.kaggle.com/datasets/gregorut/videogamesales

USE portfolioprojects;

SELECT * FROM vgsales;

/*
|---------------------------|
|vgsales					|
|---------------------------|
|rank 			| INT		|
|Name 			| TEXT		|
|platform 		| TEXT		|
|year			| INT		|
|publisher		| TEXT		|
|na_sales		| DOUBLE	|
|eu_sales		| DOUBLE	|
|jp_sales		| DOUBLE	|
|other_sales	| DOUBLE	|
|global_sales	| DOUBLE	|
|---------------------------|
*/


-- Highest selling game by publisher

WITH ranked_vgsales AS(
	SELECT 
		*,
		RANK() OVER(PARTITION BY publisher ORDER BY global_sales DESC) AS ranks
    FROM
		vgsales
)

SELECT
	publisher,
    name AS highest_selling_game,
    global_sales
FROM
	ranked_vgsales
WHERE 
	ranks = 1
ORDER BY global_sales DESC;



-- Highest selling game by genre

WITH ranked_vgsales AS(
	SELECT *,
		RANK() OVER(PARTITION BY genre ORDER BY global_sales DESC) AS ranks
    FROM
		vgsales
)

SELECT
	genre,
    publisher,
    name AS highest_selling_game,
    global_sales
FROM
	ranked_vgsales
WHERE 
	ranks = 1
ORDER BY global_sales DESC;





-- Percentage of sales per game by region, only including games sold in all major regions

SELECT
	publisher,
	name,
    platform,
    CONCAT(ROUND((na_sales/global_sales)*100, 2), '%') AS NA_percentage,
    CONCAT(ROUND((jp_sales/global_sales)*100, 2), '%') AS NA_percentage,
    CONCAT(ROUND((eu_sales/global_sales)*100, 2), '%') AS NA_percentage,
    CONCAT(ROUND((other_sales/global_sales)*100, 2), '%') AS other_percentage
FROM
	vgsales
WHERE
	na_sales <> 0 AND
    jp_sales <> 0 AND
    eu_sales <> 0
ORDER BY
	publisher;





-- Highest-selling and lowest-selling genre per region
/*
Using a cte for both queries, we get the total sales per region for each genre,
Then we grab the genre which matches the highest/lowest total for each region, limiting to one row because of redundancy.
*/

WITH genre_sales AS(
	SELECT
		genre,
        ROUND(SUM(na_sales), 2) AS na_sales,
        ROUND(SUM(eu_sales), 2) AS eu_sales,
        ROUND(SUM(jp_sales), 2) AS jp_sales,
        ROUND(SUM(other_sales), 2) AS other_sales
	FROM
		vgsales
	GROUP BY
		genre
)
SELECT
	(SELECT genre FROM genre_sales WHERE na_sales = (SELECT MAX(na_sales) FROM genre_sales)) AS top_na_genre,
    (SELECT genre FROM genre_sales WHERE eu_sales = (SELECT MAX(eu_sales) FROM genre_sales)) AS top_eu_genre,
    (SELECT genre FROM genre_sales WHERE jp_sales = (SELECT MAX(jp_sales) FROM genre_sales)) AS top_jp_genre,
    (SELECT genre FROM genre_sales WHERE other_sales = (SELECT MAX(other_sales) FROM genre_sales)) AS top_other_genre
FROM
	genre_sales
LIMIT 1;

WITH genre_sales AS(
	SELECT
		genre,
        ROUND(SUM(na_sales), 2) AS na_sales,
        ROUND(SUM(eu_sales), 2) AS eu_sales,
        ROUND(SUM(jp_sales), 2) AS jp_sales,
        ROUND(SUM(other_sales), 2) AS other_sales
	FROM
		vgsales
	GROUP BY
		genre
)
SELECT
	(SELECT genre FROM genre_sales WHERE na_sales = (SELECT MIN(na_sales) FROM genre_sales)) AS bottom_na_genre,
    (SELECT genre FROM genre_sales WHERE eu_sales = (SELECT MIN(eu_sales) FROM genre_sales)) AS bottom_eu_genre,
    (SELECT genre FROM genre_sales WHERE jp_sales = (SELECT MIN(jp_sales) FROM genre_sales)) AS bottom_jp_genre,
    (SELECT genre FROM genre_sales WHERE other_sales = (SELECT MIN(other_sales) FROM genre_sales)) AS bottom_other_genre
FROM
	genre_sales
LIMIT 1;



-- average sales per year per region and globally (excluding years past 2016 due to lack of data)

SELECT
	year,
    ROUND(AVG(na_sales), 2) AS avg_na_sales,
    ROUND(AVG(eu_sales), 2) AS avg_eu_sales,
    ROUND(AVG(jp_sales), 2) AS avg_jp_sales,
    ROUND(AVG(other_sales), 2) AS avg_other_sales,
    ROUND(AVG(global_sales), 2) AS avg_global_sales
FROM
	vgsales
WHERE
	year <= 2016
GROUP BY
	year
ORDER BY
	year DESC;



-- Total sales by platform for each publisher that sold video games in all four tracked regions

SELECT
	publisher,
    platform,
    ROUND(SUM(na_sales), 2) AS total_na_sales,
    ROUND(SUM(eu_sales), 2) AS total_eu_sales,
    ROUND(SUM(jp_sales), 2) AS total_jp_sales,
    ROUND(SUM(other_sales), 2) AS total_other_sales,
    ROUND(SUM(global_sales), 2) AS total_global_sales
FROM
	vgsales
GROUP BY
	publisher, platform
HAVING
	SUM(na_sales) > 0 AND
    SUM(eu_sales) > 0 AND
    SUM(jp_sales) > 0 AND
    SUM(other_sales) > 0
ORDER BY
	publisher, platform;



-- Comparing lifetime sales of the Pokemon and Digimon games, separated by genre

SELECT
	'Pokemon' AS series_name,
    genre AS genre,
    ROUND(SUM(na_sales), 2) AS total_na_sales,
    ROUND(SUM(eu_sales), 2) AS total_eu_sales,
    ROUND(SUM(jp_sales), 2) AS total_jp_sales,
    ROUND(SUM(other_sales), 2) AS total_other_sales,
	ROUND(SUM(global_sales), 2) AS total_global_sales
FROM
	vgsales
WHERE
	name LIKE '%pokemon%'
GROUP BY
	genre
    
UNION

SELECT
	'Digimon' AS series_name,
    genre AS genre,
    ROUND(SUM(na_sales), 2) AS total_na_sales,
    ROUND(SUM(eu_sales), 2) AS total_eu_sales,
    ROUND(SUM(jp_sales), 2) AS total_jp_sales,
    ROUND(SUM(other_sales), 2) AS total_other_sales,
	ROUND(SUM(global_sales), 2) AS total_global_sales
FROM
	vgsales
WHERE
	name LIKE '%digimon%'
GROUP BY
	genre;