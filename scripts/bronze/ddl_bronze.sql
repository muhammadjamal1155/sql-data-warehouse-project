-- =============================================================================
-- Create Bronze Layer Tables
-- =============================================================================
-- This script creates tables in the 'Bronze' schema, dropping existing tables 
-- if they already exist. The Bronze layer stores raw, unprocessed data loaded 
-- directly from source systems (CRM and ERP).
-- =============================================================================

-- ------------------------------------------------------------------------------
-- Table: Bronze.crm_cust_info
-- Purpose: Stores raw customer master data from the CRM system 
--          (ID, name, marital status, gender, and account creation date).
-- Logic: Checks if the table already exists using OBJECT_ID; if it does, 
--        drops it first so the table can be recreated with the latest structure.
-- ------------------------------------------------------------------------------
IF OBJECT_ID('Bronze.crm_cust_info' , 'U') IS NOT NULL
    DROP TABLE Bronze.crm_cust_info
CREATE TABLE Bronze.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);
GO

-- ------------------------------------------------------------------------------
-- Table: Bronze.crm_prd_info
-- Purpose: Stores raw product master data from the CRM system 
--          (ID, key, name, cost, product line, and start/end availability dates).
-- Logic: Checks if the table already exists using OBJECT_ID; if it does, 
--        drops it first so the table can be recreated with the latest structure.
-- ------------------------------------------------------------------------------
IF OBJECT_ID('Bronze.crm_prd_info' , 'U') IS NOT NULL
    DROP TABLE Bronze.crm_prd_info
CREATE TABLE Bronze.crm_prd_info(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME
);
GO

-- ------------------------------------------------------------------------------
-- Table: Bronze.crm_sales_details
-- Purpose: Stores raw sales transaction data from the CRM system 
--          (order number, product key, customer ID, order/ship/due dates, 
--          sales amount, quantity, and price).
-- Logic: Checks if the table already exists using OBJECT_ID; if it does, 
--        drops it first so the table can be recreated with the latest structure.
-- ------------------------------------------------------------------------------
IF OBJECT_ID('Bronze.crm_sales_details' , 'U') IS NOT NULL
    DROP TABLE Bronze.crm_sales_details
CREATE TABLE Bronze.crm_sales_details(
	sls_ord_num	NVARCHAR(50),
	sls_prd_key	NVARCHAR(50),
	sls_cust_id	INT,
	sls_order_dt INT,
	sls_ship_dt	 INT,
	sls_due_dt INT,
	sls_sales	INT,
	sls_quantity INT,
	sls_price INT
);
GO

-- ------------------------------------------------------------------------------
-- Table: Bronze.erp_loc_a101
-- Purpose: Stores raw customer location data from the ERP system 
--          (customer ID and country).
-- Logic: Checks if the table already exists using OBJECT_ID; if it does, 
--        drops it first so the table can be recreated with the latest structure.
-- ------------------------------------------------------------------------------
IF OBJECT_ID('Bronze.erp_loc_a101' , 'U') IS NOT NULL
    DROP TABLE Bronze.erp_loc_a101
CREATE TABLE Bronze.erp_loc_a101(
	cid NVARCHAR(50),
	cntry NVARCHAR(50)
);
GO

-- ------------------------------------------------------------------------------
-- Table: Bronze.erp_cust_az12
-- Purpose: Stores raw customer demographic data from the ERP system 
--          (customer ID, birthdate, and gender).
-- Logic: Checks if the table already exists using OBJECT_ID; if it does, 
--        drops it first so the table can be recreated with the latest structure.
-- ------------------------------------------------------------------------------
IF OBJECT_ID('Bronze.erp_cust_az12' , 'U') IS NOT NULL
    DROP TABLE Bronze.erp_cust_az12
CREATE TABLE Bronze.erp_cust_az12(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50)
);
GO

-- ------------------------------------------------------------------------------
-- Table: Bronze.erp_px_cat_g1v2
-- Purpose: Stores raw product category data from the ERP system 
--          (product ID, category, subcategory, and maintenance flag).
-- Logic: Checks if the table already exists using OBJECT_ID; if it does, 
--        drops it first so the table can be recreated with the latest structure.
-- ------------------------------------------------------------------------------
IF OBJECT_ID('Bronze.erp_px_cat_g1v2' , 'U') IS NOT NULL
    DROP TABLE Bronze.erp_px_cat_g1v2
CREATE TABLE Bronze.erp_px_cat_g1v2(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50)
);
GO
