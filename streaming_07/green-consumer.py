import json
from kafka import KafkaConsumer

TOPIC = "green-trips"
BOOTSTRAP = "localhost:9092"

consumer = KafkaConsumer(
    TOPIC,
    bootstrap_servers=[BOOTSTRAP],
    auto_offset_reset="earliest",
    enable_auto_commit=False,
    group_id="green-trips-q3",
    consumer_timeout_ms=5000,  # stop after 5s of no new messages
    value_deserializer=lambda b: json.loads(b.decode("utf-8")),
)

count = 0

for message in consumer:
    ride = message.value
    trip_distance = ride.get("trip_distance")
    if trip_distance is not None and float(trip_distance) > 5.0:
        count += 1

print(count)
consumer.close()