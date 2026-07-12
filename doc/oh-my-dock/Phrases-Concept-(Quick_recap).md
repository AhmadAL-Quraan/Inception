

## Docker phrases you will see often

 * **Docker-client**: The interface (CLI commands or GUI) that allow users to interact with Docker ecosystem (mainly Dockerd).
 * **Docker Engine API**: Docker provides an API for interacting with the Docker daemon (called the Docker Engine API), as well as SDKs for Go and Python.
 * **Dockerd**: a persistent background service that manages Docker containers, images, networks, and storage volumes.
 
 ```
 Docker-client --> Docker Engine API --> Dockerd
 ```

* **Docker**: It is a container engine that uses the Linux Kernel features like **namespaces** and **control groups**, to create containers on top of an operating system. So you can call it **OS-level virtualization**.
* **Containers**: Object of an image. Isolated process (Not a mini VM or smthing), that has it's own configurations to run a specific application (it's 0-application layer virtualization).
* **Image**: Class or a package, that has the necessary configurations and layers to run a container. It's a **read-only**, immutable template made of layered system (**multiple read-only filesystem layers and configuration files metadata**), not a typical file that you can read.
* **Dockerfile**: Commands, script, text-based doc, that it's used to make an image. See [How to write Dockerfile](./How-to-write-Dockerfile.md) .

```
Dockerfile ---> image ---> container
```

* **Docker-compose**: is an **orchestration tool**. It reads a YAML file — usually `docker-compose.yml` — where you describe:
	- Which **images** to build or pull
	- What **containers** to run from them
	- How they're connected (networks, volumes, ports, env vars, dependencies between them)
	- You don't need a `Dockerfile` if you want to use a pre-built images, directly from a register like `Docker-hub`, it can pull them directly from it.
	- If you want to make a **Custom image**, you must have `Dockerfile`.

```
Dockerfile        → recipe for ONE image
docker run         → starts ONE container from an image
docker-compose.yml → recipe for MULTIPLE containers working together
docker-compose up  → builds/starts ALL of them at once, wired together
```

* **Docker volumes**: the preferred and safest mechanism for persisting data generated and used by Docker containers, **Managed by Dockerd itself**. Because containers are ephemeral by nature, any data written to their internal storage layers is permanently lost if the container is deleted. Volumes solve this by storing data outside the container's standard file-system in a host directory completely managed by Docker.
* **Docker registry**: A centralized location where images are uploaded to, it could be public or private. Ex: [DockerHub](https://hub.docker.com/)
* **Docker networks**: A virtual network config, allows independent containers to talk to each other.

## Image internals concepts

* Structure to the name of an image:
```
[HOST[:PORT_NUMBER]/]PATH[:TAG]
```
Explanation:
	- `HOST`: The optional registry hostname where the image is located. If no host is specified, Docker's public registry at `docker.io` is used by default.
	- `PORT_NUMBER`: The registry port number if a hostname is provided
	- `PATH`: The path of the image, consisting of slash-separated components. For Docker Hub, the format follows `[NAMESPACE/]REPOSITORY`, where namespace is either a user's or organization's name (mostly your account on docker hub). If no namespace is specified, `library` is used, which is the namespace for Docker Official Images.
	- `TAG`: A custom, human-readable identifier that's typically used to identify different versions or variants of an image. If no tag is specified, `latest` is used by default.
	Ex: `docker.io/library/nginx:latest` -> `docker.io`: Host, `PATH`: namespace: library, Repo: nginx, tag: latest.

> If you have an image from one syllabus only, Ex: `debian:bookworm-slim`, **debian** is the image name and there is no **namespace** in this case, because debian is an official image provided by docker hub and the maintainers of this image.



- **Image layers / Union filesystem (OverlayFS)**: An image isn't one blob, it's a stack of read-only layers, one per **Dockerfile** instruction (`FROM`, `RUN`, `COPY`, etc.) see [here](https://docs.docker.com/reference/dockerfile/). Docker merges them into a single view using a union file-system. This is _why_ **builds cache**: if a layer's instruction and its inputs haven't changed, Docker reuses the cached layer instead of rebuilding it. I can see the Image layer throw `docker image histroy`,[See more](https://docs.docker.com/get-started/docker-concepts/building-images/understanding-image-layers/), Also: [Understanding Docker -- File System, Resources, and chroot](./Understanding_Docker_File-System_Resources_and_chroot.md) .
- **Build cache**: Docker builds top-down and reuses any layer whose instruction + [context](https://docs.docker.com/build/concepts/context/#what-is-a-build-context) hasn't changed since the last build. This is why you `COPY package.json` and run `npm install` _before_ copying the rest of your source code, dependency layers stay cached even when your app code changes.
- **Multi-stage build**: A **Dockerfile** with multiple `FROM` statements [see](https://docs.docker.com/reference/dockerfile/#from=), where you build/compile in one stage and copy only the final artifact into a slim final stage. Keeps final images small — build tools never ship in production.
- **.dockerignore**: Same idea as `.gitignore`, excludes files from the build context sent to the daemon (keeps builds fast, avoids leaking secrets/`.git`/`node_modules` into the image).

## Container lifecycle & process model

- **PID 1 in a container**: The first process a container runs (or any Linux system runs) becomes PID 1,  same as `init` on a real Linux boot. This is a big deal for **Inception** project: PID 1 doesn't get default signal handling (Linux kernel forces it to ignore signals), so if your main process doesn't properly handle `SIGTERM`, `docker stop` won't gracefully kill it (it'll hang until forced). This is why some setups use a tiny init wrapper like `tini`. Read [PID-1 Handling for container termination](./PID-1-Handling-for-container-termination.md) .
- **Container states**: `created` → `running` → (`paused`) → `exited`/`dead`. A stopped container isn't gone, its filesystem and metadata still exist until `docker rm`.
- **Restart policies**: `--restart=on-failure`, `always`, `unless-stopped`. Controls whether Docker auto-restarts a container after it exits or the daemon restarts. Relevant for Inception since services should stay up (`restart: on-failure` or `always` in compose).
- **Foreground vs daemonized process inside a container**: A container exits the moment its PID 1 process exits. This is why you can't just run `service nginx start` inside a container and expect it to stay alive, that command daemonizes and returns immediately, PID 1 exits, container dies. You need the actual binary running in the foreground (e.g. `nginx -g "daemon off;"`, `mysqld_safe`, `php-fpm -F`). This trips up almost everyone on Inception at first.

## Networking

- **Bridge network**: Docker's default network driver, creates a **private virtual network** on the host, containers get internal IPs, and Docker's embedded DNS resolves other containers by service/container name. This is what docker-compose gives you automatically.
- **Bind mount vs (named) volume**: A **bind mount** maps an exact host path into the container (`-v /home/user/data:/var/data`), you control the host path directly. A **named volume** (`-v db_data:/var/lib/mysql`) is managed entirely by Docker under `/var/lib/docker/volumes/`, and is the more **portable/recommended** option. Inception typically requires named volumes bound to a specific host path (`/home/<login>/data/...`). see more [Docker Storage Options Comparison](./Docker-Storage-Options-Comparison.md)

## Registry-adjacent

- **Image tag vs digest**: A tag (`nginx:1.25`) custom, human-readable label used to identify a specific version, variant, or release of a Docker image. A **digest** (`nginx@sha256:...`) is an immutable content hash, always points to the exact same bytes. Digests matter for reproducibility/security; tags are convenience.
- **`docker context`**: Lets the Docker CLI target a different daemon (local, remote host, or a different Docker Desktop VM) without reconfiguring everything — useful once you're managing more than one Docker environment.




