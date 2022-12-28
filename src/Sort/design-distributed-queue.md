# Design distributed queue

How would you design distributed queue that support one billion topics? I think its a good question because it shows if designer understands "limitations" and can orove that solution can support 1 billuon topics.

why is this a good interview question? seems like it would require very specific knowledge about kafka and how to scale kafka

We can not scale kafka for 1 billion topics. Kafka has a limitation because of controller. I mean one of kafka broker is a controller .this controller is responsible for assigment a leader for each partition. If that controller killed ( died) it will take a lot of time to recover from that in case of 1 billion topic/partitions. So kafka approach can not be used for 1 billion. There is an article that kafka can support up to 200k partitions only. So we need more scalable architecture.

kafka can do more than 200k partitions now, they removed zookeeper. it can do millions. but still not a great question because it assumes really deep knowledge of streaming system internals. this is like a question you'd ask someone who designs streaming services, like a core kafka contributor or something.

kafka does not keep offset in zookeper now. since ZK is needed to save state, it becomes the bottleneck in exchanging metadata, so by removing ZK, you remove the bottleneck to the traditionally held 200k partitions.

They were able to reach 200k because of async update of zk.  I mean it used to be sequentional before kafka 1.1.0. ZK is the problem, having this central bottleneck is not scalable. controller will not let scale well. Also kafka create many files for each topic. May be 5 files or something like this. We can not have 5 billion files

- [https://www.confluent.io/blog/kafka-without-zookeeper-a-sneak-peek/](https://www.confluent.io/blog/kafka-without-zookeeper-a-sneak-peek/)
- [https://www.confluent.io/blog/apache-kafka-supports-200k-partitions-per-cluster/](https://www.confluent.io/blog/apache-kafka-supports-200k-partitions-per-cluster/)
