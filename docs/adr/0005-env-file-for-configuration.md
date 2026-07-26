# 0005 — Use `.env` file for configuration and credentials

## Status
Accepted

## Context
Container configuration (domain name, DB name/user/password, WordPress
admin credentials, etc.) must not be hardcoded into Dockerfiles or committed
to version control, per the subject's rule that no credential may be exposed
outside of an env file. Two mechanisms were considered: Docker secrets
(files mounted at `/run/secrets/...`, referenced via `_FILE` env-var
convention) and a single root-level `.env` file consumed by Compose.

## Decision
Use a single `.env` file at the project root (git-ignored, with an
`.env.example` committed for reference) as the source of all configuration
and credentials. `docker-compose.yml` reads values via `${VARIABLE}`
interpolation and passes them into each service's `environment:` block.

Docker secrets were **not** adopted for this iteration.

## Consequences
- **Positive:** simpler to reason about and debug for a single-host,
  evaluation-scoped project; one file to manage; no extra secret-mounting
  machinery in Compose or entrypoint scripts.
- **Negative:** credentials are visible in plaintext in `docker inspect`
  output and in the container's environment (`env` command inside the
  container), whereas Docker secrets would keep them out of `environment:`
  entirely and restrict them to a tmpfs mount. This is an accepted trade-off
  given the project's scope (local VM, evaluation context) rather than a
  production deployment.
- **Mitigation:** `.env` is excluded via `.gitignore` so real credentials
  never reach the repository; only `.env.example` with placeholder values is
  committed.
- **Revisit trigger:** if this stack is ever deployed somewhere multi-tenant
  or internet-facing beyond the 42 VM, this decision should be superseded by
  adopting Docker secrets or an external secrets manager.
