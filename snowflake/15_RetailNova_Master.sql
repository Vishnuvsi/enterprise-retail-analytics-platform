-- RetailNova: Complete Snowflake Data Engineering project with reference guide
-- Co-authored with CoCo

--##########################################################
--##                                                      ##
--##    RETAILNOVA - SNOWFLAKE DATA ENGINEER REFERENCE    ##
--##                                                      ##
--##########################################################


--==========================================================
-- PART A: SNOWFLAKE CONCEPT REFERENCE (What & Why)
--==========================================================
--
-- ┌─────────────────────┬────────────────────────────────────────────────────────────┐
-- │ TOPIC               │ WHY / WHEN USED                                            │
-- ├─────────────────────┼────────────────────────────────────────────────────────────┤
-- │                     │                                                            │
-- │  --- ADMINISTRATION ---                                                          │
-- │                     │                                                            │
-- │ Warehouse           │ Compute engine that runs queries/ETL. Resize per workload. │
-- │                     │ You pay ONLY when it's running (credits/hr).               │
-- │ Database            │ Logical container for schemas. Usually per project/domain. │
-- │ Schema              │ Groups tables, views, stages, procedures by purpose.       │
-- │ Table               │ Stores structured business data (rows + columns).          │
-- │ Transient Table     │ No Fail-safe = cheaper. Use for staging/temp data.         │
-- │ Temporary Table     │ Session-only. Auto-dropped when session ends.              │
-- │ External Stage      │ Points to ADLS/S3/GCS for reading external files.          │
-- │ Internal Stage      │ Snowflake-managed storage for temporary file uploads.      │
-- │ Storage Integration │ IAM/Entra-based auth to cloud storage. No hardcoded keys.  │
-- │ File Format         │ Tells Snowflake how to parse CSV/JSON/Parquet/Avro/ORC/XML.│
-- │                     │                                                            │
-- │  --- DATA LOADING ---                                                            │
-- │                     │                                                            │
-- │ COPY INTO           │ Bulk load from stage into table. Manual or scheduled.      │
-- │ Snowpipe            │ Auto-ingest on file arrival (event-driven, near real-time).│
-- │ Snowpipe Streaming  │ Direct row streaming into Snowflake. No files needed.      │
-- │                     │                                                            │
-- │  --- SEMI-STRUCTURED ---                                                         │
-- │                     │                                                            │
-- │ VARIANT             │ Native column type for JSON/XML/Avro. Stores any structure.│
-- │ FLATTEN()           │ Unpacks nested JSON arrays/objects into relational rows.    │
-- │ Colon Notation      │ Access JSON keys: column:key::TYPE (e.g., data:name::STRING)│
-- │                     │                                                            │
-- │  --- DATA ENGINEERING (Medallion Architecture) ---                               │
-- │                     │                                                            │
-- │ Bronze Layer        │ Raw data exactly as received. Zero transformation.         │
-- │ Silver Layer        │ Cleaned, validated, standardized. Single source of truth.  │
-- │ Gold Layer          │ Business model: facts, dimensions, reporting datasets.     │
-- │ MERGE               │ UPSERT logic (insert if new, update if exists). For CDC.   │
-- │ Streams             │ Captures INSERT/UPDATE/DELETE changes from source tables.   │
-- │ Tasks               │ Schedules SQL execution (cron-like). Pairs with Streams.   │
-- │ Stored Procedures   │ Reusable workflows with IF/ELSE, loops, error handling.    │
-- │ Dynamic Tables      │ Auto-refresh using TARGET_LAG. No manual MERGE needed.     │
-- │                     │                                                            │
-- │  --- RECOVERY ---                                                                │
-- │                     │                                                            │
-- │ Time Travel         │ Query/restore data after accidental UPDATE/DELETE/DROP.     │
-- │ UNDROP              │ Recover dropped databases, schemas, or tables.             │
-- │ Zero-Copy Clone     │ Instant copy sharing micro-partitions. Ideal for DEV/UAT.  │
-- │ Fail-Safe           │ 7-day last-resort recovery (Snowflake Support only).       │
-- │                     │                                                            │
-- │  --- PERFORMANCE ---                                                             │
-- │                     │                                                            │
-- │ Micro-partitions    │ Immutable 50-500MB storage units. Auto-managed by SF.      │
-- │ Partition Pruning   │ Skips irrelevant partitions using metadata. Faster queries.│
-- │ Clustering Keys     │ Reorganize large tables for better pruning on filters.     │
-- │ Search Optimization │ Index-like service for fast point lookups (WHERE id = X).  │
-- │ Query Profile       │ UI tool: diagnose scans, joins, spills, bottlenecks.       │
-- │ Materialized View   │ Pre-computed results. Faster dashboards. Auto-refreshed.   │
-- │ AUTO_SUSPEND        │ Warehouse shuts off after N seconds idle (saves credits).  │
-- │ AUTO_RESUME         │ Warehouse auto-starts when a query arrives.                │
-- │                     │                                                            │
-- │  --- SECURITY ---                                                                │
-- │                     │                                                            │
-- │ Roles (RBAC)        │ Users inherit permissions through roles. Never direct.     │
-- │ ACCOUNTADMIN        │ Top-level admin. Billing + security. Use sparingly!        │
-- │ SYSADMIN            │ Owns databases, schemas, warehouses, objects.              │
-- │ SECURITYADMIN       │ Manages roles, grants, users, policies.                   │
-- │ USERADMIN           │ Creates and manages users only.                            │
-- │ ORGADMIN            │ Organization-wide admin across multiple SF accounts.       │
-- │ PUBLIC              │ Default role for all users. Grant here = grant to everyone.│
-- │ Grants             │ Assign specific permissions to a role on an object.        │
-- │ Future Grants       │ Auto-grant permissions on objects created in the future.   │
-- │ Masking Policy      │ Column-level: hide sensitive values based on role.         │
-- │ Row Access Policy   │ Row-level: filter which rows a role can see.              │
-- │ Secure View         │ Hides SQL logic from non-owners. Required for sharing.    │
-- │ Network Policy      │ IP allowlist/blocklist. Controls who can connect.          │
-- │                     │                                                            │
-- │  --- GOVERNANCE ---                                                              │
-- │                     │                                                            │
-- │ Resource Monitor    │ Credit budget + alerts + auto-suspend triggers.            │
-- │ Data Sharing        │ Share live data with other accounts. Zero-copy.            │
-- └─────────────────────┴────────────────────────────────────────────────────────────┘
--
--
--==========================================================
-- PART B: INTERVIEW CHEAT SHEET (Requirement → Feature)
--==========================================================
--
-- ┌─────────────────────────────────┬─────────────────────────────┐
-- │ REQUIREMENT                     │ SNOWFLAKE FEATURE           │
-- ├─────────────────────────────────┼─────────────────────────────┤
-- │ Load historical files           │ COPY INTO                   │
-- │ Continuous file ingestion       │ Snowpipe                    │
-- │ Real-time row ingestion         │ Snowpipe Streaming          │
-- │ Capture changed rows (CDC)      │ Streams                     │
-- │ Schedule SQL jobs               │ Tasks                       │
-- │ Reusable transaction workflow   │ Stored Procedures           │
-- │ Automatic table refresh         │ Dynamic Tables              │
-- │ Incremental load (upsert)       │ MERGE                       │
-- │ Recover deleted data            │ Time Travel                 │
-- │ Recover dropped object          │ UNDROP                      │
-- │ Create instant DEV/UAT copy     │ Zero-Copy Clone             │
-- │ Large table optimization        │ Clustering Keys             │
-- │ Point lookup optimization       │ Search Optimization         │
-- │ Investigate slow queries        │ Query Profile               │
-- │ Faster dashboard queries        │ Materialized Views          │
-- │ Hide sensitive columns          │ Masking Policy              │
-- │ Restrict rows by role           │ Row Access Policy           │
-- │ Hide business logic in views    │ Secure View                 │
-- │ Auto-permissions for new tables │ Future Grants               │
-- │ Control credit spending         │ Resource Monitor            │
-- │ Share data externally           │ Secure Data Sharing         │
-- └─────────────────────────────────┴─────────────────────────────┘
--
--
--==========================================================
-- PART C: ARCHITECTURE MENTAL MODEL (Data Flow)
--==========================================================
--
--  ┌─────────────────────────────────────────────────────────────┐
--  │                     AZURE PLATFORM                          │
--  │  Entra ID • RBAC • Managed Identity • Key Vault             │
--  │  Storage Account • ADLS Gen2 • Event Grid                   │
--  └────────────────────────────┬────────────────────────────────┘
--                               │
--                               ▼
--  ┌─────────────────────────────────────────────────────────────┐
--  │                    DATA INGESTION                            │
--  │  ADF (batch) • Snowpipe (auto files) • Streaming (rows)     │
--  └────────────────────────────┬────────────────────────────────┘
--                               │
--                               ▼
--  ┌─────────────────────────────────────────────────────────────┐
--  │               SNOWFLAKE (Data Warehouse)                    │
--  │                                                             │
--  │  ┌─────────┐   Streams + Tasks    ┌─────────┐    dbt       │
--  │  │ BRONZE  │ ───────────────────▶  │ SILVER  │ ──────────▶ │
--  │  │ (Raw)   │   MERGE / Procedures  │ (Clean) │             │
--  │  └─────────┘                       └────┬────┘             │
--  │                                         │                   │
--  │                          Dynamic Tables / Views              │
--  │                                         │                   │
--  │                                         ▼                   │
--  │                                    ┌─────────┐              │
--  │                                    │  GOLD   │              │
--  │                                    │ (Facts) │              │
--  │                                    └────┬────┘              │
--  │                                         │                   │
--  │                          Materialized Views (optional)       │
--  └─────────────────────────────────────────┬───────────────────┘
--                                            │
--                                            ▼
--  ┌─────────────────────────────────────────────────────────────┐
--  │                   ANALYTICS LAYER                            │
--  │  Semantic Layer • Power BI • Tableau • Looker               │
--  └────────────────────────────┬────────────────────────────────┘
--                               │
--                               ▼
--  ┌─────────────────────────────────────────────────────────────┐
--  │                      AI LAYER                                │
--  │  Embeddings • Vector Search • RAG • LLMs • Chatbots         │
--  └─────────────────────────────────────────────────────────────┘
--
--
--  ┌─────────────────────────────────────────────────────────────┐
--  │                    DEVELOPERS                                │
--  │  Git + GitHub • Pull Requests • GitHub Actions              │
--  │  Azure DevOps • Terraform (Infrastructure as Code)          │
--  └─────────────────────────────────────────────────────────────┘
--
--
--==========================================================
-- PART D: TECHNOLOGY STACK (Who Does What)
--==========================================================
--
-- ┌──────────────────────────┬─────────────────────────────┐
-- │ RESPONSIBILITY           │ COMMON TOOL                 │
-- ├──────────────────────────┼─────────────────────────────┤
-- │ Infrastructure (IaC)     │ Terraform                   │
-- │ Identity & Security      │ Entra ID + RBAC             │
-- │ Cloud Storage            │ ADLS Gen2                   │
-- │ Batch Data Movement      │ Azure Data Factory (ADF)    │
-- │ Auto File Ingestion      │ Snowpipe                    │
-- │ Real-time Streaming      │ Snowpipe Streaming          │
-- │ Big Data Processing      │ Databricks + PySpark        │
-- │ Reliable Storage Format  │ Delta Lake                  │
-- │ Data Warehouse           │ Snowflake                   │
-- │ Business Transformations │ dbt                         │
-- │ Orchestration            │ Airflow / ADF               │
-- │ Reporting & Dashboards   │ Power BI                    │
-- │ AI Search                │ Vector Search               │
-- │ Generative AI            │ RAG + LLM                   │
-- └──────────────────────────┴─────────────────────────────┘
--
--
--==========================================================
-- PART E: PROJECT SECTION INDEX
--==========================================================
--
-- ┌──────────────────────────────────────────────────────────┐
-- │  INFRASTRUCTURE                          Sections 1-2    │
-- │  Warehouses • Databases • Schemas • Integration • Formats│
-- ├──────────────────────────────────────────────────────────┤
-- │  LOADING                                 Sections 3, 6   │
-- │  Stages • COPY INTO • Incremental • ON_ERROR             │
-- ├──────────────────────────────────────────────────────────┤
-- │  SEMI-STRUCTURED                         Sections 7-8    │
-- │  JSON • VARIANT • LATERAL FLATTEN • Colon Notation       │
-- ├──────────────────────────────────────────────────────────┤
-- │  DATA ENGINEERING                  Sections 3-11, 15-16  │
-- │  Bronze • Silver • Gold • Streams • Tasks • Procedures   │
-- │  Dynamic Tables • MERGE • Task Graphs (DAG)              │
-- ├──────────────────────────────────────────────────────────┤
-- │  RECOVERY                                Sections 13-14  │
-- │  Time Travel • Zero-Copy Clone • Fail-Safe (Sec 30)      │
-- ├──────────────────────────────────────────────────────────┤
-- │  PERFORMANCE                         Sections 17, 26     │
-- │  Micro-partitions • Pruning • Clustering • Search Opt    │
-- │  Query Profile • Materialized Views • Warehouse Tuning   │
-- ├──────────────────────────────────────────────────────────┤
-- │  SECURITY                                Sections 18-25  │
-- │  System Roles • Custom Roles • Grants • Future Grants    │
-- │  Masking • Row Access • Secure Views • Network Policies  │
-- ├──────────────────────────────────────────────────────────┤
-- │  GOVERNANCE & ENTERPRISE                 Sections 27-30  │
-- │  Resource Monitors • Data Sharing • Task DAG • Fail-Safe │
-- ├──────────────────────────────────────────────────────────┤
-- │  MONITORING                              Section 12      │
-- │  SHOW commands • Query History • Credit Metering         │
-- └──────────────────────────────────────────────────────────┘
--


