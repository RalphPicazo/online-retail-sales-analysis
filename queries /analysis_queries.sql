</> SQL
============================================================================
1. DATA CLEANING
============================================================================
- Invoice Date to timestamp data type

CREATE TABLE data_1_clean
AS
SELECT *, to_timestamp(InvoiceDate, 'MM/dd/yy H:mm') AS InvoiceDate_clean
FROM data_1;

- Standardize invoice date and create clean table

-- Upon reviewing the dataset, I found that some dates were in a different format, so the month and day sections were made a bit more flexible.
-- A new table was created to have the Invoice_timestamp column with the correct data type.
CREATE TABLE data_1_clean AS
SELECT
    *,
    CASE
        WHEN InvoiceDate RLIKE '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2} [0-9]{1,2}:[0-9]{2}$'
            THEN to_timestamp(InvoiceDate, 'M/d/yy H:mm')
        WHEN InvoiceDate RLIKE '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{2}$'
            THEN to_timestamp(InvoiceDate, 'M/d/yyyy H:mm')
        ELSE NULL
    END AS Invoice_timestamp
FROM data_1;

============================================================================
2. SALES TREND ANALYSIS
============================================================================
- Monthly sales trend

SELECT
  invoice_date,
  ROUND(SUM(total),2) AS total_revenue_per_month
FROM data_1_final_2
GROUP BY invoice_date
HAVING total_revenue_per_month > 0 -- Excluding negative values ​​to obtain actual sales
ORDER BY invoice_date ASC;

============================================================================
3. CUSTOMER SEGMENTATION
============================================================================
- Segment customer into High / Medium / Low Value

-- According to the Pareto Principle, 20% of customers generate 80% of revenue.
-- Based on this...
-- High Level Customers = Top 20% of customers by revenue
-- Medium Level Customers = Remaining 30%
-- Low Level Customers = The other 50% of customers
-- Ranking is used for segmentation.
-- Customers were segmented based on their total purchase value using percentile distribution.
WITH segmented_customers AS (
WITH customer_spending AS ( -- WITH is used to create CTE for each calculation
  SELECT
    CustomerID,
    ROUND(SUM(total),2) AS total_spent
  FROM data_1_final_2
  GROUP BY CustomerID
),
customer_percentiles AS (
  SELECT
    CustomerID,
    total_spent,
    NTILE(5) OVER (ORDER BY total_spent DESC) AS spending_group
  FROM customer_spending
)
SELECT
  CustomerID,
  total_spent,
  CASE
    WHEN spending_group = 1 THEN '01-High Value'
    WHEN spending_group IN (2,3) THEN '02-Medium Value'
    ELSE '03-Low Value'
  END AS customer_segment
FROM customer_percentiles
ORDER BY total_spent DESC
)
SELECT
  customer_segment,
  COUNT (*) AS number_of_customers
FROM segmented_customers
GROUP BY customer_segment
ORDER BY customer_segment;

============================================================================
4. PARETO ANALYSIS
============================================================================
- Revenue contribution by customer segment

-- Based on the Pareto Principle (80/20 rule), the analysis reveals a strong revenue concentration among a small portion of customers. High-value customers generate approximately 80% of the total revenue, highlighting the significant impact of this segment on overall business performance.
WITH segmented_customers AS (
  WITH customer_spending AS ( 
  SELECT
    CustomerID,
    ROUND(SUM(total),2) AS total_spent
  FROM data_1_final_2
  GROUP BY CustomerID
),
customer_percentiles AS (
  SELECT
    CustomerID,
    total_spent,
    NTILE(5) OVER (ORDER BY total_spent DESC) AS spending_group
  FROM customer_spending
)
SELECT
  CustomerID,
  total_spent,
  CASE
    WHEN spending_group = 1 THEN 'High Value'
    WHEN spending_group IN (2,3) THEN 'Medium Value'
    ELSE 'Low Value'
  END AS customer_segment
FROM customer_percentiles
ORDER BY total_spent DESC
)
SELECT
  customer_segment,
  ROUND(SUM(total_spent),2) AS total_revenue_per_segment,
  ROUND(SUM(total_spent) / SUM(SUM(total_spent)) OVER() * 100,2) AS total_revenue_percentage
FROM segmented_customers
GROUP BY customer_segment;

============================================================================
5. CUSTOMER BEHAVIOR
============================================================================
- Monthly purchase frequency by customer type

SELECT
  CASE
    WHEN CustomerID IS NULL THEN 'Not Registered' ELSE 'Registered'
  END AS Customer_type,
  COUNT(*) AS total_customers,
  CASE 
    WHEN invoice_month = 1 THEN '01-Jan'
    WHEN invoice_month = 2 THEN '02-Feb'
    WHEN invoice_month = 3 THEN '03-Mar'
    WHEN invoice_month = 4 THEN '04-Apr'
    WHEN invoice_month = 5 THEN '05-May'
    WHEN invoice_month = 6 THEN '06-Jun'
    WHEN invoice_month = 7 THEN '07-Jul'
    WHEN invoice_month = 8 THEN '08-Aug'
    WHEN invoice_month = 9 THEN '09-Sep'
    WHEN invoice_month = 10 THEN '10-Oct'
    WHEN invoice_month = 11 THEN '11-Nov'
    WHEN invoice_month = 12 THEN '12-Dec'
  END AS invoice_month_name
FROM data_1_final_2
GROUP BY Customer_type, invoice_month_name
ORDER BY Customer_type, invoice_month_name;

============================================================================
6. PRODUCT ANALYSIS
============================================================================
- Top selling products

SELECT
  Description,
  SUM(Quantity) AS total_sold
FROM data_1_final_2
WHERE Quantity > 0 -- Exclusion of negative values (returns)
GROUP BY Description
ORDER BY total_sold DESC
LIMIT 10;

- Least-selling products

SELECT
  Description,
  SUM(Quantity) AS total_sold
FROM data_1_final_2
GROUP BY Description
HAVING total_sold > 0 -- Exclusion of negative values (returns)
ORDER BY total_sold ASC
LIMIT 10;

============================================================================
7. RETURN VALIDATION
============================================================================
- Validate negative quantities as returns

-- Getting the matched negative returns to check how many there are
SELECT
    COUNT(*) AS matched_negative_returns
FROM data_1_final_2 n
WHERE n.Quantity < 0
  AND EXISTS (
      SELECT 1
      FROM data_1_final_2 p
      WHERE p.Quantity > 0
        AND p.StockCode = n.StockCode
        AND p.Quantity = ABS(n.Quantity)
        AND p.UnitPrice = n.UnitPrice
        AND (
              (n.CustomerID IS NOT NULL AND p.CustomerID = n.CustomerID)
              OR
              (n.CustomerID IS NULL)
            )
  );

-- Getting the unmatched negative returns to check how many there are
SELECT
    COUNT(*) AS unmatched_negative_returns
FROM data_1_final_2 n
WHERE n.Quantity < 0
  AND NOT EXISTS (
      SELECT 1
      FROM data_1_final_2 p
      WHERE p.Quantity > 0
        AND p.StockCode = n.StockCode
        AND p.Quantity = ABS(n.Quantity)
        AND p.UnitPrice = n.UnitPrice
        AND (
              (n.CustomerID IS NOT NULL AND p.CustomerID = n.CustomerID)
              OR
              (n.CustomerID IS NULL)
            )
  );
