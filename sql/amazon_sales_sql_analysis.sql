/* ============================================================
   AMAZON SALES DATA ANALYSIS — SQL EXPLORATORY ANALYSIS
   ============================================================ */

---------------------------------------------------------------
-- 1. DROP & CREATE TABLE
---------------------------------------------------------------

DROP TABLE IF EXISTS amazon_products;

CREATE TABLE amazon_products (
    product_id            VARCHAR(20),
    product_name          TEXT,
    main_category         VARCHAR(100),
    sub_category          VARCHAR(150),
    sub_sub_category      VARCHAR(150),
    discounted_price      NUMERIC(10,2),
    actual_price          NUMERIC(10,2),
    discount_percentage   NUMERIC(5,2),
    rating                NUMERIC(3,2),
    rating_count          NUMERIC(10,2)   -- changed here
);

---------------------------------------------------------------
-- 2. TOTAL PRODUCTS
---------------------------------------------------------------

SELECT COUNT(*) AS total_products
FROM amazon_products;

---------------------------------------------------------------
-- 3. PRODUCTS BY MAIN CATEGORY
---------------------------------------------------------------

SELECT main_category,
       COUNT(*) AS product_count
FROM amazon_products
GROUP BY main_category
ORDER BY product_count DESC;


---------------------------------------------------------------
-- 4. AVERAGE RATING & DISCOUNT BY CATEGORY
---------------------------------------------------------------

SELECT main_category,
       ROUND(AVG(rating),2) AS avg_rating,
       ROUND(AVG(discount_percentage),2) AS avg_discount
FROM amazon_products
GROUP BY main_category
ORDER BY avg_rating DESC;


---------------------------------------------------------------
-- 5. TOP 10 MOST REVIEWED PRODUCTS
---------------------------------------------------------------

SELECT product_name,
       rating_count,
       rating,
       main_category
FROM amazon_products
ORDER BY rating_count DESC
LIMIT 10;


---------------------------------------------------------------
-- 6. TOP 10 MOST EXPENSIVE PRODUCTS
---------------------------------------------------------------

SELECT product_name,
       discounted_price,
       main_category
FROM amazon_products
ORDER BY discounted_price DESC
LIMIT 10;

---------------------------------------------------------------
-- 7. RATING BUCKET ANALYSIS (Correlation-like Insight)
---------------------------------------------------------------

SELECT
  CASE
    WHEN rating >= 4.5 THEN 'Excellent'
    WHEN rating >= 4.0 THEN 'Good'
    WHEN rating >= 3.5 THEN 'Average'
    ELSE 'Low'
  END AS rating_bucket,
  ROUND(AVG(discounted_price),2) AS avg_price
FROM amazon_products
GROUP BY rating_bucket
ORDER BY avg_price DESC;

---------------------------------------------------------------
-- 8. TOP 3 MOST REVIEWED PRODUCTS PER MAIN CATEGORY
---------------------------------------------------------------

SELECT *
FROM (
    SELECT 
        main_category,
        product_name,
        rating_count,
        rating,
        RANK() OVER (
            PARTITION BY main_category
            ORDER BY rating_count DESC
        ) AS category_rank
    FROM amazon_products
    WHERE rating_count IS NOT NULL
) AS ranked_products
WHERE category_rank <= 3
ORDER BY main_category, category_rank;



---------------------------------------------------------------
-- 9. ESTIMATED POPULARITY-BASED REVENUE
---------------------------------------------------------------

SELECT product_name,
       main_category,
       discounted_price,
       rating_count,
       (discounted_price * rating_count) AS estimated_revenue
FROM amazon_products
ORDER BY estimated_revenue DESC
LIMIT 10;
