/******************************************************************************
Project      : RetailNova
Module       : 09 - Stored Procedures
Author       : V Raju
Environment  : DEV
Platform     : Snowflake

Description
-----------
Implements an enterprise Stored Procedure framework for loading
incremental data from Bronze to Silver.

Architecture
------------

Azure ADLS
      │
      ▼
External Stage
      │
      ▼
COPY INTO
      │
      ▼
BRONZE.ORDERS_RAW
      │
      ▼
STREAM (CDC)
      │
      ▼
TASK
      │
      ▼
SP_LOAD_ORDERS()
      │
      ├── Validate Stream
      ├── Start Transaction
      ├── MERGE Bronze → Silver
      ├── Reject Invalid Records (Future Enhancement)
      ├── Update Audit Table
      ├── Commit / Rollback
      ├── Return Status
      └── Task History

******************************************************************************/

USE ROLE SYSADMIN;

USE DATABASE RETAILNOVA_DB;

USE SCHEMA SILVER;

--------------------------------------------------------------------------------
-- SILVER TABLE
--------------------------------------------------------------------------------

CREATE OR REPLACE TABLE ORDERS
(
    ORDER_ID           NUMBER,
    CUSTOMER_ID        NUMBER,
    PRODUCT_ID         NUMBER,
    STORE_ID           NUMBER,
    ORDER_DATE         DATE,
    QUANTITY           NUMBER,
    UNIT_PRICE         NUMBER(10,2),
    TOTAL_AMOUNT       NUMBER(12,2),

    LOAD_TIMESTAMP     TIMESTAMP,

    SOURCE_FILENAME    STRING,

    LOAD_DATE          DATE
);

--------------------------------------------------------------------------------
-- AUDIT TABLE
--------------------------------------------------------------------------------

CREATE OR REPLACE TABLE LOAD_AUDIT
(
    PIPELINE_NAME      STRING,
    START_TIME         TIMESTAMP,
    END_TIME           TIMESTAMP,
    STATUS             STRING,
    ROWS_PROCESSED     NUMBER,
    ERROR_MESSAGE      STRING
);

--------------------------------------------------------------------------------
-- STORED PROCEDURE
--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE SP_LOAD_ORDERS()

RETURNS STRING

LANGUAGE SQL

EXECUTE AS OWNER

AS

$$

DECLARE

V_ROWS NUMBER DEFAULT 0;

BEGIN

    ------------------------------------------------------------------------
    -- STEP 1 : Validate Stream
    ------------------------------------------------------------------------

    IF (SYSTEM$STREAM_HAS_DATA('STR_ORDERS') = FALSE) THEN

        RETURN 'No new data found in Stream';

    END IF;

    ------------------------------------------------------------------------
    -- STEP 2 : Begin Transaction
    ------------------------------------------------------------------------

    BEGIN TRANSACTION;

    ------------------------------------------------------------------------
    -- STEP 3 : Merge Bronze → Silver
    ------------------------------------------------------------------------

    MERGE INTO SILVER.ORDERS T

    USING BRONZE.STR_ORDERS S

    ON T.ORDER_ID = S.ORDER_ID

    WHEN MATCHED THEN

        UPDATE SET

            CUSTOMER_ID      = S.CUSTOMER_ID,
            PRODUCT_ID       = S.PRODUCT_ID,
            STORE_ID         = S.STORE_ID,
            ORDER_DATE       = S.ORDER_DATE,
            QUANTITY         = S.QUANTITY,
            UNIT_PRICE       = S.UNIT_PRICE,
            TOTAL_AMOUNT     = S.TOTAL_AMOUNT,
            LOAD_TIMESTAMP   = S.LOAD_TIMESTAMP,
            SOURCE_FILENAME  = S.SOURCE_FILENAME,
            LOAD_DATE        = S.LOAD_DATE

    WHEN NOT MATCHED THEN

        INSERT
        (
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
        )

        VALUES
        (
            S.ORDER_ID,
            S.CUSTOMER_ID,
            S.PRODUCT_ID,
            S.STORE_ID,
            S.ORDER_DATE,
            S.QUANTITY,
            S.UNIT_PRICE,
            S.TOTAL_AMOUNT,
            S.LOAD_TIMESTAMP,
            S.SOURCE_FILENAME,
            S.LOAD_DATE
        );

    ------------------------------------------------------------------------
    -- STEP 4 : Capture Processed Row Count
    ------------------------------------------------------------------------

    V_ROWS := SQLROWCOUNT;

    ------------------------------------------------------------------------
    -- STEP 5 : Audit Success
    ------------------------------------------------------------------------

    INSERT INTO LOAD_AUDIT

    VALUES
    (
        'ORDER_PIPELINE',
        CURRENT_TIMESTAMP(),
        CURRENT_TIMESTAMP(),
        'SUCCESS',
        V_ROWS,
        NULL
    );

    ------------------------------------------------------------------------
    -- STEP 6 : Commit
    ------------------------------------------------------------------------

    COMMIT;

    RETURN 'Pipeline completed successfully';

