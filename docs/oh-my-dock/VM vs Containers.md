
![[vm_vs_docker.png]]
## VM

* Stronger isolation -> Each VM has it's own kernel.
* Heavy on resources (more memory, CPU, ..)
* Full OS.
* There is Type 1 or Type 2.
* Slower to start.


## Containers

* Process level isolation (weaker than VM) -> share the host kernel.
* Lightweight (mostly holding just one service with it's config).
* No full OS.
* Fast to start