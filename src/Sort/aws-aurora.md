# Amazon Aurora

As we know it can have up to `15 read-only` database

I think that these replicas are cache!  as i understand they do not keep information about locks.. etc. They just keep pages without lock information. So it looks like complex cache. i mean complex because we ca do some complex logic here: join, group by etc.
I guess you may think of read replicas as read-only entity, but that is not true. don't forget about WAL
How does WAL impact in case of replica? In Aurora replica does not do any writes?
For instance - update. you have to lock an entity before an update, right?
Yes. I have to set lock byte in particular row. But only master will do it. Replica does not do any writes to a storage.
How a data appears in read replica if so?
In case if raft/paxos replicas do writes to log(wal). But in case if aurora replica only do reads.
By writes I mean synchronization (in a wide sense) with primary.
How aurora does that?
Aurora replica just know that its time to reconstract page from storage. as i understand master will send just an event that replica should apply new changes from distributed storage. The main idea that replica does not do any writes ! It looks like cache! I am not sure about sharding. But aurora support multi-master.

Can you send an article for that? I kind of agree that read replica mostly required for 2 things:

1. failover
2. read queries that can tolerate eventual consistency

but I didn't get the way how the data is transferred from primary to that replicas

- YT [AWS re:Invent 2018: [REPEAT 1] Deep Dive on Amazon Aurora with MySQL Compatibility (DAT304-R1)](https://youtu.be/U42mC_iKSBg)
- [p1041-verbitski](./assets/p1041-verbitski.pdf)

Its also clea why they propose only 15 read-only replicas. It because all replica have the same data. They do not propose sharding on case of single master. Please correct me if i am wrong. If we want to have sharding we need to have multi-master
