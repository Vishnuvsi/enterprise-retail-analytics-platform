/******************************************************************************
Project      : RetailNova
Module       : 04 - External Stage Creation
Author       : V Raju
Environment  : DEV
Platform     : Snowflake

Description
-----------
Creates reusable External Stages pointing to Azure ADLS Gen2.

Architecture
------------

Azure ADLS
      │
Storage Integration
      │
External Stage
      │
LIST
      │
COPY INTO

******************************************************************************/

USE ROLE SYSADMIN;

USE DATABASE RETAILNOVA_DB;

USE SCHEMA BRONZE;

-------------------------------------------------------------------------
-- CREATE EXTERNAL STAGE
-------------------------------------------------------------------------

CREATE OR REPLACE STAGE STG_RETAILNOVA
URL='azure://retailnovastorage.blob.core.windows.net/data'
STORAGE_INTEGRATION=RETAILNOVA_AZURE_INT
FILE_FORMAT=FF_CSV
COMMENT='RetailNova Azure External Stage';

-------------------------------------------------------------------------
-- VERIFY STAGE
-------------------------------------------------------------------------

SHOW STAGES;

DESCRIBE STAGE STG_RETAILNOVA;

-------------------------------------------------------------------------
-- LIST FILES
-------------------------------------------------------------------------

LIST @STG_RETAILNOVA;

-------------------------------------------------------------------------
-- LIST FILES INSIDE ORDERS FOLDER
-------------------------------------------------------------------------

LIST @STG_RETAILNOVA/landing/orders;

-------------------------------------------------------------------------
-- LIST FILES INSIDE CUSTOMERS FOLDER
-------------------------------------------------------------------------

LIST @STG_RETAILNOVA/landing/customers;

-------------------------------------------------------------------------
-- LIST FILES INSIDE PRODUCTS FOLDER
-------------------------------------------------------------------------

LIST @STG_RETAILNOVA/landing/products;

-------------------------------------------------------------------------
-- LOAD ONLY CSV FILES
-------------------------------------------------------------------------

LIST @STG_RETAILNOVA
PATTERN='.*\.csv';

-------------------------------------------------------------------------
-- LOAD ONLY JSON FILES
-------------------------------------------------------------------------

LIST @STG_RETAILNOVA
PATTERN='.*\.json';

-------------------------------------------------------------------------
-- READ FILE DIRECTLY FROM STAGE
-------------------------------------------------------------------------

SELECT *

FROM @STG_RETAILNOVA/landing/orders/

(FILE_FORMAT => FF_CSV)

LIMIT 10;

-------------------------------------------------------------------------
-- READ JSON FILE DIRECTLY
-------------------------------------------------------------------------

SELECT *

FROM @STG_RETAILNOVA/json/

(FILE_FORMAT => FF_JSON);

-------------------------------------------------------------------------
-- OPTIONAL CLEANUP
-------------------------------------------------------------------------

/*

DROP STAGE STG_RETAILNOVA;

*/

-------------------------------------------------------------------------
-- INTERVIEW NOTES
-------------------------------------------------------------------------

/*

Q1. What is an External Stage?

Stores the location of files
outside Snowflake.

Only metadata is stored.

Data remains in Azure.


-----------------------------------------------------

Q2. Difference between Internal and External Stage?

Internal Stage

↓

Snowflake Storage

External Stage

↓

Azure

AWS

GCP


-----------------------------------------------------

Q3. Why create Stage?

Avoid repeatedly specifying

URL

Storage Integration

File Format

in every COPY INTO statement.


-----------------------------------------------------

Q4. Can one Stage load multiple folders?

Yes.

Example

landing/orders

landing/customers

landing/products

landing/stores


-----------------------------------------------------

Q5. What does LIST do?

Displays files available
inside the Stage.


-----------------------------------------------------

Q6. Why use PATTERN?

Load only

CSV

JSON

Parquet

or specific files.


-----------------------------------------------------

Best Practices

✔ One Stage per Storage Container

✔ Use Storage Integration

✔ Reuse File Formats

✔ Keep folder hierarchy organized

✔ Validate using LIST before COPY INTO

*/