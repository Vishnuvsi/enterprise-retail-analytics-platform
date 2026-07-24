/******************************************************************************
Project      : RetailNova
Module       : 01 - Database Setup
Author       : V Raju
Environment  : DEV
Platform     : Snowflake

Description
-----------
Creates the core Snowflake objects required for the RetailNova project.

Objects Created
---------------
1. Warehouse
2. Database
3. Bronze Schema
4. Silver Schema
5. Gold Schema

Business Architecture
---------------------
Azure ADLS
      │
      ▼
 Bronze Schema
      │
      ▼
 Silver Schema
      │
      ▼
 Gold Schema

******************************************************************************/

-------------------------------------------------------------------------
-- STEP 1 : USE SYSADMIN ROLE
-------------------------------------------------------------------------

USE ROLE SYSADMIN;

-------------------------------------------------------------------------
-- STEP 2 : CREATE WAREHOUSE
-------------------------------------------------------------------------

CREATE WAREHOUSE IF NOT EXISTS RETAILNOVA_WH
WITH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for RetailNova Data Engineering Project';

-------------------------------------------------------------------------
-- STEP 3 : CREATE DATABASE
-------------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS RETAILNOVA_DB
COMMENT='RetailNova Enterprise Data Platform';

-------------------------------------------------------------------------
-- STEP 4 : CREATE SCHEMAS
-------------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS RETAILNOVA_DB.BRONZE
COMMENT='Raw Landing Layer';

CREATE SCHEMA IF NOT EXISTS RETAILNOVA_DB.SILVER
COMMENT='Validated Business Layer';

CREATE SCHEMA IF NOT EXISTS RETAILNOVA_DB.GOLD
COMMENT='Reporting Layer';

-------------------------------------------------------------------------
-- STEP 5 : USE OBJECTS
-------------------------------------------------------------------------

USE WAREHOUSE RETAILNOVA_WH;

USE DATABASE RETAILNOVA_DB;

USE SCHEMA BRONZE;

-------------------------------------------------------------------------
-- STEP 6 : VERIFY CREATED OBJECTS
-------------------------------------------------------------------------

SHOW WAREHOUSES;

SHOW DATABASES;

SHOW SCHEMAS IN DATABASE RETAILNOVA_DB;

-------------------------------------------------------------------------
-- STEP 7 : VERIFY CURRENT CONTEXT
-------------------------------------------------------------------------

SELECT CURRENT_ROLE();

SELECT CURRENT_WAREHOUSE();

SELECT CURRENT_DATABASE();

SELECT CURRENT_SCHEMA();

-------------------------------------------------------------------------
-- STEP 8 : OPTIONAL CLEANUP (ONLY FOR PRACTICE)
-------------------------------------------------------------------------

/*

DROP DATABASE RETAILNOVA_DB;

DROP WAREHOUSE RETAILNOVA_WH;

*/

-------------------------------------------------------------------------
-- INTERVIEW NOTES
-------------------------------------------------------------------------

/*

Q1. Why separate Bronze, Silver and Gold schemas?

Bronze
-------
Stores raw data exactly as received.

Silver
-------
Stores validated and transformed business data.

Gold
-----
Stores analytical models such as Fact and Dimension tables.


--------------------------------------------------

Q2. Why create a Warehouse separately?

Warehouse provides compute.

Storage and Compute are independent in Snowflake.

Multiple Warehouses can query the same Database.


--------------------------------------------------

Q3. Why AUTO_SUSPEND = 60 ?

To reduce Snowflake compute cost.

Warehouse automatically suspends after
60 seconds of inactivity.


--------------------------------------------------

Q4. Difference between Warehouse and Database?

Warehouse
----------
Compute

Database
---------
Storage


--------------------------------------------------

Q5. Why create separate schemas instead of one schema?

Logical separation

Security

Easy maintenance

Role-based access

Environment isolation


--------------------------------------------------

Best Practices

✔ Always use IF NOT EXISTS

✔ Keep Warehouse separate from Storage

✔ Use AUTO_SUSPEND

✔ Use AUTO_RESUME

✔ Add COMMENTS

✔ Follow Bronze → Silver → Gold architecture

*/