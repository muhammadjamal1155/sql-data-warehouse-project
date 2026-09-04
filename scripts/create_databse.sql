-- =============================================================================
-- Create Database and Schemas
-- =============================================================================
-- This script creates a new database named 'DataWarehouse' after checking if it 
-- already exists. If the database exists, it is dropped and recreated. Additionally,
-- the script sets up three schemas within the database: 'Bronze', 'Silver', and 'Gold',
-- following the Medallion Architecture pattern for organizing data
-- (raw -> cleansed -> business-ready layers).
--
-- WARNING:
--     Running this script will drop the entire 'DataWarehouse' database if it exists.
--     All data in the database will be permanently deleted. Proceed with caution
--     and ensure you have proper backups before running this script.
-- =============================================================================

-- Check if the 'DataWarehouse' database already exists in the system catalog
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    -- Set the database to SINGLE_USER mode and roll back any open transactions immediately
    -- This forcibly disconnects any other users/sessions so the DROP can succeed
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    -- Drop (delete) the existing 'DataWarehouse' database
    DROP DATABASE DataWarehouse;
END;
GO -- Batch separator: ensures the above statements execute before continuing

-- Create a fresh 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO -- Batch separator

-- Switch context to the newly created 'DataWarehouse' database
USE DataWarehouse;
GO -- Batch separator

-- Create the 'Bronze' schema (for raw, unprocessed data)
CREATE SCHEMA Bronze;
GO -- Batch separator

-- Create the 'Silver' schema (for cleansed, transformed data)
CREATE SCHEMA Silver;
GO -- Batch separator

-- Create the 'Gold' schema (for business-ready, aggregated data)
CREATE SCHEMA Gold;
GO -- Batch separator
