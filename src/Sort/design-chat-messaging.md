# Design Chat Messaging

For a messaging application, how does a client send and receive messages?

The naive solution is to send messages using POSTs and to receive messages using GETs (polling). For each send, there is a TCP handshake to set up a new connection. For receives, in addition to the aforesaid TCP handshakes, many GETs will return no results. And even when there are new messages, the client has to wait until the next GET to get them.

To solve both of these problems, we can use WebSockets. Send latency is improved because we remove the overhead of a TCP handshake per send. And receive latency is improved additionally because clients are pushed new messages as soon as they become available. Long polling is another alternative for receiving messages.

To handle failure, such as Internet or the power going out, persistently queue up messages on the client, and if there is a failure, re-queue them in the new WebSocket connection. So that we don’t deliver sent messages twice or display messages more than once, we can give each message a unique, random ID that is generated on the client to achieve idempotence.

For Messenger, the read/write ratio is about the same, so it makes sense to use one type of server, which minimizes deployment/maintenance complexity. For something like Slack, there are many more receives than sends, so it may make sense to split up the functionality into read and write services so that they can be scaled separately and optimally for their specific workload characteristics.

A WebSocket connection is between a client and a particular API server. So the load balancer must forward packets to the same API server. This can be done with L3 load balancing, which operates at the IP layer (as opposed to the TCP layer). For example, the load balancer can hash the client’s IP address to the same server. Instead of doing that, however, we should use consistent hashing so that we don’t remap all clients to different API servers when an API server goes down, which would kill every WebSocket connection.

To minimise handshakes, you can use TCP keep-alive.

## FB Chat Architecture

Question related to cache.
A cache is typically used to support more reads and reduce writes to the DB. So in this case, a cache may be introduced for all active user inboxes. When two people are chatting, their inboxes are in the cache. Messages are written to both their inboxes and then transmitted to the client. In this strategy, what is the best way to periodically persist the messages to durable storage? How can we be sure that messages will not be lost before they are written to DB?

Generally write through caches take care of writing to DB. Caches can't reduce writes to the DB, or shouldn't be used in this way. The cache should reflect the source of truth, and not be another source of truth. Otherwise, you run into weird sync issues. Ideally, you write aside or like Uday mentioned, write through. fwiw, most caching is a best effort thing, and should be used to reduce the reads, but shouldn't be entirely relied on to be functioning. Cache misses are a thing. Probably what you were thinking of is write behind (write back) caching where we write to the cache first, then write to the DB later. But this doesn't reduce out total DB writes, it just defers them and makes it async. But at the risk of data loss.

The question you need to ask is what is the cost of a cache miss? If it's high, write through is preferable because it will synchronously write to cache and DB at the same time. If it's low, cache aside or read through is preferable.

They do not need cache for this part of system. Channel Servers take care of message queuing and delivery. Erlang keeps inbox in memory already. May be it can also persist it. i do not know how they garantee durability.

> How can we be sure that messages will not be lost before they are written to DB?

One thing you can do is put the message in a pub/sub topic. Once it's in there, it's persisted. There can be subscribers of that pub/sub topic that write to the DB and separate subscribers that bypass the DB and send the message straight to the recipient.

If it’s in-memory, won’t messages get lost if machine gets rebooted or there is a power failure?
There's no way they don't store this to disk. There's no magic here, this is probably a `poorly written article` that is omitting some details. It looks like what they do is flush to disk using Iris. The recent messages are sent from Iris’s memory and the older conversations are fetched from the traditional storage. Iris is built on top of MySQL & Flash memory.

- [Facebook Real-time Chat Architecture Scaling With Over Multi-Billion Messages Daily](https://scaleyourapp.com/facebook-real-time-chat-architecture-scaling-with-over-multi-billion-messages-daily/)
- YT [MySQL for Messaging - @Scale 2014 - Data](https://www.youtube.com/watch?v=eADBCKKf8PA)
- Meta [Building Mobile-First Infrastructure for Messenger](https://engineering.fb.com/2014/10/09/production-engineering/building-mobile-first-infrastructure-for-messenger/)
- Slideshare [Storage Infrastructure Behind Facebook Messages](https://www.slideshare.net/feng1212/storage-infrastructure-behind-facebook-messages-31360618?qid=7b23455d-04ec-413c-b36f-29742d8ac4fe&v=&b=&from_search=11) - Info on the persistence tech in fb, I find the presentation helpful to understand the storage layer
