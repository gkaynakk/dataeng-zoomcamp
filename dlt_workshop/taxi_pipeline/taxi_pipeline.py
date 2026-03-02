import dlt
from dlt.sources.helpers.rest_client import RESTClient
from dlt.sources.helpers.rest_client.paginators import PageNumberPaginator


@dlt.resource(name="yellow_taxi_trips", write_disposition="replace")
def yellow_taxi_trips():
    client = RESTClient(
        base_url="https://us-central1-dlthub-analytics.cloudfunctions.net",
        paginator=PageNumberPaginator(base_page=1, total_path=None),
    )

    for page in client.paginate("data_engineering_zoomcamp_api"):
        yield page


def main():
    pipeline = dlt.pipeline(
        pipeline_name="taxi_pipeline",
        destination="duckdb",
        dataset_name="taxi_data",
    )

    load_info = pipeline.run(yellow_taxi_trips())
    print(load_info)


if __name__ == "__main__":
    main()