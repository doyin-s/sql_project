USE Amazon_sales;
SELECT * FROM report;

-- DATA CLEANING
-- Rename column names for Order ID, Courier Status and Ship-city

ALTER TABLE report
RENAME COLUMN `Order ID` to Order_ID;

SELECT Order_ID 
FROM report;

ALTER TABLE report 
RENAME COLUMN `Courier Status`to Courier_Status;

SELECT Courier_Status
FROM report;

ALTER TABLE report 
RENAME COLUMN `ship-city`to City;

SELECT City 
FROM report;

ALTER TABLE report
RENAME COLUMN Curreny to Currency;

ALTER TABLE report
RENAME COLUMN `ship-state` to State;

ALTER TABLE report
RENAME COLUMN `ship-postal-code` to Postcode;

ALTER TABLE report
RENAME COLUMN `promotion-ids` to Promotion_ids;


ALTER TABLE report
RENAME COLUMN `fulfilled-by` to Fulfilled_by;

ALTER TABLE report
RENAME COLUMN `ship-country` to Country;

ALTER TABLE report
RENAME COLUMN `ship-service-level` to Ship_service;


-- Check for duplicate records in specific columns

SELECT Order_ID, Style, Category, ASIN, Qty, Amount,COUNT(*) as Duplicates
FROM report
GROUP BY 1,2,3,4,5,6
HAVING Duplicates >1;


-- EXPLORING VARIABLES

-- 1.Most orders
-- 1a. Which category has the most sales and percentage of category to total orders

SELECT Category,
	COUNT(Category) as Orders,
	(COUNT(*)/(SELECT COUNT(*) FROM report)*100) as Percentage
FROM report
GROUP BY Category
ORDER BY Orders DESC;

-- 1b. Which category has the most Shipped/Delivered to Buyer sales and percentage of category to Total orders
SELECT Category, SUM(Qty) as Total, (COUNT(*)/(SELECT COUNT(*) FROM report)*100) as Percentage
FROM report
WHERE `Status`= 'Shipped' OR `Status`= 'Shipped - Delivered to Buyer' 
GROUP BY Category
ORDER BY Total DESC;

-- 2.What items were cancelled?

-- 2a. Making all cancelled orders courier status 'unshipped'
SET Courier_Status = 'Unshipped'
WHERE `Status`= 'Cancelled' AND Courier_Status IS NOT NULL;


-- 2b. Category with most cancelled items
SELECT Category, SUM(Qty) as Total
FROM report
WHERE `Status`= 'Cancelled' 
GROUP BY Category
ORDER BY Total DESC;

-- 3. Sets ordered vs non-sets ordered
SELECT
	SUM(case when Category IN ('Set') then 1 else 0 end)/COUNT(*) *100 AS SETS,
	SUM(case when Category NOT IN ('Set') then 1 else 0 end)/COUNT(*) *100 AS NON_SETS
FROM report;

-- 4. Orders in each city

-- 4a. Checking City names only contains letters and not numbers
SELECT City 
FROM report
WHERE City REGEXP '%[0-9]%';

-- Making data uniform by converting City column into UPPERCASE
UPDATE
	report
SET 
	City = UPPER(City);
    
-- 4b. Top 5 cities with highest value of orders
SELECT City as 'TOP 5 CITIES' ,ROUND(SUM(AMOUNT),0) as 'Orders'
FROM report
GROUP BY City
ORDER BY 'Orders' DESC
LIMIT 5 ;


-- 4c. Average Order Value per city
SELECT City, ROUND(AVG(AMOUNT),1) as Average
FROM report
GROUP BY City
ORDER BY Average DESC;

-- 4d.Average number of orders per customer per city
WITH c AS ( 
	SELECT Order_ID, City,COUNT(*) as 'Total'
	FROM report
	GROUP BY 1,2)

SELECT City, AVG(Total) as Average
FROM c
GROUP BY 1
ORDER BY Average DESC; 

-- How many orders used a Promotion
SELECT
	SUM(case when Promotion_ids LIKE '%Amazon%' then 1 else 0 end) AS 'Amazon Promotion used',
	SUM(case when Promotion_ids IS NOT NULL then 1 else 0 end) AS 'Other promotion used',
	SUM(case when Promotion_ids = "" then 1 else 0 end) AS 'No promotion'
FROM report;

