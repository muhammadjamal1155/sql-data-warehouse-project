/*
================================================================================
Layer        : Bronze Layer Data Quality Checks
Database     : DataWarehouse

Description:
    This script performs comprehensive data quality and consistency checks
    on tables in the Bronze layer before transforming and loading the data
    into the Silver layer.

    The validation checks include:

    1. NULL and duplicate checks on primary/business keys
    2. Unwanted whitespace and trimming checks
    3. Low-cardinality column consistency checks
    4. Negative and NULL value checks
    5. Date validation and date range checks
    6. Date relationship/consistency checks
    7. Referential integrity checks between CRM tables
    8. Sales, quantity, and price consistency checks
    9. Customer birth-date validation
    10. Country, gender, and marital-status value checks
    11. Product category and subcategory validation
    12. Referential integrity between ERP and CRM product data

Expected Result:
    Most validation queries are expected to return NO RESULTS.
    Any returned rows indicate potential data quality issues that should
    be investigated before loading data into the Silver layer.

================================================================================
*/


USE DataWarehouse;
GO


/*==============================================================================
  1. CRM CUSTOMER INFO
==============================================================================*/

SELECT *
FROM Bronze.crm_cust_info;


/*------------------------------------------------------------------------------
  Check NULL and duplicate values in customer ID

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    cst_id,
    COUNT(*) AS record_count
FROM Bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


/*------------------------------------------------------------------------------
  Check unwanted spaces in first name

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cst_firstname
FROM Bronze.crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname);


/*------------------------------------------------------------------------------
  Check unwanted spaces in last name

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cst_lastname
FROM Bronze.crm_cust_info
WHERE cst_lastname <> TRIM(cst_lastname);


/*------------------------------------------------------------------------------
  Check unwanted spaces in gender

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cst_gndr
FROM Bronze.crm_cust_info
WHERE cst_gndr <> TRIM(cst_gndr);


/*------------------------------------------------------------------------------
  Check unwanted spaces in marital status

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cst_marital_status
FROM Bronze.crm_cust_info
WHERE cst_marital_status <> TRIM(cst_marital_status);


/*------------------------------------------------------------------------------
  Check distinct gender values

  Used to identify inconsistent values such as:
  F, Female, f, M, Male, etc.
------------------------------------------------------------------------------*/

SELECT DISTINCT cst_gndr
FROM Bronze.crm_cust_info;


/*------------------------------------------------------------------------------
  Check distinct marital status values

  Used to identify inconsistent values such as:
  M, Married, S, Single, etc.
------------------------------------------------------------------------------*/

SELECT DISTINCT cst_marital_status
FROM Bronze.crm_cust_info;



/*==============================================================================
  2. CRM PRODUCT INFO
==============================================================================*/

SELECT *
FROM Bronze.crm_prd_info;


/*------------------------------------------------------------------------------
  Check NULL and duplicate values in product ID

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    prd_id,
    COUNT(*) AS record_count
FROM Bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


/*------------------------------------------------------------------------------
  Check unwanted spaces in product name

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT prd_nm
FROM Bronze.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);


/*------------------------------------------------------------------------------
  Check product cost for negative or NULL values

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT prd_cost
FROM Bronze.crm_prd_info
WHERE prd_cost < 0
   OR prd_cost IS NULL;


/*------------------------------------------------------------------------------
  Check distinct product line values

  Used to identify inconsistent values before standardization.
------------------------------------------------------------------------------*/

SELECT DISTINCT prd_line
FROM Bronze.crm_prd_info;


/*------------------------------------------------------------------------------
  Check product date consistency

  End date should not be earlier than start date.

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT *
FROM Bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;



/*==============================================================================
  3. CRM SALES DETAILS
==============================================================================*/

SELECT *
FROM Bronze.crm_sales_details;


/*------------------------------------------------------------------------------
  Supporting table checks
------------------------------------------------------------------------------*/

SELECT *
FROM Bronze.crm_cust_info;

SELECT *
FROM Bronze.crm_prd_info;


