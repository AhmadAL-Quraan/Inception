



### Dockerfile instructions worth knowing distinctly

- **`ENTRYPOINT` vs `CMD`**: `ENTRYPOINT` sets the fixed executable that always runs; `CMD` supplies default _arguments_ to it (overridable at `docker run`). Often used together: `ENTRYPOINT ["nginx"]`, `CMD ["-g", "daemon off;"]`.
- **`ARG` vs `ENV`**: `ARG` is a build-time-only variable (not present in the final image or running container). `ENV` persists into the running container and is visible via `docker inspect` / `printenv`. Never put secrets in either — they end up baked into image layers or history.