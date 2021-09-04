import oci
import os
import sys
import time
import json

from base64 import b64encode, b64decode

# Load the default configuration
# export OCI_CONFIG_FILE=~/.oci/config
config = oci.config.from_file('~/.oci/config', 'DEFAULT')
print('config', config)

# to check the user
identity = oci.identity.IdentityClient(config)
user = identity.get_user(config['user']).data

# Create a StreamAdminClientCompositeOperations for composite operations.
stream_admin_client = oci.streaming.StreamAdminClient(config)
stream_admin_client_composite = oci.streaming.StreamAdminClientCompositeOperations(stream_admin_client)

# global variables
COMPARTMENT_ID=os.environ.get('COMPARTMENT_ID')
STREAM_NAME=os.environ.get('STREAM_NAME')
PARTITIONS=int(os.environ.get('PARTITIONS', '1'))
LIMIT=int(os.environ.get('LIMIT', '100'))

def publish_example_messages(client, stream_id):
    # Build up a PutMessagesDetails and publish some messages to the stream
    message_list = []
    for i in range(50):
      key = 'key' + str(i)
      value = 'value' + str(i)
      message = json.dumps({'key': key, 'value': value})
      print(message)
      message_list.append(oci.streaming.models.PutMessagesDetailsEntry(key=None, value=b64encode(message)))

    print('Publishing {} messages to the stream {} '.format(len(message_list), stream_id))
    messages = oci.streaming.models.PutMessagesDetails(messages=message_list)

    put_message_result = client.put_messages(stream_id, messages)

    # The put_message_result can contain some useful metadata for handling failures
    for entry in put_message_result.data.entries:
      if entry.error:
        print('Error ({}) : {}'.format(entry.error, entry.error_message))
      else:
        print('Published message to partition {}, offset {}'.format(entry.partition, entry.offset))

def fetch_message_loop(client, stream_id, initial_cursor, limit=100):
    cursor = initial_cursor

    while True:
      messages_response = client.get_messages(stream_id, cursor, limit=limit)
      # No messages to process. return
      if not messages_response.data:
        print('No data found, sleeping 5 secs...')
        time.sleep(5)
        continue

      # Process the messages
      print('Read {} messages'.format(len(messages_response.data)))
      for message in messages_response.data:
        if (message.key):
          print('key', b64decode(message.key.encode()).decode())

        print(json.loads(b64decode(message.value.encode()).decode()))

      # use the next-cursor for iteration
      print('messages_response.headers', messages_response.headers)
      cursor = messages_response.headers['opc-next-cursor']

      # get_messages is a throttled method; clients should retrieve sufficiently large message
      # batches, as to avoid too many http requests
      print('Sleeping 2 secs for throttle...')
      time.sleep(2)

def get_cursor_by_partition(client, stream_id, partition):
    print('Creating a cursor for partition {}'.format(partition))

    cursor_details = oci.streaming.models.CreateCursorDetails(partition=partition,
                                                              type=oci.streaming.models.CreateCursorDetails.TYPE_TRIM_HORIZON)

    response = client.create_cursor(stream_id, cursor_details)
    cursor = response.data.value

    return cursor

def get_cursor_by_group(sc, stream_id, group_name, instance_name):
    print(' Creating a cursor for group {}, instance {}'.format(group_name, instance_name))

    # commit_on_get is to define whether to commit automatically or not after consuming messages
    cursor_details = oci.streaming.models.CreateGroupCursorDetails(group_name=group_name,
                                                                  instance_name=instance_name,
                                                                  type=oci.streaming.models.CreateGroupCursorDetails.TYPE_TRIM_HORIZON,
                                                                  commit_on_get=True)

    response = sc.create_group_cursor(stream_id, cursor_details)
    return response.data.value

def get_stream(admin_client, stream_id):
    return admin_client.get_stream(stream_id)

def get_stream_by_name(client, compartment_id, stream_name, stream_admin_client_composite):
    list_streams = client.list_streams(compartment_id=compartment_id, name=stream_name,
                                      lifecycle_state=oci.streaming.models.StreamSummary.LIFECYCLE_STATE_ACTIVE)

    if list_streams.data:
      print('An active stream {} has been found'.format(stream_name))
      stream_id = list_streams.data[0].id
      return get_stream(stream_admin_client_composite.client, stream_id)

    return None

stream = get_stream_by_name(stream_admin_client, COMPARTMENT_ID, STREAM_NAME, stream_admin_client_composite).data

stream_client = oci.streaming.StreamClient(config, service_endpoint=stream.messages_endpoint)
s_id = stream.id

# to publish
publish_example_messages(stream_client, s_id)

# to consumer
# partition_cursor = get_cursor_by_partition(stream_client, s_id, partition='0')
# fetch_message_loop(stream_client, s_id, partition_cursor, LIMIT)

# to consumer using group
group_cursor = get_cursor_by_group(stream_client, s_id, 'kafka-connect-group', 'stream_instance_1')
fetch_message_loop(stream_client, s_id, group_cursor, LIMIT)
