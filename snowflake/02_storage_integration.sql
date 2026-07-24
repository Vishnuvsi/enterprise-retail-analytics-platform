/******************************************************************************
Project      : RetailNova
Module       : 02 - Azure Storage Integration
Author       : V Raju
Environment  : DEV
Platform     : Snowflake

Description
-----------
Creates a secure integration between Snowflake and Azure ADLS Gen2
using Microsoft Entra ID and RBAC.

Architecture
------------

Azure ADLS Gen2
        │
Microsoft Entra ID
        │
Managed Identity
        │
RBAC (Storage Blob Data Reader)
        │
Storage Integration
        │
External Stage
        │
COPY INTO

******************************************************************************/

-------------------------------------------------------------------------
-- STEP 1 : USE ROLE
-------------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;

-------------------------------------------------------------------------
-- STEP 2 : CREATE STORAGE INTEGRATION
-------------------------------------------------------------------------

CREATE OR REPLACE STORAGE INTEGRATION RETAILNOVA_AZURE_INT
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = AZURE
ENABLED = TRUE
AZURE_TENANT_ID = '<YOUR_AZURE_TENANT_ID>'
STORAGE_ALLOWED_LOCATIONS = (
'azure://retailnovastorage.blob.core.windows.net/data'
);

-------------------------------------------------------------------------
-- STEP 3 : VERIFY STORAGE INTEGRATION
-------------------------------------------------------------------------

DESC STORAGE INTEGRATION RETAILNOVA_AZURE_INT;

-------------------------------------------------------------------------
-- STEP 4 : COPY VALUES FROM OUTPUT
-------------------------------------------------------------------------

/*

From DESC STORAGE INTEGRATION copy

AZURE_CONSENT_URL

AZURE_MULTI_TENANT_APP_NAME

These are required while granting Azure permissions.

*/

-------------------------------------------------------------------------
-- STEP 5 : AZURE CONFIGURATION
-------------------------------------------------------------------------

/*

1. Open Azure Portal

2. Open Storage Account

3. Access Control (IAM)

4. Add Role Assignment

Role

Storage Blob Data Reader

Principal

AZURE_MULTI_TENANT_APP_NAME

Grant Access

Done

*/

-------------------------------------------------------------------------
-- STEP 6 : VERIFY ACCESS
-------------------------------------------------------------------------

DESC STORAGE INTEGRATION RETAILNOVA_AZURE_INT;

-------------------------------------------------------------------------
-- STEP 7 : OPTIONAL CLEANUP
-------------------------------------------------------------------------

/*

DROP STORAGE INTEGRATION RETAILNOVA_AZURE_INT;

*/

-------------------------------------------------------------------------
-- INTERVIEW NOTES
-------------------------------------------------------------------------

/*

Q1. Why Storage Integration?

Avoid storing
Username
Password
SAS Tokens

Uses Azure Entra ID authentication.


--------------------------------------------------

Q2. Why RBAC?

Provides least privilege access.

Only required permissions are granted.


--------------------------------------------------

Q3. Why Storage Blob Data Reader?

Snowflake only needs to read files.

No write permission required.


--------------------------------------------------

Q4. Difference between Storage Integration and Stage?

Storage Integration
-------------------

Authentication

External Stage
--------------

Location of files


--------------------------------------------------

Q5. Which Role creates Storage Integration?

ACCOUNTADMIN


--------------------------------------------------

Best Practices

✔ Never hardcode credentials

✔ Use Entra ID

✔ Use RBAC

✔ Restrict STORAGE_ALLOWED_LOCATIONS

✔ One Integration can serve multiple Stages

*/