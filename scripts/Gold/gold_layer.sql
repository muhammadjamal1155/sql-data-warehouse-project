/*
===============================================================================
Gold Layer - Dimension and Fact Views
===============================================================================

Description:
This script creates business-ready views in the Gold layer of the data
warehouse. The Gold layer follows a Star Schema design and integrates
cleaned data from the Silver layer for reporting, analytics, and Power BI.

Views Created:
1. Gold.dim_customers
   - Combines CRM customer data with ERP demographic and location data.
   - Uses CRM as the master source for customer attributes.
   - Uses ERP data to fill missing gender information.
   - Generates a surrogate customer key.

2. Gold.dim_products
   - Combines CRM product data with ERP category information.
   - Includes only currently active products.
   - Generates a surrogate product key.

3. Gold.fact_sales
   - Contains sales transactions linked to customer and product dimensions.
   - Includes order, customer, product, date, sales, quantity, and price data.

Data Flow:
Bronze Layer → Silver Layer → Gold Layer

Purpose:
The Gold layer provides clean, integrated, and business-ready data for
reporting, analytics, dashboard development, and business intelligence.
===============================================================================
*/


-- ============================================================================
-- Customer Dimension
-- ============================================================================
CREATE VIEW Gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    cl.cntry AS country,
    ci.cst_marital_status AS martial_status,

    -- CRM is the master source for gender.
    -- If CRM gender is unavailable, use the ERP value.
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a') 
    END AS gender,

    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date

FROM Silver.crm_cust_info AS ci

-- Add customer demographic information from ERP
LEFT JOIN Silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid

-- Add customer location information from ERP
LEFT JOIN Silver.erp_loc_a101 AS cl
    ON ci.cst_key = cl.cid;


-- ============================================================================
-- Product Dimension
-- ============================================================================
GO

CREATE VIEW Gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (
        ORDER BY pr.prd_start_dt, pr.prd_key
    ) AS product_key,

    pr.prd_id AS product_id,
    pr.prd_key AS product_number,
    pr.prd_nm AS product_name,
    pr.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pr.prd_cost AS cost,
    pr.prd_line AS product_line,
    pr.prd_start_dt AS start_date

FROM Silver.crm_prd_info AS pr

-- Add category and subcategory information
LEFT JOIN Silver.erp_px_cat_g1v2 AS pc
    ON pr.cat_id = pc.id

-- Include only currently active products
WHERE pr.prd_end_dt IS NULL;


-- ============================================================================
-- Sales Fact Table
-- ============================================================================
GO

CREATE VIEW Gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    dp.product_key,
    dc.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price

FROM Silver.crm_sales_details AS sd

-- Connect sales to customer dimension
LEFT JOIN Gold.dim_customers AS dc
    ON sd.sls_cust_id = dc.customer_id

-- Connect sales to product dimension
LEFT JOIN Gold.dim_products AS dp
    ON sd.sls_prd_key = dp.product_number;
