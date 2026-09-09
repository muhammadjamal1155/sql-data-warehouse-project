/*
===============================================================================
Gold Layer - Data Quality and Validation Checks
===============================================================================

Description:
This script performs data quality checks on the Gold layer and validates the
joins between CRM and ERP sources used to build the dimensional model.

The checks focus on:

1. Customer Join Validation
   - Checks whether joins between customer, demographic, and location tables
     create duplicate customer records.

2. Customer Attribute Consistency
   - Compares gender values from CRM and ERP sources to identify matching or
     conflicting values.
   - CRM is treated as the master source for customer gender.

3. Customer Dimension Validation
   - Reviews the Gold customer dimension.
   - Checks the distinct gender values available in the final dimension.

4. Product Join Validation
   - Checks whether joining product and category tables creates duplicate
     active product records.

5. Product Dimension Validation
   - Reviews the final Gold product dimension.

6. Fact Table Validation
   - Checks whether sales records can successfully connect to both customer
     and product dimensions.
   - Records with missing dimension keys indicate broken relationships or
     unmatched source data.

Purpose:
These validation queries help ensure that the Gold layer is accurate,
consistent, and ready for reporting, analytics, and Power BI.

Data Flow:
Bronze Layer → Silver Layer → Gold Layer → Data Quality Checks
===============================================================================
*/


-- ============================================================================
-- 1. CHECK FOR DUPLICATES CAUSED BY CUSTOMER JOINS
-- ============================================================================
-- Expected Result: No rows
-- If rows are returned, one customer is being duplicated because of the joins.

SELECT 
    t.cst_id,
    COUNT(*) AS record_count
FROM 
(
    SELECT 
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_gndr,
        ci.cst_marital_status,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        cl.cntry

    FROM Silver.crm_cust_info AS ci

    LEFT JOIN Silver.erp_cust_az12 AS ca
        ON ci.cst_key = ca.cid

    LEFT JOIN Silver.erp_loc_a101 AS cl
        ON ci.cst_key = cl.cid

) AS t

GROUP BY t.cst_id
HAVING COUNT(*) > 1;


-- ============================================================================
-- 2. CHECK CUSTOMER GENDER VALUES FROM DIFFERENT SOURCES
-- ============================================================================
-- Compares gender values from CRM and ERP for the same customer.
-- This helps identify matching and conflicting values between the sources.

SELECT DISTINCT
    ci.cst_gndr AS crm_gender,
    ca.gen AS erp_gender

FROM Silver.crm_cust_info AS ci

LEFT JOIN Silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid

LEFT JOIN Silver.erp_loc_a101 AS cl
    ON ci.cst_key = cl.cid

ORDER BY 1, 2;


-- ============================================================================
-- 3. VALIDATE CUSTOMER DIMENSION IN GOLD LAYER
-- ============================================================================
-- Review the final customer dimension created in the Gold layer.

SELECT *
FROM Gold.dim_customers;


-- Check the distinct gender values available in the Gold customer dimension.

SELECT DISTINCT 
    gender
FROM Gold.dim_customers;


-- ============================================================================
-- 4. CHECK FOR DUPLICATES CAUSED BY PRODUCT JOINS
-- ============================================================================
-- Expected Result: No rows
-- Checks whether joining active products with the category table creates
-- duplicate product records.

SELECT 
    prd_key,
    COUNT(*) AS record_count

FROM
(
    SELECT 
        pr.prd_id,
        pr.cat_id,
        pr.prd_key,
        pr.prd_nm,
        pr.prd_cost,
        pr.prd_line,
        pr.prd_start_dt,
        pc.cat,
        pc.subcat,
        pc.maintenance

    FROM Silver.crm_prd_info AS pr

    LEFT JOIN Silver.erp_px_cat_g1v2 AS pc
        ON pr.cat_id = pc.id

    WHERE pr.prd_end_dt IS NULL

) AS t

GROUP BY prd_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- 5. VALIDATE PRODUCT DIMENSION IN GOLD LAYER
-- ============================================================================
-- Review the final product dimension created in the Gold layer.

SELECT *
FROM Gold.dim_products;


-- ============================================================================
-- 6. VALIDATE FACT TABLE DIMENSION RELATIONSHIPS
-- ============================================================================
-- Checks whether sales records successfully connect to both customer and
-- product dimensions through their surrogate keys.
--
-- Expected Result: No rows
-- If rows are returned, the sales record has no matching customer AND
-- product dimension record.

SELECT *
FROM Gold.fact_sales AS f

LEFT JOIN Gold.dim_customers AS c
    ON f.customer_key = c.customer_key

LEFT JOIN Gold.dim_products AS p
    ON f.product_key = p.product_key

WHERE c.customer_key IS NULL
  AND p.product_key IS NULL;
