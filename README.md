# online-retail-sales-analysis
SQL-based retail sales analysis including customer segmentation, Pareto Analysis, return validation, and sales insights.
The project uses Databricks SQL to clean, transform, and analyze transactional data, generating insights useful for marketing, merchandising, and retention strategies.

Business Problem:
- Retail companies need to understand:
    * Which customers drive most of the revenue
    * Which products perform best or worst
    * How customer behavior changes over time
    * Whether negative quantities represent legitimate returns

This analysis answers those questions using SQL-driven exploratory analysis and segmentation techniques.

Dataset:
The dataset used corresponds to a public Online Retail transactional dataset commonly used for analytics practice.

Main fields include:
1. InvoiceNo – transaction identifier
1. StockCode – product identifier
3. Description – product name
4. Quantity – number of items purchased
5. InvoiceDate – date and time of the transaction
6. UnitPrice – product price
7. CustomerID – customer identifier
8. Country – customer location

NOTE: A cleaned table (data_1_final_2) was created to standardize fields and facilitate analysis.

Methodology:
The analysis was performed using Databricks SQL and includes:

1. Data Cleaning:
- Standardized invoice timestamps
- Verified negative quantities representing product returns

2. Exploratory Analysis:
- Monthly sales trends
- Customer purchase frequency
- Product sales ranking

3. Customer Segmentation
- Customers were segmented using SQL window functions (NTILE) based on total spending:
- High Value Customers
- Medium Value Customers
- Low Value Customers

4. Pareto Analysis:
- Following the Pareto Principle (80/20 rule), revenue contribution by customer segments was evaluated.

5. Product Performance:
- Identification of:
   * Top selling products
   * Least selling products

6. Return Validation:
- Negative quantities were validated against positive transactions to identify confirmed returns vs unmatched negative records.

Key Insights:
1. Customer Segmentation: A small group of High Value customers generates the majority of the revenue, confirming a Pareto-like distribution.
2. Revenue Concentration: High Value customers contribute approximately 80% of total revenue, highlighting the importance of retention strategies.
3. Product Performance: A small subset of products drives most of the sales, while several products show very low sales volumes, suggesting potential catalog optimization.
4. Customer Behavior: Registered customers show higher purchase frequency and stronger seasonal patterns compared to guest customers.
5. Returns: Most negative quantities correspond to validated product returns, though a subset of unmatched negatives suggests operational adjustments or data inconsistencies.

Visualizations:
- Monthly Sales Trend
- Customer Segmentation
- Pareto Revenue Contribution
- Purchase Frequency by Customer Type
- Top Selling Products

SQL Techniques Used:
- This project demonstrates several SQL concepts commonly used in data analytics:
- Common Table Expressions (CTEs)
- Window Functions (NTILE)
- Aggregation (SUM, COUNT)
- CASE logic for segmentation
- Data validation using EXISTS
- Filtering and grouping strategies
- The full queries used in the analysis can be found in: queries/analysis_queries.sql

Repository Structure:
online-retail-sales-analysis
│
├── notebook
│   └── retail_sales_analysis.html
│
├── queries
│   └── analysis_queries.sql
│
├── images
│   ├── monthly_sales_trend.png
│   ├── customer_segmentation.png
│   ├── pareto_revenue_contribution.png
│   ├── purchase_frequency_registered_vs_guest.png
│   ├── top_10_products.png
│   └── bottom_10_products.png
│
└── README.md

Tools Used:
- Databricks
- SQL
- GitHub

Author:
Rafael Picazo Schroeder
Biomedical Engineer transitioning into Data Analytics.

This project is part of my analytics portfolio demonstrating SQL-based data analysis and business insights generation.
