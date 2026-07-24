# Snowflake Performance - Caching

## Why Caching?

Snowflake caches query results and data to improve performance and reduce compute cost.

Instead of reading data repeatedly from storage,
Snowflake intelligently reuses previous results whenever possible.

--------------------------------------------------------

Caching Layers

Result Cache

↓

Local Disk Cache

↓

Remote Storage

--------------------------------------------------------

1. RESULT CACHE

Stores

Entire Query Result

Duration

24 Hours

Uses

Repeated Queries

Example

SELECT *

FROM GOLD.FACT_ORDERS

WHERE ORDER_ID=100;

Run again

↓

No warehouse compute

Almost Instant

--------------------------------------------------------

Requirements

Same SQL

Same Data

Same Role

No Underlying Data Changes

--------------------------------------------------------

2. LOCAL DISK CACHE

Stored inside Warehouse SSD.

When warehouse remains running

↓

Previously scanned micro-partitions
can be reused.

Faster than reading from cloud storage.

--------------------------------------------------------

If Warehouse Suspends

↓

Local Cache disappears.

--------------------------------------------------------

3. METADATA CACHE

Snowflake stores

Micro-partition metadata

Minimum Value

Maximum Value

Distinct Values

Null Count

Used for

Partition Pruning.

--------------------------------------------------------

4. QUERY ACCELERATION SERVICE

Optional Enterprise Feature.

Helps

Very Large Queries

Automatically allocates additional resources

for long-running scans.

--------------------------------------------------------

Cache Hierarchy

User Query

↓

Result Cache

↓

Warehouse Cache

↓

Cloud Storage

--------------------------------------------------------

Interview Questions

Q.

Does Result Cache consume warehouse credits?

Answer

No.

Warehouse is not started.

--------------------------------------------------------

Q.

When is Result Cache invalidated?

When

Underlying table changes

Different SQL

Different Role

Cache expires

--------------------------------------------------------

Q.

Difference between Result Cache and Warehouse Cache?

Result Cache

Stores Final Query Output.

Warehouse Cache

Stores Previously Read Data Blocks.

--------------------------------------------------------

Best Practices

✔ Keep frequently used Warehouse running during business hours

✔ Avoid unnecessary warehouse suspension for repetitive workloads

✔ Let Snowflake reuse Result Cache

✔ Check Query Profile before resizing Warehouse

✔ Don't disable caching unless required
