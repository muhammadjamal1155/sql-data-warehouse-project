/*
===============================================================================
DDL Script: Create Silver Layer Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'Silver' schema, dropping existing 
    tables if they already exist.
    Run this script to re-define the DDL structure of the 'Silver' tables.

    The Silver layer holds cleansed, standardized, and conformed data 
    derived from the Bronze layer (raw CRM and ERP source data). Each 
    table includes a 'dwh_create_date' column to track when the record 
    was loaded into the data warehouse.

Tables Created:
    - Silver.crm_cust_info
    - Silver.crm_prd_info
    - Silver.crm_sales_details
    - Silver.erp_loc_a101
    - Silver.erp_cust_az12
    - Silver.erp_px_cat_g1v2

WARNING:
    Running this script will drop the entire 'Silver' tables listed above
    if they exist. All data in these tables will be permanently deleted.
    Ensure you have proper backups before running this script.
===============================================================================
*/

IF OBJECT_ID('Silver.crm_cust_info' , 'U') IS NOT NULL
    DROP TABLE Silver.crm_cust_info
CREATE TABLE Silver.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

GO
IF OBJECT_ID('Silver.crm_prd_info' , 'U') IS NOT NULL
    DROP TABLE Silver.crm_prd_info
CREATE TABLE Silver.crm_prd_info(
	prd_id INT,
	cat_id  NVARCHAR(50),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

GO
IF OBJECT_ID('Silver.crm_sales_details' , 'U') IS NOT NULL
    DROP TABLE Silver.crm_sales_details
CREATE TABLE Silver.crm_sales_details(
	sls_ord_num	NVARCHAR(50),
	sls_prd_key	NVARCHAR(50),
	sls_cust_id	INT,
	sls_order_dt DATE,
	sls_ship_dt	 DATE,
	sls_due_dt DATE,
	sls_sales	INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

GO

IF OBJECT_ID('Silver.erp_loc_a101' , 'U') IS NOT NULL
    DROP TABLE Silver.erp_loc_a101
CREATE TABLE Silver.erp_loc_a101(
	cid NVARCHAR(50),
	cntry NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

GO
IF OBJECT_ID('Silver.erp_cust_az12' , 'U') IS NOT NULL
    DROP TABLE Silver.erp_cust_az12
CREATE TABLE Silver.erp_cust_az12(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

GO
IF OBJECT_ID('Silver.erp_px_cat_g1v2' , 'U') IS NOT NULL
    DROP TABLE Silver.erp_px_cat_g1v2
CREATE TABLE Silver.erp_px_cat_g1v2(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
