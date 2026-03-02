
### Question 1: What is the start date and end date of the dataset?

>Answer:
```
2009-06-01 to 2009-07-01
``` 


```sql
SELECT
  MIN(trip_pickup_date_time) AS start_dt,
  MAX(trip_dropoff_date_time) AS end_dt
FROM "yellow_taxi_trips"

```

<br>

![dlthw1](dlthw1.png)

<br>


### Question 2: What proportion of trips are paid with credit card?

>Answer:
```
26.66%
``` 

```sql

SELECT payment_type, COUNT(*) cnt
FROM "yellow_taxi_trips"
GROUP BY 1
ORDER BY cnt DESC;

```
<br>

![dlthw2](dlthw2.png)

<br>


### Question 3: What is the total amount of money generated in tips?

>Answer:
```
 $6,063.41
``` 

```sql

SELECT SUM(tip_amt) AS total_tips
FROM "yellow_taxi_trips"

```

<br>

![dlthw3](dlthw3.png)

<br>