EXCEPTION

WHEN OTHER THEN

    ------------------------------------------------------------------------
    -- STEP 7 : Rollback
    ------------------------------------------------------------------------

    ROLLBACK;

    ------------------------------------------------------------------------
    -- STEP 8 : Audit Failure
    ------------------------------------------------------------------------

    INSERT INTO LOAD_AUDIT

    VALUES
    (
        'ORDER_PIPELINE',
        CURRENT_TIMESTAMP(),
        CURRENT_TIMESTAMP(),
        'FAILED',
        0,
        SQLERRM
    );

    RETURN SQLERRM;

END;

$$;

--------------------------------------------------------------------------------
-- EXECUTE
--------------------------------------------------------------------------------

CALL SP_LOAD_ORDERS();

--------------------------------------------------------------------------------
-- VERIFY SILVER DATA
--------------------------------------------------------------------------------

SELECT *

FROM SILVER.ORDERS;

--------------------------------------------------------------------------------
-- VERIFY AUDIT
--------------------------------------------------------------------------------

SELECT *

FROM LOAD_AUDIT;

--------------------------------------------------------------------------------
-- DYNAMIC SQL EXAMPLE
--------------------------------------------------------------------------------

DECLARE

V_TABLE STRING DEFAULT 'ORDERS';

BEGIN

EXECUTE IMMEDIATE

'SELECT COUNT(*) FROM ' || V_TABLE;

END;

--------------------------------------------------------------------------------
-- ENTERPRISE STORED PROCEDURE FRAMEWORK
--------------------------------------------------------------------------------

/*

Master Procedure

        │

        ▼

SP_VALIDATE

        │

        ▼

SP_MERGE

        │

        ▼

SP_REJECT

        │

        ▼

SP_AUDIT

        │

        ▼

SP_NOTIFY

*/

--------------------------------------------------------------------------------
-- ENTERPRISE EXECUTION FLOW
--------------------------------------------------------------------------------

/*

Procedure Started

        │

Validate Stream

        │

Begin Transaction

        │

MERGE Bronze → Silver

        │

Reject Invalid Records (Future)

        │

Update Audit

        │

Commit / Rollback

        │

Return Status

*/

--------------------------------------------------------------------------------
-- INTERVIEW QUESTIONS
--------------------------------------------------------------------------------

/*

Q. Why Stored Procedures?

✔ Encapsulate business logic
✔ Transaction management
✔ Error handling
✔ Reusable pipelines
✔ Easier maintenance

----------------------------------------------------

Q. Why not put MERGE inside Task?

Tasks should orchestrate.

Stored Procedures should implement business logic.

----------------------------------------------------

Q. Why Transactions?

All operations succeed together.

Otherwise rollback.

----------------------------------------------------

Q. Why Audit Table?

Operational Monitoring

SLA Reporting

Troubleshooting

Compliance

----------------------------------------------------

Q. Why Dynamic SQL?

Metadata-driven Frameworks

Generic Pipelines

Reusable Procedures

----------------------------------------------------

Q. Why Reject Table?

Never lose bad records.

Store

↓

Business Corrects

↓

Reload

----------------------------------------------------

Best Practices

✔ Keep Tasks Lightweight

✔ Business Logic inside Stored Procedures

✔ Always use Transactions

✔ Log every Pipeline

✔ Capture Errors

✔ Maintain Audit Tables

✔ Parameterize Procedures (Future Enhancement)

✔ Separate Validation, Merge, Audit into Modular Procedures

*/