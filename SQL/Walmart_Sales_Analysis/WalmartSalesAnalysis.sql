SELECT *
FROM walmartsales;

-- Change the table names
ALTER TABLE walmartsales
	RENAME COLUMN `Invoice ID` TO invoice_id,
	RENAME COLUMN `Branch` TO branch,
    RENAME COLUMN `City` TO city,
    RENAME COLUMN `Customer type` TO customer_type,
    RENAME COLUMN `Gender` TO gender,
    RENAME COLUMN `Product line` TO product_line,
    RENAME COLUMN `Unit price` TO unit_price,
    RENAME COLUMN `Quantity` TO quantity,
    RENAME COLUMN `Tax 5%` TO tax,
    RENAME COLUMN `Total` TO total,
    RENAME COLUMN `Date` TO date,
    RENAME COLUMN `Time` TO time,
    RENAME COLUMN `Payment` TO payment,
    RENAME COLUMN `gross margin percentage` TO gross_margin_pct,
    RENAME COLUMN `gross income` TO gross_income,
    RENAME COLUMN `Rating` TO rating;


-- Check 
SELECT *
FROM walmartsales;

-- --------------------------------------------------------------------
-- ----------------------- General Questions --------------------------
-- --------------------------------------------------------------------

-- How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM walmartsales;

-- In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM walmartsales;
    
-- --------------------------------------------------------------------
-- ---------------------------- Product -------------------------------
-- --------------------------------------------------------------------

-- How many unique product lines does the data have?
SELECT 
	DISTINCT product_line
FROM walmartsales;

-- What is the most common payment method?
SELECT 
	payment, 
	COUNT(payment) AS common_payment_type
FROM walmartsales
GROUP BY payment
ORDER BY common_payment_type DESC;

-- What is the most selling product line?
SELECT 
    product_line,
	SUM(quantity) AS total_quantity
FROM walmartsales
GROUP BY product_line
ORDER BY total_quantity DESC;

-- What is the total revenue by month?
SELECT 
	MONTH(date) AS mos,
    ROUND(SUM(total), 2) AS total_revenue
FROM walmartsales
GROUP BY mos
ORDER BY mos;

-- What month had the largest COGS?
SELECT 
	MONTH(date) AS mos,
    ROUND(SUM(cogs), 2) AS total_cogs
FROM walmartsales
GROUP BY mos
ORDER BY total_cogs DESC;

-- What product line had the largest revenue?
SELECT 
    product_line,
	ROUND(SUM(total), 2) AS total_revenue
FROM walmartsales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT 
    city,
	ROUND(SUM(total), 2) AS total_revenue
FROM walmartsales
GROUP BY city
ORDER BY total_revenue DESC;

-- What product line had the largest VAT? (VAT stands for "Value Added Tax", in this case, the VAT will be 5% * COGS)
SELECT 
    product_line,
    ROUND(SUM(0.05 * cogs), 2) AS VAT
FROM walmartsales
GROUP BY product_line
ORDER BY VAT DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
	product_line,
    CASE 
		WHEN AVG(quantity) > (SELECT AVG(quantity) FROM walmartsales) THEN "Good"
	ELSE "Bad"
    END AS remark
FROM walmartsales
GROUP BY product_line;

-- Which branch sold more products than average product sold?
SELECT 
	branch,
    AVG(quantity) AS avg_quantity
FROM walmartsales
GROUP BY branch
HAVING avg_quantity > (SELECT AVG(quantity) FROM walmartsales)
ORDER BY avg_quantity DESC;

-- What is the most common product line by gender?
SELECT 
	gender,
    product_line,
    COUNT(product_line) AS total_product
FROM walmartsales
GROUP BY gender, product_line
ORDER BY gender, total_product DESC;

-- What is the average rating of each product line?
SELECT 
	product_line,
    ROUND(AVG(rating), 2) AS avg_rating
FROM walmartsales
GROUP BY product_line;

-- --------------------------------------------------------------------
-- ----------------------------- Sales --------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday
SELECT 
	DAYNAME(date) AS week_day,
    COUNT(*) AS number_sales
FROM walmartsales
GROUP BY week_day
ORDER BY FIELD(week_day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Which of the customer types brings the most revenue?
SELECT 
	customer_type,
    ROUND(SUM(total), 2) AS total_revenue
FROM walmartsales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT 
	city,
    MAX(tax) AS max_tax
FROM walmartsales
GROUP BY city
ORDER BY max_tax DESC;

-- Which customer type pays the most in VAT?
SELECT 
	customer_type,
    ROUND(SUM(0.05 * cogs), 2) AS VAT
FROM walmartsales
GROUP BY customer_type
ORDER BY VAT DESC;

-- --------------------------------------------------------------------
-- --------------------------- Customers ------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT 
	DISTINCT customer_type
FROM walmartsales;

-- How many unique payment methods does the data have?
SELECT 
	DISTINCT payment
FROM walmartsales;

-- What is the most common customer type?
SELECT 
	customer_type,
	COUNT(customer_type) AS total
FROM walmartsales
GROUP BY customer_type
ORDER BY total DESC;

-- Which customer type buys the most?
SELECT 
	customer_type,
	ROUND(SUM(total), 2) AS total_revenue
FROM walmartsales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- What is the gender of most of the customers?
SELECT 
	gender,
    COUNT(gender) AS num_gender
FROM walmartsales
GROUP BY gender
ORDER BY num_gender DESC;

-- What is the gender distribution per branch?
SELECT 
	branch,
    gender,
	COUNT(gender) AS num_gender
FROM walmartsales
GROUP BY branch, gender
ORDER BY branch;

-- Which time of the day do customers give most ratings?
SELECT 
	time,
    AVG(rating) AS avg_rating
FROM walmartsales
GROUP BY time
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
WITH AvgRatings AS (
    SELECT
        branch,
        time,
        AVG(rating) AS avg_rating
    FROM walmartsales
    GROUP BY branch, time
) -- CTE calculates the average ratings per branch and time.

SELECT
    branch,
    time,
    avg_rating AS most_rating
FROM (
    SELECT
        branch,
        time,
        avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY avg_rating DESC) AS rating_rank
    FROM AvgRatings
) AS ranked -- Rank each row within each branch using the RANK()
WHERE rating_rank = 1 -- Filter the most rating
ORDER BY branch;

-- Which day fo the week has the best avg ratings?
SELECT 
	DAYNAME(date) AS week_day,
    ROUND(AVG(rating), 2) AS avg_rating
FROM walmartsales
GROUP BY week_day
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
WITH AvgRating AS (
	SELECT 
		branch,
		DAYNAME(date) AS week_day,
		ROUND(AVG(rating), 2) AS avg_rating
	FROM walmartsales
	GROUP BY branch, week_day
) -- CTE calculates the average ratings per branch and each day of the week.

SELECT 
	branch,
    week_day,
    avg_rating
FROM (
	SELECT 
		branch,
        week_day,
        avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY avg_rating DESC) AS rating_rank
	FROM AvgRating
) AS ranked -- Rank each row within each branch using the RANK()
WHERE rating_rank = 1 -- Filter the best average rating
ORDER BY branch;