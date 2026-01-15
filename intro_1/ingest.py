#!/usr/bin/env python
# coding: utf-8

import os
import argparse
from time import time

import pandas as pd
from sqlalchemy import create_engine


def main(params):
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    table_name_1 = params.table_name_1  # trips table
    table_name_2 = params.table_name_2  # zones table

    url1 = 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-11.parquet'
    url2 = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv'

    parquet_file = 'trips.parquet'
    csv_file = 'zones.csv'

    # ------------------------------------------------------------------ #
    # Download files if not present
    # ------------------------------------------------------------------ #
    print('Checking files...')
    parquet_exists = os.path.exists(parquet_file)
    csv_exists = os.path.exists(csv_file)

    if parquet_exists:
        print('Parquet (trips) already exists')
    else:
        print('Downloading parquet - trips')
        os.system(f"wget {url1} -O {parquet_file}")
        parquet_exists = os.path.exists(parquet_file)
        if not parquet_exists:
            raise RuntimeError('Failed to download trips parquet file')

    if csv_exists:
        print('CSV (zones) already exists')
    else:
        print('Downloading csv - zones')
        os.system(f"wget {url2} -O {csv_file}")
        csv_exists = os.path.exists(csv_file)
        if not csv_exists:
            raise RuntimeError('Failed to download zones csv file')

    print('Finished downloading files')

    # ------------------------------------------------------------------ #
    # Create DB connection
    # ------------------------------------------------------------------ #
    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')

    # ------------------------------------------------------------------ #
    # Ingest trips (parquet)
    # ------------------------------------------------------------------ #
    print('Inserting trips to database')

    # read parquet in chunks is not supported directly; load then chunk manually
    df_trips = pd.read_parquet(parquet_file)

    # ensure datetime columns
    if 'tpep_pickup_datetime' in df_trips.columns:
        df_trips['tpep_pickup_datetime'] = pd.to_datetime(df_trips['tpep_pickup_datetime'])
    if 'tpep_dropoff_datetime' in df_trips.columns:
        df_trips['tpep_dropoff_datetime'] = pd.to_datetime(df_trips['tpep_dropoff_datetime'])

    # write in chunks to avoid huge single insert
    chunk_size = 100_000
    df_trips.head(0).to_sql(name=table_name_1, con=engine, if_exists='replace')

    for i in range(0, len(df_trips), chunk_size):
        t_start = time()
        chunk = df_trips.iloc[i:i + chunk_size]
        chunk.to_sql(name=table_name_1, con=engine, if_exists='append')
        t_end = time()
        print(f'Inserted rows {i}–{i + len(chunk)}; took {t_end - t_start:.3f} seconds')

    print('Finished inserting trips to database')

    # ------------------------------------------------------------------ #
    # Ingest zones (csv)
    # ------------------------------------------------------------------ #
    print('Inserting zones to database')
    df_zones = pd.read_csv(csv_file)
    df_zones.to_sql(name=table_name_2, con=engine, if_exists='replace', index=False)
    print('Finished inserting zones to database')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest Parquet and CSV data to Postgres')

    parser.add_argument('--user', help='user name for postgres', required=True)
    parser.add_argument('--password', help='password for postgres', required=True)
    parser.add_argument('--host', help='host for postgres', required=True)
    parser.add_argument('--port', help='port for postgres', required=True)
    parser.add_argument('--db', help='database name for postgres', required=True)
    parser.add_argument('--table_name_1', help='name of the table for trips', required=True)
    parser.add_argument('--table_name_2', help='name of the table for zones', required=True)

    args = parser.parse_args()
    main(args)
