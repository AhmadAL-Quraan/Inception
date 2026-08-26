# Contributing to Inception

Thanks for your interest in this project. It started as a 42 school project
(NGINX + WordPress/PHP-FPM + MariaDB via Docker Compose), but contributions
and suggestions are welcome.

## How to contribute

1. **Fork** the repository and create your branch from `main`.
2. Make your changes, keeping commits focused and descriptively named.
3. Test that the stack still builds and runs cleanly:
   ```
   make
   ```
4. Make sure no secrets, `.env` files, or credentials are committed.
5. Open a **pull request** describing what changed and why.

## Reporting bugs / issues

Please use the issue templates provided. Include:
- Steps to reproduce
- Expected vs. actual behavior
- Docker/OS version if relevant

## Code style

- Keep Dockerfiles minimal and single-purpose per service.
- Prefer official base images pinned to a specific version tag.
- Document any non-obvious configuration choices with a comment.

## Questions

Open a discussion or issue — happy to clarify any part of the setup.
