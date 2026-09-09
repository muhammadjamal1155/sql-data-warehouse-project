/*
================================================================================
Layer        : Silver Layer Data Quality Checks
Database     : DataWarehouse

Description:
    This script performs data quality and transformation validation checks
    on tables in the Silver layer.

    The purpose of these checks is to verify that:
    
    1. Primary and business keys contain no NULL or duplicate values
    2. Text columns contain no unwanted leading/trailing spaces
    3. Low-cardinality columns contain standardized values
    4. Numeric columns contain valid values
    5. Date columns contain valid and logically consistent dates
    6. Sales calculations are mathematically consistent
    7. Customer and product relationships are maintained
    8. ERP data has been correctly transformed and standardized
    9. Category and product relationships are valid

Expected Result:
    Most validation queries should return NO RESULTS.
    
    Any returned rows indicate a potential data quality or transformation
    issue that should be investigated before using the Silver layer for
    further transformations or loading into the Gold layer.

================================================================================
*/


USE DataWarehouse;
GO


/*==============================================================================
  1. SILVER CRM CUSTOMER INFO
==============================================================================*/

SELECT *
FROM Silver.crm_cust_info;


/*------------------------------------------------------------------------------
  Check NULL and duplicate values in customer ID

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    cst_id,
    COUNT(*) AS record_count
FROM Silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


/*------------------------------------------------------------------------------
  Check unwanted spaces in first name

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cst_firstname
FROM Silver.crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname);


/*------------------------------------------------------------------------------
  Check unwanted spaces in last name

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cst_lastname
FROM Silver.crm_cust_info
WHERE cst_lastname <> TRIM(cst_lastname);


/*------------------------------------------------------------------------------
  Check unwanted spaces in gender

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cst_gndr
FROM Silver.crm_cust_info
WHERE cst_gndr <> TRIM(cst_gndr);


/*------------------------------------------------------------------------------
  Check unwanted spaces in marital status

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cst_marital_status
FROM Silver.crm_cust_info
WHERE cst_marital_status <> TRIM(cst_marital_status);


/*------------------------------------------------------------------------------
  Check standardized gender values

  Expected values:
      Female
      Male
      n/a
------------------------------------------------------------------------------*/

SELECT DISTINCT cst_gndr
FROM Silver.crm_cust_info;


/*------------------------------------------------------------------------------
  Check standardized marital status values

  Expected values:
      Married
      Single
      n/a
------------------------------------------------------------------------------*/

SELECT DISTINCT cst_marital_status
FROM Silver.crm_cust_info;



/*==============================================================================
  2. SILVER CRM PRODUCT INFO
==============================================================================*/

SELECT *
FROM Silver.crm_prd_info;


/*------------------------------------------------------------------------------
  Check NULL and duplicate values in product ID

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    prd_id,
    COUNT(*) AS record_count
FROM Silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


/*------------------------------------------------------------------------------
  Check unwanted spaces in product name

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT prd_nm
FROM Silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);


/*------------------------------------------------------------------------------
  Check product cost for NULL or negative values

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT prd_cost
FROM Silver.crm_prd_info
WHERE prd_cost < 0
   OR prd_cost IS NULL;


/*------------------------------------------------------------------------------
  Check standardized product line values

  Expected values:
      Road
      Mountain
      Other Sales
      n/a
------------------------------------------------------------------------------*/

SELECT DISTINCT prd_line
FROM Silver.crm_prd_info;


/*------------------------------------------------------------------------------
  Check product date consistency

  End date should never be earlier than start date.

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT *
FROM Silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


/*------------------------------------------------------------------------------
  Check product start and end dates

  End dates should be NULL for currently active products or
  greater than/equal to their start dates.

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT *
FROM Silver.crm_prd_info
WHERE prd_end_dt IS NOT NULL
  AND prd_end_dt < prd_start_dt;



/*==============================================================================
  3. SILVER CRM SALES DETAILS
==============================================================================*/

SELECT *
FROM Silver.crm_sales_details;


/*------------------------------------------------------------------------------
  Check date consistency

  Expected relationship:

      Order Date <= Ship Date
      Order Date <= Due Date

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT *
FROM Silver.crm_sales_details
WHERE sls_ship_dt < sls_order_dt
   OR sls_due_dt < sls_order_dt;


/*------------------------------------------------------------------------------
  Check sales, quantity, and price consistency

  Expected:

      Sales = Quantity × Price

  Also checks:
      - NULL values
      - Zero values
      - Negative values

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM Silver.crm_sales_details
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


/*------------------------------------------------------------------------------
  Check NULL values in important sales columns

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT *
FROM Silver.crm_sales_details
WHERE sls_ord_num IS NULL
   OR sls_prd_key IS NULL
   OR sls_cust_id IS NULL
   OR sls_order_dt IS NULL
   OR sls_quantity IS NULL
   OR sls_sales IS NULL
   OR sls_price IS NULL;



/*==============================================================================
  4. SILVER ERP CUSTOMER
==============================================================================*/