--==========================================================
--==========================================================
--     EXECUTABLE PROJECT CODE BEGINS BELOW
--==========================================================
--==========================================================

--==========================================================
-- SECTION 1: INFRASTRUCTURE SETUP
--==========================================================
-- Every Snowflake project starts with 4 building blocks:
--   WAREHOUSE = Compute engine (runs your queries). Think of it as a "server".
--               You pay credits ONLY when it's running.
--   DATABASE  = Container for all your data (like a folder).
--   SCHEMA    = Sub-folder inside a database (organizes tables by purpose).
--   STORAGE INTEGRATION = Secure bridge between Snowflake and cloud storage
--                         (Azure Blob, AWS S3, or GCS).

-- 1.1 Warehouse
-- XSMALL = cheapest (1 credit/hr). AUTO_SUSPEND=60 means it shuts off
-- after 60 seconds of inactivity (saves money!)
CREATE OR REPLACE WAREHOUSE WH_RETAILNOVA_DEV
WITH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

-- 1.2 Database
CREATE OR REPLACE DATABASE RETAILNOVA_DB;

USE DATABASE RETAILNOVA_DB;

-- 1.3 Schemas
-- We follow the MEDALLION ARCHITECTURE (Bronze/Silver/Gold pattern):
--   RAW     = Bronze layer (raw data as-is from source)
--   CURATED = Alternative name for Silver (not used here, kept for flexibility)
--   MART    = Alternative name for Gold (not used here, kept for flexibility)
--   UTILS   = Utility objects (file formats, procedures, policies)
CREATE OR REPLACE SCHEMA RAW;
CREATE OR REPLACE SCHEMA CURATED;
CREATE OR REPLACE SCHEMA MART;
CREATE OR REPLACE SCHEMA UTILS;

-- 1.4 Storage Integration
CREATE OR REPLACE STORAGE INTEGRATION RETAILNOVA_AZURE_INT
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = AZURE
    ENABLED = TRUE
    AZURE_TENANT_ID = '981ad3fa-d2b6-4382-a35a-ba04529c0c8c'
    STORAGE_ALLOWED_LOCATIONS = (
        'azure://stretailnovadev01.blob.core.windows.net/retailnova'
    );

DESC STORAGE INTEGRATION RETAILNOVA_AZURE_INT;


--==========================================================
-- SECTION 2: FILE FORMATS
--==========================================================
-- File Format = Tells Snowflake HOW to read your source files.
-- Without it, Snowflake won't know where columns start/end.
--
-- Common types:
--   CSV     = Comma-separated (most common for tabular data)
--   JSON    = Semi-structured (nested objects/arrays)
--   PARQUET = Columnar binary (fast, compressed, used in big data)
--
-- You create them once, then reuse across all stages/COPY commands.

USE DATABASE RETAILNOVA_DB;
USE SCHEMA UTILS;

CREATE OR REPLACE FILE FORMAT FF_CSV
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('NULL', '', 'null');

CREATE OR REPLACE FILE FORMAT FF_JSON
    TYPE = JSON;

CREATE OR REPLACE FILE FORMAT FF_PARQUET
    TYPE = PARQUET;


--==========================================================
-- SECTION 3: ORDERS PIPELINE - BRONZE (RAW INGESTION)
--==========================================================
-- STAGE = A pointer to where your files live (cloud storage).
--         Think of it as a "loading dock" for incoming data.
--
-- COPY INTO = The command that loads data FROM a stage INTO a table.
--
-- METADATA$FILENAME = A special Snowflake variable that captures
--                     which file each row came from (useful for auditing).
--
-- Bronze layer rule: Load data AS-IS. No transformations. Just get it in.

USE SCHEMA RAW;

-- 3.1 Stage
CREATE OR REPLACE STAGE STG_ORDERS
    STORAGE_INTEGRATION = RETAILNOVA_AZURE_INT
    URL = 'azure://stretailnovadev01.blob.core.windows.net/retailnova/landing/orders/'
    FILE_FORMAT = RETAILNOVA_DB.UTILS.FF_CSV;

LIST @STG_ORDERS;

-- 3.2 Bronze Table
USE DATABASE RETAILNOVA_DB;
USE SCHEMA RAW;

CREATE OR REPLACE TABLE ORDERS_BRONZE
(
    ORDER_ID         STRING,
    CUSTOMER_ID      STRING,
    PRODUCT_ID       STRING,
    QUANTITY         NUMBER,
    PRICE            NUMBER,
    COUNTRY          STRING,
    SOURCE_FILE_NAME STRING,
    LOAD_TIMESTAMP   TIMESTAMP_NTZ,
    INGESTION_DATE   DATE
);

-- 3.3 Initial Load
COPY INTO ORDERS_BRONZE
FROM
(
    SELECT
        $1::STRING,
        $2::STRING,
        $3::STRING,
        $4::NUMBER,
        $5::NUMBER,
        $6::STRING,
        METADATA$FILENAME,
        CURRENT_TIMESTAMP(),
        CURRENT_DATE()
    FROM @STG_ORDERS
)
FILE_FORMAT = (
    FORMAT_NAME = RETAILNOVA_DB.UTILS.FF_CSV
);

-- 3.4 Verify Stage Data
SELECT
    METADATA$FILENAME,
    $1, $2, $3, $4, $5, $6
FROM @RETAILNOVA_DB.RAW.STG_ORDERS;

SELECT * FROM ORDERS_BRONZE;


--==========================================================
-- SECTION 4: ORDERS PIPELINE - SILVER (CLEANSED)
--==========================================================
-- Silver layer = Clean, validated, business-ready data.
-- What we do here:
--   - TRIM() removes extra spaces from strings
--   - UPPER() standardizes product IDs to uppercase
--   - INITCAP() makes country names consistent (e.g., "india" -> "India")
--
-- Silver tables are the "single source of truth" for analysts.

USE DATABASE RETAILNOVA_DB;

CREATE SCHEMA IF NOT EXISTS SILVER;
USE SCHEMA SILVER;

-- 4.1 Clean Table
CREATE OR REPLACE TABLE ORDERS_CLEAN
(
    ORDER_ID         VARCHAR,
    CUSTOMER_ID      VARCHAR,
    PRODUCT_ID       VARCHAR,
    QUANTITY         NUMBER,
    PRICE            NUMBER(10,2),
    COUNTRY          VARCHAR,
    SOURCE_FILE_NAME VARCHAR,
    LOAD_TIMESTAMP   TIMESTAMP,
    INGESTION_DATE   DATE
);

SELECT * FROM RAW.ORDERS_BRONZE;

-- 4.2 Insert Cleansed Data
INSERT INTO SILVER.ORDERS_CLEAN
SELECT
    TRIM(ORDER_ID),
    TRIM(CUSTOMER_ID),
    UPPER(TRIM(PRODUCT_ID)),
    QUANTITY,
    PRICE,
    INITCAP(TRIM(COUNTRY)),
    SOURCE_FILE_NAME,
    LOAD_TIMESTAMP,
    INGESTION_DATE
FROM RAW.ORDERS_BRONZE;

SELECT * FROM SILVER.ORDERS_CLEAN;


