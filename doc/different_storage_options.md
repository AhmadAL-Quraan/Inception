
# Docker Storage Options Comparison

| Storage Feature | Docker Volumes | Bind Mounts | Container Writable Layer |
| :--- | :--- | :--- | :--- |
| **Managed By** | Docker Daemon | User (Host OS) | Container Storage Driver |
| **Host Location** | Docker storage directory | Anywhere on host disk | Tied to container filesystem |
| **Survives `docker stop`** | Yes | Yes | Yes |
| **Survives `docker rm`** | Yes | Yes | No (Data is destroyed) |
| **Best Used For** | Production databases, backups | Source code syncing, config sharing | Temporary runtime caches |
