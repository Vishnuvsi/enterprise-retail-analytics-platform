/******************************************************************************
Project      : RetailNova
Module       : 06 - COPY INTO
Author       : V Raju
Environment  : DEV
Platform     : Snowflake

Description
-----------
Loads files from Azure ADLS into Bronze Layer using COPY INTO.

This module demonstrates

1. Standard Load
2. Validation
3. Pattern Loading
4. Metadata Columns
5. Error Handling
6. Copy History
7. Best Practices

******************************************************************************/

USE ROLE SYSADMIN;

USE DATABASE RETAILNOVA_DB;

USE SCHEMA BRONZE;

------------------------------------------------------------
-- STANDARD COPY INTO
------------------------------------------------------------

COPY INTO ORDERS_RAW
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

FROM
(
SELECT

t.$1::NUMBER,
t.$2::NUMBER,
t.$3::NUMBER,
t.$4::NUMBER,
t.$5::DATE,
t.$6::NUMBER,
t.$7::NUMBER(10,2),
t.$8::NUMBER(12,2),

METADATA$FILENAME

FROM @STG_RETAILNOVA/landing/orders t

)

FILE_FORMAT=(FORMAT_NAME='FF_CSV')

ON_ERROR='ABORT_STATEMENT';

------------------------------------------------------------
-- LOAD ONLY TODAY'S FILE
------------------------------------------------------------

COPY INTO ORDERS_RAW

FROM @STG_RETAILNOVA/landing/orders

PATTERN='.*20260724.*\.csv'

FILE_FORMAT=(FORMAT_NAME='FF_CSV');

------------------------------------------------------------
-- VALIDATION MODE
------------------------------------------------------------

COPY INTO ORDERS_RAW

FROM @STG_RETAILNOVA/landing/orders

FILE_FORMAT=(FORMAT_NAME='FF_CSV')

VALIDATION_MODE='RETURN_ERRORS';

------------------------------------------------------------
-- RETURN FIRST ERROR
------------------------------------------------------------

COPY INTO ORDERS_RAW

FROM @STG_RETAILNOVA/landing/orders

FILE_FORMAT=(FORMAT_NAME='FF_CSV')

VALIDATION_MODE='RETURN_1_ROWS';

------------------------------------------------------------
-- CONTINUE EVEN IF SOME RECORDS FAIL
------------------------------------------------------------

COPY INTO ORDERS_RAW

FROM @STG_RETAILNOVA/landing/orders

FILE_FORMAT=(FORMAT_NAME='FF_CSV')

ON_ERROR='CONTINUE';

------------------------------------------------------------
-- SKIP ENTIRE FILE IF ERROR OCCURS
------------------------------------------------------------

COPY INTO ORDERS_RAW

FROM @STG_RETAILNOVA/landing/orders

FILE_FORMAT=(FORMAT_NAME='FF_CSV')

ON_ERROR='SKIP_FILE';

------------------------------------------------------------
-- FORCE RELOAD
------------------------------------------------------------

COPY INTO ORDERS_RAW

FROM @STG_RETAILNOVA/landing/orders

FILE_FORMAT=(FORMAT_NAME='FF_CSV')

FORCE=TRUE;

------------------------------------------------------------
-- LOAD JSON
------------------------------------------------------------

COPY INTO CUSTOMERS_JSON

FROM
(
SELECT

PARSE_JSON($1)

FROM @STG_RETAILNOVA/json

)

FILE_FORMAT=(FORMAT_NAME='FF_JSON');

------------------------------------------------------------
-- SEE COPY HISTORY
------------------------------------------------------------

SELECT *

FROM TABLE(

INFORMATION_SCHEMA.COPY_HISTORY(

TABLE_NAME=>'ORDERS_RAW',

START_TIME=>DATEADD('DAY',-7,CURRENT_TIMESTAMP())

)

);

------------------------------------------------------------
-- QUERY HISTORY
------------------------------------------------------------

SELECT *

FROM TABLE(

INFORMATION_SCHEMA.QUERY_HISTORY()

)

ORDER BY START_TIME DESC;

------------------------------------------------------------
-- SEE STAGE FILES
------------------------------------------------------------

LIST @STG_RETAILNOVA/landing/orders;

------------------------------------------------------------
-- REMOVE FILE FROM STAGE (Optional)
------------------------------------------------------------

/*

REMOVE @STG_RETAILNOVA/landing/orders
PATTERN='.*20260724.*';

*/

------------------------------------------------------------
-- INTERVIEW NOTES
------------------------------------------------------------

/*

Q1. Why COPY INTO?

Bulk loading files
from Stage
into Snowflake.

--------------------------------------------

Q2. Difference between COPY INTO and Snowpipe?

COPY INTO

Manual

Batch

Snowpipe

Automatic

Near Real-Time

--------------------------------------------

Q3. Why use METADATA$FILENAME?

Auditing

Restartability

Duplicate Detection

Source Tracking

--------------------------------------------

Q4. Why VALIDATION_MODE?

Check file quality

before loading.

--------------------------------------------

Q5. ON_ERROR Options

ABORT_STATEMENT

↓

Stop Immediately

CONTINUE

↓

Load good records

Ignore bad records

SKIP_FILE

↓

Skip Entire File

--------------------------------------------

Q6. FORCE=TRUE?

Reloads the file
even if already loaded.

Useful for

Testing

Backfill

Recovery

--------------------------------------------

Best Practices

✔ Always use Metadata Columns

✔ Validate before Loading

✔ Monitor COPY_HISTORY

✔ Keep ON_ERROR configurable

✔ Avoid FORCE in Production

✔ Load incrementally

*/