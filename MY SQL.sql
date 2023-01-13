


/** 1 Are there duplicates in the data? **/

SELECT 
	"row id",
	COUNT("row id")
FROM sql_project.`sample - superstore`
GROUP BY "row id" 
HAVING COUNT("row id") > 1;

/** 2 When I imported the tables, I discovered that the date columns had STRING data types instead of DATE type . 
I had to make changes to this effect by using the UPDATE command. **/ 

UPDATE sql_project.`sample - superstore`
SET order_date = str_to_date(order_date, "%Y-%m-%d"); 
UPDATE sql_project.`sample - superstore`
SET ship_date = str_to_date(ship_date, "%Y-%m-%d");
SELECT 
	order_date,
    ship_date
FROM sql_project.`sample - superstore`;

SELECT *
FROM sql_project.`sample - superstore`;

/** 4 What is the total number of sales made, total quantity of products ordered and total profits? **/

SELECT
	COUNT(*) AS total_sales_made,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(Profit),2) AS total_profit
FROM sql_project.`sample - superstore`;

/** 5 What is the total number of sales made, total quantity of products ordered and total profits? 
This will help find the year with the highest sales and profits.**/

SELECT
	DATE_FORMAT(order_date, "%Y") AS Year,
	COUNT(*) AS total_sales_made,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(Profit),2) AS total_profit
FROM sql_project.`sample - superstore`
GROUP BY Year
ORDER BY total_profit DESC;

/** 6 What category of items has the highest sales recorded? This will help find the category with the highest sales and the order.**/

SELECT category,
	   ROUND(SUM(sales)) AS total_sales
FROM sql_project.`sample - superstore`
GROUP BY category
ORDER BY category DESC;

/** 7 What is the total transaction per ship mode?**/

SELECT ship_mode,
	   COUNT(*) AS ship_mode_count
FROM sql_project.`sample - superstore`
GROUP BY ship_mode;

/**8 What is the total transaction per region?**/

SELECT region,
	   COUNT(*) AS total_transaction_per_region
FROM sql_project.`sample - superstore`
GROUP BY region
ORDER BY total_transaction_per_region DESC;

/**9 The number of times each customer made a transaction**/

SELECT customer_id,
	   customer_name,
	   COUNT(*) AS customer_count
FROM sql_project.`sample - superstore`
GROUP BY customer_name
ORDER BY customer_count DESC;

/**10 Transaction made from states in each region?**/

SELECT region,
	   COUNT(state) AS state_transaction
FROM sql_project.`sample - superstore`
GROUP BY region
ORDER BY state_transaction DESC;

/**11 What is the state with the highest transaction? 
The company wants to know what state produces the highest revenue. This will help to direct the highest influx of products. **/

WITH cte as (
SELECT state,
	   COUNT(*) AS highest_state_transaction
FROM sql_project.`sample - superstore`
GROUP BY state
ORDER BY highest_state_transaction DESC
)

SELECT State, MAX(highest_state_transaction)
FROM cte;

/**12 What is the date difference between the order date and ship date? **/

SELECT 
	row_id, DATEDIFF(ship_date, order_date) AS Delivery_period
FROM sql_project.`sample - superstore`
GROUP BY Delivery_period
ORDER BY Delivery_period;


 /**13  What is the number of times each product is sold out, alongside the category and sales of the product?
 I used the row_number function alonside the partition by function to work this out. **/
 
 SELECT product_name,
	    category,
        sub_category,
	    sales AS price,
ROW_NUMBER () OVER
(PARTITION BY product_name
			  ORDER BY sales
)
AS occurence_of_product_transaction
FROM sql_project.`sample - superstore`;

/**14 What is the product with the highest and smallest sales **/

WITH CTE
AS
(
SELECT product_name,
       sales * quantity AS total_sales,
SUM(sales * quantity) OVER(PARTITION BY product_name) AS sum_of_product_name,
AVG(sales * quantity) OVER(PARTITION BY product_name) AS avg_of_product_name,
MIN(sales * quantity) OVER(PARTITION BY product_name) AS min_of_product_name,
MAX(sales * quantity) OVER(PARTITION BY product_name) AS max_of_product_name
FROM sql_project.`sample - superstore`
)
SELECT 
	product_name,
    ROUND(Total_sales, 2) AS total_sales,
    ROUND(sum_of_product_name, 2) AS total_of_product,
    ROUND(avg_of_product_name, 2) AS avg_of_product,
    ROUND(min_of_product_name, 2) AS min_of_product,
    ROUND(max_of_product_name, 2) AS max_of_product,
    ROW_NUMBER () OVER
(PARTITION BY product_name
			  ORDER BY total_sales DESC
)
AS product_order
FROM CTE;


/**15 What is the least expensive products and most expensive products ordered by customers? **/
SELECT 
	product_name,
	sales,
    first_value(product_name) over
		(order by sales DESC) AS Most_Expensive_Product,
	last_value(product_name) over
		(order by sales DESC
			range between unbounded preceding
				and unbounded following) AS Least_Expensive_Product
FROM sql_project.`sample - superstore`
GROUP BY product_name;


SELECT *
FROM sql_project.`sample - superstore - people` p;

SELECT *
FROM sql_project.`sample - superstore - returns` r;

SELECT * FROM sql_project.`sample - superstore` o;
    
USE sql_project;
DROP procedure IF EXISTS customer_order_stats;
DELIMITER $$
USE sql_project $$
CREATE PROCEDURE customer_order_stats (IN Customer_Name VARCHAR(30))
BEGIN 
SELECT 
	row_id, order_id, customer_id, customer_name, segment, state, region, product_id, category, sub_category, product_name, sales, quantity, discount
FROM sql_project.`sample - superstore`;
END $$
DELIMITER ;
CALL customer_order_stats("Claire Gute");



