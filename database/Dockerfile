# Custom PostgreSQL image with schema and seed data
FROM postgres:15-alpine

# Copy SQL initialization scripts
COPY schema.sql /docker-entrypoint-initdb.d/01-schema.sql
COPY seed_data.sql /docker-entrypoint-initdb.d/02-seed_data.sql

# Set permissions
RUN chmod 644 /docker-entrypoint-initdb.d/*.sql

# PostgreSQL will automatically execute these files on first startup
