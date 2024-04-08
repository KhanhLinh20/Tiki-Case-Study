create database tiki

use tiki

select * from dbo.product_history;
select * from dbo.tiki_test;
select * from dbo.[X table];
select * from dbo.[Y table];

-- Question 1: 
-- a) Write a SQL query to find the best seller by each category.
select SellerID, Category, [Sales (Millions VND)]
from 
(
	select SellerID, Category, [Sales (Millions VND)], 
		rank() over (partition by Category order by [Sales (Millions VND)] desc) as rank
	from dbo.[X table]
) as T1
where rank = 1

-- b) Write a SQL query to find of 3 best sellers in (a), how many award did they received in 2017.
SELECT [Seller ID],
        COUNT (CASE WHEN [Award Year] = 2017 THEN 1 ELSE NULL END) AS Award_In_2017
FROM dbo.[Y table] AS T1
JOIN
        (
        SELECT SellerID, Category, [Sales (Millions VND)]
        FROM
        (
                SELECT SellerID, Category, [Sales (Millions VND)],
                        RANK() OVER (PARTITION BY Category ORDER BY [Sales (Millions VND)] DESC) AS Rank
                FROM dbo.[X table]

        ) AS T1     
        WHERE Rank = 1
        )  AS T2
ON T1.[Seller ID] = T2. SellerID
GROUP BY [Seller ID], Category
ORDER BY Category;

-- Question 2
-- (a) Write a SQL query to find the number of product that were available for sales at the end of each month.
WITH MonthlyProductAvailability AS (
  SELECT
    YEAR(ph.date) AS Month,
    COUNT(DISTINCT CASE WHEN ph.product_status = 'ON' THEN ph.product_id ELSE NULL END) AS ProductsAvailable
  FROM dbo.[product_history] ph
  GROUP BY YEAR(ph.date)
)
SELECT *
FROM MonthlyProductAvailability
ORDER BY Month;

-- (b) Average stock is calculated as: Total stock in a month/ total date in a month. Write a SQL query to find Product ID with the most “average stock” by month.
WITH MonthlyAverageStock AS (
  SELECT
    YEAR(ph.date) AS Month,
    ph.product_id,
    AVG(CAST(ph.stock AS float)) AS AverageStock
  FROM dbo.[product_history] ph
  GROUP BY YEAR(ph.date), ph.product_id
--   order by FORMAT(ph.date, 'y')
)
, MonthlyAverageStock_RANK AS (
SELECT
  Month,
  product_id,
  AverageStock,
  RANK() OVER(PARTITION BY Month ORDER BY AverageStock DESC) AS RANK
FROM MonthlyAverageStock
)
SELECT * 
FROM MonthlyAverageStock_RANK
WHERE RANK = 1
ORDER BY Month;