--==========================================================
-- SECTION 5: REJECTS & AUDIT TABLES
--==========================================================
-- In production pipelines, you NEVER silently drop bad records.
-- Instead, you:
--   1. REJECTS table = Store bad rows + why they failed (for debugging)
--   2. AUDIT table   = Log every pipeline run (when, how many rows, status)
--
-- This gives you full traceability: "What happened to my data?"

USE DATABASE RETAILNOVA_DB;

CREATE SCHEMA IF NOT EXISTS REJECTS;
CREATE SCHEMA IF NOT EXISTS AUDIT;

-- 5.1 Rejected Orders Table
USE SCHEMA REJECTS;

CREATE OR REPLACE TABLE ORDERS_REJECTED
(
    ORDER_ID         VARCHAR,
    CUSTOMER_ID      VARCHAR,
    PRODUCT_ID       VARCHAR,
    QUANTITY         VARCHAR,
    PRICE            VARCHAR,
    COUNTRY          VARCHAR,
    SOURCE_FILE_NAME VARCHAR,
    REJECTION_REASON VARCHAR,
    LOAD_TIMESTAMP   TIMESTAMP
);

-- 5.2 Audit History Table
USE SCHEMA AUDIT;

CREATE OR REPLACE TABLE FILE_LOAD_HISTORY
(
    PIPELINE_NAME    VARCHAR,
    FILE_NAME        VARCHAR,
    ROWS_READ        NUMBER,
    ROWS_LOADED      NUMBER,
    ROWS_REJECTED    NUMBER,
    LOAD_START_TIME  TIMESTAMP,
    LOAD_END_TIME    TIMESTAMP,
    STATUS           VARCHAR
);

SELECT * FROM AUDIT.FILE_LOAD_HISTORY;


