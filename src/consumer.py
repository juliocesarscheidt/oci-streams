import os
import re
import json

import pandas as pd

from kafka import KafkaConsumer
from datetime import datetime, timedelta

TIMEOUT=int(os.environ.get('TIMEOUT', '5000'))

conf = {
  'bootstrap_servers': os.environ.get('BOOTSTRAP_SERVERS', 'localhost:9092').split(','),
  'topic_name': os.environ.get('TOPIC_NAME', 'oci_stream'),
  'sasl_plain_username': os.environ.get('STREAM_USER_NAME'),
  'sasl_plain_password': os.environ.get('STREAM_USER_PASSWORD'),
}

def get_current_timestamp():
  return datetime.now().strftime("%d/%m/%Y %H:%M:%S")

def read_kafka_topic(conf, limit=100):
  print('Starting reading the topic ' + conf['topic_name'] + ' at ' + get_current_timestamp())

  df = pd.DataFrame(data=None)
  result = []
  cont = 0

  consumer = KafkaConsumer(
    conf['topic_name'],
    bootstrap_servers=conf['bootstrap_servers'],
    auto_offset_reset='latest',
    enable_auto_commit=True,
    group_id='stream_group',
    value_deserializer=lambda x: json.loads(x),
    security_protocol='SASL_SSL',
    sasl_mechanism='PLAIN',
    sasl_plain_username=conf['sasl_plain_username'],
    sasl_plain_password=conf['sasl_plain_password'],
  )

  response = consumer.poll(max_records=limit, timeout_ms=TIMEOUT)

  for tp , msgs in response.items():
    for m in msgs:
      print(m.key)
      print(m.value)

      df = pd.DataFrame([m.value])
      result.append(df)
      cont = cont + 1

  consumer.close()

  print('Read messages ' + str(cont))

  if len(result) > 0:
    return pd.concat(result)

  return df

def execute():
  df = read_kafka_topic(conf)

  if not df.empty:
    print(df.head(10))
    print(df.tail(10))

if __name__ in '__main__':
  execute()
