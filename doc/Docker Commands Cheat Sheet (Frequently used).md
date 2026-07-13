

A quick reference of the most-used Docker commands, grouped by purpose.

*Full [Doc](https://docs.docker.com/reference/cli/docker/) by Docker*.

---

## 1. Registry Commands
*Working with Docker Hub or any other image registry (push, pull, login, tag).*

| Command                                       | Description                                                                         |
| --------------------------------------------- | ----------------------------------------------------------------------------------- |
| `docker login`                                | Authenticate to Docker Hub (or `docker login <registry-url>` for a custom registry) |
| `docker logout`                               | Log out of the current registry                                                     |
| `docker pull <image>[:tag]`                   | Download an image from a registry                                                   |
| `docker push <username>/<image>[:tag]`        | Upload an image to a registry (must be tagged with your namespace first)            |
| `docker tag <image> <username>/<image>[:tag]` | Create a new tag for an existing local image (needed before pushing)                |
| `docker search <term>`                        | Search Docker Hub for images matching a term                                        |
| `docker image inspect <image>`                | Show low-level metadata about an image (layers, env, entrypoint, etc.)              |
|                                               |                                                                                     |

> **Namespace** is either:
> - **Your personal username** (e.g. `ahmadq`, whatever you signed up with), or
- **An organization name** you're a member of (e.g. `josa`, `fortytwo`, etc.)
---

## 2. Image & Container Commands
*Building, running, and managing images/containers day-to-day.*

| Command                                              | Description                                                                  |
| ---------------------------------------------------- | ---------------------------------------------------------------------------- |
| `docker build -t <name>[:tag] .`                     | Build an image from a Dockerfile in the current directory                    |
| `docker images` / `docker image ls`                  | List local images                                                            |
| `docker rmi <image>`                                 | Remove one or more images                                                    |
| `docker run <image>`                                 | Create and start a container from an image                                   |
| `docker run -d --name <name> <image>`                | Run a container in detached (output will be in background) mode also name it |
| `docker run -it <image> sh`                          | Run interactively with a terminal attached (great for debugging)             |
| `docker run -p <host_port>:<container_port> <image>` | Map a host port to a container port                                          |
| `docker run -v <host_path>:<container_path> <image>` | Mount a host directory/volume into the container                             |
| `docker ps`                                          | List running containers                                                      |
| `docker ps -a`                                       | List all containers (including stopped ones)                                 |
| `docker stop <container>`                            | Gracefully stop a running container                                          |
| `docker start <container>`                           | Start a stopped container, detach mode by default, to make attach use `-a`   |
| `docker restart <container>`                         | Restart a container                                                          |
| `docker rm <container>`                              | Remove a stopped container                                                   |
| `docker exec -it <container> sh`                     | Open a shell inside a running container                                      |
| `docker cp <container>:<path> <host_path>`           | Copy files between container and host                                        |
| `docker-compose up -d`                               | Build/start all services defined in `docker-compose.yml`                     |
| `docker-compose down`                                | Stop and remove containers, networks created by compose                      |

---

## 3. Process / Debugging Commands
*Inspecting and troubleshooting Docker itself, containers, and resource usage.*

| Command                            | Description                                                        |
| ---------------------------------- | ------------------------------------------------------------------ |
| `docker logs <container>`          | View a container's logs                                            |
| `docker logs -f <container>`       | Follow (stream) logs in real time                                  |
| `docker inspect <container/image>` | Full JSON metadata (IP, mounts, env vars, config)                  |
| `docker top <container>`           | Show running processes inside a container                          |
| `docker stats`                     | Live stream of CPU/memory/network usage per container              |
| `docker events`                    | Stream real-time events from the Docker daemon                     |
| `docker system df`                 | Show disk usage by images, containers, volumes                     |
| `docker system prune`              | Remove unused containers, networks, dangling images                |
| `docker system prune -a`           | Aggressively remove all unused images too (not just dangling ones) |
| `docker network ls`                | List Docker networks                                               |
| `docker network inspect <network>` | Inspect a specific network's config and connected containers       |
| `docker volume ls`                 | List volumes                                                       |
| `docker volume inspect <volume>`   | Inspect a specific volume                                          |
| `docker info`                      | Show system-wide Docker daemon info                                |
| `docker version`                   | Show Docker client and server (daemon) version info                |

---

### Notes
- For **42 Inception** project: you'll mostly live in category 2 (build/run/exec) and category 3 (logs/inspect) since everything runs locally via `docker-compose`, registry commands aren't required unless you choose to push images.
- `docker-compose` commands are technically a separate CLI/plugin but are grouped here since they wrap image & container commands.
