# SQL Data Warehouse Project

A modern data warehouse built with **SQL Server**, following the **Medallion Architecture** (Bronze → Silver → Gold) to consolidate CRM and ERP source data into clean, business-ready datasets for analytics and reporting.

This project simulates a real-world data engineering workflow: ingesting raw data from multiple source systems, cleaning and standardizing it, and modeling it into a star schema for BI consumption.

---

## 🏗️ Architecture

The project follows the **Medallion Architecture**, a layered approach to progressively refining data:

```
Source Systems (CRM + ERP flat files)
        ↓
🥉 Bronze Layer  →  Raw data, loaded as-is from source
        ↓
🥈 Silver Layer  →  Cleaned, standardized, validated data
        ↓
🥇 Gold Layer    →  Business-ready star schema (fact & dimension tables)
        ↓
   BI / Reporting / Analytics
```

| Layer      | Purpose                                         | Method                                |
| ---------- | ------------------------------------------------ | -------------------------------------- |
| **Bronze** | Raw ingestion, exact copy of source files       | `TRUNCATE` + `BULK INSERT`            |
| **Silver** | Data cleaning, deduplication, standardization   | Transformations via stored procedures |
| **Gold**   | Business-ready star schema (facts & dimensions) | Views / final modeled tables          |

---

## 📂 Data Sources

Data is sourced from two systems, provided as CSV files:

**CRM System**

- `cust_info.csv` — customer master data
- `prd_info.csv` — product master data
- `sales_details.csv` — sales transactions

**ERP System**

- `CUST_AZ12.csv` — customer demographic data
- `LOC_A101.csv` — customer location data
- `PX_CAT_G1V2.csv` — product category data

---

## 🔗 Source Data Model

Before transforming data into the Silver layer, it's important to understand how the raw CRM and ERP tables relate to each other. This model was mapped out from the Bronze layer structure and guided the join/derivation logic used in `proc_load_silver.sql`.

![Data Model Overview](docs/data_model_overview.png)

**Key relationships:**

- `crm_cust_info.cust_key` ↔ `erp_cust_az12.cid` — ERP `cid` carries a `NAS` prefix that must be stripped to match CRM's `cust_key` format.
- `crm_cust_info.cust_key` ↔ `erp_loc_a101.cid` — ERP `cid` contains hyphens that must be removed to match CRM's format.
- `crm_prd_info.prd_key` (first 5 characters, `-` → `_`) ↔ `erp_px_cat_g1v2.id` — derived as `cat_id`, used to join products to category, subcategory, and maintenance data.
- `crm_sales_details.cust_id` → `crm_cust_info.cust_id` and `crm_sales_details.prd_key` → `crm_prd_info.prd_key` — internal CRM foreign keys linking transactions to customer and product masters.

These cross-system key mismatches are the reason the Silver layer standardizes `cid` formats and derives `cat_id` — so Gold-layer joins work on consistent keys across CRM and ERP sources.

---

## 🗂️ Project Structure

```
sql-data-warehouse-project/
│
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── scripts/
│   ├── init_database.sql        -- Creates database + Bronze/Silver/Gold schemas
│   ├── bronze/
│   │   ├── ddl_bronze.sql       -- Table definitions for raw layer
│   │   └── proc_load_bronze.sql -- Stored procedure to load Bronze layer
│   ├── silver/
│   │   ├── ddl_silver.sql       -- Table definitions for cleansed layer
│   │   └── proc_load_silver.sql -- Stored procedure to load Silver layer
│   └── gold/
│       └── ddl_gold.sql
│
├── docs/
│   ├── data_architecture.png     -- Medallion architecture diagram
│   └── data_model_overview.png   -- Source (Bronze) CRM/ERP relationship model
│
└── README.md
```

---

## ⚙️ How It Works

### 1. Database & Schema Setup

```sql
CREATE DATABASE DataWarehouse;
CREATE SCHEMA Bronze;
CREATE SCHEMA Silver;
CREATE SCHEMA Gold;
```

### 2. Bronze Layer

Raw tables are created to mirror the source files exactly, then loaded using a stored procedure:

```sql
EXEC Bronze.load_bronze;
```

This procedure:

- Truncates each Bronze table before reloading (fresh load every run)
- Uses `BULK INSERT` to load CRM and ERP CSV files
- Includes `TRY...CATCH` error handling
- Logs load duration per table and total batch duration via `PRINT` statements

### 3. Silver Layer

Cleans and standardizes Bronze data — removing duplicates, fixing data types, handling nulls, standardizing coded values, and aligning keys across CRM and ERP sources — before loading into Silver tables:

```sql
EXEC Silver.load_silver;
```

This procedure follows the same logging and `TRY...CATCH` pattern as the Bronze load, with per-table timing and a total batch duration. Key transformations include:

- Deduplicating customer records (latest record per `cst_id`)
- Trimming and standardizing text fields
- Mapping coded values to readable labels (gender, marital status, product line, country)
- Deriving `cat_id` from `prd_key` and `prd_end_dt` via `LEAD()`
- Validating and reconstructing dates from Bronze integer formats
- Recalculating sales and price where source values are invalid, missing, or inconsistent
- Standardizing ERP `cid` values to align with CRM `cust_key` format (see [Source Data Model](#-source-data-model))

### 4. Gold Layer *(planned)*

Models Silver data into a **star schema** (fact and dimension tables) optimized for BI tools and reporting.

---

## 🛠️ Tech Stack

- **Database:** Microsoft SQL Server
- **Tools:** SQL Server Management Studio (SSMS)
- **Techniques used:** DDL, stored procedures, `BULK INSERT`, `TRY...CATCH` error handling, Medallion Architecture, star schema design

---

## 📌 Project Status

- [x] Database & schema setup (Bronze, Silver, Gold)
- [x] Bronze layer DDL
- [x] Bronze layer load procedure with logging & error handling
- [x] Silver layer DDL
- [x] Silver layer transformations
- [ ] Gold layer star schema (fact & dimension tables)
- [ ] Data quality checks
- [ ] Documentation & architecture diagram

---

## 🚀 About This Project

This project was built as part of a hands-on learning journey into data engineering and data warehousing concepts — covering ETL/ELT pipelines, schema design, and modern warehouse architecture patterns (Medallion, star schema).

Feel free to explore, fork, or reach out with feedback!
