#!/bin/bash
set -e

# Wait for PostgreSQL to start
until pg_isready -U "$POSTGRES_USER"; do
  echo "Waiting for postgres to be ready..."
  sleep 2
done

echo "Restoring dump into $POSTGRES_DB using user $POSTGRES_USER..."

pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" /docker-entrypoint-initdb.d/backup.dump

echo "Restore complete for $POSTGRES_DB."
