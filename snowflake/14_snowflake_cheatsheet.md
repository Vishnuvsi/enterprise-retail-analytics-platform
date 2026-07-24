| Requirement                           | Snowflake Feature   |
| ------------------------------------- | ------------------- |
| Load historical files                 | COPY INTO           |
| Automatic file loading                | Snowpipe            |
| Real-time streaming                   | Snowpipe Streaming  |
| Connect Azure securely                | Storage Integration |
| Read Azure Storage                    | External Stage      |
| Parse CSV                             | File Format         |
| Parse JSON                            | VARIANT + FLATTEN   |
| Store raw data                        | Bronze              |
| Clean business data                   | Silver              |
| Reporting data                        | Gold                |
| Capture only changes                  | Streams             |
| Schedule jobs                         | Tasks               |
| Complex business logic                | Stored Procedures   |
| UPSERT                                | MERGE               |
| Automatic transformed table           | Dynamic Tables      |
| Recover deleted rows                  | Time Travel         |
| Recover dropped table/schema/database | UNDROP              |
| Create DEV/UAT copy                   | Zero Copy Clone     |
| Optimize range queries                | Clustering Key      |
| Optimize point lookup                 | Search Optimization |
| Speed repeated aggregations           | Materialized View   |
| Analyze slow queries                  | Query Profile       |
| Reuse identical query result          | Result Cache        |
| Reduce warehouse cost                 | Auto Suspend        |
| Automatic warehouse startup           | Auto Resume         |
| Manage permissions                    | RBAC                |
| Automatically grant access            | Future Grants       |
| Hide sensitive columns                | Masking Policy      |
| Restrict visible rows                 | Row Access Policy   |
| Hide SQL logic                        | Secure View         |
| Limit credit consumption              | Resource Monitor    |
| Share live data                       | Secure Data Sharing |


#Ultimate flow 

Infrastructure

↓

Warehouse

↓

Database

↓

Schema

↓

Storage Integration

↓

External Stage

↓

COPY INTO / Snowpipe

↓

Bronze

↓

Streams

↓

Tasks

↓

Stored Procedures

↓

Silver

↓

dbt

↓

Gold

↓

Materialized Views

↓

Power BI

↓

Business

↓

AI


═══════════════════════════════════════════════════════════════════════════════
                         SNOWFLAKE MASTER CHEAT SHEET
═══════════════════════════════════════════════════════════════════════════════

ADMINISTRATION
───────────────────────────────────────────────────────────────────────────────

Warehouse
→ Compute Engine
→ Executes Queries
→ Resize based on workload

Database
→ Logical container for schemas

Schema
→ Organize tables, views, procedures etc.

Role
→ Security management using RBAC

═══════════════════════════════════════════════════════════════════════════════

INGESTION
───────────────────────────────────────────────────────────────────────────────

Need to connect Azure Storage?
        ↓
Storage Integration

Need authentication?
        ↓
Azure Entra ID + RBAC

Need location of files?
        ↓
External Stage

Need reusable parsing rules?
        ↓
File Format

Historical Load?
Once a day?
Manual Load?
        ↓
COPY INTO

Automatic file arrival?
Near Real-Time?
        ↓
Snowpipe

Real-time event streaming?
Millions of events?
        ↓
Snowpipe Streaming

═══════════════════════════════════════════════════════════════════════════════

SEMI STRUCTURED DATA
───────────────────────────────────────────────────────────────────────────────

JSON
        ↓
VARIANT

Need nested arrays?
        ↓
FLATTEN()

Need JSON fields?
        ↓
Column:Data Access

═══════════════════════════════════════════════════════════════════════════════

BRONZE LAYER
───────────────────────────────────────────────────────────────────────────────

Raw Data

Never Clean

Never Transform

Store

CSV

JSON

Parquet

Metadata

Filename

Load Timestamp

═══════════════════════════════════════════════════════════════════════════════

INCREMENTAL PROCESSING
───────────────────────────────────────────────────────────────────────────────

Need changed rows only?
        ↓
Streams

Need scheduling?
        ↓
Tasks

Need transaction?
Need Audit?
Need Error Handling?
Need Complex Logic?
        ↓
Stored Procedure

Need UPSERT?
        ↓
MERGE

Need automatic refresh?
Simple transformation?
        ↓
Dynamic Tables

═══════════════════════════════════════════════════════════════════════════════

SILVER LAYER
───────────────────────────────────────────────────────────────────────────────

Validated

Business Rules

Standardization

Clean Data

═══════════════════════════════════════════════════════════════════════════════

RECOVERY
───────────────────────────────────────────────────────────────────────────────

Deleted Rows?
Need old data?
        ↓
Time Travel

Dropped Table?
Dropped Schema?
Dropped Database?
        ↓
UNDROP

Need Dev/UAT Copy?
Testing?
No Storage Copy?
        ↓
Zero Copy Clone

═══════════════════════════════════════════════════════════════════════════════

PERFORMANCE
───────────────────────────────────────────────────────────────────────────────

Need faster filtering
on large tables?
        ↓
Clustering Key

Need point lookup?

WHERE ORDER_ID=100

        ↓
Search Optimization

Dashboard slow?

Repeated Aggregation?

        ↓
Materialized View

Need performance analysis?
        ↓
Query Profile

Warehouse idle?
Need cost optimization?
        ↓
Auto Suspend

Need automatic start?
        ↓
Auto Resume

═══════════════════════════════════════════════════════════════════════════════

CACHING
───────────────────────────────────────────────────────────────────────────────

Same Query Again?
        ↓
Result Cache

Warehouse Still Running?
        ↓
Warehouse Cache

Need partition pruning?
        ↓
Metadata Cache

═══════════════════════════════════════════════════════════════════════════════

SECURITY
───────────────────────────────────────────────────────────────────────────────

Need permissions?
        ↓
Roles

Need access?
        ↓
Grants

Need automatic grants?
        ↓
Future Grants

Need hide columns?
        ↓
Masking Policy

Need hide rows?
        ↓
Row Access Policy

Need hide SQL logic?
        ↓
Secure View

═══════════════════════════════════════════════════════════════════════════════

GOVERNANCE
───────────────────────────────────────────────────────────────────────────────

Need credit limit?
        ↓
Resource Monitor

Need share data?
Without Copy?
        ↓
Secure Data Sharing

Need customer
without Snowflake?
        ↓
Reader Account

Need Public Data?
        ↓
Marketplace

═══════════════════════════════════════════════════════════════════════════════

OBSERVABILITY
───────────────────────────────────────────────────────────────────────────────

Need copy status?
        ↓
COPY_HISTORY()

Need task execution?
        ↓
TASK_HISTORY()

Need query history?
        ↓
QUERY_HISTORY()

Need warehouse usage?
        ↓
WAREHOUSE_METERING_HISTORY()

═══════════════════════════════════════════════════════════════════════════════

ENTERPRISE PATTERN
───────────────────────────────────────────────────────────────────────────────

Azure ADLS

        │

Storage Integration

        │

External Stage

        │

COPY INTO / Snowpipe

        │

Bronze

        │

Streams

        │

Tasks

        │

Stored Procedures

        │

Silver

        │

dbt

        │

Gold

        │

Materialized Views

        │

Power BI

═══════════════════════════════════════════════════════════════════════════════