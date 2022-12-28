# Availability

Fail-over Active-Active seems similar to Master-Master replication. Are these both same or some difference between them?

The two concepts are slightly different:

active-active refers to a high availability configuration: several nodes offers the full service. In a normal situation, load-balancing occurs, to distribute the requests equally between all the active nodes. When one server is down, the requests are rerouted to the others. When used in a database context, there is only one database for the outside world. It is not specified how this is achieved: database servers can for example share the same data on (high availability) disks if the internal data structures are designed for concurrency. The advantage of active-active is to avoid having a very expensive spare-servers staying idle most of the cases (active-passive configuration).

master-master replication (also called multi-master replication) refers to a specific database technique to synchronise database objects across several database instances in a way to ensure global consistency. The advantage is the flexibility, each participating database instance being well encapsulated, and hybrid replication scenarios are possible with several sets of masters.

Conclusion: there is a tiny overlap between the two concepts: master-master could be used as one specific way to implement active-active for databases. But active-active can be implemented differently, and multi-master can have other purposes than high availability.

AFAIK

- fail over active active is a kind of a HA (high availability deployment) of a server, where both servers are active (serving requests), via a load balancer (one goes down, the other gets more load)
- master master replication is a way for a distributed database cluster to have >1 source of truth (multiple master), by keeping the writes in sync using some consensus algo
so, the 2 are not entirely the same
