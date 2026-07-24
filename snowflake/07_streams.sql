/******************************************************************************
Project      : RetailNova
Module       : 07 - Streams (CDC)
Author       : V Raju
Environment  : DEV
Platform     : Snowflake

Description
-----------
Creates Streams to capture INSERT, UPDATE and DELETE changes
from Bronze tables.

Architecture
------------

Bronze Table
      │
      ▼
Stream (CDC)
      │
      ▼
Task / Stored Procedure
      │
      ▼
Silver Layer

******************************************************************************/

USE ROLE SYSADMIN;

USE DATABASE RETAILNOVA_DB;

USE SCHEMA BRONZE;

------------------------------------------------------------
-- CREATE STREAMS
------------------------------------------------------------

CREATE OR REPLACE STREAM STR_ORDERS
ON TABLE ORDERS_RAW;

CREATE OR REPLACE STREAM STR_CUSTOMERS
ON TABLE CUSTOMERS_RAW;

CREATE OR REPLACE STREAM STR_PRODUCTS
ON TABLE PRODUCTS_RAW;

CREATE OR REPLACE STREAM STR_STORES
ON TABLE STORES_RAW;

------------------------------------------------------------
-- VERIFY STREAMS
------------------------------------------------------------

SHOW STREAMS;

DESC STREAM STR_ORDERS;

------------------------------------------------------------
-- SEE CHANGES
------------------------------------------------------------

SELECT *
FROM STR_ORDERS;

------------------------------------------------------------
-- CHECK IF STREAM HAS DATA
------------------------------------------------------------

SELECT SYSTEM$STREAM_HAS_DATA('STR_ORDERS');

------------------------------------------------------------
-- INSERT SAMPLE RECORD
------------------------------------------------------------

INSERT INTO ORDERS_RAW
(
ORDER_ID,
CUSTOMER_ID,
PRODUCT_ID,
STORE_ID,
ORDER_DATE,
QUANTITY,
UNIT_PRICE,
TOTAL_AMOUNT,
SOURCE_FILENAME
)

VALUES
(
9999,
100,
200,
1,
CURRENT_DATE(),
2,
150,
300,
'manual_test.csv'
);

------------------------------------------------------------
-- VERIFY STREAM
------------------------------------------------------------

SELECT *
FROM STR_ORDERS;

------------------------------------------------------------
-- UPDATE SAMPLE
------------------------------------------------------------

UPDATE ORDERS_RAW

SET QUANTITY=5

WHERE ORDER_ID=9999;

------------------------------------------------------------
-- VERIFY UPDATE
------------------------------------------------------------

SELECT *
FROM STR_ORDERS;

------------------------------------------------------------
-- DELETE SAMPLE
------------------------------------------------------------

DELETE FROM ORDERS_RAW

WHERE ORDER_ID=9999;

------------------------------------------------------------
-- VERIFY DELETE
------------------------------------------------------------

SELECT *
FROM STR_ORDERS;

------------------------------------------------------------
-- OPTIONAL CLEANUP
------------------------------------------------------------

/*

DROP STREAM STR_ORDERS;

DROP STREAM STR_CUSTOMERS;

DROP STREAM STR_PRODUCTS;

DROP STREAM STR_STORES;

*/

------------------------------------------------------------
-- INTERVIEW NOTES
------------------------------------------------------------

/*

Q1. What is a Stream?

A Stream captures
INSERT
UPDATE
DELETE

changes made to a table.

--------------------------------------------------

Q2. Does Stream store data?

No.

It stores change metadata.

--------------------------------------------------

Q3. Does Stream replace the source table?

No.

Source table remains unchanged.

--------------------------------------------------

Q4. Difference between Stream and Table?

Table

Stores actual data.

Stream

Stores changes since last consumption.

--------------------------------------------------

Q5. When is a Stream consumed?

Usually

Tasks

Stored Procedures

MERGE

consume the Stream.

--------------------------------------------------

Best Practices

✔ Create Stream only on required tables

✔ Consume Streams regularly

✔ Pair Streams with Tasks

✔ Use Streams for Incremental Loads

✔ Monitor Stream Lag

*/