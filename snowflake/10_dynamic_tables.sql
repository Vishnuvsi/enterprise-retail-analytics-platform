/******************************************************************************
Project      : RetailNova
Module       : 10 - Dynamic Tables
Author       : V Raju
Environment  : DEV
Platform     : Snowflake

Description
-----------
Automatically maintains transformed tables without manually
executing MERGE statements or scheduling Tasks.

Business Scenario
-----------------
RetailNova receives incremental data in Bronze.

Instead of writing

Bronze
   │
   ▼
Stream
   │
   ▼
Task
   │
   ▼
Stored Procedure
   │
   ▼
MERGE
   │
   ▼
Silver

We can allow Snowflake to automatically refresh
a transformed table using Dynamic Tables.

******************************************************************************/

USE ROLE SYSADMIN;

USE DATABASE RETAILNOVA_DB;

USE SCHEMA SILVER;

------------------------------------------------------------
-- CREATE DYNAMIC TABLE
------------------------------------------------------------

CREATE OR REPLACE DYNAMIC TABLE DT_ORDERS

TARGET_LAG='5 MINUTES'

WAREHOUSE=RETAILNOVA_WH

AS

SELECT

ORDER_ID,
CUSTOMER_ID,
PRODUCT_ID,
STORE_ID,
ORDER_DATE,
QUANTITY,
UNIT_PRICE,
TOTAL_AMOUNT,
LOAD_TIMESTAMP,
SOURCE_FILENAME,
LOAD_DATE

FROM BRONZE.ORDERS_RAW;

------------------------------------------------------------
-- VERIFY
------------------------------------------------------------

SHOW DYNAMIC TABLES;

DESC DYNAMIC TABLE DT_ORDERS;

------------------------------------------------------------
-- QUERY DYNAMIC TABLE
------------------------------------------------------------

SELECT *

FROM DT_ORDERS

LIMIT 20;

------------------------------------------------------------
-- SUSPEND REFRESH
------------------------------------------------------------

ALTER DYNAMIC TABLE DT_ORDERS

SUSPEND;

------------------------------------------------------------
-- RESUME REFRESH
------------------------------------------------------------

ALTER DYNAMIC TABLE DT_ORDERS

RESUME;

------------------------------------------------------------
-- CHANGE TARGET LAG
------------------------------------------------------------

ALTER DYNAMIC TABLE DT_ORDERS

SET TARGET_LAG='10 MINUTES';

------------------------------------------------------------
-- REFRESH HISTORY
------------------------------------------------------------

SELECT *

FROM TABLE(

INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY()

)

ORDER BY DATA_TIMESTAMP DESC;

------------------------------------------------------------
-- OPTIONAL CLEANUP
------------------------------------------------------------

/*

DROP DYNAMIC TABLE DT_ORDERS;

*/

------------------------------------------------------------
-- INTERVIEW NOTES
------------------------------------------------------------

/*

Q1. What is a Dynamic Table?

A Dynamic Table automatically
maintains the result of a query.

--------------------------------------------------

Q2. What is TARGET_LAG?

Maximum acceptable data freshness.

Example

TARGET_LAG='5 MINUTES'

means Snowflake attempts to keep
the Dynamic Table within 5 minutes
of the source data.

--------------------------------------------------

Q3. Does Dynamic Table replace Streams?

No.

Streams

↓

Capture Changes

Dynamic Tables

↓

Maintain Query Results

--------------------------------------------------

Q4. Does Dynamic Table replace Tasks?

Partially.

Simple transformation pipelines

↓

Dynamic Tables

Complex workflows

↓

Tasks + Stored Procedures + Airflow

--------------------------------------------------

Q5. When should we use Dynamic Tables?

Simple

Incremental

Transformation

Pipelines

--------------------------------------------------

When should we avoid them?

Complex

Business Rules

Multi-step Processing

Heavy Transaction Logic

--------------------------------------------------

Best Practices

✔ Keep SQL simple

✔ Use reasonable TARGET_LAG

✔ Monitor Refresh History

✔ Suspend in DEV when not required

✔ Prefer dbt for enterprise transformation layers

*/