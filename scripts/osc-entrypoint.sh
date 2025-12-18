#!/bin/bash

# AIRFLOW_HOME=/opt/airflow by default in the base image

if [ ! -z "$DATABASE_URL" ]; then
  export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="$DATABASE_URL"
fi

if [ ! -z "$OSC_HOSTNAME" ]; then
  export AIRFLOW__WEBSERVER__BASE_URL="https://$OSC_HOSTNAME"
  export AIRFLOW__CORE__EXECUTION_API_SERVER_URL="https://$OSC_HOSTNAME/execution/"
fi

if [ ! -f "/opt/airflow/simple_auth_manager_passwords.json.generated" ]; then
  echo "No existing password file found, creating a new one."
  if [ -z "$ADMIN_PASSWORD" ]; then
    echo "ADMIN_PASSWORD is not set, using default 'admin'"
    ADMIN_PASSWORD="admin"
  fi
  echo "{\"admin\": \"$ADMIN_PASSWORD\"}" > /opt/airflow/simple_auth_manager_passwords.json.generated
fi

airflow db migrate

exec "/entrypoint" "$@"