/******************************************************************************
Project      : RetailNova
Module       : 13 - Governance, Resource Monitors & Secure Data Sharing
Author       : V Raju
Environment  : DEV
Platform     : Snowflake

Description
-----------
Implements enterprise governance features.

Topics Covered

1. Resource Monitors
2. Credit Management
3. Warehouse Governance
4. Secure Data Sharing
5. Reader Accounts (Overview)
6. Snowflake Marketplace (Overview)

******************************************************************************/

USE ROLE ACCOUNTADMIN;

----------------------------------------------------------------------------
-- RESOURCE MONITOR
----------------------------------------------------------------------------

CREATE OR REPLACE RESOURCE MONITOR RM_RETAILNOVA

WITH

CREDIT_QUOTA = 100

FREQUENCY = MONTHLY

START_TIMESTAMP = IMMEDIATELY

TRIGGERS

ON 75 PERCENT DO NOTIFY

ON 90 PERCENT DO SUSPEND

ON 100 PERCENT DO SUSPEND_IMMEDIATE;

----------------------------------------------------------------------------
-- ASSIGN RESOURCE MONITOR
----------------------------------------------------------------------------

ALTER WAREHOUSE RETAILNOVA_WH

SET RESOURCE_MONITOR = RM_RETAILNOVA;

----------------------------------------------------------------------------
-- VERIFY
----------------------------------------------------------------------------

SHOW RESOURCE MONITORS;

SHOW WAREHOUSES;

----------------------------------------------------------------------------
-- SECURE DATA SHARING
----------------------------------------------------------------------------

CREATE SHARE RETAILNOVA_SHARE;

----------------------------------------------------------------------------
-- GRANT DATABASE USAGE
----------------------------------------------------------------------------

GRANT USAGE

ON DATABASE RETAILNOVA_DB

TO SHARE RETAILNOVA_SHARE;

----------------------------------------------------------------------------
-- GRANT SCHEMA USAGE
----------------------------------------------------------------------------

GRANT USAGE

ON SCHEMA GOLD

TO SHARE RETAILNOVA_SHARE;

----------------------------------------------------------------------------
-- SHARE TABLE
----------------------------------------------------------------------------

GRANT SELECT

ON TABLE GOLD.FACT_ORDERS

TO SHARE RETAILNOVA_SHARE;

----------------------------------------------------------------------------
-- VERIFY SHARE
----------------------------------------------------------------------------

SHOW SHARES;

----------------------------------------------------------------------------
-- READER ACCOUNT (Reference)
----------------------------------------------------------------------------

/*

Reader Accounts

Allow customers

without Snowflake Accounts

to consume shared data.

Typically used

for external partners.

*/

----------------------------------------------------------------------------
-- DATA MARKETPLACE (Reference)
----------------------------------------------------------------------------

/*

Snowflake Marketplace

Publish

Datasets

ML Models

Weather

Financial Data

Geographical Data

Healthcare Data

Partners can subscribe

without file movement.

*/

----------------------------------------------------------------------------
-- OPTIONAL CLEANUP
----------------------------------------------------------------------------

/*

DROP SHARE RETAILNOVA_SHARE;

DROP RESOURCE MONITOR RM_RETAILNOVA;

*/

----------------------------------------------------------------------------
-- INTERVIEW NOTES
----------------------------------------------------------------------------

/*

--------------------------------------------------

RESOURCE MONITOR

Controls

Warehouse Credit Usage

Can

Notify

Suspend

Suspend Immediately

--------------------------------------------------

Why Resource Monitor?

Avoid

Unexpected Costs

Credit Overruns

Weekend Warehouse Usage

--------------------------------------------------

SECURE DATA SHARING

Shares

Live Data

Without

CSV

FTP

ETL

Data Duplication

--------------------------------------------------

Benefits

Real-Time

Secure

Governed

Read Only

No Data Copy

--------------------------------------------------

Difference

Database Backup

↓

Copies Data

Data Sharing

↓

No Copy

--------------------------------------------------

Reader Account

Consumer

Without

Snowflake License

--------------------------------------------------

Marketplace

Public Data Sharing

--------------------------------------------------

Best Practices

✔ Create Resource Monitor

✔ Monitor Warehouse Credits

✔ Share only Gold Layer

✔ Never Share Bronze

✔ Use Secure Views

✔ Mask Sensitive Columns

✔ Apply Row Access Policies

✔ Share Read Only Objects

*/