/******************************************************************************
Project      : RetailNova
Module       : 12 - Performance Optimization
Author       : V Raju
Environment  : DEV
Platform     : Snowflake

Description
-----------
Demonstrates enterprise performance optimization techniques.

Topics Covered
--------------
1. Query Profile
2. Warehouse Optimization
3. Micro-partitions
4. Clustering Keys
5. Search Optimization
6. Materialized Views

******************************************************************************/

USE ROLE SYSADMIN;

USE DATABASE RETAILNOVA_DB;

USE SCHEMA GOLD;

----------------------------------------------------------------------------
-- QUERY PROFILE
----------------------------------------------------------------------------

/*

Run the query below and inspect Query Profile
from the Snowflake UI.

Look for

✔ Partitions Scanned
✔ Bytes Scanned
✔ Join Strategy
✔ Disk Spillage
✔ Execution Time

*/

SELECT *

FROM FACT_ORDERS

WHERE ORDER_DATE='2026-07-24';

----------------------------------------------------------------------------
-- CLUSTERING KEY
----------------------------------------------------------------------------

ALTER TABLE FACT_ORDERS

CLUSTER BY (ORDER_DATE);

----------------------------------------------------------------------------
-- VERIFY CLUSTERING
----------------------------------------------------------------------------

SELECT SYSTEM$CLUSTERING_INFORMATION('FACT_ORDERS');

----------------------------------------------------------------------------
-- SEARCH OPTIMIZATION
----------------------------------------------------------------------------

ALTER TABLE FACT_ORDERS

ADD SEARCH OPTIMIZATION;

----------------------------------------------------------------------------
-- REMOVE SEARCH OPTIMIZATION
----------------------------------------------------------------------------

/*

ALTER TABLE FACT_ORDERS

DROP SEARCH OPTIMIZATION;

*/

----------------------------------------------------------------------------
-- MATERIALIZED VIEW
----------------------------------------------------------------------------

CREATE OR REPLACE MATERIALIZED VIEW MV_COUNTRY_SALES

AS

SELECT

COUNTRY,

SUM(TOTAL_AMOUNT) TOTAL_SALES,

COUNT(*) TOTAL_ORDERS

FROM FACT_ORDERS

GROUP BY COUNTRY;

----------------------------------------------------------------------------
-- VERIFY MATERIALIZED VIEW
----------------------------------------------------------------------------

SELECT *

FROM MV_COUNTRY_SALES;

----------------------------------------------------------------------------
-- WAREHOUSE RESIZE
----------------------------------------------------------------------------

ALTER WAREHOUSE RETAILNOVA_WH

SET WAREHOUSE_SIZE='MEDIUM';

----------------------------------------------------------------------------
-- AUTO SUSPEND
----------------------------------------------------------------------------

ALTER WAREHOUSE RETAILNOVA_WH

SET AUTO_SUSPEND=60;

----------------------------------------------------------------------------
-- AUTO RESUME
----------------------------------------------------------------------------

ALTER WAREHOUSE RETAILNOVA_WH

SET AUTO_RESUME=TRUE;

----------------------------------------------------------------------------
-- VERIFY WAREHOUSE
----------------------------------------------------------------------------

SHOW WAREHOUSES;

----------------------------------------------------------------------------
-- OPTIONAL CLEANUP
----------------------------------------------------------------------------

/*

DROP MATERIALIZED VIEW MV_COUNTRY_SALES;

*/

----------------------------------------------------------------------------
-- INTERVIEW NOTES
----------------------------------------------------------------------------

/*

--------------------------------------------------

MICRO-PARTITIONS

Automatically created by Snowflake.

Approximately 16 MB compressed.

Contain metadata

Minimum Value

Maximum Value

Distinct Values

Null Count

Used for

Partition Pruning.

--------------------------------------------------

PARTITION PRUNING

Reads only

required Micro-partitions.

Not the entire table.

--------------------------------------------------

CLUSTERING KEY

Used for

Very Large Tables

Frequently Filtered Columns

Examples

ORDER_DATE

CUSTOMER_ID

COUNTRY

Avoid for

Small Tables

Frequently Updated Tables

--------------------------------------------------

SEARCH OPTIMIZATION

Best for

Point Lookups

Examples

WHERE ORDER_ID=12345

WHERE CUSTOMER_ID=1001

Not useful for

Large Range Scans

--------------------------------------------------

MATERIALIZED VIEW

Stores precomputed query results.

Best for

Dashboards

Aggregations

Frequently Executed Reports

--------------------------------------------------

WAREHOUSE TUNING

Scale Warehouse

for

Heavy Queries

Do NOT

Oversize Warehouses

Without Analysis.

--------------------------------------------------

QUERY PROFILE

Always check

Disk Spillage

Join Strategy

Bytes Scanned

Partitions Scanned

Execution Time

--------------------------------------------------

Best Practices

✔ Let Snowflake use Partition Pruning

✔ Cluster only when necessary

✔ Use Search Optimization selectively

✔ Use Materialized Views for repeated aggregations

✔ Monitor Query Profile before resizing Warehouses

✔ Keep Auto Suspend enabled

*/