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

## How to scale websockets

So that say max they r able to scale it out as 100k connections per machine.

Instead of each thread for a client they use akka framework.
Create an actor for each client. They also say using a thread is expensive due to the call stacks and then concurrency issues arise.
Where as with akka it's very lightweight and concurrency issues r handled by itself.
Moreover they tweek few system settings to increase the max connections.
65k max connection limit is for a client and not server. Hence for a server we may scale it to anything but due to memory limitations there is a Max cap u can reach to. So 100K is something which is easily doable with 16Gb heap assigned.

## Message Ordering

How is correct message ordering is preserved in a messaging app?

Multiple participants sending messages parallely from different devices to your application cannot easily agree on the same order (that's the nature of distributed systems). There are sophisticated algorithms to solve this very problem. But a messaging platform's core requirement should not address this problem because real time interaction takes higher priority.

What it can control is that the ordering for each user remains intact. That it does by timestamp + sequence number on the server which has received the message. This way your experience for both users separately remains consistent even if they open the app on multiple devices.

There could be different approaches. For instance telegram and whatsApp uses opposite approaches to re-order messages at client side. You can check it. For example . You can switch off your internet and send some messages in Telegam group and whatsApp group. wait enougth time to be sure to have new messages in both groups. you will see a difference. if we are talking about whatsApp,Discord .. These use actor model. Each group has it own actor. This actor defines total ordering. So you have total order within single group and not in whole messages.

But ideally in an interview if the ordering logic is asked them the interviewer would be more interested to see what the candidates approach is towards ordering. Whether it is lamports or vector clocks and why. It's better for us to discuss about trade-off in different approaches. for example if we know 2 different approaches we can  "compare" these approaches during an interview and point out what are props and cons of these different approaches in case of particular requirements.

- [Twitter IDs](https://developer.twitter.com/en/docs/twitter-ids)
- Akka [Motivation behind Actors](https://doc.akka.io/docs/akka/current/typed/guide/actors-motivation.html) - As for me the main idea of actor = lightweight thread + inbound queue. Each host can have a lot of actors (much more compare to number of CPU). Actors send messages to each other( all messages will be placed to inboud queue before processing).if we have an inbound queue for messages we have an ordering and dont have contention .  of course there more details .. for example - supervision, actor hierarchy

## Other References

- [Facebook Real-time Chat Architecture Scaling With Over Multi-Billion Messages Daily](https://scaleyourapp.com/facebook-real-time-chat-architecture-scaling-with-over-multi-billion-messages-daily/)
- YT [MySQL for Messaging - @Scale 2014 - Data](https://www.youtube.com/watch?v=eADBCKKf8PA)
- Meta [Building Mobile-First Infrastructure for Messenger](https://engineering.fb.com/2014/10/09/production-engineering/building-mobile-first-infrastructure-for-messenger/)
- Slideshare [Storage Infrastructure Behind Facebook Messages](https://www.slideshare.net/feng1212/storage-infrastructure-behind-facebook-messages-31360618?qid=7b23455d-04ec-413c-b36f-29742d8ac4fe&v=&b=&from_search=11) - Info on the persistence tech in fb, I find the presentation helpful to understand the storage layer
- [https://labs.ripe.net/author/ramakrishna_padmanabhan/reasons-dynamic-addresses-change/](https://labs.ripe.net/author/ramakrishna_padmanabhan/reasons-dynamic-addresses-change/) - if the IP address changes then a new WebSocket connection will need to be established. WS connections dropping is pretty normal. Once a new connection is established, the client can indicate what message it received last and it can send messages that weren't sent yet.