SELECT *
FROM Silver.erp_cust_az12;


/*------------------------------------------------------------------------------
  Check NULL and duplicate customer IDs

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    cid,
    COUNT(*) AS record_count
FROM Silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1
    OR cid IS NULL;


/*------------------------------------------------------------------------------
  Check unwanted spaces in customer ID

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cid
FROM Silver.erp_cust_az12
WHERE cid <> TRIM(cid);


/*------------------------------------------------------------------------------
  Check future birth dates

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT DISTINCT bdate
FROM Silver.erp_cust_az12
WHERE bdate > GETDATE();


/*------------------------------------------------------------------------------
  Check standardized gender values

  Expected values:
      Female
      Male
      n/a
------------------------------------------------------------------------------*/

SELECT DISTINCT gen
FROM Silver.erp_cust_az12;


/*------------------------------------------------------------------------------
  Check unwanted spaces in gender

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT gen
FROM Silver.erp_cust_az12
WHERE gen <> TRIM(gen);



/*==============================================================================
  5. SILVER ERP LOCATION
==============================================================================*/

SELECT *
FROM Silver.erp_loc_a101;


/*------------------------------------------------------------------------------
  Check NULL and duplicate customer IDs

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    cid,
    COUNT(*) AS record_count
FROM Silver.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1
    OR cid IS NULL;


/*------------------------------------------------------------------------------
  Check unwanted spaces in customer ID

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cid
FROM Silver.erp_loc_a101
WHERE cid <> TRIM(cid);


/*------------------------------------------------------------------------------
  Check standardized country values

  Expected values include:
      Germany
      United States
      Australia
      United Kingdom
      Canada
      France
      n/a
------------------------------------------------------------------------------*/

SELECT DISTINCT cntry
FROM Silver.erp_loc_a101;



/*==============================================================================
  6. SILVER ERP PRODUCT CATEGORY
==============================================================================*/

SELECT *
FROM Silver.erp_px_cat_g1v2;


/*------------------------------------------------------------------------------
  Check NULL and duplicate category IDs

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT 
    id,
    COUNT(*) AS record_count
FROM Silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1
    OR id IS NULL;


/*------------------------------------------------------------------------------
  Check unwanted spaces in category ID

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT id
FROM Silver.erp_px_cat_g1v2
WHERE id <> TRIM(id);


/*------------------------------------------------------------------------------
  Check category IDs against CRM product information

  Every category ID should exist in CRM product information.

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT id
FROM Silver.erp_px_cat_g1v2
WHERE id NOT IN (
    SELECT cat_id
    FROM Silver.crm_prd_info
);


/*------------------------------------------------------------------------------
  Check standardized category values
------------------------------------------------------------------------------*/

SELECT DISTINCT cat
FROM Silver.erp_px_cat_g1v2;


/*------------------------------------------------------------------------------
  Check unwanted spaces in category

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT cat
FROM Silver.erp_px_cat_g1v2
WHERE cat <> TRIM(cat);


/*------------------------------------------------------------------------------
  Check standardized subcategory values
------------------------------------------------------------------------------*/

SELECT DISTINCT subcat
FROM Silver.erp_px_cat_g1v2;


/*------------------------------------------------------------------------------
  Check unwanted spaces in subcategory

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT subcat
FROM Silver.erp_px_cat_g1v2
WHERE subcat <> TRIM(subcat);


/*------------------------------------------------------------------------------
  Check distinct maintenance values
------------------------------------------------------------------------------*/

SELECT DISTINCT maintenance
FROM Silver.erp_px_cat_g1v2;


/*------------------------------------------------------------------------------
  Check unwanted spaces in maintenance

  Expectation: No Results
------------------------------------------------------------------------------*/

SELECT maintenance
FROM Silver.erp_px_cat_g1v2
WHERE maintenance <> TRIM(maintenance);



/*==============================================================================
  7. FINAL SILVER LAYER DATA REVIEW
==============================================================================*/


/*------------------------------------------------------------------------------
  Review all Silver layer tables
------------------------------------------------------------------------------*/

SELECT *
FROM Silver.crm_cust_info;

SELECT *
FROM Silver.crm_prd_info;

SELECT *
FROM Silver.crm_sales_details;

SELECT *
FROM Silver.erp_cust_az12;

SELECT *
FROM Silver.erp_loc_a101;

SELECT *
FROM Silver.erp_px_cat_g1v2;


/*==============================================================================
  END OF SILVER LAYER DATA QUALITY CHECKS
==============================================================================*/
