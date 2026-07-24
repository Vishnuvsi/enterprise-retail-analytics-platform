/******************************************************************************
Project      : RetailNova
Module       : 03 - File Formats
Author       : V Raju
Environment  : DEV
Platform     : Snowflake

Description
-----------
Creates reusable Snowflake File Formats for loading different file types.

Supported Formats
-----------------
1. CSV
2. JSON
3. PARQUET
4. AVRO
5. ORC
6. XML

******************************************************************************/

USE ROLE SYSADMIN;

USE DATABASE RETAILNOVA_DB;

----------------------------------------------------------------------------
-- CSV FILE FORMAT
----------------------------------------------------------------------------

CREATE OR REPLACE FILE FORMAT FF_CSV
TYPE = CSV
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
TRIM_SPACE = TRUE
NULL_IF = ('NULL','null','')
EMPTY_FIELD_AS_NULL = TRUE
COMMENT='CSV File Format';

----------------------------------------------------------------------------
-- JSON FILE FORMAT
----------------------------------------------------------------------------

CREATE OR REPLACE FILE FORMAT FF_JSON
TYPE = JSON
STRIP_OUTER_ARRAY = TRUE
COMMENT='JSON File Format';

----------------------------------------------------------------------------
-- PARQUET FILE FORMAT
----------------------------------------------------------------------------

CREATE OR REPLACE FILE FORMAT FF_PARQUET
TYPE = PARQUET
COMMENT='Parquet File Format';

----------------------------------------------------------------------------
-- AVRO FILE FORMAT
----------------------------------------------------------------------------

CREATE OR REPLACE FILE FORMAT FF_AVRO
TYPE = AVRO
COMMENT='Avro File Format';

----------------------------------------------------------------------------
-- ORC FILE FORMAT
----------------------------------------------------------------------------

CREATE OR REPLACE FILE FORMAT FF_ORC
TYPE = ORC
COMMENT='ORC File Format';

----------------------------------------------------------------------------
-- XML FILE FORMAT
----------------------------------------------------------------------------

CREATE OR REPLACE FILE FORMAT FF_XML
TYPE = XML
COMMENT='XML File Format';

----------------------------------------------------------------------------
-- VERIFY
----------------------------------------------------------------------------

SHOW FILE FORMATS;

DESCRIBE FILE FORMAT FF_CSV;

DESCRIBE FILE FORMAT FF_JSON;

----------------------------------------------------------------------------
-- OPTIONAL CLEANUP
----------------------------------------------------------------------------

/*

DROP FILE FORMAT FF_CSV;

DROP FILE FORMAT FF_JSON;

DROP FILE FORMAT FF_PARQUET;

DROP FILE FORMAT FF_AVRO;

DROP FILE FORMAT FF_ORC;

DROP FILE FORMAT FF_XML;

*/

----------------------------------------------------------------------------
-- INTERVIEW NOTES
----------------------------------------------------------------------------

/*

CSV
----

Most common file format

Human readable

Easy to generate

Usually received from

ERP

CRM

SAP

Legacy Systems


---------------------------------------------------

JSON
-----

Semi-Structured

API Responses

Web Applications

REST APIs

Nested Data

Stored using VARIANT datatype


---------------------------------------------------

PARQUET
--------

Columnar Storage

Compressed

Fast Analytics

Preferred in

Databricks

Spark

Data Lakes


---------------------------------------------------

AVRO
-----

Schema Evolution

Streaming

Kafka

Event Data


---------------------------------------------------

ORC
----

Optimized Row Columnar

Mostly Hadoop Ecosystem

Hive


---------------------------------------------------

XML
----

Enterprise Applications

SOAP APIs

Legacy Integrations


---------------------------------------------------

Interview Question

Why use File Formats?

Instead of specifying

Delimiter

Header

Null Handling

every time,

Snowflake stores the configuration once
and reuses it.


---------------------------------------------------

Best Practices

✔ Create reusable File Formats

✔ Keep one File Format per type

✔ Never hardcode options inside COPY INTO

✔ Store all File Formats centrally

✔ Use descriptive names

*/