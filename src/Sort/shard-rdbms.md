# Shard RDBMS

Can we shard / replicate / partition rdbms databases like nosql databases?. In my search, I see that partitioning replication are possible for rdbms. I am not sure about sharding though. Also the single most important thing is that nodqls have no need for joins, which reduce retrieval time. And this is faster than having index on rdbms database tables.

There are multiple challenges, as there are multiple tables its a challenge to know how to partition them so that there is complete isolation between shards. Join operations can't be done or can be with some complex operation. Ton more, in a nutshell youll be using it at a nosql db so its not done generally. Acid properties wont be there too. Also nosqls are mostly used where joining is not needed, in cases where there is complex user data, booking data there nosql isnt needed.
It is difficult to join across shards. You shard tables such that joins  are required only within one shard, hence the complexity on how to decide sharding criteria

Actually this is a really really big topic of discussion, mostly its about CAP theorem, acid, base properties of sql and nosql dbs, how different dbs work like cassandra. There are many YouTubers like gaurav sen who cover these well.

RDBMS can be sharded : horizontal or vertical. Horizontal is when you split at row level across different nodes and vertical is when you move logically related tables to different nodes i.e. dB is split across nodes. Replication can be achieved by Master-Slave configuration, etc. Example: `Google Spaner`, `CockroachDB`.
RDBMS were not built like nosql with sharding or replication out of the box. With proper planning, RDBMS can achieve those things, but it requires work.
