#!/usr/bin/env bash
echo "Restoring database"
psql -U postgres -c "CREATE DATABASE sageteaview"
pg_restore -v -d ${DBNAME} /tmp/${FILE} > /tmp/log
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${DBNAME} TO postgres"
echo "Database restored successfully"