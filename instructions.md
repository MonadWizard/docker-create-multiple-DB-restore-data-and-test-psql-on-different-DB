## 📁 Folder Structure

```
pg-cluster/
├── docker-compose.yml
├── init-db.sh
├── backup.dump         # <-- your existing dump file

```

## 📜 docker-compose.yml

```
version: "3.9"

services:
  pg1:
    image: postgres
    container_name: pg1
    environment:
      POSTGRES_PASSWORD: pass
    ports:
      - "5433:5432"
    volumes:
      - ./backup.dump:/docker-entrypoint-initdb.d/backup.dump
      - ./init-db.sh:/docker-entrypoint-initdb.d/init-db.sh
    entrypoint: ["docker-entrypoint.sh"]
    command: ["postgres"]

  pg2:
    image: postgres
    container_name: pg2
    environment:
      POSTGRES_PASSWORD: pass
    ports:
      - "5434:5432"
    volumes:
      - ./backup.dump:/docker-entrypoint-initdb.d/backup.dump
      - ./init-db.sh:/docker-entrypoint-initdb.d/init-db.sh
    entrypoint: ["docker-entrypoint.sh"]
    command: ["postgres"]

  pg3:
    image: postgres
    container_name: pg3
    environment:
      POSTGRES_PASSWORD: pass
    ports:
      - "5435:5432"
    volumes:
      - ./backup.dump:/docker-entrypoint-initdb.d/backup.dump
      - ./init-db.sh:/docker-entrypoint-initdb.d/init-db.sh
    entrypoint: ["docker-entrypoint.sh"]
    command: ["postgres"]

  pg4:
    image: postgres
    container_name: pg4
    environment:
      POSTGRES_PASSWORD: pass
    ports:
      - "5436:5432"
    volumes:
      - ./backup.dump:/docker-entrypoint-initdb.d/backup.dump
      - ./init-db.sh:/docker-entrypoint-initdb.d/init-db.sh
    entrypoint: ["docker-entrypoint.sh"]
    command: ["postgres"]

```

## 🛠️ init-db.sh – Restore Script

```
#!/bin/bash
set -e

# Wait until PostgreSQL is ready
until pg_isready -U postgres; do
  echo "Waiting for postgres..."
  sleep 2
done

# Restore the dump to the default "postgres" database
echo "Restoring database from backup.dump..."
pg_restore -U postgres -d postgres /docker-entrypoint-initdb.d/backup.dump

echo "Restore complete!"

```

## ✅ Make sure init-db.sh is executable:

```
chmod +x init-db.sh
```

## 🚀 Start Everything

```
docker compose up --build
```

```
docker compose up -d

```

## 🧪 Test Access 📦 1. Connect to pg1

```
psql -h localhost -p 5433 -U aggame_dev -d aggamedb

# password: pass



```