--==========================================================
-- SECTION 6: INCREMENTAL ORDERS LOAD (2026-07-23 INDIA)
--==========================================================
-- In real pipelines, you don't reload ALL data every time.
-- You load ONLY new files (incremental loading).
--
-- COPY INTO is idempotent: Snowflake tracks which files were already
-- loaded (in the stage's load history) and skips them automatically.
-- You can also target a sub-path (e.g., /india/2026/07/23) for specific files.
--
-- ON_ERROR = CONTINUE means: if some rows fail, keep loading the rest
-- (bad rows are skipped, not the whole file).

LIST @RETAILNOVA_DB.RAW.STG_ORDERS;

-- 6.1 Load New Data
COPY INTO RAW.ORDERS_BRONZE
FROM
(
    SELECT
        $1,
        $2,
        $3,
        $4,
        $5,
        $6,
        METADATA$FILENAME,
        CURRENT_TIMESTAMP(),
        CURRENT_DATE()
    FROM @RETAILNOVA_DB.RAW.STG_ORDERS/india/2026/07/23
)
FILE_FORMAT = (FORMAT_NAME = RETAILNOVA_DB.UTILS.FF_CSV)
ON_ERROR = CONTINUE;

-- 6.2 Insert Valid Records into Silver
INSERT INTO SILVER.ORDERS_CLEAN
SELECT *
FROM RAW.ORDERS_BRONZE
WHERE ORDER_ID IS NOT NULL
  AND CUSTOMER_ID IS NOT NULL
  AND PRICE > 0
  AND QUANTITY > 0;

-- 6.3 Insert Rejected Records
INSERT INTO REJECTS.ORDERS_REJECTED
(
    ORDER_ID,
    CUSTOMER_ID,
    PRODUCT_ID,
    QUANTITY,
    PRICE,
    COUNTRY,
    SOURCE_FILE_NAME,
    REJECTION_REASON,
    LOAD_TIMESTAMP
)
SELECT
    ORDER_ID,
    CUSTOMER_ID,
    PRODUCT_ID,
    QUANTITY,
    PRICE,
    COUNTRY,
    SOURCE_FILE_NAME,
    CASE
        WHEN ORDER_ID IS NULL    THEN 'Missing Order ID'
        WHEN CUSTOMER_ID IS NULL THEN 'Missing Customer'
        WHEN PRICE <= 0          THEN 'Invalid Price'
        WHEN QUANTITY <= 0       THEN 'Invalid Quantity'
    END,
    CURRENT_TIMESTAMP()
FROM RAW.ORDERS_BRONZE
WHERE ORDER_ID IS NULL
   OR CUSTOMER_ID IS NULL
   OR PRICE <= 0
   OR QUANTITY <= 0;

-- 6.4 Audit Log
INSERT INTO AUDIT.FILE_LOAD_HISTORY
SELECT
    'ORDERS_PIPELINE',
    SOURCE_FILE_NAME,
    COUNT(*),
    COUNT_IF(
        ORDER_ID IS NOT NULL
        AND CUSTOMER_ID IS NOT NULL
        AND PRICE > 0
        AND QUANTITY > 0
    ),
    COUNT_IF(
        ORDER_ID IS NULL
        OR CUSTOMER_ID IS NULL
        OR PRICE <= 0
        OR QUANTITY <= 0
    ),
    MIN(LOAD_TIMESTAMP),
    MAX(LOAD_TIMESTAMP),
    'SUCCESS'
FROM RAW.ORDERS_BRONZE
GROUP BY SOURCE_FILE_NAME;


--==========================================================
-- SECTION 7: PRODUCTS PIPELINE - BRONZE (JSON INGESTION)
--==========================================================
-- JSON data is "semi-structured" - it has nested objects and arrays.
-- Snowflake handles this with the VARIANT data type.
--
-- VARIANT = A special column type that can hold ANY JSON/XML/Parquet data.
--           You query it with colon notation: column:key::TYPE
--
-- LATERAL FLATTEN = "Unpack" a JSON array into individual rows.
--   If your JSON is [{"id":1}, {"id":2}], FLATTEN gives you 2 rows.
--   Each row's data is in the VALUE pseudo-column.

CREATE OR REPLACE FILE FORMAT FF_JSON
    TYPE = JSON;

-- 7.1 Stage
CREATE OR REPLACE STAGE STG_PRODUCTS
    STORAGE_INTEGRATION = RETAILNOVA_AZURE_INT
    URL = 'azure://stretailnovadev01.blob.core.windows.net/retailnova/landing/products/'
    FILE_FORMAT = FF_JSON;

-- 7.2 Bronze Table
CREATE OR REPLACE TABLE RAW.PRODUCTS_BRONZE
(
    RAW_DATA       VARIANT,
    SOURCE_FILE    STRING,
    LOAD_TIMESTAMP TIMESTAMP
);

-- 7.3 Load
COPY INTO RAW.PRODUCTS_BRONZE
FROM
(
    SELECT
        $1,
        METADATA$FILENAME,
        CURRENT_TIMESTAMP()
    FROM @STG_PRODUCTS
);

SELECT * FROM RAW.PRODUCTS_BRONZE;

-- 7.4 Verify Flattened Data
SELECT
    VALUE:PRODUCT_ID::STRING   AS PRODUCT_ID,
    VALUE:PRODUCT_NAME::STRING AS PRODUCT_NAME,
    VALUE:CATEGORY::STRING     AS CATEGORY,
    VALUE:PRICE::NUMBER        AS PRICE
FROM RAW.PRODUCTS_BRONZE,
LATERAL FLATTEN(INPUT => RAW_DATA);


--==========================================================
-- SECTION 8: PRODUCTS PIPELINE - SILVER (CLEANSED)
--==========================================================

CREATE OR REPLACE TABLE SILVER.PRODUCTS_CLEAN
(
    PRODUCT_ID       STRING,
    PRODUCT_NAME     STRING,
    CATEGORY         STRING,
    PRICE            NUMBER,
    SOURCE_FILE_NAME STRING,
    LOAD_TIMESTAMP   TIMESTAMP
);

INSERT INTO SILVER.PRODUCTS_CLEAN
SELECT
    VALUE:PRODUCT_ID::STRING,
    VALUE:PRODUCT_NAME::STRING,
    VALUE:CATEGORY::STRING,
    VALUE:PRICE::NUMBER,
    SOURCE_FILE,
    LOAD_TIMESTAMP
FROM RAW.PRODUCTS_BRONZE,
LATERAL FLATTEN(INPUT => RAW_DATA);

SELECT * FROM SILVER.PRODUCTS_CLEAN;


--==========================================================
-- SECTION 9: GOLD LAYER - FACT VIEW & ANALYTICS
--==========================================================
-- Gold layer = Business-ready aggregations and joined datasets.
-- We use VIEWs (not tables) because:
--   - Views always reflect the latest Silver data (no stale copies)
--   - Zero storage cost (it's just a saved query)
--   - Easy to change logic without reloading data
--
-- FACT table/view = Transactional events (orders, clicks, payments)
-- DIMENSION table = Descriptive attributes (products, customers, locations)
--
-- Here we JOIN orders (fact) with products (dimension) for full context.

CREATE SCHEMA IF NOT EXISTS GOLD;

-- 9.1 Fact Sales View
CREATE OR REPLACE VIEW GOLD.FACT_SALES AS
SELECT
    O.ORDER_ID,
    O.CUSTOMER_ID,
    P.PRODUCT_NAME,
    P.CATEGORY,
    O.QUANTITY,
    O.PRICE,
    (O.QUANTITY * O.PRICE) AS TOTAL_AMOUNT,
    O.COUNTRY,
    O.INGESTION_DATE
FROM SILVER.ORDERS_CLEAN O
LEFT JOIN SILVER.PRODUCTS_CLEAN P
    ON O.PRODUCT_ID = P.PRODUCT_ID;

SELECT * FROM GOLD.FACT_SALES;

-- 9.2 Sales by Category
SELECT
    CATEGORY,
    SUM(TOTAL_AMOUNT) AS SALES
FROM GOLD.FACT_SALES
GROUP BY CATEGORY;

-- 9.3 Sales by Country
SELECT
    COUNTRY,
    SUM(TOTAL_AMOUNT) AS SALES
FROM GOLD.FACT_SALES
GROUP BY COUNTRY;

-- 9.4 Sales by Product (Top Sellers)
SELECT
    PRODUCT_NAME,
    SUM(TOTAL_AMOUNT) AS SALES
FROM GOLD.FACT_SALES
GROUP BY PRODUCT_NAME
ORDER BY SALES DESC;

-- 9.5 Top 5 Customers by Revenue
SELECT
    CUSTOMER_ID,
    COUNT(*)           AS TOTAL_ORDERS,
    SUM(TOTAL_AMOUNT)  AS TOTAL_SPENT
FROM GOLD.FACT_SALES
GROUP BY CUSTOMER_ID
ORDER BY TOTAL_SPENT DESC
LIMIT 5;

-- 9.6 Daily Sales Trend
SELECT
    INGESTION_DATE,
    COUNT(*)          AS ORDERS,
    SUM(TOTAL_AMOUNT) AS REVENUE
FROM GOLD.FACT_SALES
GROUP BY INGESTION_DATE
ORDER BY INGESTION_DATE;


--==========================================================
-- SECTION 10: STREAMS & TASKS - ORDERS CDC PIPELINE
--==========================================================
-- CDC = Change Data Capture. Detects what changed since last time.
--
-- STREAM = A Snowflake object that sits on a table and tracks changes.
--          It records INSERTS, UPDATES, and DELETES since last consumed.
--          Think of it as: "What's new since I last looked?"
--
-- TASK = A scheduled job (like a cron job) that runs SQL automatically.
--        WHEN clause = only run IF the stream has new data (saves credits!)
--
-- MERGE = Upsert (INSERT if new, UPDATE if exists). Perfect for CDC.
--
-- Together: Stream detects changes -> Task wakes up -> MERGE applies them.

USE DATABASE RETAILNOVA_DB;
USE SCHEMA RAW;

-- 10.1 Stream on Orders Bronze
CREATE OR REPLACE STREAM STR_ORDERS_BRONZE
    ON TABLE ORDERS_BRONZE;

SHOW STREAMS;

-- 10.2 Task: Merge Orders Bronze -> Silver
CREATE OR REPLACE TASK TASK_ORDERS_BRONZE_TO_SILVER
    WAREHOUSE = WH_RETAILNOVA_DEV
    SCHEDULE = '5 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('RETAILNOVA_DB.RAW.STR_ORDERS_BRONZE')
AS
MERGE INTO RETAILNOVA_DB.SILVER.ORDERS_CLEAN T
USING
(
    SELECT
        ORDER_ID,
        CUSTOMER_ID,
        PRODUCT_ID,
        QUANTITY,
        PRICE,
        INITCAP(TRIM(COUNTRY)) AS COUNTRY,
        SOURCE_FILE_NAME,
        LOAD_TIMESTAMP,
        INGESTION_DATE
    FROM RETAILNOVA_DB.RAW.STR_ORDERS_BRONZE
) S
ON T.ORDER_ID = S.ORDER_ID
WHEN MATCHED THEN
    UPDATE SET
        T.CUSTOMER_ID      = S.CUSTOMER_ID,
        T.PRODUCT_ID       = S.PRODUCT_ID,
        T.QUANTITY         = S.QUANTITY,
        T.PRICE            = S.PRICE,
        T.COUNTRY          = S.COUNTRY,
        T.SOURCE_FILE_NAME = S.SOURCE_FILE_NAME,
        T.LOAD_TIMESTAMP   = S.LOAD_TIMESTAMP,
        T.INGESTION_DATE   = S.INGESTION_DATE
WHEN NOT MATCHED THEN
    INSERT
    (
        ORDER_ID,
        CUSTOMER_ID,
        PRODUCT_ID,
        QUANTITY,
        PRICE,
        COUNTRY,
        SOURCE_FILE_NAME,
        LOAD_TIMESTAMP,
        INGESTION_DATE
    )
    VALUES
    (
        S.ORDER_ID,
        S.CUSTOMER_ID,
        S.PRODUCT_ID,
        S.QUANTITY,
        S.PRICE,
        S.COUNTRY,
        S.SOURCE_FILE_NAME,
        S.LOAD_TIMESTAMP,
        S.INGESTION_DATE
    );

-- 10.3 Resume & Test Orders Task
ALTER TASK TASK_ORDERS_BRONZE_TO_SILVER RESUME;

SELECT * FROM RAW.STR_ORDERS_BRONZE;

-- 10.4 Manual Test Insert
INSERT INTO RAW.ORDERS_BRONZE
(
    ORDER_ID,
    CUSTOMER_ID,
    PRODUCT_ID,
    QUANTITY,
    PRICE,
    COUNTRY,
    SOURCE_FILE_NAME,
    LOAD_TIMESTAMP,
    INGESTION_DATE
)
VALUES
(
    'O2001',
    'C020',
    'P101',
    2,
    99999,
    'India',
    'manual_test.csv',
    CURRENT_TIMESTAMP(),
    CURRENT_DATE()
);

SELECT * FROM RAW.STR_ORDERS_BRONZE;

-- 10.5 Execute & Verify
EXECUTE TASK TASK_ORDERS_BRONZE_TO_SILVER;

SELECT * FROM SILVER.ORDERS_CLEAN WHERE ORDER_ID = 'O2001';

ALTER TASK TASK_ORDERS_BRONZE_TO_SILVER SUSPEND;


--==========================================================
-- SECTION 11: STREAMS & TASKS - PRODUCTS CDC PIPELINE
--==========================================================

-- 11.1 Stream on Products Bronze
CREATE OR REPLACE STREAM RAW.STR_PRODUCTS_BRONZE
    ON TABLE RAW.PRODUCTS_BRONZE;

-- 11.2 Task: Merge Products Bronze -> Silver
CREATE OR REPLACE TASK TASK_PRODUCTS_BRONZE_TO_SILVER
    WAREHOUSE = WH_RETAILNOVA_DEV
    WHEN SYSTEM$STREAM_HAS_DATA('RETAILNOVA_DB.RAW.STR_PRODUCTS_BRONZE')
AS
MERGE INTO SILVER.PRODUCTS_CLEAN T
USING
(
    SELECT
        VALUE:PRODUCT_ID::STRING   AS PRODUCT_ID,
        VALUE:PRODUCT_NAME::STRING AS PRODUCT_NAME,
        VALUE:CATEGORY::STRING     AS CATEGORY,
        VALUE:PRICE::NUMBER        AS PRICE,
        SOURCE_FILE,
        LOAD_TIMESTAMP
    FROM RAW.STR_PRODUCTS_BRONZE,
    LATERAL FLATTEN(INPUT => RAW_DATA)
) S
ON T.PRODUCT_ID = S.PRODUCT_ID
WHEN MATCHED THEN
    UPDATE SET
        PRODUCT_NAME     = S.PRODUCT_NAME,
        CATEGORY         = S.CATEGORY,
        PRICE            = S.PRICE,
        SOURCE_FILE_NAME = S.SOURCE_FILE,
        LOAD_TIMESTAMP   = S.LOAD_TIMESTAMP
WHEN NOT MATCHED THEN
    INSERT
    (
        PRODUCT_ID,
        PRODUCT_NAME,
        CATEGORY,
        PRICE,
        SOURCE_FILE_NAME,
        LOAD_TIMESTAMP
    )
    VALUES
    (
        S.PRODUCT_ID,
        S.PRODUCT_NAME,
        S.CATEGORY,
        S.PRICE,
        S.SOURCE_FILE,
        S.LOAD_TIMESTAMP
    );

-- 11.3 Resume & Test Products Task
ALTER TASK TASK_PRODUCTS_BRONZE_TO_SILVER RESUME;

-- 11.4 Manual Test Insert (JSON)
INSERT INTO RAW.PRODUCTS_BRONZE
SELECT
    PARSE_JSON('
    [
        {
            "PRODUCT_ID": "P200",
            "PRODUCT_NAME": "Gaming Laptop",
            "CATEGORY": "Electronics",
            "PRICE": 95000
        }
    ]
    '),
    'manual_test.json',
    CURRENT_TIMESTAMP();

SELECT * FROM RAW.STR_PRODUCTS_BRONZE;

-- 11.5 Execute & Verify
EXECUTE TASK TASK_PRODUCTS_BRONZE_TO_SILVER;

SELECT * FROM SILVER.PRODUCTS_CLEAN WHERE PRODUCT_ID = 'P200';

ALTER TASK TASK_PRODUCTS_BRONZE_TO_SILVER SUSPEND;


--==========================================================
-- SECTION 12: MONITORING & DIAGNOSTICS
--==========================================================
-- Always monitor your pipelines! Key questions:
--   - Is my warehouse running (burning credits)?
--   - Are my tasks running or failed?
--   - What queries ran recently (and how long did they take)?

SHOW WAREHOUSES;
SHOW TASKS;

-- Recent query history (last 20 queries)
SELECT *
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
ORDER BY START_TIME DESC
LIMIT 20;

-- Check for failed queries in the last hour
SELECT QUERY_ID, QUERY_TEXT, ERROR_MESSAGE, EXECUTION_STATUS
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY(
    RESULT_LIMIT => 50,
    END_TIME_RANGE_START => DATEADD('HOUR', -1, CURRENT_TIMESTAMP())
))
WHERE EXECUTION_STATUS = 'FAIL'
ORDER BY START_TIME DESC;

-- Check current warehouse credit usage
SELECT *
FROM TABLE(INFORMATION_SCHEMA.WAREHOUSE_METERING_HISTORY(
    DATE_RANGE_START => DATEADD('DAY', -7, CURRENT_DATE())
))
WHERE WAREHOUSE_NAME = 'WH_RETAILNOVA_DEV'
ORDER BY START_TIME DESC;


--==========================================================
-- SECTION 13: TIME TRAVEL - DELETE & RESTORE
--==========================================================
-- Time Travel = Query or restore data as it was in the PAST.
-- Snowflake automatically keeps history for 1-90 days (depends on edition).
--
-- Syntax options:
--   AT(OFFSET => -60*5)          = "5 minutes ago"
--   AT(TIMESTAMP => '2026-...')  = "at this exact time"
--   BEFORE(STATEMENT => 'id')    = "just before this query ran"
--
-- Use cases:
--   - Accidental DELETE? Restore from the past.
--   - Compare today's data vs yesterday's.
--   - Audit what changed and when.

-- 13.1 View Current Data
SELECT * FROM SILVER.ORDERS_CLEAN;

-- 13.2 Delete a Record
DELETE FROM SILVER.ORDERS_CLEAN
WHERE ORDER_ID = 'O1001';

-- 13.3 Verify Deletion
SELECT *
FROM SILVER.ORDERS_CLEAN
WHERE ORDER_ID = 'O1001';

-- 13.4 Restore from Time Travel (5 minutes ago)
INSERT INTO SILVER.ORDERS_CLEAN
SELECT *
FROM SILVER.ORDERS_CLEAN AT(OFFSET => -60*5)
WHERE ORDER_ID = 'O1001';

-- 13.5 Verify Restoration
SELECT *
FROM SILVER.ORDERS_CLEAN
WHERE ORDER_ID = 'O1001';


--==========================================================
-- SECTION 14: ZERO-COPY CLONING
--==========================================================
-- Clone = Instant copy of a database, schema, or table.
-- "Zero-copy" means it shares the same underlying storage initially.
-- Only when you MODIFY the clone does it create separate storage.
--
-- Use cases:
--   - Create a dev/test environment instantly (no extra cost!)
--   - Take a snapshot before a risky migration
--   - Let analysts experiment without affecting production
--
-- Clone inherits: all tables, views, data, stages, sequences
-- Clone does NOT inherit: privileges (you must re-grant)

-- 14.1 Clone Entire Database
CREATE DATABASE RETAILNOVA_DEV
    CLONE RETAILNOVA_DB;

SHOW DATABASES;

USE DATABASE RETAILNOVA_DEV;
SHOW SCHEMAS;

-- 14.2 Clone a Single Schema
CREATE SCHEMA RETAILNOVA_DB.SILVER_CLONE
    CLONE RETAILNOVA_DB.SILVER;

USE SCHEMA RETAILNOVA_DB.SILVER_CLONE;
SHOW TABLES;


--==========================================================
-- SECTION 15: STORED PROCEDURES
--==========================================================
-- Stored Procedure = A reusable block of SQL logic you can CALL by name.
-- Think of it as a "function" in programming.
--
-- Why use procedures:
--   - Encapsulate complex multi-step logic into one CALL
--   - Use variables, IF/ELSE, loops, error handling
--   - Control access (grant USAGE on procedure, not on underlying tables)
--
-- Key syntax:
--   :variable  = Reference a variable inside SQL statements (colon prefix!)
--   INTO       = Capture query result into a variable
--   RETURN     = Send a value back to the caller

-- 15.1 Simple Hello Procedure
CREATE OR REPLACE PROCEDURE HELLO_RETAILNOVA()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    RETURN 'Welcome to RetailNova!';
END;
$$;

CALL HELLO_RETAILNOVA();

-- 15.2 Get Order Count
CREATE OR REPLACE PROCEDURE GET_ORDER_COUNT()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    V_COUNT NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO :V_COUNT
    FROM SILVER.ORDERS_CLEAN;

    RETURN 'Total Orders = ' || V_COUNT;
END;
$$;

CALL GET_ORDER_COUNT();

-- 15.3 Full Load Orders Pipeline Procedure
CREATE OR REPLACE PROCEDURE LOAD_ORDERS()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

    ----------------------------------------------------
    -- Step 1 : Check Stream
    ----------------------------------------------------

    IF (SYSTEM$STREAM_HAS_DATA('RETAILNOVA_DB.RAW.STR_ORDERS_BRONZE'))
    THEN

        ------------------------------------------------
        -- Step 2 : Merge Bronze -> Silver
        ------------------------------------------------

        MERGE INTO SILVER.ORDERS_CLEAN T
        USING
        (
            SELECT *
            FROM RAW.STR_ORDERS_BRONZE
        ) S
        ON T.ORDER_ID = S.ORDER_ID
        WHEN MATCHED THEN
            UPDATE SET
                PRICE    = S.PRICE,
                QUANTITY = S.QUANTITY,
                COUNTRY  = S.COUNTRY
        WHEN NOT MATCHED THEN
            INSERT
            (
                ORDER_ID,
                CUSTOMER_ID,
                PRODUCT_ID,
                QUANTITY,
                PRICE,
                COUNTRY,
                SOURCE_FILE_NAME,
                LOAD_TIMESTAMP,
                INGESTION_DATE
            )
            VALUES
            (
                S.ORDER_ID,
                S.CUSTOMER_ID,
                S.PRODUCT_ID,
                S.QUANTITY,
                S.PRICE,
                S.COUNTRY,
                S.SOURCE_FILE_NAME,
                S.LOAD_TIMESTAMP,
                S.INGESTION_DATE
            );

        ------------------------------------------------
        -- Step 3 : Reject Records
        ------------------------------------------------

        INSERT INTO REJECTS.ORDERS_REJECTED
        (ORDER_ID, CUSTOMER_ID, PRODUCT_ID, QUANTITY, PRICE,
         COUNTRY, SOURCE_FILE_NAME, REJECTION_REASON, LOAD_TIMESTAMP)
        SELECT
            ORDER_ID, CUSTOMER_ID, PRODUCT_ID, QUANTITY, PRICE,
            COUNTRY, SOURCE_FILE_NAME,
            CASE
                WHEN ORDER_ID IS NULL    THEN 'Missing Order ID'
                WHEN CUSTOMER_ID IS NULL THEN 'Missing Customer'
                WHEN PRICE <= 0          THEN 'Invalid Price'
                WHEN QUANTITY <= 0       THEN 'Invalid Quantity'
            END,
            CURRENT_TIMESTAMP()
        FROM RAW.STR_ORDERS_BRONZE
        WHERE ORDER_ID IS NULL
           OR CUSTOMER_ID IS NULL
           OR PRICE <= 0
           OR QUANTITY <= 0;

        ------------------------------------------------
        -- Step 4 : Audit
        ------------------------------------------------

        INSERT INTO AUDIT.FILE_LOAD_HISTORY
        SELECT
            'ORDERS_PIPELINE',
            SOURCE_FILE_NAME,
            COUNT(*),
            COUNT_IF(ORDER_ID IS NOT NULL AND PRICE > 0 AND QUANTITY > 0),
            COUNT_IF(ORDER_ID IS NULL OR PRICE <= 0 OR QUANTITY <= 0),
            MIN(LOAD_TIMESTAMP),
            MAX(LOAD_TIMESTAMP),
            'SUCCESS'
        FROM RAW.STR_ORDERS_BRONZE
        GROUP BY SOURCE_FILE_NAME;

        ------------------------------------------------
        -- Step 5 : Log Success
        ------------------------------------------------

        RETURN 'SUCCESS : Orders Loaded';

    ELSE

        RETURN 'No New Data Found';

    END IF;

END;
$$;

CALL LOAD_ORDERS();


--==========================================================
-- SECTION 16: DYNAMIC TABLES
--==========================================================
-- Dynamic Table = A table that auto-refreshes itself based on a query.
-- Think of it as: "Keep this result always up-to-date, within X minutes."
--
-- Dynamic Table vs Stream+Task:
--   Stream+Task = You write the MERGE logic yourself (more control)
--   Dynamic Table = Snowflake handles refresh logic automatically (simpler)
--
-- TARGET_LAG = Maximum allowed staleness.
--   '5 minutes' means data can be at most 5 minutes behind the source.
--   Smaller lag = more frequent refresh = more credits.
--
-- Best for: Downstream analytics that need near-real-time data
--           without writing complex CDC logic.

-- 16.1 Create Dynamic Table
CREATE OR REPLACE DYNAMIC TABLE SILVER.ORDERS_DYNAMIC
    TARGET_LAG = '5 minutes'
    WAREHOUSE = WH_RETAILNOVA_DEV
AS
SELECT
    ORDER_ID,
    CUSTOMER_ID,
    PRODUCT_ID,
    QUANTITY,
    PRICE,
    INITCAP(TRIM(COUNTRY)) AS COUNTRY,
    SOURCE_FILE_NAME,
    LOAD_TIMESTAMP,
    INGESTION_DATE
FROM RAW.ORDERS_BRONZE
WHERE ORDER_ID IS NOT NULL;

-- 16.2 Query & Cleanup
SELECT * FROM SILVER.ORDERS_DYNAMIC;

DROP DYNAMIC TABLE SILVER.ORDERS_DYNAMIC;


--==========================================================
-- SECTION 17: PERFORMANCE & OPTIMIZATION REFERENCE
--==========================================================
-- Snowflake stores data in MICRO-PARTITIONS (small chunks of 50-500MB).
-- Each micro-partition has metadata: min/max values, distinct count, nulls.
--
-- How queries get fast:
--   1. PARTITION PRUNING = Snowflake reads metadata and SKIPS partitions
--      that can't possibly match your WHERE clause. Fewer partitions = faster.
--
--   2. CLUSTERING = Physically sort data by chosen columns so related
--      rows are in the same partition. Great for columns in WHERE/JOIN.
--
--   3. SEARCH OPTIMIZATION = An index-like service for point lookups
--      (WHERE col = 'exact_value'). Background service, extra cost.
--
-- Rule of thumb:
--   - Tables < 1GB: Don't bother with clustering (already fast)
--   - Tables > 1GB with frequent filters: Add clustering key
--   - Point lookups on large tables: Add search optimization

-- 17.1 Partition Pruning Example
SELECT *
FROM SILVER.ORDERS_CLEAN
WHERE COUNTRY = 'India';

-- Micro-partition Metadata -> Partition Pruning -> Only Relevant Partitions Read

-- 17.2 Clustering Information
SELECT SYSTEM$CLUSTERING_INFORMATION('SILVER.ORDERS_CLEAN');
SELECT SYSTEM$CLUSTERING_DEPTH('SILVER.ORDERS_CLEAN');

-- 17.3 Create Clustering Key
ALTER TABLE SILVER.ORDERS_CLEAN
    CLUSTER BY (ORDER_DATE);

-- (or by Country)
ALTER TABLE SILVER.ORDERS_CLEAN
    CLUSTER BY (COUNTRY);

-- 17.4 Remove Clustering Key
ALTER TABLE SILVER.ORDERS_CLEAN
    DROP CLUSTERING KEY;

-- 17.5 Search Optimization - Enable
ALTER TABLE SILVER.ORDERS_CLEAN
    ADD SEARCH OPTIMIZATION;

-- (or on specific column)
ALTER TABLE SILVER.ORDERS_CLEAN
    ADD SEARCH OPTIMIZATION ON EQUALITY(ORDER_ID);

-- 17.6 Search Optimization - Disable
ALTER TABLE SILVER.ORDERS_CLEAN
    DROP SEARCH OPTIMIZATION;

-- 17.7 Warehouse Management
CREATE WAREHOUSE WH_RETAILNOVA_DEV
WITH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

ALTER WAREHOUSE WH_RETAILNOVA_DEV SET WAREHOUSE_SIZE = 'LARGE';
ALTER WAREHOUSE WH_RETAILNOVA_DEV SUSPEND;
ALTER WAREHOUSE WH_RETAILNOVA_DEV RESUME;
SHOW WAREHOUSES;

-- 17.8 Query History
SELECT *
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
ORDER BY START_TIME DESC;

-- 17.9 Query Profile (UI Only)
--   History -> Click Query -> Query Profile
--   Look for: Table Scan, Joins, Aggregation, Disk Spill, Network, Partition Pruning

-- 17.10 Cost Saving Tips
--   Always enable: AUTO_SUSPEND, AUTO_RESUME


--##########################################################
--##########################################################
--##                                                      ##
--##         SNOWFLAKE DATA ENGINEERING DEEP DIVE         ##
--##         (Security, Performance, Enterprise)          ##
--##                                                      ##
--##########################################################
--##########################################################


--==========================================================
-- SECTION 18: SECURITY - SYSTEM ROLES
--==========================================================
-- Snowflake has 5 built-in system roles (you can't delete them).
-- They form a hierarchy: ACCOUNTADMIN > SECURITYADMIN > SYSADMIN > PUBLIC
--
-- ACCOUNTADMIN   = Top-level. Manages billing, security, and all objects.
--                  Use sparingly! Only for admin tasks.
-- SECURITYADMIN  = Manages roles, users, and grants. Can grant privileges.
-- SYSADMIN       = Manages all databases, warehouses, schemas, tables.
--                  This is your "builder" role.
-- USERADMIN      = Can create users and roles only.
-- PUBLIC         = Every user automatically gets this role.
--                  Grant to PUBLIC = grant to everyone.
--
-- The golden rule: NEVER use ACCOUNTADMIN for daily work.
-- Use SYSADMIN for creating objects, SECURITYADMIN for managing access.

-- See all roles in your account
SHOW ROLES;

-- See which roles are granted to your user
SHOW GRANTS TO USER VISHNU;

-- See the role hierarchy (who inherits what)
SHOW GRANTS OF ROLE SYSADMIN;


--==========================================================
-- SECTION 19: SECURITY - CUSTOM ROLES (RBAC)
--==========================================================
-- RBAC = Role-Based Access Control
-- In real companies, you NEVER give direct access to users.
-- Instead: Create Role -> Grant Privileges to Role -> Assign Role to User
--
-- Think of it like a keychain:
--   User (person) -> Role (keychain) -> Privileges (keys) -> Objects (doors)
--
-- Best practice: Grant custom roles TO SYSADMIN so admins can manage them.

-- 19.1 Create Custom Roles for RetailNova
CREATE ROLE IF NOT EXISTS RETAILNOVA_ANALYST;    -- Can read Silver/Gold data
CREATE ROLE IF NOT EXISTS RETAILNOVA_ENGINEER;   -- Can read/write all schemas
CREATE ROLE IF NOT EXISTS RETAILNOVA_VIEWER;     -- Can only read Gold layer

-- Grant custom roles to SYSADMIN (best practice - maintains hierarchy)
GRANT ROLE RETAILNOVA_ANALYST  TO ROLE SYSADMIN;
GRANT ROLE RETAILNOVA_ENGINEER TO ROLE SYSADMIN;
GRANT ROLE RETAILNOVA_VIEWER   TO ROLE SYSADMIN;

-- 19.2 Verify Roles Created
SHOW ROLES LIKE 'RETAILNOVA%';


--==========================================================
-- SECTION 20: SECURITY - GRANTS (PRIVILEGES)
--==========================================================
-- Grants follow a chain: Database -> Schema -> Object
-- You MUST grant USAGE on the parent before granting anything on the child.
--
-- Common privilege types:
--   USAGE     = "You can see this exists and use it" (database, schema, warehouse)
--   SELECT    = "You can read data" (tables, views)
--   INSERT    = "You can add data"
--   UPDATE    = "You can modify data"
--   DELETE    = "You can remove data"
--   ALL       = "You can do everything" (be careful!)
--   OPERATE   = "You can start/stop" (warehouses, tasks)

-- 20.1 Grant Analyst Role: Read access to Silver & Gold
-- Step 1: Warehouse access (without this, they can't run queries)
GRANT USAGE ON WAREHOUSE WH_RETAILNOVA_DEV
    TO ROLE RETAILNOVA_ANALYST;

-- Step 2: Database access
GRANT USAGE ON DATABASE RETAILNOVA_DB
    TO ROLE RETAILNOVA_ANALYST;

-- Step 3: Schema access
GRANT USAGE ON SCHEMA RETAILNOVA_DB.SILVER
    TO ROLE RETAILNOVA_ANALYST;
GRANT USAGE ON SCHEMA RETAILNOVA_DB.GOLD
    TO ROLE RETAILNOVA_ANALYST;

-- Step 4: Table/View access
GRANT SELECT ON ALL TABLES IN SCHEMA RETAILNOVA_DB.SILVER
    TO ROLE RETAILNOVA_ANALYST;
GRANT SELECT ON ALL VIEWS IN SCHEMA RETAILNOVA_DB.GOLD
    TO ROLE RETAILNOVA_ANALYST;

-- 20.2 Grant Engineer Role: Full access to all schemas
GRANT USAGE ON WAREHOUSE WH_RETAILNOVA_DEV
    TO ROLE RETAILNOVA_ENGINEER;
GRANT USAGE ON DATABASE RETAILNOVA_DB
    TO ROLE RETAILNOVA_ENGINEER;
GRANT USAGE ON ALL SCHEMAS IN DATABASE RETAILNOVA_DB
    TO ROLE RETAILNOVA_ENGINEER;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA RETAILNOVA_DB.RAW
    TO ROLE RETAILNOVA_ENGINEER;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA RETAILNOVA_DB.SILVER
    TO ROLE RETAILNOVA_ENGINEER;

-- 20.3 Grant Viewer Role: Read-only Gold layer
GRANT USAGE ON WAREHOUSE WH_RETAILNOVA_DEV
    TO ROLE RETAILNOVA_VIEWER;
GRANT USAGE ON DATABASE RETAILNOVA_DB
    TO ROLE RETAILNOVA_VIEWER;
GRANT USAGE ON SCHEMA RETAILNOVA_DB.GOLD
    TO ROLE RETAILNOVA_VIEWER;
GRANT SELECT ON ALL VIEWS IN SCHEMA RETAILNOVA_DB.GOLD
    TO ROLE RETAILNOVA_VIEWER;

-- 20.4 Assign Roles to Users
GRANT ROLE RETAILNOVA_ANALYST TO USER VISHNU;

-- 20.5 Verify Grants
SHOW GRANTS TO ROLE RETAILNOVA_ANALYST;
SHOW GRANTS TO ROLE RETAILNOVA_ENGINEER;
SHOW GRANTS ON SCHEMA RETAILNOVA_DB.SILVER;


--==========================================================
-- SECTION 21: SECURITY - FUTURE GRANTS
--==========================================================
-- Problem: "GRANT SELECT ON ALL TABLES" only works for tables that EXIST NOW.
--          New tables created later won't be accessible!
--
-- Solution: FUTURE GRANTS = automatically grant privileges on objects
--           that will be created in the future.
--
-- Think of it as: "Any new table in this schema should automatically
--                  be readable by this role."

-- 21.1 Future Grants for Analyst (auto-grant SELECT on new Silver/Gold tables)
GRANT SELECT ON FUTURE TABLES IN SCHEMA RETAILNOVA_DB.SILVER
    TO ROLE RETAILNOVA_ANALYST;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA RETAILNOVA_DB.GOLD
    TO ROLE RETAILNOVA_ANALYST;

-- 21.2 Future Grants for Engineer (auto-grant full access on new RAW tables)
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA RETAILNOVA_DB.RAW
    TO ROLE RETAILNOVA_ENGINEER;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA RETAILNOVA_DB.SILVER
    TO ROLE RETAILNOVA_ENGINEER;

-- 21.3 Future Grants for Viewer (auto-grant on new Gold views)
GRANT SELECT ON FUTURE VIEWS IN SCHEMA RETAILNOVA_DB.GOLD
    TO ROLE RETAILNOVA_VIEWER;

-- 21.4 Verify Future Grants
SHOW FUTURE GRANTS IN SCHEMA RETAILNOVA_DB.SILVER;
SHOW FUTURE GRANTS IN SCHEMA RETAILNOVA_DB.GOLD;


--==========================================================
-- SECTION 22: SECURITY - MASKING POLICIES
--==========================================================
-- Masking Policy = Hides sensitive data from unauthorized roles.
-- The data is still there, but certain roles see masked values.
--
-- Example: A salary column shows the real number to HR_ROLE,
--          but shows NULL or '***' to everyone else.
--
-- How it works:
--   1. CREATE MASKING POLICY (define the rule)
--   2. ALTER TABLE ... SET MASKING POLICY (attach it to a column)
--
-- The policy runs at query time - no data is physically changed.

USE DATABASE RETAILNOVA_DB;
USE SCHEMA UTILS;

-- 22.1 Create a Masking Policy for Customer IDs
-- Only RETAILNOVA_ENGINEER can see full Customer IDs
CREATE OR REPLACE MASKING POLICY MASK_CUSTOMER_ID
AS (VAL STRING)
RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'RETAILNOVA_ENGINEER')
        THEN VAL
        ELSE '***MASKED***'
    END;

-- 22.2 Apply Masking Policy to a Column
ALTER TABLE SILVER.ORDERS_CLEAN
    MODIFY COLUMN CUSTOMER_ID
    SET MASKING POLICY MASK_CUSTOMER_ID;

-- 22.3 Test: As ACCOUNTADMIN you'll see real data
SELECT ORDER_ID, CUSTOMER_ID, PRODUCT_ID
FROM SILVER.ORDERS_CLEAN
LIMIT 5;

-- 22.4 To test as another role (you'd see '***MASKED***'):
-- USE ROLE RETAILNOVA_VIEWER;
-- SELECT ORDER_ID, CUSTOMER_ID FROM SILVER.ORDERS_CLEAN LIMIT 5;

-- 22.5 Remove Masking Policy (if needed)
ALTER TABLE SILVER.ORDERS_CLEAN
    MODIFY COLUMN CUSTOMER_ID
    UNSET MASKING POLICY;

-- 22.6 Create a Numeric Masking Policy (for prices/amounts)
CREATE OR REPLACE MASKING POLICY MASK_PRICE
AS (VAL NUMBER)
RETURNS NUMBER ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'RETAILNOVA_ENGINEER', 'RETAILNOVA_ANALYST')
        THEN VAL
        ELSE 0
    END;

-- 22.7 Show All Masking Policies
SHOW MASKING POLICIES IN DATABASE RETAILNOVA_DB;


--==========================================================
-- SECTION 23: SECURITY - ROW ACCESS POLICIES
--==========================================================
-- Row Access Policy = Controls WHICH ROWS a user can see.
-- Masking hides column values. Row Access hides entire rows.
--
-- Example: India team can only see rows WHERE COUNTRY = 'India'
--          US team can only see rows WHERE COUNTRY = 'United States'
--
-- How it works:
--   1. CREATE ROW ACCESS POLICY (returns TRUE/FALSE per row)
--   2. ALTER TABLE ... ADD ROW ACCESS POLICY (attach to table)
--   3. At query time, only rows returning TRUE are visible.

USE SCHEMA UTILS;

-- 23.1 Create Row Access Policy
-- RETAILNOVA_ENGINEER and ACCOUNTADMIN see all rows.
-- RETAILNOVA_ANALYST only sees rows for 'India'.
CREATE OR REPLACE ROW ACCESS POLICY RAP_COUNTRY_FILTER
AS (COUNTRY_COL STRING)
RETURNS BOOLEAN ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'RETAILNOVA_ENGINEER')
        THEN TRUE
        WHEN CURRENT_ROLE() = 'RETAILNOVA_ANALYST' AND COUNTRY_COL = 'India'
        THEN TRUE
        ELSE FALSE
    END;

-- 23.2 Apply Row Access Policy to Silver Orders
ALTER TABLE SILVER.ORDERS_CLEAN
    ADD ROW ACCESS POLICY RAP_COUNTRY_FILTER ON (COUNTRY);

-- 23.3 Test: As ACCOUNTADMIN you see all countries
SELECT COUNTRY, COUNT(*) AS CNT
FROM SILVER.ORDERS_CLEAN
GROUP BY COUNTRY;

-- 23.4 Remove Row Access Policy (if needed)
ALTER TABLE SILVER.ORDERS_CLEAN
    DROP ROW ACCESS POLICY RAP_COUNTRY_FILTER;

-- 23.5 Show All Row Access Policies
SHOW ROW ACCESS POLICIES IN DATABASE RETAILNOVA_DB;


--==========================================================
-- SECTION 24: SECURITY - SECURE VIEWS
--==========================================================
-- A Secure View hides its SQL definition from non-owner roles.
-- Regular views: anyone with USAGE can see the view's SQL (SHOW CREATE VIEW).
-- Secure views: only the owner role can see the definition.
--
-- When to use:
--   - When the view logic contains business logic you want to protect
--   - When combining with masking/row-access for defense-in-depth
--   - When sharing data (Data Sharing requires secure views)
--
-- Trade-off: The query optimizer has less info, so secure views
--            can sometimes be slightly slower. Use only when needed.

-- 24.1 Create a Secure View (Gold layer - safe to share externally)
CREATE OR REPLACE SECURE VIEW GOLD.SECURE_FACT_SALES AS
SELECT
    O.ORDER_ID,
    O.CUSTOMER_ID,
    P.PRODUCT_NAME,
    P.CATEGORY,
    O.QUANTITY,
    O.PRICE,
    (O.QUANTITY * O.PRICE) AS TOTAL_AMOUNT,
    O.COUNTRY,
    O.INGESTION_DATE
FROM SILVER.ORDERS_CLEAN O
LEFT JOIN SILVER.PRODUCTS_CLEAN P
    ON O.PRODUCT_ID = P.PRODUCT_ID;

-- 24.2 Query Secure View (works exactly like a normal view)
SELECT * FROM GOLD.SECURE_FACT_SALES LIMIT 10;

-- 24.3 Verify it's secure
SHOW VIEWS LIKE 'SECURE%' IN SCHEMA GOLD;
-- The "is_secure" column will show TRUE

-- 24.4 Non-owners trying to see the definition will get an error:
-- SHOW CREATE VIEW GOLD.SECURE_FACT_SALES;
-- (would fail for non-owner roles)


--==========================================================
-- SECTION 25: SECURITY - NETWORK POLICIES (OVERVIEW)
--==========================================================
-- Network Policy = IP allowlist/blocklist for your Snowflake account.
-- Controls WHO (which IP addresses) can even connect to Snowflake.
--
-- Use cases:
--   - Only allow office IPs (block all others)
--   - Block known bad IPs
--   - Restrict specific users to specific IPs (e.g., service accounts)
--
-- Two levels:
--   Account-level: Applies to ALL users (set by ACCOUNTADMIN)
--   User-level:    Applies to a specific user only
--
-- CAUTION: If you lock yourself out, you'll need Snowflake Support!

-- 25.1 Create a Network Policy (example - DO NOT RUN unless you know your IP)
CREATE OR REPLACE NETWORK POLICY RETAILNOVA_OFFICE_POLICY
    ALLOWED_IP_LIST = ('203.0.113.0/24', '198.51.100.0/24')
    BLOCKED_IP_LIST = ('203.0.113.99')
    COMMENT = 'Allow only office IPs';

-- 25.2 Apply to Account (CAREFUL - can lock you out!)
-- ALTER ACCOUNT SET NETWORK_POLICY = RETAILNOVA_OFFICE_POLICY;

-- 25.3 Apply to Specific User Only (safer for testing)
-- ALTER USER SERVICE_ACCOUNT SET NETWORK_POLICY = RETAILNOVA_OFFICE_POLICY;

-- 25.4 Remove Network Policy
-- ALTER ACCOUNT UNSET NETWORK_POLICY;

-- 25.5 Show Network Policies
SHOW NETWORK POLICIES;

-- 25.6 Check your current IP
SELECT CURRENT_IP_ADDRESS();


--==========================================================
-- SECTION 26: PERFORMANCE - MATERIALIZED VIEWS
--==========================================================
-- Materialized View = A view whose results are PRE-COMPUTED and stored.
-- Regular view: re-runs the query every time you SELECT from it.
-- Materialized view: stores the result physically, updates automatically.
--
-- Benefits:
--   - Much faster reads (data already computed)
--   - Snowflake auto-refreshes when base table changes
--
-- Limitations:
--   - Extra storage cost (stores the result)
--   - Extra compute cost (auto-refresh uses credits)
--   - Limited SQL support (no joins, no UDFs, no subqueries in some cases)
--   - Enterprise Edition required
--
-- Best for: Frequently-queried aggregations on large tables.

-- 26.1 Create Materialized View (aggregation on orders)
CREATE OR REPLACE MATERIALIZED VIEW GOLD.MV_SALES_BY_COUNTRY AS
SELECT
    COUNTRY,
    COUNT(*)        AS TOTAL_ORDERS,
    SUM(PRICE)      AS TOTAL_REVENUE,
    AVG(PRICE)      AS AVG_ORDER_VALUE
FROM SILVER.ORDERS_CLEAN
GROUP BY COUNTRY;

-- 26.2 Query it (fast - reads pre-computed results)
SELECT * FROM GOLD.MV_SALES_BY_COUNTRY;

-- 26.3 Check refresh status
SHOW MATERIALIZED VIEWS IN SCHEMA GOLD;

-- 26.4 Drop if not needed (saves costs)
DROP MATERIALIZED VIEW IF EXISTS GOLD.MV_SALES_BY_COUNTRY;


--==========================================================
-- SECTION 27: ENTERPRISE - DATA SHARING
--==========================================================
-- Data Sharing = Share live data with other Snowflake accounts
--                WITHOUT copying, moving, or transferring data.
--
-- How it works:
--   Provider (you) creates a SHARE object.
--   Consumer (another account) creates a database FROM the share.
--   Consumer always sees YOUR latest data - zero lag, zero copies.
--
-- Key facts:
--   - Consumer doesn't pay for storage (provider owns the data)
--   - Consumer pays only for their compute (queries)
--   - Only SECURE VIEWS, SECURE UDFs, and tables can be shared
--   - Works across clouds and regions (with replication)

-- 27.1 Create a Share
CREATE OR REPLACE SHARE RETAILNOVA_ANALYTICS_SHARE
    COMMENT = 'RetailNova sales analytics for partner accounts';

-- 27.2 Grant objects to the Share
-- Must grant in order: Database -> Schema -> Objects
GRANT USAGE ON DATABASE RETAILNOVA_DB
    TO SHARE RETAILNOVA_ANALYTICS_SHARE;
GRANT USAGE ON SCHEMA RETAILNOVA_DB.GOLD
    TO SHARE RETAILNOVA_ANALYTICS_SHARE;
GRANT SELECT ON VIEW RETAILNOVA_DB.GOLD.SECURE_FACT_SALES
    TO SHARE RETAILNOVA_ANALYTICS_SHARE;

-- 27.3 Add Consumer Account(s)
-- Replace 'CONSUMER_ACCOUNT_LOCATOR' with the actual account
-- ALTER SHARE RETAILNOVA_ANALYTICS_SHARE
--     ADD ACCOUNTS = CONSUMER_ACCOUNT_LOCATOR;

-- 27.4 Show Shares
SHOW SHARES;

-- 27.5 See what's in a share
DESC SHARE RETAILNOVA_ANALYTICS_SHARE;

-- 27.6 Consumer side (run on the OTHER account):
-- CREATE DATABASE RETAILNOVA_SHARED FROM SHARE PROVIDER_ACCOUNT.RETAILNOVA_ANALYTICS_SHARE;
-- SELECT * FROM RETAILNOVA_SHARED.GOLD.SECURE_FACT_SALES;

-- 27.7 Revoke/Drop Share
-- DROP SHARE RETAILNOVA_ANALYTICS_SHARE;


--==========================================================
-- SECTION 28: ENTERPRISE - RESOURCE MONITORS
--==========================================================
-- Resource Monitor = Credit spending alarm + auto-shutdown.
-- Prevents runaway queries from burning through your budget.
--
-- How it works:
--   - Set a CREDIT QUOTA (e.g., 100 credits/month)
--   - Set TRIGGERS at percentages (e.g., notify at 75%, suspend at 100%)
--   - Actions: NOTIFY (email alert), SUSPEND (stop new queries),
--             SUSPEND_IMMEDIATELY (kill running queries too)
--
-- You can attach a monitor to:
--   - The entire account (catches everything)
--   - A specific warehouse (granular control)

-- 28.1 Create Resource Monitor (100 credits/month)
CREATE OR REPLACE RESOURCE MONITOR RETAILNOVA_MONITOR
WITH
    CREDIT_QUOTA = 100
    FREQUENCY = MONTHLY
    START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND
        ON 110 PERCENT DO SUSPEND_IMMEDIATELY;

-- 28.2 Attach to a Warehouse
ALTER WAREHOUSE WH_RETAILNOVA_DEV
    SET RESOURCE_MONITOR = RETAILNOVA_MONITOR;

-- 28.3 Attach to Entire Account (use carefully)
-- ALTER ACCOUNT SET RESOURCE_MONITOR = RETAILNOVA_MONITOR;

-- 28.4 Check Monitor Status
SHOW RESOURCE MONITORS;

-- 28.5 Remove Monitor from Warehouse
-- ALTER WAREHOUSE WH_RETAILNOVA_DEV SET RESOURCE_MONITOR = NULL;


--==========================================================
-- SECTION 29: ENTERPRISE - STREAMS & TASKS GRAPH (DAG)
--==========================================================
-- In Sections 10-11 we created individual tasks.
-- A Task Graph (DAG) = Multiple tasks chained together.
--   Root Task -> Child Task 1 -> Child Task 2 -> ...
--
-- How it works:
--   - Root task has a SCHEDULE (e.g., every 5 min, or CRON)
--   - Child tasks have AFTER <parent_task> (no schedule)
--   - When root finishes, children run automatically in order
--   - A "Finalizer" task runs LAST, regardless of success/failure
--
-- Think of it as: Trigger -> Load -> Transform -> Validate -> Log
--
-- Important rules:
--   - Only RESUME the ROOT task (children auto-resume with it)
--   - Max 1000 tasks in a single graph
--   - SUSPEND the root task to stop the entire pipeline

-- 29.1 Create a Task DAG for RetailNova Orders Pipeline
-- Root Task: Loads new data from stage to Bronze
CREATE OR REPLACE TASK RETAILNOVA_DAG_ROOT
    WAREHOUSE = WH_RETAILNOVA_DEV
    SCHEDULE = 'USING CRON 0 */6 * * * Asia/Kolkata'  -- Every 6 hours
    COMMENT = 'RetailNova pipeline root - checks for new order files'
AS
    COPY INTO RAW.ORDERS_BRONZE
    FROM
    (
        SELECT
            $1, $2, $3, $4, $5, $6,
            METADATA$FILENAME,
            CURRENT_TIMESTAMP(),
            CURRENT_DATE()
        FROM @RETAILNOVA_DB.RAW.STG_ORDERS
    )
    FILE_FORMAT = (FORMAT_NAME = RETAILNOVA_DB.UTILS.FF_CSV)
    ON_ERROR = CONTINUE;

-- Child Task 1: Clean and load into Silver (runs AFTER root)
CREATE OR REPLACE TASK RETAILNOVA_DAG_SILVER
    WAREHOUSE = WH_RETAILNOVA_DEV
    AFTER RETAILNOVA_DAG_ROOT
    COMMENT = 'Merge valid orders into Silver layer'
AS
    INSERT INTO SILVER.ORDERS_CLEAN
    SELECT
        ORDER_ID, CUSTOMER_ID, PRODUCT_ID,
        QUANTITY, PRICE, INITCAP(TRIM(COUNTRY)),
        SOURCE_FILE_NAME, LOAD_TIMESTAMP, INGESTION_DATE
    FROM RAW.ORDERS_BRONZE
    WHERE ORDER_ID IS NOT NULL
      AND CUSTOMER_ID IS NOT NULL
      AND PRICE > 0
      AND QUANTITY > 0;

-- Child Task 2: Log rejected records (runs AFTER silver load)
CREATE OR REPLACE TASK RETAILNOVA_DAG_REJECTS
    WAREHOUSE = WH_RETAILNOVA_DEV
    AFTER RETAILNOVA_DAG_SILVER
    COMMENT = 'Capture rejected orders'
AS
    INSERT INTO REJECTS.ORDERS_REJECTED
    (ORDER_ID, CUSTOMER_ID, PRODUCT_ID, QUANTITY, PRICE,
     COUNTRY, SOURCE_FILE_NAME, REJECTION_REASON, LOAD_TIMESTAMP)
    SELECT
        ORDER_ID, CUSTOMER_ID, PRODUCT_ID, QUANTITY, PRICE,
        COUNTRY, SOURCE_FILE_NAME,
        CASE
            WHEN ORDER_ID IS NULL    THEN 'Missing Order ID'
            WHEN CUSTOMER_ID IS NULL THEN 'Missing Customer'
            WHEN PRICE <= 0          THEN 'Invalid Price'
            WHEN QUANTITY <= 0       THEN 'Invalid Quantity'
        END,
        CURRENT_TIMESTAMP()
    FROM RAW.ORDERS_BRONZE
    WHERE ORDER_ID IS NULL
       OR CUSTOMER_ID IS NULL
       OR PRICE <= 0
       OR QUANTITY <= 0;

-- Finalizer Task: Audit log (runs LAST, even if earlier tasks fail)
CREATE OR REPLACE TASK RETAILNOVA_DAG_AUDIT
    WAREHOUSE = WH_RETAILNOVA_DEV
    AFTER RETAILNOVA_DAG_REJECTS
    COMMENT = 'Log pipeline run to audit table'
AS
    INSERT INTO AUDIT.FILE_LOAD_HISTORY
    SELECT
        'ORDERS_DAG_PIPELINE',
        SOURCE_FILE_NAME,
        COUNT(*),
        COUNT_IF(ORDER_ID IS NOT NULL AND PRICE > 0),
        COUNT_IF(ORDER_ID IS NULL OR PRICE <= 0),
        MIN(LOAD_TIMESTAMP),
        MAX(LOAD_TIMESTAMP),
        'SUCCESS'
    FROM RAW.ORDERS_BRONZE
    GROUP BY SOURCE_FILE_NAME;

-- 29.2 Resume the DAG (only resume ROOT - children follow automatically)
ALTER TASK RETAILNOVA_DAG_ROOT RESUME;

-- 29.3 Check Task Graph
SHOW TASKS IN SCHEMA RAW;

-- 29.4 Monitor Task Runs
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    SCHEDULED_TIME_RANGE_START => DATEADD('HOUR', -24, CURRENT_TIMESTAMP())
))
ORDER BY SCHEDULED_TIME DESC;