/*------------------------------------------------------------------------------
  Check unwanted spaces in sales order number

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT sls_ord_num
FROM Bronze.crm_sales_details
WHERE sls_ord_num <> TRIM(sls_ord_num);


/*------------------------------------------------------------------------------
  Check customer ID relationship

  Every sales customer ID should exist in the customer table.

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM Bronze.crm_sales_details
WHERE sls_cust_id NOT IN (
    SELECT cst_id
    FROM Silver.crm_cust_info
);


/*------------------------------------------------------------------------------
  Check product key relationship

  Every sales product key should exist in the product table.

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM Bronze.crm_sales_details
WHERE sls_prd_key NOT IN (
    SELECT prd_key
    FROM Silver.crm_prd_info
);


/*------------------------------------------------------------------------------
  Check invalid order dates

  Conditions:
  - Date is zero or negative
  - Date does not contain 8 digits
  - Date is after 2050
  - Date is before 1900

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    sls_order_dt
FROM Bronze.crm_sales_details
WHERE sls_order_dt <= 0
   OR LEN(sls_order_dt) <> 8
   OR sls_order_dt > 20500101
   OR sls_order_dt < 19000101;


/*------------------------------------------------------------------------------
  Check invalid shipping dates

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    sls_ship_dt
FROM Bronze.crm_sales_details
WHERE sls_ship_dt <= 0
   OR LEN(sls_ship_dt) <> 8
   OR sls_ship_dt > 20500101
   OR sls_ship_dt < 19000101;


/*------------------------------------------------------------------------------
  Check invalid due dates

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    sls_due_dt
FROM Bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LEN(sls_due_dt) <> 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;


/*------------------------------------------------------------------------------
  Check date consistency

  Expected relationship:

      Order Date <= Ship Date
      Order Date <= Due Date

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT *
FROM Bronze.crm_sales_details
WHERE sls_ship_dt < sls_order_dt
   OR sls_due_dt < sls_order_dt;


/*------------------------------------------------------------------------------
  Check sales, quantity, and price consistency

  Expected:

      Sales = Quantity × Price

  Also checks for:
      - NULL values
      - Zero values
      - Negative values

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM Bronze.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY
    sls_sales,
    sls_quantity,
    sls_price;



/*==============================================================================
  4. ERP CUSTOMER
==============================================================================*/

SELECT *
FROM Bronze.erp_cust_az12;

SELECT *
FROM Bronze.crm_cust_info;


/*------------------------------------------------------------------------------
  Check NULL and duplicate customer IDs

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    cid,
    COUNT(*) AS record_count
FROM Bronze.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1
    OR cid IS NULL;


/*------------------------------------------------------------------------------
  Check unwanted spaces in customer ID

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cid
FROM Bronze.erp_cust_az12
WHERE cid <> TRIM(cid);


/*------------------------------------------------------------------------------
  Check customer birth dates

  Birth date should not:
      - Be before 1924
      - Be in the future

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT DISTINCT bdate
FROM Bronze.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();


/*------------------------------------------------------------------------------
  Check distinct gender values
------------------------------------------------------------------------------*/

SELECT DISTINCT gen
FROM Bronze.erp_cust_az12;


/*------------------------------------------------------------------------------
  Check unwanted spaces in gender

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT gen
FROM Bronze.erp_cust_az12
WHERE gen <> TRIM(gen);



/*==============================================================================
  5. ERP LOCATION
==============================================================================*/

SELECT *
FROM Bronze.erp_loc_a101;


/*------------------------------------------------------------------------------
  Check NULL and duplicate customer IDs

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    cid,
    COUNT(*) AS record_count
FROM Bronze.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1
    OR cid IS NULL;


/*------------------------------------------------------------------------------
  Check unwanted spaces in customer ID

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cid
FROM Bronze.erp_loc_a101
WHERE cid <> TRIM(cid);


/*------------------------------------------------------------------------------
  Check distinct country values

  Used to identify inconsistent country representations such as:
  DE, Germany, USA, US, United States, etc.
------------------------------------------------------------------------------*/

SELECT DISTINCT cntry
FROM Bronze.erp_loc_a101;



/*==============================================================================
  6. ERP PRODUCT CATEGORY
==============================================================================*/

SELECT *
FROM Bronze.erp_px_cat_g1v2;

SELECT *
FROM Silver.crm_prd_info;


/*------------------------------------------------------------------------------
  Check NULL and duplicate category IDs

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    id,
    COUNT(*) AS record_count
FROM Bronze.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1
    OR id IS NULL;


/*------------------------------------------------------------------------------
  Check unwanted spaces in category ID

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT id
FROM Bronze.erp_px_cat_g1v2
WHERE id <> TRIM(id);


/*------------------------------------------------------------------------------
  Check category IDs that do not exist in CRM product information

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT id
FROM Bronze.erp_px_cat_g1v2
WHERE id NOT IN (
    SELECT cat_id
    FROM Silver.crm_prd_info
);


/*------------------------------------------------------------------------------
  Check distinct category values
------------------------------------------------------------------------------*/

SELECT DISTINCT cat
FROM Bronze.erp_px_cat_g1v2;


/*------------------------------------------------------------------------------
  Check unwanted spaces in category

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cat
FROM Bronze.erp_px_cat_g1v2
WHERE cat <> TRIM(cat);


/*------------------------------------------------------------------------------
  Check distinct subcategory values
------------------------------------------------------------------------------*/

SELECT DISTINCT subcat
FROM Bronze.erp_px_cat_g1v2;


/*------------------------------------------------------------------------------
  Check unwanted spaces in subcategory

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT subcat
FROM Bronze.erp_px_cat_g1v2
WHERE subcat <> TRIM(subcat);


/*------------------------------------------------------------------------------
  Check distinct maintenance values
------------------------------------------------------------------------------*/

SELECT DISTINCT maintenance
FROM Bronze.erp_px_cat_g1v2;


/*------------------------------------------------------------------------------
  Check unwanted spaces in maintenance

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT maintenance
FROM Bronze.erp_px_cat_g1v2
WHERE maintenance <> TRIM(maintenance);



/*==============================================================================
  END OF BRONZE DATA QUALITY CHECKS
==============================================================================*/
