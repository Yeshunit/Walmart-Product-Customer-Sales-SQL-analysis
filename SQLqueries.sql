-- Create the database
CREATE DATABASE walmart;

-- Use the created database
USE walmart;

-- Create the sales table
CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12,4),
    rating FLOAT(2,1)
);

-- Fetching time and executing on the basis of Morning, Afternoon, Evening
-- Data Cleaning
SELECT 
    time,
    (CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'MORNING'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'AFTERNOON'
        ELSE 'EVENING'
    END) AS time_of_day
FROM sales;

-- Alter table to add time_of_day column
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(50);

-- Update table with time_of_day data
UPDATE sales 
SET 
    time_of_day = (CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'MORNING'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'AFTERNOON'
        ELSE 'EVENING'
    END);

-- Show updated table
SELECT * FROM sales;

-- Fetch day name from date
SELECT date, DAYNAME(date) AS day_name FROM sales;

-- Alter table to add day_name column
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

-- Update table with day_name data
UPDATE sales 
SET day_name = DAYNAME(date);

-- Fetch month name from date
SELECT date, MONTHNAME(date) AS month_name FROM sales;

-- Alter table to add month_name column
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

-- Update table with month_name data
UPDATE sales 
SET month_name = MONTHNAME(date);

-- Display the updated table
SELECT * FROM sales;

-- Generic Questions
-- 1. How many unique cities does the data have?
SELECT DISTINCT city FROM sales;

-- 2. In which city is each branch?
SELECT DISTINCT city, branch FROM sales;

-- Product Questions
-- 1. How many unique product lines does the data have?
SELECT DISTINCT product_line FROM sales;

-- 2. What is the most common payment method?
SELECT payment, COUNT(payment) AS max_payment
FROM sales
GROUP BY payment;

-- 3. What is the most selling product line?
SELECT product_line, COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- 4. What is the total revenue by month?
SELECT month_name, SUM(total) AS monthsale
FROM sales
GROUP BY month_name
ORDER BY monthsale DESC;

-- 5. What month had the largest COGS?
SELECT month_name, SUM(cogs) AS maxcogs
FROM sales
GROUP BY month_name
ORDER BY maxcogs DESC;

-- 6. What product line had the largest revenue?
SELECT product_line, SUM(total) AS maxrevenue
FROM sales
GROUP BY product_line
ORDER BY maxrevenue DESC;

-- 7. What is the city with the largest revenue?
SELECT city, branch, SUM(total) AS cityrevenue
FROM sales
GROUP BY city, branch
ORDER BY cityrevenue DESC;

-- 8. What product line had the largest VAT?
SELECT product_line, ROUND(SUM(tax_pct * total / 100), 2) AS largestVAT
FROM sales
GROUP BY product_line
ORDER BY largestVAT DESC;

-- 9. Fetch each product line showing "Good" or "Bad" performance
SELECT product_line,
    CASE
        WHEN SUM(quantity) > (SELECT AVG(quantity) FROM sales) THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- 10. Which branch sold more products than the average sold?
SELECT branch, SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING qty > (SELECT AVG(quantity) FROM sales);

-- 11. What is the most common product line by gender?
WITH ranked_sales AS (
    SELECT gender, product_line, COUNT(gender) AS total_count,
           RANK() OVER (PARTITION BY product_line ORDER BY COUNT(gender) DESC) AS rn
    FROM sales
    GROUP BY gender, product_line
)
SELECT gender, product_line, total_count
FROM ranked_sales
WHERE rn = 1;

-- 12. What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating;

-- Sales Questions
-- 1. Number of sales made in each time of day per weekday
SELECT time_of_day, COUNT(*) AS total_sales
FROM sales
WHERE day_name = 'Monday'
GROUP BY time_of_day;

-- 2. Which customer type brings the most revenue?
SELECT customer_type, SUM(total) AS max_revenue
FROM sales
GROUP BY customer_type
ORDER BY max_revenue DESC;

-- 3. Which city has the largest tax percent/VAT?
SELECT city, ROUND(AVG(tax_pct), 2) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- 4. Which customer type pays the most in VAT?
SELECT customer_type, ROUND(SUM(tax_pct * total / 100), 2) AS total_vat
FROM sales
GROUP BY customer_type
ORDER BY total_vat DESC;

-- Customer Questions
-- 1. How many unique customer types does the data have?
SELECT DISTINCT customer_type FROM sales;

-- 2. How many unique payment methods does the data have?
SELECT DISTINCT payment FROM sales;

-- 3. What is the most common customer type?
SELECT customer_type, COUNT(customer_type) AS commontype
FROM sales
GROUP BY customer_type
ORDER BY commontype DESC;

-- 4. Which customer type spends the most?
SELECT customer_type, SUM(total) AS most_purchase
FROM sales
GROUP BY customer_type
ORDER BY most_purchase DESC;

-- 5. Which is the gender of most of the customers?
SELECT gender, COUNT(*) AS most_gender
FROM sales
GROUP BY gender
ORDER BY most_gender DESC;

-- 6. What is the gender distribution per branch?
SELECT branch, gender, COUNT(*) AS gender_distribution
FROM sales
GROUP BY branch, gender
ORDER BY branch;

-- 7. Which time of day do customers give the most ratings?
SELECT time_of_day, COUNT(rating) AS most_rating
FROM sales
GROUP BY time_of_day
ORDER BY most_rating DESC;

-- 8. Which time of day do customers give the most ratings per branch?
SELECT time_of_day, branch, COUNT(rating) AS most_rating_per_branch
FROM sales
GROUP BY branch, time_of_day
ORDER BY most_rating_per_branch DESC;

-- 9. Which day of the week has the best average ratings per time of day?
SELECT time_of_day, ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC
LIMIT 1;

-- 10. Which day of the week has the best average ratings per branch?
SELECT branch, day_name, ROUND(AVG(rating), 2) AS rating
FROM sales
GROUP BY branch, day_name
ORDER BY rating DESC
LIMIT 1;