-- 29.5 Suspend the DAG (stops everything)
ALTER TASK RETAILNOVA_DAG_ROOT SUSPEND;

-- 29.6 Cleanup (drop in reverse order: children first, root last)
-- DROP TASK RETAILNOVA_DAG_AUDIT;
-- DROP TASK RETAILNOVA_DAG_REJECTS;
-- DROP TASK RETAILNOVA_DAG_SILVER;
-- DROP TASK RETAILNOVA_DAG_ROOT;


--==========================================================
-- SECTION 30: ENTERPRISE - FAIL-SAFE (QUICK RECAP)
--==========================================================
-- Fail-Safe = Snowflake's LAST RESORT data recovery layer.
--
-- Timeline of data protection:
--   ┌─────────────────────────────────────────────────────┐
--   │ Active Data │ Time Travel (1-90 days) │ Fail-Safe  │
--   │  (current)  │   (you can query/undo)  │  (7 days)  │
--   └─────────────────────────────────────────────────────┘
--
-- Key facts:
--   - Fail-Safe = 7 days AFTER Time Travel expires
--   - You CANNOT access Fail-Safe yourself
--   - Only Snowflake Support can recover data from Fail-Safe
--   - It's for catastrophic disasters only (not an "undo" feature)
--   - Fail-Safe storage costs money (you pay for it)
--   - Transient/Temporary tables have NO Fail-Safe (saves cost)
--
-- Storage cost hierarchy:
--   Permanent Table:  Active + Time Travel (1-90 days) + Fail-Safe (7 days)
--   Transient Table:  Active + Time Travel (0-1 day)   + NO Fail-Safe
--   Temporary Table:  Active + Time Travel (0-1 day)   + NO Fail-Safe (session only)

