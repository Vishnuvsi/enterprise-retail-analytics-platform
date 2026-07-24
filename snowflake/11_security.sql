/******************************************************************************
Project      : RetailNova
Module       : 11 - Security
Author       : V Raju
Environment  : DEV
Platform     : Snowflake

Description
-----------
Implements Enterprise Security using

• Roles
• Users
• Grants
• Future Grants
• Masking Policies
• Row Access Policies
• Secure Views

Architecture
------------

User
   │
Role (RBAC)
   │
Privileges
   │
Objects

******************************************************************************/

USE ROLE SECURITYADMIN;

USE DATABASE RETAILNOVA_DB;

----------------------------------------------------------------------------
-- CREATE ROLES
----------------------------------------------------------------------------

CREATE ROLE IF NOT EXISTS RETAIL_ADMIN_ROLE;

CREATE ROLE IF NOT EXISTS DATA_ENGINEER_ROLE;

CREATE ROLE IF NOT EXISTS BI_ANALYST_ROLE;

CREATE ROLE IF NOT EXISTS HR_ROLE;

----------------------------------------------------------------------------
-- ROLE HIERARCHY
----------------------------------------------------------------------------

GRANT ROLE DATA_ENGINEER_ROLE TO ROLE SYSADMIN;

GRANT ROLE BI_ANALYST_ROLE TO ROLE SYSADMIN;

GRANT ROLE HR_ROLE TO ROLE SYSADMIN;

----------------------------------------------------------------------------
-- DATABASE ACCESS
----------------------------------------------------------------------------

GRANT USAGE
ON DATABASE RETAILNOVA_DB
TO ROLE DATA_ENGINEER_ROLE;

GRANT USAGE
ON DATABASE RETAILNOVA_DB
TO ROLE BI_ANALYST_ROLE;

----------------------------------------------------------------------------
-- SCHEMA ACCESS
----------------------------------------------------------------------------

GRANT USAGE
ON SCHEMA BRONZE
TO ROLE DATA_ENGINEER_ROLE;

GRANT USAGE
ON SCHEMA SILVER
TO ROLE DATA_ENGINEER_ROLE;

GRANT USAGE
ON SCHEMA GOLD
TO ROLE DATA_ENGINEER_ROLE;

GRANT USAGE
ON SCHEMA GOLD
TO ROLE BI_ANALYST_ROLE;

----------------------------------------------------------------------------
-- TABLE ACCESS
----------------------------------------------------------------------------

GRANT SELECT
ON TABLE GOLD.FACT_ORDERS
TO ROLE BI_ANALYST_ROLE;

GRANT SELECT,INSERT,UPDATE,DELETE
ON ALL TABLES IN SCHEMA SILVER
TO ROLE DATA_ENGINEER_ROLE;

----------------------------------------------------------------------------
-- FUTURE GRANTS
----------------------------------------------------------------------------

GRANT SELECT
ON FUTURE TABLES
IN SCHEMA GOLD
TO ROLE BI_ANALYST_ROLE;

GRANT SELECT,INSERT,UPDATE,DELETE
ON FUTURE TABLES
IN SCHEMA SILVER
TO ROLE DATA_ENGINEER_ROLE;

----------------------------------------------------------------------------
-- MASKING POLICY
----------------------------------------------------------------------------

CREATE OR REPLACE MASKING POLICY MASK_PHONE

AS

(PHONE STRING)

RETURNS STRING

->

CASE

WHEN CURRENT_ROLE()='HR_ROLE'

THEN PHONE

ELSE '**********'

END;

----------------------------------------------------------------------------
-- APPLY MASKING POLICY
----------------------------------------------------------------------------

ALTER TABLE SILVER.CUSTOMERS

MODIFY COLUMN PHONE

SET MASKING POLICY MASK_PHONE;

----------------------------------------------------------------------------
-- ROW ACCESS POLICY
----------------------------------------------------------------------------

CREATE OR REPLACE ROW ACCESS POLICY COUNTRY_POLICY

AS

(COUNTRY STRING)

RETURNS BOOLEAN

->

CASE

WHEN CURRENT_ROLE()='INDIA_MANAGER_ROLE'

THEN COUNTRY='India'

WHEN CURRENT_ROLE()='USA_MANAGER_ROLE'

THEN COUNTRY='USA'

ELSE TRUE

END;

----------------------------------------------------------------------------
-- APPLY ROW ACCESS POLICY
----------------------------------------------------------------------------

ALTER TABLE GOLD.FACT_ORDERS

ADD ROW ACCESS POLICY COUNTRY_POLICY

ON (COUNTRY);

----------------------------------------------------------------------------
-- SECURE VIEW
----------------------------------------------------------------------------

CREATE OR REPLACE SECURE VIEW VW_SALES

AS

SELECT

ORDER_ID,

CUSTOMER_ID,

TOTAL_AMOUNT

FROM GOLD.FACT_ORDERS;

----------------------------------------------------------------------------
-- VERIFY ROLES
----------------------------------------------------------------------------

SHOW ROLES;

SHOW GRANTS TO ROLE DATA_ENGINEER_ROLE;

SHOW GRANTS TO ROLE BI_ANALYST_ROLE;

----------------------------------------------------------------------------
-- VERIFY MASKING
----------------------------------------------------------------------------

SELECT

PHONE

FROM SILVER.CUSTOMERS;

----------------------------------------------------------------------------
-- VERIFY ROW ACCESS
----------------------------------------------------------------------------

SELECT *

FROM GOLD.FACT_ORDERS;

----------------------------------------------------------------------------
-- CLEANUP (OPTIONAL)
----------------------------------------------------------------------------

/*

DROP MASKING POLICY MASK_PHONE;

DROP ROW ACCESS POLICY COUNTRY_POLICY;

DROP VIEW VW_SALES;

DROP ROLE BI_ANALYST_ROLE;

DROP ROLE DATA_ENGINEER_ROLE;

DROP ROLE HR_ROLE;

*/

----------------------------------------------------------------------------
-- INTERVIEW NOTES
----------------------------------------------------------------------------

/*

ROLE

↓

Collection of Privileges


USER

↓

Assigned one or more Roles


---------------------------------------------------

SYSADMIN

Creates Objects


---------------------------------------------------

SECURITYADMIN

Creates Roles

Grants Permissions


---------------------------------------------------

ACCOUNTADMIN

Complete Account Administration


---------------------------------------------------

ORGADMIN

Multiple Snowflake Accounts


---------------------------------------------------

USERADMIN

Creates Users


---------------------------------------------------

Masking Policy

↓

Column Level Security


---------------------------------------------------

Row Access Policy

↓

Row Level Security


---------------------------------------------------

Secure View

↓

Hide Business Logic


---------------------------------------------------

Future Grants

↓

Automatically grant access to
future objects


---------------------------------------------------

Best Practices

✔ Always grant Roles

Never Users

✔ Principle of Least Privilege

✔ Use Future Grants

✔ Use Secure Views

✔ Mask PII Columns

✔ Use Row Access for Regional Security

✔ Never use ACCOUNTADMIN
for day-to-day work

*/