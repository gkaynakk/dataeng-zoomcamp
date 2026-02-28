"""@bruin
name: ingestion.trips
type: python
image: python:3.11
connection: duckdb-default

materialization:
  type: table
  strategy: append

columns:
  - name: pickup_datetime
    type: timestamp
    description: "When the meter was engaged"
  - name: dropoff_datetime
    type: timestamp
    description: "When the meter was disengaged"
  - name: passenger_count
    type: integer
    description: "Number of passengers in the trip"
  - name: trip_distance
    type: float
    description: "Distance of the trip in miles"
  - name: fare_amount
    type: float
    description: "Fare amount for the trip"
@bruin"""

import os
import json
import pandas as pd
from datetime import datetime, timedelta


def generate_month_range(start_date: str, end_date: str) -> list[str]:
    """Generate a list of year-month strings between start_date and end_date."""
    start = datetime.strptime(start_date, "%Y-%m-%d")
    end = datetime.strptime(end_date, "%Y-%m-%d")

    months: list[str] = []
    cursor = start.replace(day=1)
    while cursor <= end:
        months.append(cursor.strftime("%Y-%m"))
        cursor = (cursor + timedelta(days=32)).replace(day=1)

    return months


def fetch_parquet_files(taxi_type: str, year_month: str) -> pd.DataFrame:
    """Fetch and load a parquet file for a given taxi type and year-month."""
    url = f"https://d37ci6vzurychx.cloudfront.net/trip-data/{taxi_type}_tripdata_{year_month}.parquet"
    try:
        return pd.read_parquet(url)
    except Exception as e:
        print(f"Failed to fetch data for {taxi_type} {year_month}: {e}")
        return pd.DataFrame()


def materialize() -> pd.DataFrame:
    start_date = os.environ["BRUIN_START_DATE"]
    end_date = os.environ["BRUIN_END_DATE"]

    # BRUIN_VARS is a JSON string, e.g. {"taxi_types":["yellow","green"]}
    vars_json = os.environ.get("BRUIN_VARS", "{}")
    taxi_types = json.loads(vars_json).get("taxi_types", ["yellow"])

    months = generate_month_range(start_date, end_date)
    dataframes: list[pd.DataFrame] = []

    for taxi_type in taxi_types:
        for year_month in months:
            df = fetch_parquet_files(taxi_type, year_month)
            if not df.empty:
                dataframes.append(df)

    if not dataframes:
        print("No data was fetched.")
        return pd.DataFrame()

    final_dataframe = pd.concat(dataframes, ignore_index=True)

    # Keep only the required columns (skip missing gracefully)
    required = ["pickup_datetime", "dropoff_datetime", "passenger_count", "trip_distance", "fare_amount"]
    existing = [c for c in required if c in final_dataframe.columns]
    return final_dataframe[existing]