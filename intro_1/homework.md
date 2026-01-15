## Week 1 Homework

In this homework we'll prepare the environment 
and practice with terraform and SQL

## Question 1. Understanding Docker Images

Run docker with the python:3.13 image. Use an entrypoint bash to interact with the container.

What's the version of pip in the image?

To get the version, run `pip -V`

>Answer:
```
25.3
```
>Full output for pip -V:
```
pip 25.3 from /usr/local/lib/python3.13/site-packages/pip (python 3.13)
```

## Question 2. Understanding Docker networking and docker-compose


Given the following `docker-compose.yaml`, what is the `hostname` and `port` that pgadmin should use to connect to the postgres database?

```yaml
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432'
    volumes:
      - vol-pgdata:/var/lib/postgresql/data

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
      PGADMIN_DEFAULT_PASSWORD: "pgadmin"
    ports:
      - "8080:80"
    volumes:
      - vol-pgadmin_data:/var/lib/pgadmin

volumes:
  vol-pgdata:
    name: vol-pgdata
  vol-pgadmin_data:
    name: vol-pgadmin_data
```

>Answer:
```
db:5432
```

## Question 3. Counting short trips

For the trips in November 2025 (lpep_pickup_datetime between '2025-11-01' and '2025-12-01', exclusive of the upper bound), how many trips had a `trip_distance` of less than or equal to 1 mile?

>Command:
```
 SELECT COUNT(*) AS trip_count
 FROM green_trips
 WHERE lpep_pickup_datetime >= '2025-11-01'
   AND lpep_pickup_datetime <  '2025-12-01'
   AND trip_distance <= 1;
```

>Answer:
```
 8007   
```


## Question 4. Longest trip for each day

Which was the pick up day with the longest trip distance? Only consider trips with trip_distance less than 100 miles (to exclude data errors).

Use the pick up time for your calculations.

>Command:
```

 SELECT
     DATE(lpep_pickup_datetime) AS pickup_day,
     SUM(trip_distance) AS total_distance
 FROM green_trips
 WHERE lpep_pickup_datetime >= '2025-11-01'
   AND lpep_pickup_datetime <  '2025-12-01'
   AND trip_distance < 100
 GROUP BY DATE(lpep_pickup_datetime)
 ORDER BY total_distance DESC
 LIMIT 1;
``` 
>Answer:
```
2025-11-20 
```
## Question 5. Biggest pickup zone

Which was the pickup zone with the largest total_amount (sum of all trips) on November 18th, 2025?

>Command:
```

SELECT
    z."Zone" AS pickup_zone,
    SUM(t.total_amount) AS total_amount_sum
FROM green_trips AS t
JOIN zones AS z
    ON t."PULocationID" = z."LocationID"
WHERE t.lpep_pickup_datetime >= '2025-11-18'
  AND t.lpep_pickup_datetime <  '2025-11-19'
GROUP BY z."Zone"
ORDER BY total_amount_sum DESC
LIMIT 1;
``` 

>Answer:
```
East Harlem North 
```

## Question 6. Largest tip

For the passengers picked up in the zone named "East Harlem North" in November 2025, which was the drop off zone that had the largest tip?

>Command:
```

SELECT
    doz."Zone" AS dropoff_zone,
    MAX(t.tip_amount) AS max_tip
FROM green_trips AS t
JOIN zones AS puz
    ON t."PULocationID" = puz."LocationID"
JOIN zones AS doz
    ON t."DOLocationID" = doz."LocationID"
WHERE puz."Zone" = 'East Harlem North'
  AND t.lpep_pickup_datetime >= '2025-11-01'
  AND t.lpep_pickup_datetime <  '2025-12-01'
GROUP BY doz."Zone"
ORDER BY max_tip DESC
LIMIT 1;
```

>Answer:
```
Yorkville West
```


## Question 7. Terraform Workflow

Which of the following sequences, respectively, describes the workflow for:
1. Downloading the provider plugins and setting up backend,
2. Generating proposed changes and auto-executing the plan
3. Remove all resources managed by terraform`

>Answer:
```
terraform init, terraform apply -auto-approve, terraform destroy
```
