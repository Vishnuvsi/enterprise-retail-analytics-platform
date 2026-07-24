/******************************************************************************
Project      : RetailNova
Module       : 08 - Tasks
Author       : V Raju
Environment  : DEV
Platform     : Snowflake

Description
-----------
Automates incremental processing using Snowflake Tasks.

Architecture
------------

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
Silver

******************************************************************************/

USE ROLE SYSADMIN;

USE DATABASE RETAILNOVA_DB;

-------------------------------------------------------------------------
-- CREATE TASK
-------------------------------------------------------------------------

CREATE OR REPLACE TASK TASK_LOAD_ORDERS

WAREHOUSE = RETAILNOVA_WH

SCHEDULE = '5 MINUTE'

WHEN SYSTEM$STREAM_HAS_DATA('STR_ORDERS')

AS

CALL SP_LOAD_ORDERS();

-------------------------------------------------------------------------
-- VERIFY TASK
-------------------------------------------------------------------------

SHOW TASKS;

DESCRIBE TASK TASK_LOAD_ORDERS;

-------------------------------------------------------------------------
-- ENABLE TASK
-------------------------------------------------------------------------

ALTER TASK TASK_LOAD_ORDERS RESUME;

-------------------------------------------------------------------------
-- DISABLE TASK
-------------------------------------------------------------------------

ALTER TASK TASK_LOAD_ORDERS SUSPEND;

-------------------------------------------------------------------------
-- MANUAL EXECUTION
-------------------------------------------------------------------------

EXECUTE TASK TASK_LOAD_ORDERS;

-------------------------------------------------------------------------
-- TASK HISTORY
-------------------------------------------------------------------------

SELECT *

FROM TABLE(

INFORMATION_SCHEMA.TASK_HISTORY(

TASK_NAME=>'TASK_LOAD_ORDERS',

RESULT_LIMIT=>20

)

)

ORDER BY SCHEDULED_TIME DESC;

-------------------------------------------------------------------------
-- VERIFY STREAM BEFORE RUNNING
-------------------------------------------------------------------------

SELECT SYSTEM$STREAM_HAS_DATA('STR_ORDERS');

-------------------------------------------------------------------------
-- TASK GRAPH (Future Example)
-------------------------------------------------------------------------

/*

TASK_1

↓

TASK_2

↓

TASK_3

↓

TASK_4

*/

-------------------------------------------------------------------------
-- CREATE CHILD TASK
-------------------------------------------------------------------------

/*

CREATE TASK TASK_LOAD_PRODUCTS

AFTER TASK_LOAD_ORDERS

AS

CALL SP_LOAD_PRODUCTS();

*/

-------------------------------------------------------------------------
-- OPTIONAL CLEANUP
-------------------------------------------------------------------------

/*

DROP TASK TASK_LOAD_ORDERS;

*/

-------------------------------------------------------------------------
-- INTERVIEW NOTES
-------------------------------------------------------------------------

/*

Q1. What is a Task?

Schedules SQL automatically.

--------------------------------------------------

Q2. Difference between Task and Airflow?

Task

Runs inside Snowflake.

Airflow

Orchestrates multiple systems.

--------------------------------------------------

Q3. Why WHEN SYSTEM$STREAM_HAS_DATA?

Avoid unnecessary warehouse execution.

Task runs only when
new data exists.

--------------------------------------------------

Q4. Why suspend Tasks?

Save Snowflake credits.

Especially in DEV environments.

--------------------------------------------------

Q5. What is a Task Graph?

Multiple dependent Tasks.

Example

Load Customers

↓

Load Orders

↓

Load Sales

--------------------------------------------------

Best Practices

✔ Always pair Tasks with Streams

✔ Suspend Tasks in DEV

✔ Monitor TASK_HISTORY

✔ Keep Tasks lightweight

✔ Move complex logic to Stored Procedures

*/