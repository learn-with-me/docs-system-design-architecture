# Counters in Large scale systems

What nowadays is being used for counters in the world of large scale systems?
I see that cassandra has a special thing for it.
[https://docs.datastax.com/en/cql-oss/3.3/cql/cql_using/useCounters.html](https://docs.datastax.com/en/cql-oss/3.3/cql/cql_using/useCounters.html)
Heard negative reviews about this.

Can u just use Redis for counter?
Redis has a `crdt based counter` if eventual consistency is acceptable. It has to be persisted anyway. how would you do this part?

We do not have anything except G-Counter for leader less replication in case of eventually consistency. Not sure, but for me it seems like not that often used procedure.
Scenario of usage: number of likes in FB

The "like" counter problem is pretty common, and takes many forms. Youtube video likes, thumbs up, etc. Generally there's a few patterns. Redis is common used, if you simply want to store/return the literal likes. Think of the FB badge embed.
What about Redis internals? is it simple long value or something more?
Should just be redis hash by user id or post id. Complex key/value.

Another idea is to actually create something in the DB, a literal table, which is eventually consistent, that contains like count for a given post or user or whatever. The advantage of this you actually have persistent data that is query-able, as in it's a real database, but it's more complex than using redis.

Another another idea would be a top k lambda architecture or spark/flink/batch processing. There are trade offs here as well, but that's more for a real time analytics system such as google analytics. It might help to understand exactly where this counter is being used as that will shape design.

In all these cases we do not need to merge counts from enother hosts, do we? i mean we never have case when 2 different hosts show different numbers. Nah posts are resolved to a single cluster, which should be eventually consistent but containing all the data to that post (or whatever). Data is sharded.

Does it mean that in this case we have all data in one DC? i mean if we use single cluster to support youtube counters. it could be too much for 1 DC, could not be? There are probably a lot of data even for counters in case of youtube.

Pretty old stats: `5B views per day`. 57K per second. if each view event size = 1kb we have around 57Mb/sec. 57K/sec is not a big deal but it's better to use several DC because of availability. I mean even DC could be down. so i still think it's better to have multi-master in different DC in that case. Similar to multi master, we can have one topic for each dc in kafka and let each dc consume records from other dcs and on a write update its local counter and emit messages to other dc topics.
And btw - views count is kind of financial data. Based on this authors are being paid.

What options do we have here except G-counter? if we have sinlge leader we can simply apply click stream. i agree that we do not need GCounter in this case. if we have more than 1 leader we will have to merge counters from different leaders. if we have to merge we need something like G-counter( Because G-Counter suppose merge operation).
Talking about multi-master architecture.

## Design the feature to count the view count for a given news article

__Interview Question__: Suppose you have logs for all users view history. If a user views same article > 1 times within 30 minutes, it will be only counted for one time. Should focus on architecture solutions, scalability etc.

My initial impression is to use MapReduce jobs for logs generated for each hour, then aggregate view counts for each hour. In case of MR you will have significant delay in count update.

Any better alternative? If we don't care about duplicates, redis could be a very easy and scabale solution, using key as article Id and an integer as a counter. But if we want to apply this custom logic, then it won't work, as we need to look into past data. If we want to store counter for each individual user, then how to aggregate stats from all users?
I would propouse to use event stream in case of single node. If we have more than 1 node i would propose also use G-Counter. "A G-Counter is a increment-only counter (inspired by vector clocks) in which only increment and merge are possible. Incrementing the counter adds 1 to the count for the current node. Divergent histories are resolved by taking the maximum count for each node (like a vector clock merge). The value of the counter is the sum of all node counts."

How is the sla and how much is the accuracy of the system? This is a typical `lambda architecture`. For dedup in streaming you need to use checkpoint and watermark. Search for them. I assume SLA is more important than accuracy.
