# Module 3 Homework

For this homework we will be using the Yellow Taxi Trip Records for January 2024 - June 2024 Parquet Files from the New York City Taxi Data found here:

https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

## Inserting data manually:

1: Create a bucket in Google Cloud Storage

2: Upload parquet files to the bucket:


<br>

![hw1](hw1.png)

<br>


3: Create external table 

Run this query in Big Query:


```sql

CREATE OR REPLACE EXTERNAL TABLE
  `project-9dccbae3-37b5-4c84-9b7.zoomcamp.external_yellow_2024`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://kestra-zoomcamp-gurcan/yellow_tripdata_2024-*']
);

```

<br>

![hw2](hw2.png)

<br>

4: Create native table 

```sql

CREATE OR REPLACE TABLE   `project-9dccbae3-37b5-4c84-9b7.zoomcamp.native_yellow_2024`
AS(
  SELECT * FROM   `project-9dccbae3-37b5-4c84-9b7.zoomcamp.external_yellow_2024`
)

```

## Question 1:

What is count of records for the 2024 Yellow Taxi Data?

```sql

SELECT count(1) FROM `zoomcamp-airflow-444903.homework2025.native_yellow_2024` ;

```

Answer: 20,332,093

## Question 2:

Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.
What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?

Native table:

<br>

![hw3](hw3.png)

<br>

External table:

<br>

![hw4](hw4.jpg)

<br>

Answer: 0 MB for the External Table and 155.12 MB for the Materialized Table


## Question 3:

Write a query to retrieve the PULocationID from the table (not the external table) in BigQuery. Now write a query to retrieve the PULocationID and DOLocationID on the same table. Why are the estimated number of Bytes different?

<br>

![hw5](hw5.png)

<br>

<br>

![hw6](hw6.png)

<br>

BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed.

## Question 4:

How many records have a fare_amount of 0?

```sql


SELECT COUNT(fare_amount)  FROM `project-9dccbae3-37b5-4c84-9b7.zoomcamp.native_yellow_2024`
WHERE fare_amount = 0 ;
```

Answer: 8333

## Question 5:

What is the best strategy to make an optimized table in Big Query if your query will always filter based on tpep_dropoff_datetime and order the results by VendorID (Create a new table with this strategy)

Answer:  Partition by tpep_dropoff_datetime and Cluster on VendorID

Partitioning on the dropoff timestamp matches your consistent filter on tpep_dropoff_datetime, so BigQuery can prune whole date partitions.
Clustering by VendorID improves ordering and pruning within each date partition for queries that filter or order by VendorID.

```sql

CREATE OR REPLACE TABLE `project-9dccbae3-37b5-4c84-9b7.zoomcamp.partitioned_yellow_2024`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID
AS(
  SELECT * FROM `project-9dccbae3-37b5-4c84-9b7.zoomcamp.native_yellow_2024`
)
```
## Question 6:

Write a query to retrieve the distinct VendorIDs between tpep_dropoff_datetime 2024-03-01 and 2024-03-15 (inclusive)

Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 5 and note the estimated bytes processed. What are these values?

<br>

![hw7](hw7.png)
![hw8](hw8.png)

<br>

Answer: 310.24 MB for non-partitioned table and 26.84 MB for the partitioned table

## Question 7:

Where is the data stored in the External Table you created?

Answer: GCP Bucket

## Question 8:

It is best practice in Big Query to always cluster your data:

Answer: False

BigQuery recommends clustering only when it brings a clear benefit (large tables, queries filtering/ordering on high‑cardinality columns), not “always” by default.