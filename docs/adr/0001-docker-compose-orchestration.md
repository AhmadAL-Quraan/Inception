# 0001 — Use Docker Compose for multi-container orchestration

## Status
Accepted

## Context
The project requires several independent services (web server, application
runtime, database) to run as separate containers, each built from a custom
Dockerfile, connected over a private network, and brought up/down together in
a reproducible way. Running `docker build` / `docker run` manually for each
service is error-prone and not reproducible across machines. The 42 Inception
subject also mandates that containers be declared and started through
`docker-compose.yml`, itself invoked from a `Makefile`.

## Decision
Use Docker Compose (`srcs/docker-compose.yml`) as the single orchestration
layer for all services (NGINX, WordPress/PHP-FPM, MariaDB). Each service:
- has its own build context and Dockerfile under `srcs/requirements/<service>/`
- is declared as a distinct Compose service with an explicit `container_name`
  matching the service name
- is attached to one user-defined bridge network so containers can resolve
  each other by service name via Docker's embedded DNS

A `Makefile` at the project root wraps `docker compose build` / `up` / `down`
so the whole stack starts with `make`.

## Consequences
- **Positive:** one command reproducibly builds and starts the entire stack;
  service-to-service DNS resolution is free (no manual `--link` or static IPs);
  matches the 42 subject requirement exactly.
- **Negative:** Compose is a single-host tool — this does not extend to a
  multi-node/orchestrated (Swarm/Kubernetes) setup without rework.
- **Neutral:** all image builds are custom (no pulling prebuilt
  nginx/wordpress/mariadb images), which is a project constraint, not a
  Compose limitation.
