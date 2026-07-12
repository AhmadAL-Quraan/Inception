```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

## Main commands

* `FROM`:picks the **base image** your image starts from. -> first layer
is just downloading that filesystem snapshot, nothing more

---

* `RUN`: Executes a command **during the build process** (Image creation, build time), and saves the result as a new layer (filesystem) in the image. `/bin/bash -c` inside it.
---
* `COPY`: Copies files from your **host machine** (build context) into the image. 
	Ex: `COPY host-machine_fs docker_fs`
---
* `Entrypoint`: defines the command that runs when the container starts, it becomes `PID 1` .
	* Two forms:
		1) `ENTRYPOINT ["nginx", "-g", "daemon off;"]` --> (**exec form**, Runs the binary **directly** — no shell involved. Binary becomes `PID 1`.)
		2) `ENTRYPOINT nginx -g "daemon off;`--> Runs as `/bin/sh -c "nginx -g 'daemon off;'"` — the **shell** becomes `PID 1`, nginx is a child underneath it.
		
		> Same broken pattern, shell at `PID 1`, signals never reach nginx. So always use **exec form**.
---
* `CMD`: provides **default arguments** to `ENTRYPOINT` (overridable), or a default command if no `ENTRYPOINT` is set.
	* The main purpose of this, is to overridable argument for `ENTRYPOINT`
	
```Dockerfile
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
```

**Normal run (uses CMD defaults):**
```bash
docker run my-image
# runs: nginx -g "daemon off;"
```
**Override CMD at runtime:**
```bash
docker run my-image -v
# runs nginx -v
```

**Override ENTRYPOINT itself:**
```bash
docker run --entrypoint sh my-image
# runs: sh
```

---
* `ARG`: a variable available **only during build time**, gone after image is built.
```Dockerfile
ARG VERSION=1.0
RUN echo $VERSION      # works during build
```

---

* `ENV`: a variable available at **runtime** inside the running container, baked into the image permanently.
```Dockerfile
ENV DB_HOST=mariadb
```

Any process running inside the container can read it via `printenv` or `$DB_HOST`.



> One important security note: Never put passwords in `ENV` — they're visible to anyone who runs `docker inspect` on the image. That's exactly why Inception requires `.env` files and Docker secrets instead.


---

* `WORKDIR`: Create directories and move into them inside images (working directory).

```Dockerfile
FROM node:18

# 1. Creates /app and moves into it
WORKDIR /app

# 2. Copies package.json from your host machine into /app/
COPY package.json .

# 3. Executes 'npm install' inside /app/
RUN npm install

# 4. Copies the rest of your project into /app/
COPY . .

# 5. Starts the app inside /app/ when the container boots
CMD ["npm", "start"]
```


---


> All `Dockerfile` instructions happened at **build time** except `ENTRYPOINT` and `CMD`, happened at **runtime**(container creation using `docker run`). 

> Every `Dockerfile` instruction that modifies the filesystem creates a new layer, including `COPY`.





## Dockerfile instructions worth knowing distinctly

- **`ENTRYPOINT` vs `CMD`**: `ENTRYPOINT` sets the fixed executable that always runs; `CMD` supplies default _arguments_ to it (overridable at `docker run`). Often used together: `ENTRYPOINT ["nginx"]`, `CMD ["-g", "daemon off;"]`.

---

- **`ARG` vs `ENV`**: `ARG` is a build-time-only variable (not present in the final image or running container). `ENV` persists into the running container and is visible via `docker inspect` / `printenv`. Never put secrets in either — they end up baked into image layers or history.


|                             | `ARG`               | `ENV`             |
| --------------------------- | ------------------- | ----------------- |
| Available at build time     | ✅                   | ✅                 |
| Available at runtime        | ❌                   | ✅                 |
| Visible in `docker inspect` | ❌                   | ✅                 |
| Use case                    | Build configuration | App configuration |



## Multi-stage pattern

Multi-stage builds introduce multiple stages in your Dockerfile, each with a specific purpose. Think of it like the ability to run different parts of a build in multiple different environments, concurrently. By separating the build environment from the final runtime environment, you can significantly reduce the image size and attack surface. This is especially beneficial for applications with large build dependencies.



Ex: simple example of multi stage pattern to run C code that prints hello world.

Compilation will be on a specific stage and running will on another

```Dockerfile
FROM debian:bookworm-slim AS build-stage
RUN apt-get update && apt-get install -y gcc
COPY hello.c .
RUN gcc hello.c -o hello

FROM debian:bookworm-slim AS run-stage
COPY --from=build-stage hello .
ENTRYPOINT ["./hello"]
```

* The first `FROM` (build-stage), has compiled the file.
* The second `FROM` (run-stage), has copied the result compiled file from build-stage and run it.

> Only the last `FROM` is the one which the image is going to keep and makes the layer from. Each `FROM` is a separated layer and filesystem.