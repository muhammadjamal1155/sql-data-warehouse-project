-- =============================================================================
-- Stored Procedure: Bronze.load_bronze
-- =============================================================================
-- Purpose: Loads raw source data into the Bronze layer tables.
--          For each table, this procedure:
--            1. Truncates the existing table (removes all rows, keeps structure).
--            2. Bulk inserts fresh data from the corresponding CSV source file.
-- Sources: 
--          - CRM: cust_info.csv, prd_info.csv, sales_details.csv
--          - ERP: CUST_AZ12.csv, LOC_A101.csv, PX_CAT_G1V2.csv
-- Notes:
--          - FIRSTROW = 2 skips the header row in each CSV file.
--          - FIELDTERMINATOR = ',' specifies comma-separated values.
--          - TABLOCK improves bulk load performance by taking a table-level lock.
--          - Load duration for each table (and the full batch) is printed for monitoring.
--          - Wrapped in TRY/CATCH so any failure is caught and logged with 
--            the error message and error number instead of crashing silently.
--
-- Usage:
--          EXEC Bronze.load_bronze;
-- =============================================================================

CREATE OR ALTER PROCEDURE Bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=============================';
		PRINT 'Loading the bronze layer';
		PRINT '=============================';

		PRINT '-----------------------------';
		PRINT 'Loading CRM Data';
		PRINT '-----------------------------';

		-- ------------------------------------------------------------------------------
		-- Load: Bronze.crm_cust_info
		-- Truncates the table, then bulk inserts customer master data from cust_info.csv
		-- ------------------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.crm_cust_info';
		TRUNCATE TABLE Bronze.crm_cust_info;
		PRINT '>> Inserting Data Into: Bronze.crm_cust_info';
		BULK INSERT Bronze.crm_cust_info
		FROM 'D:\Cothm Interns\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------------';

		-- ------------------------------------------------------------------------------
		-- Load: Bronze.crm_prd_info
		-- Truncates the table, then bulk inserts product master data from prd_info.csv
		-- ------------------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.crm_prd_info';
		TRUNCATE TABLE Bronze.crm_prd_info;
		PRINT '>> Inserting Data Into: Bronze.crm_prd_info';
		BULK INSERT Bronze.crm_prd_info
		FROM 'D:\Cothm Interns\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------------';

		-- ------------------------------------------------------------------------------
		-- Load: Bronze.crm_sales_details
		-- Truncates the table, then bulk inserts sales transaction data from sales_details.csv
		-- ------------------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.crm_sales_details';
		TRUNCATE TABLE Bronze.crm_sales_details;
		PRINT '>> Inserting Data Into: Bronze.crm_sales_details';
		BULK INSERT Bronze.crm_sales_details
		FROM 'D:\Cothm Interns\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------------';


		PRINT '-----------------------------';
		PRINT 'Loading ERP Data';
		PRINT '-----------------------------';

		-- ------------------------------------------------------------------------------
		-- Load: Bronze.erp_cust_az12
		-- Truncates the table, then bulk inserts customer demographic data from CUST_AZ12.csv
		-- ------------------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.erp_cust_az12';
		TRUNCATE TABLE Bronze.erp_cust_az12;
		PRINT '>> Inserting Data Into: Bronze.erp_cust_az12';
		BULK INSERT Bronze.erp_cust_az12
		FROM 'D:\Cothm Interns\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------------';

		-- ------------------------------------------------------------------------------
		-- Load: Bronze.erp_loc_a101
		-- Truncates the table, then bulk inserts customer location data from LOC_A101.csv
		-- ------------------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.erp_loc_a101';
		TRUNCATE TABLE Bronze.erp_loc_a101;
		PRINT '>> Inserting Data Into: Bronze.erp_loc_a101';
		BULK INSERT Bronze.erp_loc_a101
		FROM 'D:\Cothm Interns\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------------';

		-- ------------------------------------------------------------------------------
		-- Load: Bronze.erp_px_cat_g1v2
		-- Truncates the table, then bulk inserts product category data from PX_CAT_G1V2.csv
		-- ------------------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE Bronze.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into: Bronze.erp_px_cat_g1v2';
		BULK INSERT Bronze.erp_px_cat_g1v2
		FROM 'D:\Cothm Interns\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '=============================';
		PRINT 'Bronze Layer Load Completed';
		PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=============================';
	END TRY
	BEGIN CATCH
		-- Catches any error raised during the TRY block (e.g., missing file, 
		-- bad file path, data type mismatch) and logs details instead of failing silently
		PRINT '=============================';
		PRINT 'ERROR OCCURED DURING BRONZE LAYER DATA LOADING';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT '============================='
	END CATCH
END
