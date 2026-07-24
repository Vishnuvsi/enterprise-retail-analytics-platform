/******************************************************************************
Project      : RetailNova
Module       : 05 - Bronze Table Creation
Author       : V Raju
Environment  : DEV
Platform     : Snowflake

Description
-----------
Creates all Bronze Layer tables.

Business Scenario
-----------------
RetailNova receives files daily from Azure ADLS.

Orders
Customers
Products
Stores

The Bronze layer stores data exactly as received.

No business transformations are performed here.

Additional metadata columns are captured
for auditing and troubleshooting.

******************************************************************************/

USE ROLE SYSADMIN;

USE DATABASE RETAILNOVA_DB;

USE SCHEMA BRONZE;

------------------------------------------------------------
-- ORDERS RAW
------------------------------------------------------------

CREATE OR REPLACE TABLE ORDERS_RAW
(
    ORDER_ID            NUMBER,
    CUSTOMER_ID         NUMBER,
    PRODUCT_ID          NUMBER,
    STORE_ID            NUMBER,
    ORDER_DATE          DATE,
    QUANTITY            NUMBER,
    UNIT_PRICE          NUMBER(10,2),
    TOTAL_AMOUNT        NUMBER(12,2),

    LOAD_TIMESTAMP      TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),

    SOURCE_FILENAME     STRING,

    LOAD_DATE           DATE DEFAULT CURRENT_DATE()
);

------------------------------------------------------------
-- CUSTOMERS RAW
------------------------------------------------------------

CREATE OR REPLACE TABLE CUSTOMERS_RAW
(
    CUSTOMER_ID         NUMBER,
    CUSTOMER_NAME       STRING,
    EMAIL               STRING,
    PHONE               STRING,
    CITY                STRING,
    STATE               STRING,
    COUNTRY             STRING,

    LOAD_TIMESTAMP      TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),

    SOURCE_FILENAME     STRING,

    LOAD_DATE           DATE DEFAULT CURRENT_DATE()
);

------------------------------------------------------------
-- PRODUCTS RAW
------------------------------------------------------------

CREATE OR REPLACE TABLE PRODUCTS_RAW
(
    PRODUCT_ID          NUMBER,
    PRODUCT_NAME        STRING,
    CATEGORY            STRING,
    BRAND               STRING,
    UNIT_PRICE          NUMBER(10,2),

    LOAD_TIMESTAMP      TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),

    SOURCE_FILENAME     STRING,

    LOAD_DATE           DATE DEFAULT CURRENT_DATE()
);

------------------------------------------------------------
-- STORES RAW
------------------------------------------------------------

CREATE OR REPLACE TABLE STORES_RAW
(
    STORE_ID            NUMBER,
    STORE_NAME          STRING,
    CITY                STRING,
    STATE               STRING,
    COUNTRY             STRING,

    LOAD_TIMESTAMP      TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),

    SOURCE_FILENAME     STRING,

    LOAD_DATE           DATE DEFAULT CURRENT_DATE()
);

------------------------------------------------------------
-- VERIFY
------------------------------------------------------------

SHOW TABLES;

DESC TABLE ORDERS_RAW;

DESC TABLE CUSTOMERS_RAW;

DESC TABLE PRODUCTS_RAW;

DESC TABLE STORES_RAW;

------------------------------------------------------------
-- OPTIONAL CLEANUP
------------------------------------------------------------

/*

DROP TABLE ORDERS_RAW;

DROP TABLE CUSTOMERS_RAW;

DROP TABLE PRODUCTS_RAW;

DROP TABLE STORES_RAW;

*/

------------------------------------------------------------
-- INTERVIEW NOTES
------------------------------------------------------------

/*

Why Bronze?

Stores raw data exactly as received.

Never modify source values.


--------------------------------------------------

Why LOAD_TIMESTAMP?

Know exactly when
the file entered Snowflake.


--------------------------------------------------

Why SOURCE_FILENAME?

Useful for

Auditing

Troubleshooting

Replay

Duplicate detection


--------------------------------------------------

Why LOAD_DATE?

Useful for

Partition filtering

Daily reconciliation

Incremental loads


--------------------------------------------------

Should primary keys be enforced?

Snowflake stores
Primary Keys
Foreign Keys

mainly as metadata.

They are generally not enforced
for standard tables.

Data quality is validated during
the transformation layer.


--------------------------------------------------

Best Practices

✔ Never clean data in Bronze

✔ Add Metadata Columns

✔ Preserve Source Values

✔ Use Meaningful Datatypes

✔ One Table per Entity

✔ Store Audit Information

*/