-- 30.1 Check your table types and their Time Travel settings
SELECT
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE,
    IS_TRANSIENT,
    RETENTION_TIME
FROM RETAILNOVA_DB.INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('RAW', 'SILVER', 'GOLD')
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- 30.2 Set Time Travel retention (max depends on edition)
-- Standard Edition: max 1 day
-- Enterprise Edition: max 90 days
ALTER TABLE SILVER.ORDERS_CLEAN
    SET DATA_RETENTION_TIME_IN_DAYS = 7;

-- 30.3 Create a Transient Table (no Fail-Safe, saves storage cost)
-- Use for staging/temp data that can be re-loaded
CREATE OR REPLACE TRANSIENT TABLE RAW.ORDERS_STAGING
(
    ORDER_ID         STRING,
    CUSTOMER_ID      STRING,
    PRODUCT_ID       STRING,
    QUANTITY         NUMBER,
    PRICE            NUMBER,
    COUNTRY          STRING
)
DATA_RETENTION_TIME_IN_DAYS = 0;

-- 30.4 Create a Temporary Table (exists only during your session)
CREATE OR REPLACE TEMPORARY TABLE RAW.TEMP_ANALYSIS AS
SELECT COUNTRY, COUNT(*) AS CNT
FROM SILVER.ORDERS_CLEAN
GROUP BY COUNTRY;

