#!/bin/sh

echo "${KAFKA_CONNECT_URI}"

while [ "$(curl --silent -o /dev/null -L -w "%{http_code}" --url "${KAFKA_CONNECT_URI}/connectors")" != "200" ] ; do
  echo "[INFO] Sleeping..."
  sleep 5
done

DATA=$(cat << EOF
{
  "name": "${TOPIC_NAME}",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
    "connection.url": "jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}?allowPublicKeyRetrieval=true&useSSL=false",
    "connection.user": "${MYSQL_USER}",
    "connection.password": "${MYSQL_PASS}",
    "tasks.max": "1",
    "topic.prefix": "${TOPIC_NAME}",
    "db.timezone": "America/Sao_Paulo",
    "errors.tolerance": "all",
    "errors.log.enable": "true",
    "errors.log.include.messages": "true",
    "poll.interval.ms": "5000",
    "reconnect.backoff.max.ms": "10000",
    "reconnect.backoff.ms": "5000",
    "retry.backoff.ms": "10000",
    "connection.attempts": "10",
    "numeric.mapping": "best_fit",
    "mode": "timestamp+incrementing",
    "incrementing.column.name": "id",
    "timestamp.column.name": "created_at",
    "schema.pattern": "${MYSQL_DATABASE}",
    "table.types": "TABLE",
    "query": "SELECT CAST(id AS UNSIGNED) AS id, name, email, password, created_at, updated_at, deleted_at FROM ${MYSQL_DATABASE}.users",
    "validate.non.null": "false",
    "quote.sql.identifiers": "never"
  }
}
EOF
)

echo "${DATA}"

export URL_CONNECTOR_EXISTING="${KAFKA_CONNECT_URI}/connectors/${TOPIC_NAME}"
echo "${URL_CONNECTOR_EXISTING}"

if [ "$(curl --silent -o /dev/null -L -w "%{http_code}" --url ${URL_CONNECTOR_EXISTING})" != "200" ]; then
  curl --silent \
    -X POST \
    -H 'Content-Type: application/json' \
    --data "${DATA}" \
    "${KAFKA_CONNECT_URI}/connectors"

else
  curl --silent \
    -X DELETE \
    -H 'Content-Type: application/json' \
    "${KAFKA_CONNECT_URI}/connectors/${TOPIC_NAME}"

  sleep 2

  curl --silent \
    -X POST \
    -H 'Content-Type: application/json' \
    --data "${DATA}" \
    "${KAFKA_CONNECT_URI}/connectors"
fi

curl --silent \
  -X GET \
  -H 'Content-Type: application/json' \
  "${KAFKA_CONNECT_URI}/connectors/${TOPIC_NAME}"

exit 0
