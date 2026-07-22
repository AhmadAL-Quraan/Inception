

## Main concept

* **DRIVER**: Engine/ Blueprint underlying network tech inside docker.

> Main drivers: Bridge, Host, overlay, macvlan, overlay, None

---

* **Network**: Instance created from a driver.

Ex: `BRIDGE Driver -> Bridge (default "docker0")`



## Bridge driver

* Driver type, acts as a **virtual switch** connecting containers with **router-features** like IP, NAT, DNS, Default gateway, ... (local area network LAN).
* It's the default driver that docker uses if nothing specified.


> **"Router-features"**, but technically the bridge itself operates at L2 (switching, MAC-based). The IP/NAT/DNS layer is added by **Docker's networking stack** (iptables rules + embedded DNS server), not the bridge device itself doing routing. Still, from a user's mental model, calling it "switch + router features" is a very reasonable simplification.

Two types:
1) **Default bridge** ("docker0"): Auto created as an instance of Bridge driver, IP only communication (NO DNS).

2) **Custom bridge**: User created using `docker network create --driver bridge <network_name>`, DNS name resolution, better isolation, standard way of making docker network.


## Physical / virtual concept

* Interface: A network endpoint visible, type `ip a`.

`Container has interface gig/1  <--veth--> switch (docker0) has interface gig/0`

![[Pasted image 20260723010331.png]]

> These are three separate bridge interfaces, each belong to a different docker network.
> `br-xxxx`: Is a **Custom bridge**.



---


*  Veth pair:  `virtaul ethernet cable`,  which connects container's namespace to the bridge.

> namespace: Is which makes a container isolated from each other, contains a separate network stack, veth here is used to make them connected again with the host.



## Internal model


![[Pasted image 20260723011120.png]]


Important notes:

* Each container has it's own **private IP address (only)**, from bridge networks's subnet (by docker built-in DHCP like). 

	* **Container → internet (outbound)**: the container sends traffic from its private IP. Docker's iptables rules do **SNAT** (masquerade) — rewriting the source IP to the **host's** IP before it leaves the machine. To the outside world, it looks like the traffic came from the host, not the container.
	
	* **Internet → container (inbound)**: someone connects to the **host's** public IP on a specific port. Docker's **DNAT** rule (set up by your `-p host_port:container_port` flag) rewrites the destination to the container's private IP:port and forwards it in.

* A container could be inside more than one network at the same time (different IP address per network).