SELECT * FROM RAW.TEMP_ANALYSIS;
-- This table disappears when your session ends!

-- 30.5 Check Storage Usage (see Fail-Safe costs)
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TABLE_CATALOG = 'RETAILNOVA_DB'
  AND TABLE_SCHEMA = 'SILVER'
ORDER BY FAILSAFE_BYTES DESC
LIMIT 10;


--==========================================================
-- END OF RETAILNOVA PROJECT
--==========================================================
-- Summary of all sections:
--   1.  Infrastructure Setup (Warehouse, DB, Schemas)
--   2.  File Formats (CSV, JSON, Parquet)
--   3.  Orders Pipeline - Bronze (Raw Ingestion)
--   4.  Orders Pipeline - Silver (Cleansed)
--   5.  Rejects & Audit Tables
--   6.  Incremental Orders Load
--   7.  Products Pipeline - Bronze (JSON)
--   8.  Products Pipeline - Silver
--   9.  Gold Layer - Fact View & Analytics
--   10. Streams & Tasks - Orders CDC
--   11. Streams & Tasks - Products CDC
--   12. Monitoring & Diagnostics
--   13. Time Travel - Delete & Restore
--   14. Zero-Copy Cloning
--   15. Stored Procedures
--   16. Dynamic Tables
--   17. Performance & Optimization Reference
--   18. Security - System Roles
--   19. Security - Custom Roles (RBAC)
--   20. Security - Grants (Privileges)
--   21. Security - Future Grants
--   22. Security - Masking Policies
--   23. Security - Row Access Policies
--   24. Security - Secure Views
--   25. Security - Network Policies
--   26. Performance - Materialized Views
--   27. Enterprise - Data Sharing
--   28. Enterprise - Resource Monitors
--   29. Enterprise - Streams & Tasks Graph (DAG)
--   30. Enterprise - Fail-Safe
--==========================================================