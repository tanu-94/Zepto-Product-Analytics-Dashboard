CREATE DATABASE zepto_analysis;

USE zepto_analysis;

select * from zepto_dataset;

-- total records
select count(*) as total_products
from zepto_dataset;

-- preview the data
select * from zepto_dataset
limit 10;

-- check the table structure
describe zepto_dataset;

-- Data Cleaning Check Missing Values
select * from zepto_dataset
where name is null
or price is null
or category is null;

-- remove leading / tralling spaces
UPDATE zepto_dataset
SET
Name = TRIM(Name),
Category = TRIM(Category),
`Sub_Category` = TRIM(`Sub_Category`),
Quantity = TRIM(Quantity),
Status = TRIM(Status),
Interface = TRIM(Interface);

-- check duplicate product
select name,
count(*) as duplicate_count
from zepto_dataset
group by name
having count(*) > 1;

-- Exploratory Data Analysis (EDA)

-- Total Categories
select count(distinct category) as total_catgy
from zepto_dataset;

-- total sub-categories
select count(distinct 'sub_category') as totol_subcat
from zepto_dataset;

-- total interfaces
select count(distinct interface) as total_inter
from zepto_dataset;

-- Business Analysis

-- Which categories have the most products?
select category,
count(*) as total_products
from zepto_dataset
group by category
order by total_products desc;

-- Number of Products in Each Sub-Category
select sub_category,
count(*) as total_products
from zepto_dataset
group by sub_category
order by total_products desc;

-- Average Selling Price by Category
select category,
round(avg(price),2) as avg_price
from zepto_dataset
group by category
order by avg_price desc;

-- most expensive products
select name,category,price
from zepto_dataset
order by price desc
limit 10;

-- cheapest products
select name,category,price
from zepto_dataset
order by price
limit 10;

-- highest rated products
select name,ratings,review
from zepto_dataset
order by ratings desc, review desc
limit 10;

-- most reviewed products
select name,review
from zepto_dataset
order by review desc 
limit 10;

-- average rating by category
select category,
round(avg(ratings),2) as avg_rating
from zepto_dataset
group by category
order by avg_rating desc;

-- categories with the most reviews
select category,
sum(review) as total_reviews
from zepto_dataset
group by category
order by total_reviews desc;

-- biggest discount
select name,price,original_price,
(original_price - price) as discount
from zepto_dataset
order  by discount desc
limit 10;

-- discount percentage
select name,
round(((original_price - price)/ original_price)*100,2) as discount_per
from zepto_dataset
where original_price > 0
order by discount_per desc
limit 10;

-- products on discount
select 
count(*) as discounted_products
from zepto_dataset
where price < original_price;

-- product by stock status
select status,
count(status) as total_products
from zepto_dataset
group by status;

-- most common quantity sizes
select quantity,
count(*) as product_count
from zepto_dataset
group by quantity
order by product_count desc;

-- interface wise product count
select interface,
count(*) as total_products
from zepto_dataset 
group by interface;

-- Which category have more than 500 product
select category,
count(*) as total_products
from zepto_dataset
group by category 
having count(*) >500
order by total_products desc;

-- case when
-- classify products by price

select name,price,
case
when price < 100 then 'budget'
when price between 100 and 500 then 'mid range'
else 'premium'
end as price_category
from zepto_dataset;
-- Segment products into Budget, Mid Range, and Premium.

-- Convert category names to uppercase.
SELECT
UPPER(Category) AS Category
FROM zepto_dataset;

-- Product Name Length
SELECT
Name,
LENGTH(Name) AS Name_Length
FROM zepto_dataset
ORDER BY Name_Length DESC;

-- First 20 Characters
SELECT
LEFT(Name,20) AS Short_Name
FROM zepto_dataset;

-- Aggregate Functions
-- Overall Statistics
SELECT
MIN(Price) AS Lowest_Price,
MAX(Price) AS Highest_Price,
AVG(Price) AS Average_Price,
SUM(Price) AS Total_Price,
COUNT(*) AS Total_Products
FROM zepto_dataset;

-- Window Functions
-- ROW_NUMBER()
SELECT
Name,
Category,
Price,
ROW_NUMBER() OVER(
PARTITION BY Category
ORDER BY Price DESC
) AS Row_Num
FROM zepto_dataset;
-- Number products within each category.

-- RANK()
SELECT
Name,
Category,
Price,
RANK() OVER(
PARTITION BY Category
ORDER BY Price DESC
) AS Price_Rank
FROM zepto_dataset;

-- DENSE_RANK()
SELECT
Name,
Category,
Price,
DENSE_RANK() OVER(
PARTITION BY Category
ORDER BY Price DESC
) AS Dense_Ranks
FROM zepto_dataset;

-- Subqueries
-- Products Costlier Than Overall Average
SELECT
Name,
Price
FROM zepto_dataset
WHERE Price >
(
SELECT AVG(Price)
FROM zepto_dataset
);

-- Products Costlier Than Their Category Average
SELECT
Name,
Category,
Price
FROM zepto_dataset z
WHERE Price >
(
SELECT AVG(Price)
FROM zepto_dataset
WHERE Category = z.Category
);

-- Common Table Expression (CTE)
WITH AvgPrice AS
(
SELECT
Category,
AVG(Price) AS Avg_Price
FROM zepto_dataset
GROUP BY Category
)

SELECT
z.Name,
z.Category,
z.Price,
a.Avg_Price
FROM zepto_dataset z
JOIN AvgPrice a
ON z.Category = a.Category;


-- Views
-- Create a reusable view for premium products.
CREATE VIEW Premium_Products AS

SELECT
Name,
Category,
Price
FROM zepto_dataset
WHERE Price > 1000;

SELECT *
FROM Premium_Products;

-- Top Rated Product in Every Category
SELECT *
FROM
(
SELECT
Category,
Name,
Ratings,
ROW_NUMBER() OVER(
PARTITION BY Category
ORDER BY Ratings DESC,
Review DESC
) AS rn
FROM zepto_dataset
) x
WHERE rn = 1;

-- Top 3 Expensive Products per Category
SELECT *
FROM
(
SELECT
Category,
Name,
Price,
ROW_NUMBER() OVER(
PARTITION BY Category
ORDER BY Price DESC
) AS rn
FROM zepto_dataset
) x
WHERE rn <= 3;