# Databases

It doesn't makes sense to talk about database (rdbms vs nosql) if we dont know QPS . If we have less than 10k-20k/sec write requests we can use even not sharded rdbms. If we have to support 100k/sec write requests it makes sense to start talk about noSql.

- RDBMS vs Columnar vs KV
  - [https://docs.microsoft.com/en-us/azure/architecture/guide/technology-choices/data-store-overview](https://docs.microsoft.com/en-us/azure/architecture/guide/technology-choices/data-store-overview)
  - Dzone articles are really good at these. You can learn a lot from there about the types of databases, when to use realtime or graph or kv databases and much more
  - YT [Introduction to NoSQL • Martin Fowler • GOTO 2012](https://www.youtube.com/watch?v=qI_g07C_Q5I&ab_channel=GOTOConferences)

![Martin Fowler - Suitable DB](./assets/martin-fowler-suitable-db.png)

## Sharding

[https://vitess.io/docs/15.0/reference/features/sharding/](https://vitess.io/docs/15.0/reference/features/sharding/) - for MySQL

## Shard Size

how much is typically the max or recommended size of each shard of say MySQL or for PostgreSQL ? This will help me estimate the number of shards required given that say I need to store 1 PB of data.

The link below in "Data Sharing" claims that the avg shard size ranges from 20 to 40 GB. Perhaps this is for MySQL.
[https://www.codercrunch.com/design/634265/designing-instagram#mcetoc_1dv10vl8s1l](https://www.codercrunch.com/design/634265/designing-instagram#mcetoc_1dv10vl8s1l)

## Million Records report

Let's say there is a table which has millions of records and records get updated frequently in that table. If you had to build a report for end users to show the statics of each hour, what would be your approach. Keep performance in mind since table has huge number of records.

It can be done in may ways. Each will have its own pros and cons:

1. Complex Indexing with tradeoff in write performance and less extensible in case any change is needed in report due to cost of reindexing.
2. Create multiple replicas and serve report by any replica only. This might work but if read txn is not implemented optimally may lead to replication lag and can affect the overall perf.
3. View in db, this wont be managable and less extensible. For critical db , views are usually not appreciated.
4. Send the metrics to timeseries monitoring db like prometheus. Not sure if this is right use case for prometheus and may require metrics to be published explicity from write path or prom will have read from slave. Both the ways addition of code is making it less modular in my view.
5. These days DBs can emit change event in the form of stream in async. We can enable these stream of updates. Write a consumer for these updates stream of event. Patch the update in some cold storage and let the user design amd customize their own report in cold storage or write an api for report powered by cold storage. This approach will not touch any code in write path hence no performance degradation in write path and events are sent async so no read performace degragation of db. All we might need is to scale the DB config as per event stream requirement.

## Index

An index is an auxiliary data structure that speeds up look-ups by a particular column. As a mental model (not completely accurate), think of taking a particular column of a table and building a balanced BST from the values of that column so you can look each one up in O(log n) time. And imagine each node in the tree has a pointer to the corresponding row in the table.

For the `flexible sharding model`, you might imagine it using a timestamp to pick the pertinent sharding strategy or a feature ID.

## Hinted Handoff & Schemaless Bufffered Writes

In Cassandra's hintedhandoff or Schemaless's Buffered writes  - How is the case for master failure before replicating the data to a quorum of nodes handled ? Since these systems are designed to be max write available they cannot discard writes (like in High-water mark). Lets take a specific example -  Will Write 4 be lost in case of hintedhandoff (see Log Truncation section here).

My hypothesis is that : master failure -> writes are still accepted and written to secondary master -> till master is back up (or another is elected) and then new master replays these writes from secondary so everything is up to date. Only caveat : Immediate writes may not be read available.

- [High-Water Mark](https://martinfowler.com/articles/patterns-of-distributed-systems/high-watermark.html)

## Other References

- [How Discord stores billions of messages](https://discord.com/blog/how-discord-stores-billions-of-messages)
- [How Discord indexes billions of messages](https://discord.com/blog/how-discord-indexes-billions-of-messages)
- YT [Types of NoSQL Databases | Why you should learn NoSQL before your next System Design Interview](https://www.youtube.com/watch?v=Tkr_2Hl8StE)
- [https://www.sqlite.org/fasterthanfs.html](https://www.sqlite.org/fasterthanfs.html)
- [Index Merge Optimization](https://dev.mysql.com/doc/refman/8.0/en/index-merge-optimization.html)
- [A deeper dive into Facebook's MySQL 8.0 migration](https://www.zdnet.com/article/a-deeper-dive-into-facebooks-mysql-8-0-migration/)
- [Scaling Datastores at Slack with Vitess](https://slack.engineering/scaling-datastores-at-slack-with-vitess/) - actually a terribly written article
  - [Scalability Philosophy](https://vitess.io/docs/overview/scalability-philosophy/)
  - [Sharding](https://vitess.io/docs/reference/features/sharding/)
  - [Citusdata](https://www.citusdata.com/) - equivalent of Vitess for Postgres
- [Building Distributed Locks with the DynamoDB Lock Client](https://aws.amazon.com/blogs/database/building-distributed-locks-with-the-dynamodb-lock-client/)
- [The Architecture of Schemaless, Uber Engineering's Trip Datastore Using MySQL](https://eng.uber.com/schemaless-part-two-architecture/)
- [Search Engine Indexing](https://en.wikipedia.org/wiki/Search_engine_indexing)
