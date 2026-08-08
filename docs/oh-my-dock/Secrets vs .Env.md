

Both store configuration values consumed by your containers, but they differ in **what they're meant for** and **how exposed the values are**.





#### `.env`: plain environment variables

- Values are injected into the container as regular environment variables (`environment:` in `docker-compose.yml`)
- **Visible** via `docker inspect <container>`, `docker exec <container> env`, and inherited by every child process spawned inside that container
- Appropriate for **non-sensitive configuration**: domain names, database names, usernames, values that aren't secret, just configurable
- Required by the subject for exactly this purpose

#### Docker secrets : file-based, more restricted

- Values are mounted as **files** inside the container (`/run/secrets/<name>`), not injected as environment variables
- **Not** visible via `docker inspect` or process environment listings — reduces the number of places a password could accidentally leak (logs, debugging output, `docker inspect` shared in a bug report)
- Read explicitly by the application at the moment it's needed (`cat /run/secrets/db_password`), rather than being ambiently available to every process
- Appropriate for **actual sensitive values**: database passwords, WordPress admin/user passwords.




#### What neither one actually provides

Worth being upfront about this, since it's easy to overstate: neither `.env` nor Docker Compose secrets provide real encryption at rest. Anyone with shell access inside the container, or root access to the host, can read both in plaintext. The real value of this separation is **narrower and more specific**: keeping sensitive values out of `docker inspect` output, out of environment-variable leaks, and — most concretely for this project — out of Git history, since both `.env` and `secrets/` are gitignored.