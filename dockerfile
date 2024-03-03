# Use the official PostgreSQL image from Docker Hub
FROM postgres:latest

# Set environment variables
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=password
ENV POSTGRES_DB=haskell_vulnerabilities

# Copy custom initialization scripts into the container
COPY init.sql /docker-entrypoint-initdb.d/
