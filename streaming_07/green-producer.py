import json
from time import time

import pandas as pd
from kafka import KafkaProducer

TOPIC = "green-trips"
BOOTSTRAP = "localhost:9092"

COLUMNS = [
    "lpep_pickup_datetime",
    "lpep_dropoff_datetime",
    "PULocationID",
    "DOLocationID",
    "passenger_count",
    "trip_distance",
    "tip_amount",
    "total_amount",
]

def json_serializer(data):
    return json.dumps(data).encode("utf-8")

def clean_record(row: dict) -> dict:
    out = {}
    for k, v in row.items():
        if pd.isna(v):
            out[k] = None
        elif "datetime" in k and v is not None:
            out[k] = str(v)
        else:
            out[k] = v
    return out

def main():
    df = pd.read_parquet("data/green_tripdata_2025-10.parquet", columns=COLUMNS)

    producer = KafkaProducer(
        bootstrap_servers=[BOOTSTRAP],
        value_serializer=json_serializer,
    )

    t0 = time()

    for record in df.to_dict(orient="records"):
        producer.send(TOPIC, value=clean_record(record))

    producer.flush()

    t1 = time()
    print(f"took {(t1 - t0):.2f} seconds")

if __name__ == "__main__":
    main()