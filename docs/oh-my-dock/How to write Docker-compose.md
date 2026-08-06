* Docker-compose could be useful to run multiple containers at once.
* Create a common network for those containers. 

![[Pasted image 20260718151750.png]]



---


## Docker command == Docker compose 


**Example 1 :**

`docker network create --driver bridge backend_network` & `docker run --network backend_network`
```yaml
version: '3.8'

services:
  web:
    image: nginx
    networks:
      - backend_network

networks:
  backend_network:
    driver: bridge

```






---

# Resources

[Official doc](https://docs.docker.com/compose/)