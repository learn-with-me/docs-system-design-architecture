# To be sorted

## Calculate network bandwidth requirement

How to calculate network bandwidth requirements for a video sharing site like YouTube. Assume average video size is 100MB and 500000 users uploading 1 video per day. 5 million daily active users seeing 5 videos per day.

You will probably not upload all video to 1 DC and 1 host. How many DC and hosts will you use? Let’s assume we need this globally. So 4 availability zones, 2 DC each, 2 hosts per DC

## Design YouTube view history

Design YouTube view history. Discuss system architecture, data storage etc.

What is the storage system you would use, why and how?

## Sync data for large number of devices

Design of how data is synced when there are large number of devices and data is updating rapidly. Like we wear fitness bands, data is updated with every step in the band and then synced with the global storage.

What is the point of sync that on every step?
There are multiple reasons of not to do that

1. it's expensive
2. the device doesn't have an internet connection all the time
3. it consumes a lot of battery
4. and probably the main reason: it is not needed to have such an latency on syncing that. it's not a HFT thing

Then how is data synced behind the scenes?  What is the architecture?
I'd upload the data (whatever precision is required) into a cell phone via bt and just send an butch update to the server.
DB depends on requirements, might be wide column, or time series db

## Consistent Hashing

- [https://www.acodersjourney.com/system-design-interview-consistent-hashing/](https://www.acodersjourney.com/system-design-interview-consistent-hashing/)

## Fanout Implementation

What's your thought for fanout implementation  - listen change stream + lambda  instead of a queue + consumer? consider you have high write throughput.
I wanted to understand the limitation of Lambda. I got the answer. Example, timeline update for follower in twitter system.
If you want to build listen change stream you need to use a queue internally + consumer.

## Lambda

I dont recommend lambda for low latency, HA and high throughput usecases. Lambda cold starts are pretty well knows time consumers and you'd have to account to the latency addition (sometimes in seconds).

[https://aws.amazon.com/blogs/compute/new-for-aws-lambda-predictable-start-up-times-with-provisioned-concurrency/](https://aws.amazon.com/blogs/compute/new-for-aws-lambda-predictable-start-up-times-with-provisioned-concurrency/)

You won't have cold start with Provisioned Concurrency. You are gonna pay for it and it's not cheap. basically what PC does is to warm up some additional containers (more containers, more $), ready to serve a request. also say you have 100 containers ready and you get a burst call of 101 requests which makes the last call a cold-start one.

### Other References

- [https://databricks.com/glossary/lambda-architecture](https://databricks.com/glossary/lambda-architecture)
- [https://en.wikipedia.org/wiki/Lambda_architecture](https://en.wikipedia.org/wiki/Lambda_architecture)

## Design Instagram vs Twitter

Can I say that system design for twitter vs instagram is the same except that twitter has 140 char limit?
Rest seems to be same. user posts txt, img & video. Fanout to followers with celebrity as special case. Read heavy.. say 10 times of write.. eventual consistency is fine.

- follow part is totaly different in twitter and insta
- Instagram should be media heavy than Twitter
- The way news feed is computed is totally different in both. The main idea of any news feed is fanout.

In write heavy scenario. if we have more reads that writes its better to spend more time in write to prerate data so that read will be cheaper.

## Kafka

It is worth noting that typically only one consumer within a consumer group is subscribed to a partition... [1] this is how Kafka achieves high message processing throughput. So, even in the case of multiple partitions, messages within a single partition are truly processed in the order they were sent.

Also worth noting is that partitions are specific to Kafka. For example, Google Cloud Pub/Sub doesn’t expose partitions to the user — they are there, but they are behind the scenes. [2].

In a systems design interview, it is sufficient to just talk about topics and subscribers. There is no need to go deeper than topics or to mention specific products. In fact, I am told by an insider that mentioning specific products is frowned upon at Google, which has its own version of all the open-source projects (and more).

[1] “Each partition is connected to at most one consumer from a group.” [https://blog.cloudera.com/scalability-of-kafka-messaging-using-consumer-groups/](https://blog.cloudera.com/scalability-of-kafka-messaging-using-consumer-groups/)

[2] “Partitions are not exposed to users.” [https://medium.com/google-cloud/google-cloud-pub-sub-ordered-delivery-1e4181f60bc8](https://medium.com/google-cloud/google-cloud-pub-sub-ordered-delivery-1e4181f60bc8)

- Confluent [Build Services on a Backbone of Events](https://www.confluent.io/blog/build-services-backbone-events/)
- Confluent [Apache Kafka Supports 200K Partitions Per Cluster](https://www.confluent.io/blog/apache-kafka-supports-200k-partitions-per-cluster/)
- [Kafka vs Redis Pub-Sub, Differences which you should know](https://blog.containerize.com/2021/04/09/kafka-vs-redis-pub-sub-differences-which-you-should-know/)
- YT - [Kafka: A Modern Distributed System](https://www.youtube.com/watch?v=Ea3aoACnbEk)

## Distributed Consensus

To get Redis to be fault tolerant for this use case, you need to give up the idea of a partially synchronous system, or you need to sync up state using transactions, or you need a Redis master node. Basically to have consistent state in Redis is difficult and to get it, you need to give up a lot.

So one answer is a distributed consensus algo, where at least the majority of nodes agree on state. This eliminates a lot of the problems and possible bottlenecks that Redis might have.

But Replicated State machines, configuration stores, leader election, distributed locking are all very good use cases for distribute consensus. Distributed concensus algos, in general, allow you to cheat some of the problems that "normal" concensus patterns might have.

There's no free lunch of course, these algos have serious problems with round trip times. and other concerns. It's not some magic solution.

If that data can't change, it reduces the complexity and need for these algos.

[https://sre.google/sre-book/managing-critical-state/](https://sre.google/sre-book/managing-critical-state/)

## Open Questions

- LLD design for Log4J library

## Really Random things

- [https://engineering.fb.com/2021/04/05/video-engineering/how-facebook-encodes-your-videos/](https://engineering.fb.com/2021/04/05/video-engineering/how-facebook-encodes-your-videos/)
- [https://blog.dream11engineering.com/building-scalable-real-time-analytics-alerting-and-anomaly-detection-architecture-at-dream11-e20edec91d33](https://blog.dream11engineering.com/building-scalable-real-time-analytics-alerting-and-anomaly-detection-architecture-at-dream11-e20edec91d33) - scaling for dimensionality, aggregated data, metrics after I collect the data. Collecting the data from devices. around 1.2 billions devices a day. Edge computing means at the device, some level of aggregations should happen and collect the data through HTTP through Kafka by topic
- [https://medium.com/@jadsarmo/why-we-chose-java-for-our-high-frequency-trading-application-600f7c04da94](https://medium.com/@jadsarmo/why-we-chose-java-for-our-high-frequency-trading-application-600f7c04da94)
- [https://netflixtechblog.com/how-netflix-uses-ebpf-flow-logs-at-scale-for-network-insight-e3ea997dca96](https://netflixtechblog.com/how-netflix-uses-ebpf-flow-logs-at-scale-for-network-insight-e3ea997dca96)
- Cloudflare [Cloudflare architecture and how BPF eats the world](https://blog.cloudflare.com/cloudflare-architecture-and-how-bpf-eats-the-world/) - incredible articles
  Cloudflare [CDN Caching](https://www.cloudflare.com/learning/cdn/caching-static-and-dynamic-content/) - Dynamic content is generated by scripts that change the content on a page. By running scripts in a CDN cache instead of in a distant origin server, dynamic content can be generated and delivered from a cache. Dynamic content is thus essentially "cached" and does not have to be served all the way from the origin, reducing the response time to client requests and speeding up dynamic webpages. Cloudflare Workers, for example, are serverless JavaScript functions that run on the Cloudflare CDN
- [A Closer Look At Etcd: The Brain Of A Kubernetes Cluster](https://betterprogramming.pub/a-closer-look-at-etcd-the-brain-of-a-kubernetes-cluster-788c8ea759a5)etcd will almost always be the bottleneck because everything is stored there by API Server
- AirBnb - [Avoiding Double Payments in a Distributed Payments System](https://medium.com/airbnb-engineering/avoiding-double-payments-in-a-distributed-payments-system-2981f6b070bb)
- [https://logz.io/blog/kafka-vs-redis/](https://logz.io/blog/kafka-vs-redis/)
  - [https://www.educba.com/redis-vs-kafka/](https://www.educba.com/redis-vs-kafka/)
- YT [Query Petabyte Scale Dataset on S3](https://www.youtube.com/watch?v=EO6KgpAOea4)
- YT [https://www.youtube.com/channel/UCZEfiXy7PmtVTezYUvc4zZw](https://www.youtube.com/channel/UCZEfiXy7PmtVTezYUvc4zZw) - 14 videos on this YouTube channel. This dude has nice videos, beginner friendly. The databases video summed it up pretty well, i would suggest it to beginners aswell who want a databases overview
- YT [MIT 6.824 Distributed Systems (Spring 2020)](https://youtube.com/playlist?list=PLrw6a1wE39_tb2fErI4-WkMbsvGQk9_UB)
- YT [Four Distributed Systems Architectural Patterns by Tim Berglund](https://www.youtube.com/watch?v=BO761Fj6HH8)
- YT [Designing Udemy's Taxonomy on SQL | System Design](https://youtu.be/4_jlmX_oB94)
- YT [Cancel token](https://youtu.be/H0pWdbbPH_U)
- YT - [Airbnb Search Architecture](https://www.youtube.com/watch?v=qeLekzZc3XU)
- YT - [Consistent Hashing Rajeev](https://youtu.be/QWeO2OB40VY) - Basically, nodes are arranged in a ring structure (not actually a ring but conceptually). Each node is responsible for keys hashed between it and its predecessor in the ring. Node placement has nothing to do with hash function used or how keys are hashed- instead it’s based on data, mostly to spread data evenly across all nodes. A virtual node placed in the ring structure would relieve load on its successor.
- YT - [why it is very hard to cancel an HTTP request](https://www.youtube.com/watch?v=WmPKzFYKijM)
- YT - [AWS re:Invent 2017: Architecting a data lake with Amazon S3, Amazon Kinesis, and Ama (ABD318)](https://www.youtube.com/watch?v=0vdW1ORLWyk) - Atlassian built a data lake from S3, Kinesis, Glue, and Athena
- YT - [Episode 109: eBay’s Architecture Principles with Randy Shoup](https://www.youtube.com/watch?v=OYY3XR2JT3o&ab_channel=ieeeComputerSociety) - a great podcast by Randy Shoup ( VP Engineering and Chief Architect  at Ebay) on ebay Architecture principles
- YT - [Streaming a Million Likes/Second: Real-Time Interactions on Live Video](https://youtu.be/yqc3PPmHvrA)
- YT - [Watermarks: Time and Progress in Apache Beam and Beyond](https://youtu.be/TWxSLmkWPm4) - about event time ordering
- [https://docs.microsoft.com/en-us/azure/architecture/best-practices/api-design](https://docs.microsoft.com/en-us/azure/architecture/best-practices/api-design) - references for API design best practices. Very comprehensive collection of best practices
  - [https://docs.microsoft.com/en-us/azure/architecture/patterns/index-patterns](https://docs.microsoft.com/en-us/azure/architecture/patterns/index-patterns)
- Java Prep
  - [https://docs.oracle.com/javase/tutorial/](https://docs.oracle.com/javase/tutorial/)
  - [https://github.com/javadroider/interview-prep/tree/master/interview](https://github.com/javadroider/interview-prep/tree/master/interview)
- [https://netflix.github.io/atlas-docs/overview/](https://netflix.github.io/atlas-docs/overview/)
- [https://leetcode.com/problems/flatten-a-multilevel-doubly-linked-list/](https://leetcode.com/problems/flatten-a-multilevel-doubly-linked-list/)
- [https://leetcode.com/problems/median-of-two-sorted-arrays/](https://leetcode.com/problems/median-of-two-sorted-arrays/) - pretty much needs a big trick/2 and even then the edge cases are hard to explain/code in the timeframe, esp without prev practice.
- U can share ur screen with [sketchboard.io](sketchboard.io) or digital pad+pencil works well with google jamboard. I simply share my screen on hangouts or zoom and diacuss on sketchboard.io
If thats not possible then macbook sidecar with ipad and using this i can write or draw on any digital whiteboard. I have tried with jamboard.
- DDIA Notes
  - [DDIA notes - keyvanakbary](https://github.com/keyvanakbary/learning-notes/blob/master/books/designing-data-intensive-applications.md)
  - [DDIA notes - ibillett](https://github.com/ibillett/designing-data-intensive-applications-notes)
  - [DDIA notes - xx](https://timilearning.com/posts/ddia/notes/)
  - [DDIA Chapter 1](https://comeshare.net/2020/04/02/designing-data-intensive-applications-chapter-1-reliable-scalable-and-maintainable-applications/)
- [https://chiragshah9696.medium.com/interviews-interviews-interviews-7407faf4c7cc](https://chiragshah9696.medium.com/interviews-interviews-interviews-7407faf4c7cc)
- [https://betterprogramming.pub/top-30-apple-coding-interview-questions-with-solutions-19990071ebfc](https://betterprogramming.pub/top-30-apple-coding-interview-questions-with-solutions-19990071ebfc)
- MongoDB
  - Reddit - [cons of mongodb](https://news.ycombinator.com/item?id=17497164)
  - [HSBC moves to MongoDB](https://diginomica.com/hsbc-moves-65-relational-databases-one-global-mongodb-database)
- end to end system design with data generation, data ingestion, data aggregation, and data representation
- XMPP is decentralized whereas WebSockets are centralized. XMPP works on the application layer whereas WebSockets are a transport protocol
- [https://aws.amazon.com/blogs/compute/using-amazon-api-gateway-as-a-proxy-for-dynamodb/](https://aws.amazon.com/blogs/compute/using-amazon-api-gateway-as-a-proxy-for-dynamodb/)
- Leaderboard - [Building real-time Leaderboard with Redis](https://medium.com/@sandeep4.verma/building-real-time-leaderboard-with-redis-82c98aa47b9f)
- [What Is Load Balancing? Types, Configurations, and Best Tools - DNSstuff](www.dnsstuff.com/what-is-server-load-balancing)
- Architecture blogs
  - Fraud Detection - at the simplest, it's just a stream of events and some query or model looking over the data
    - AWS [Architecture Overview - Fraud Detection Using Machine Learning](https://docs.aws.amazon.com/solutions/latest/fraud-detection-using-machine-learning/architecture.html)
    - [Real-time fraud detection - Azure Example Scenarios](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/data/fraud-detection)
  - [Developing a flash sale system | HackerNoon](https://hackernoon.com/developing-a-flash-sale-system-7481f6ede0a3)
  - News Feed Ranking
    - Meta [How machine learning powers Facebook’s News Feed ranking algorithm](https://engineering.fb.com/2021/01/26/ml-applications/news-feed-ranking/)
    - [How the Facebook Algorithm Works in 2023](https://blog.hootsuite.com/facebook-algorithm/)
- Stack Overflow [How did WhatsApp achieve 2 million connections per server?](https://stackoverflow.com/questions/22090229/how-did-whatsapp-achieve-2-million-connections-per-server)
  - Stack Overflow [Elasticsearch index sharding explanation](https://stackoverflow.com/questions/47003336/elasticsearch-index-sharding-explanation)
- [https://microservices.io/](https://microservices.io/)
- [http://distributedsystemscourse.com/](http://distributedsystemscourse.com/)
- Push notifications
  - [https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_background_updates_to_your_app](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_background_updates_to_your_app)
- Concurrency & Parallelsim
  - [Overview of Modern Concurrency and Parallelism Concepts](https://nikgrozev.com/2015/07/14/overview-of-modern-concurrency-and-parallelism-concepts/)
  - Educative [Multithreading](https://github.com/rahulgupta-rg/java-senior-interviews/blob/main/1_Introduction-combined.pdf) notes
  - [Introduction to Thread Pools in Java | Baeldung](https://www.baeldung.com/thread-pool-java-and-guava)
  - [Java Concurrency and Multithreading Tutorial](http://tutorials.jenkov.com/java-concurrency/index.html)
- REST vs RPC
  - [gRPC vs REST: Understanding gRPC, OpenAPI and REST and when to use them in API design | Google Cloud Blog](https://cloud.google.com/blog/products/api-management/understanding-grpc-openapi-and-rest-and-when-to-use-them)
  - YT [Distributed Systems lecture series](https://youtube.com/playlist?list=PLeKd45zvjcDFUEv_ohr_HdUFe97RItdiB)
- Coding / OO problems
  - [Design Tic Tac Toe](https://workat.tech/machine-coding/practice/design-tic-tac-toe-smyfi9x064ry) - establish a contract of a board that an implementer would fulfill
  - [Snake and Ladder](https://workat.tech/machine-coding/practice/snake-and-ladder-problem-zgtac9lxwntg)
  [HyperLogLog](https://en.wikipedia.org/wiki/HyperLogLog) - probabilistic data structure
  - [https://leetcode.com/problems/design-search-autocomplete-system/](https://leetcode.com/problems/design-search-autocomplete-system/)
  - [https://www.oodesign.com](https://www.oodesign.com)
  - [https://github.com/iluwatar/java-design-patterns](https://github.com/iluwatar/java-design-patterns)
- [Bloom Filter](https://pages.cs.wisc.edu/~cao/papers/summary-cache/node8.html)
  - Cassandra [Bloom Filters](https://cassandra.apache.org/doc/latest/cassandra/operating/bloom_filters.html)
  - [Ribbon Filter](https://engineering.fb.com/2021/07/09/data-infrastructure/ribbon-filter/)
- [https://serverfault.com/questions/238417/are-networks-now-faster-than-disks](https://serverfault.com/questions/238417/are-networks-now-faster-than-disks)
- [https://thenewstack.io/datadog-monitors-scalable-systems/](https://thenewstack.io/datadog-monitors-scalable-systems/)
- [Write a time-series database engine from scratch](https://nakabonne.dev/posts/write-tsdb-from-scratch/)
- Datadog [How to solve 5 Elasticsearch performance and scaling problems](https://www.datadoghq.com/blog/elasticsearch-performance-scaling-problems/)
- [Optimizing Flipkart’s Serviceability Data from 300 GB to 150 MB in-memory](https://blog.flipkart.tech/remodelling-flipkarts-serviceability-data-an-optimization-journey-from-300-gb-to-150-mb-in-memory-5c7e9c38bde)
- Leadership Principles [https://www.levels.fyi/blog/amazon-leadership-principles.html](https://www.levels.fyi/blog/amazon-leadership-principles.html)
  - YT - [Amazon Interrview Questions](https://www.youtube.com/playlist?list=PLLucmoeZjtMR990BPePcn5WgoCM_OX0YB) playlist
- [https://druid.apache.org/](https://druid.apache.org/)
- [https://linkerd.io/](https://linkerd.io/)
- [theoretical-maximum-number-of-open-tcp-connections-that-a-modern-linux](https://stackoverflow.com/questions/2332741/what-is-the-theoretical-maximum-number-of-open-tcp-connections-that-a-modern-lin)
- [Exclusive: a behind-the-scenes look at Facebook release engineering](https://arstechnica.com/information-technology/2012/04/exclusive-a-behind-the-scenes-look-at-facebook-release-engineering/) - explains a bit on how to copy 38 GB file located in US to all the 1000 Data Center located in China. All Data Center are loaded with work and using all bandwidth might affect the work. (BitTorrent like question)
- [Sky Computing, the Next Era After Cloud Computing](https://thenewstack.io/sky-computing-the-next-era-after-cloud-computing/)
- [Sequence Generation in Cloud Spanner](https://cloud.google.com/solutions/sequence-generation-in-cloud-spanner)
  - Stack Overflow [Distributed Sequence Number Generation](https://stackoverflow.com/questions/2671858/distributed-sequence-number-generation)
  - Redis [INCR](https://redis.io/commands/incr/)
