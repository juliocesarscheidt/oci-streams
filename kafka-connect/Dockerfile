FROM confluentinc/cp-kafka-connect-base:6.0.0

RUN confluent-hub install --no-prompt hpgrahsl/kafka-connect-mongodb:1.1.0 \
  && confluent-hub install --no-prompt debezium/debezium-connector-mysql:1.5.0 \
  && confluent-hub install --no-prompt confluentinc/kafka-connect-elasticsearch:11.0.0 \
  && confluent-hub install --no-prompt jcustenborder/kafka-connect-json-schema:0.2.5 \
  && confluent-hub install --no-prompt confluentinc/kafka-connect-http:1.0.3 \
  && confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.0.0

USER root
RUN yum install -y gettext

COPY --chown=1000:1000 kafka-connect.properties /tmp/connect-distributed.properties

ARG BOOTSTRAP_SERVERS
ARG STREAM_USER_NAME
ARG STREAM_USER_PASSWORD
ARG KAFKA_CONNECT_TOPIC_CONFIG
ARG KAFKA_CONNECT_TOPIC_OFFSET
ARG KAFKA_CONNECT_TOPIC_STATUS

ENV BOOTSTRAP_SERVERS=$BOOTSTRAP_SERVERS
ENV STREAM_USER_NAME=$STREAM_USER_NAME
ENV STREAM_USER_PASSWORD=$STREAM_USER_PASSWORD
ENV KAFKA_CONNECT_TOPIC_CONFIG=$KAFKA_CONNECT_TOPIC_CONFIG
ENV KAFKA_CONNECT_TOPIC_OFFSET=$KAFKA_CONNECT_TOPIC_OFFSET
ENV KAFKA_CONNECT_TOPIC_STATUS=$KAFKA_CONNECT_TOPIC_STATUS

RUN cat /tmp/connect-distributed.properties | envsubst \${BOOTSTRAP_SERVERS},\${STREAM_USER_NAME},\${STREAM_USER_PASSWORD},\${KAFKA_CONNECT_TOPIC_CONFIG},\${KAFKA_CONNECT_TOPIC_OFFSET},\${KAFKA_CONNECT_TOPIC_STATUS} | \
    tee /etc/kafka/connect-distributed.properties

RUN rm -f /tmp/connect-distributed.properties
RUN chmod 444 /etc/kafka/connect-distributed.properties
RUN cat /etc/kafka/connect-distributed.properties

USER appuser
EXPOSE 8083

ENTRYPOINT ["/usr/bin/connect-distributed", "/etc/kafka/connect-distributed.properties"]
