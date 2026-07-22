

**Why PID-1 is important ?**
  ->   `PID-1` is the main (first) process to run on any Linux system.
    All sub-process are descendant from it in one way or another.
	 In Docker, a container is defined as **running**, until `PID-1` terminated.

---
	 
We have two main signals to shutdown any container: 
	1) `SIGTERM`: A process handler (running it's own way of shutting down)
	
	2) `SIGKILL`: Kernel forces (Kernel forces a process to shutdown/terminate)

## Problem 

* Without proper handling of `PID-1`, if using `docker stop <container>`:

1) Kernel delivers `SIGTERM` to `PID-1` (a "please stop" request), bash has no handler for this (process running as `PID-1` doesn't have a shutdown code), so nothing happens, bash keeps running.

2) Docker's daemon just... waits (default: 10 seconds) this is Docker giving the process a grace period, not the kernel enforcing anything.

3) After timeout, Docker daemon issues a `SIGKILL` to `PID 1` inside this container→ kernel forcibly terminates the process, no cooperation needed, no code in bash runs, it's just gone instantly, and the container now died.

**So if it is going to shutdown either way, where is the problem ?**

> That is right that it is going to shutdown either way, but there is a big difference between forcing a process to shutdown, and letting it running it's own shutdown process.         
	
- **`SIGTERM` (handled correctly, avoid errors)**: the process gets to run its _own_ shutdown code first — close network connections properly, finish writing any in-progress data to disk, flush buffers, release locks, close files cleanly — and _then_ exit.

- **`SIGKILL`(Not handled correctly, errors could happens)**: the process is yanked out from under itself mid-instruction. No code runs. Whatever it was doing at that exact microsecond just... stops. Nothing gets to finish or clean up.

> This is important if we running an application/service inside a container, Ex: Nginx , To let it handle it's configurations and save it's state with what ever it has. Make less errors. 

Services like MariaDB would give this error if `SIGKILL`:
```
InnoDB: Database was not shutdown normally!
InnoDB: Starting crash recovery.
```
## Solution 

### 1) `tini`

tiny init system built specifically to solve the exact PID 1 problem but it solves it from a different angle than the `exec` pattern.


>`tini` is a ~2000-line C program whose entire job is to be a **correct, minimal PID 1**. Instead of your real service (or your script) being PID 1 directly, `tini` sits as PID 1, and your actual application runs as its child (PID 2+).

Ex:
```Dockerfile
Without tini:          With tini:
PID 1 = mysqld          PID 1 = tini
                         PID 2 = mysqld (tini's child)
```

**What problem it solves that plain PID 1 doesn't  ?**

Two things a normal PID 1 process usually _doesn't_ do correctly, but `tini` does:

1. **Signal forwarding**: `tini` receives `SIGTERM` (from `docker stop`) and explicitly forwards it to its child process. Even if your app wasn't written with perfect signal-handling assumptions about being PID 1, `tini` bridges that gap.
2. **Zombie reaping**: This is the one `exec` alone doesn't solve. On Linux, PID 1 has a special extra responsibility — it must "reap" (clean up) any orphaned and zombie processes whose parents have died, otherwise they pile up in the process table. Normal applications (`mysqld`, `nginx`) were never written expecting to be an init system, so they don't do this. `tini` does it correctly, since that's literally its purpose.


So, in short:

|Job|What it does|Applies to|
|---|---|---|
|Signal forwarding|`tini` relays `SIGTERM` to its direct child so it can shut down gracefully|Live, running children|
|Zombie reaping|`tini` calls `wait()` on any orphaned process once it exits, so it doesn't linger as a zombie|Processes that have already finished|

> Orphaned process: A process which it's parent died but it is still running.

> Zombie process: A process which has finished but it's parent doesn't know yet (no `wait()` has been used by the parent to collect it's status from the process table). 

> **Zombie reaping**: This is the one `exec` alone doesn't solve. On Linux, PID 1 has a special extra responsibility — it must "reap" (clean up) any orphaned zombie processes whose parents have died, otherwise they pile up in the process table. Normal applications (`mysqld`, `nginx`) were never written expecting to be an init system, so they don't do this. `tini` does it correctly, since that's literally its purpose.

**How to do this**
```Dockerfile
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y tini mysql-server

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"] # Add it here
```

Or, in **Docker-compose**, Docker actually has this **built in** — no separate binary needed:
```yaml
services:
  mariadb:
    build: ./requirements/mariadb
    init: true
```


**How tini kills it's child processes ?**

consider `Nginx` is running inside the container.
`tini` doesn't get killed at once from `SIGTERM`, it wait/passes it to it's direct child first, and then wait for it to be **well** terminated.

```
docker stop → SIGTERM → tini
                          │
                tini is ALIVE, running its own signal handler
                          │
                tini's code explicitly does: kill(nginx_pid, SIGTERM)
                          │
                nginx receives it, shuts down properly
                          │
                nginx exits → tini notices (via wait()) → tini exits too
```




---



### 2) `exec`: A command that executes a process.

Normaly to execute a child process a `fork()` happened first:
```
Shell (PID 100)
   │
   ├── fork() ──> creates a NEW process (PID 101), a copy of the shell
   │                    │
   │                    └── exec() ──> PID 101 now runs the new program
   │
   └── Shell (PID 100) still exists, waiting for PID 101 to finish
```

But, What if no `fork()` like direct `exec mysqld` ? 4
**Only replaces**.
```
Script (PID 1)
   │
   └── exec() ──> the KERNEL replaces this process's own memory image
                   with mysqld's code, data, and stack —
                   same PID, same process table entry, same file descriptors
```

* We can use this behavior to make the main process different in a container so it can accept signals (because these applications/process can take signals).


| Replaced                                 | Preserved                                           |
| ---------------------------------------- | --------------------------------------------------- |
| Program code/instructions being executed | Process ID (PID)                                    |
| Memory contents (heap, stack)            | Open file descriptors (unless marked close-on-exec) |
| CPU register state                       | Environment variables                               |
| The program's name (as seen in `ps`)     | Working directory                                   |
|                                          | Process group, session, parent PID                  |

Without `exec`

```bash
#!/bin/bash
# setup...
mysqld            # forked as a CHILD process
```

```
ps aux inside container:
PID 1   bash entrypoint.sh
PID 47  mysqld          ← SIGTERM never reaches here automatically
```

With `exec`
```bash
#!/bin/bash
# setup...
exec mysqld       # REPLACES the current process
```

```
ps aux inside container:
PID 1   mysqld          ← SIGTERM reaches this directly, mysqld handles it itself
```



**How to use it ?** 

We can make a script for the configuration of our application, and apply it inside the `Dockerfile`

```bash
#!/bin/bash
# setup...
exec mysqld       # REPLACES the current process
```

in `Dockerfile`
```Dockerfile
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
```

---
