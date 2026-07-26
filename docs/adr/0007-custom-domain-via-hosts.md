# 0007 — Custom domain `aqoraan.42.fr` resolved via `/etc/hosts`

## Status
Accepted

## Context
The subject requires the site to be reachable through a personal domain of
the form `<login>.42.fr` rather than `localhost` or a raw IP, to mirror how a
real virtual-host setup would be configured. There is no real DNS zone for
`42.fr` available to students, so resolution has to be handled locally.

## Decision
Use `aqoraan.42.fr` as the `server_name` in NGINX's config and as the value
of `WORDPRESS_URL`/site-URL passed to WP-CLI. Resolution to the local/VM IP
is done by adding an entry to the host machine's `/etc/hosts`
(`<VM-IP> aqoraan.42.fr`) rather than via any real DNS record or a
Compose-internal mechanism.

## Consequences
- **Positive:** matches the subject's requirement for a personal domain;
  NGINX's TLS cert and `server_name` block are consistent with what the
  browser requests, avoiding certificate-name mismatches.
- **Negative:** the domain only resolves on machines where the `/etc/hosts`
  entry has been added manually — this is inherently local-only and not
  portable to other evaluators' machines without repeating the step (an
  accepted constraint of the 42 evaluation format).
- **Note:** this is unrelated to Docker's internal DNS (used for
  container-to-container names like `mariadb`, `wordpress`) — that
  resolution works automatically within the Compose network and required no
  extra configuration.
