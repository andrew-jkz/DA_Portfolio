SELECT * 
FROM nyc_ab;

-- Average price with OVER()
SELECT
	id,
    name,
    neighbourhood_group, 
	AVG(price)OVER()
FROM nyc_ab;

-- Average, Minimum and Maximum price with OVER()
SELECT
	id,
    name,
    neighbourhood_group, 
	AVG(price)OVER(),
    MIN(price)OVER(),
    MAX(price)OVER()
FROM nyc_ab;

-- Percent of Average price with OVER()
SELECT
	id,
    name,
    neighbourhood_group, 
    price,
    ROUND(AVG(price) OVER(), 2) AS avg_price,
    ROUND((price / AVG(price) OVER() * 100), 2) AS percent_of_avg_price
FROM nyc_ab;

-- Percent difference form Avgrage price
SELECT
	id,
    name,
    neighbourhood_group, 
    price,
    ROUND(AVG(price) OVER(), 2) AS avg_price,
    ROUND((price / AVG(price) OVER() -1) * 100, 2) AS percent_of_avg_price
FROM nyc_ab;

-- PARTITION BY() neighbourhood group
SELECT
	id,
    name,
    neighbourhood_group, 
    neighbourhood,
    price,
    AVG(price) OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group
FROM nyc_ab;

-- PARTITION BY() neighbourhood group and neighbourhood
SELECT
	id,
    name,
    neighbourhood_group, 
    neighbourhood,
    price,
    AVG(price) OVER(PARTITION BY neighbourhood_group, neighbourhood) AS avg_price_by_group_and_neigh
FROM nyc_ab;

-- Neighbourhood group, neighbourhood group and neighbourhood delta
SELECT
	id,
    name,
    neighbourhood_group, 
    neighbourhood,
    price,
    ROUND(price - AVG(price) OVER(PARTITION BY neighbourhood_group), 2) AS neigh_group_delta,
	ROUND(price - AVG(price) OVER(PARTITION BY neighbourhood_group, neighbourhood), 2) AS neigh_delta
FROM nyc_ab;

-- Difference between ROW_NUMBER, RANK, and DENSE_RANK
SELECT
	id,
    name,
    neighbourhood_group, 
    neighbourhood,
    price,
    ROW_NUMBER() OVER(ORDER BY price DESC) AS "ROW_NUMBER",
    RANK() OVER(ORDER BY price DESC) AS "RANK",
    DENSE_RANK() OVER(ORDER BY price DESC) AS "DENSE_RANK"
FROM nyc_ab;

-- Top 3
SELECT
	id,
    name,
    neighbourhood_group, 
    neighbourhood,
    price,
    ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
    ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank,
    CASE 
		WHEN ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) <= 3 THEN "YES"
        ELSE "NO" 
	END AS top3_flag
FROM nyc_ab;

-- Difference between LAG and LEAD
SELECT
	id,
    name,
    neighbourhood_group, 
    neighbourhood,
	host_name,
    price,
	last_review,
    LAG(price) OVER(PARTITION BY host_name ORDER BY last_review) AS "LAG",
    LEAD(price) OVER(PARTITION BY host_name ORDER BY last_review) AS "LEAD"
FROM nyc_ab;

