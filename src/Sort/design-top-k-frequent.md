# Design top k frequent

Design a service that would give top K most frequent results where the input is an unbounded data stream. Some options:

1. LB partitions the input stream accoss multiple minheap service. The Read API service will ask the top K from each minheap service, merge and return the result.
Drawback: storage issue in minheap service, how long to retain the data as the input is infinite.

2. log all the incoming request across different partitions, run MAP-Reduce jobs and then return the top K results
Drawback: Map-Reduce is batch jobs. won't get real-time results

3. using some probabilistic DS like count min sketch to get the real-time approximate top K results and combine with option#2 to get more accurate top K results over a longer period.

Standard answer is lambda architecture.
The real world answer is use a `stream processing framework` like Spark or Flink. But basically some combination of all those options are needed. Modern stream processing frameworks can actually do map reduce size jobs in addition to short term calculations.

I dont think that "standard" minHeap will work in option 1, as the K is unknown it could be 5min or 5 days. You need to put pair (word, 1) if its absent and you need to increase frequence if its already there. But if you have such not standard Heap you need to keep TopK for thrumbling windows. Spark streaming will submit a new job for each window. I mean it will batch messages and submit a new job to process each micro batch

Definitely there will be an upper bound. let say 1K ? Any major design consideration?
In сase of 1k system can keeps data in memory.if we have 1 billion.... its another case

Stay away from heap type implementations, it's problematic for a large variety of reasons. The heap data structure isn't really designed for range queries. Also scaling it out to many instances has issues.

So for TopK. i would propose: kafka + spark streaming + keep intermediate results in database ( partition by time) + service which can merge result for different windows (it produces result for range query). Not sure about sharding.

I was thinking along the lines of using redis. Processing the incoming data and updating sorted list in redis. Data could be shared based on hash of the word or range. To get top k elements, top k elements from all redis instances could be picked and then merged to return the overall top k.
The issue is the immense amount of requests need to materialize a single request. It's not very efficient. Also, most top k require some time function, so top k within 5 min, top k within 15 min, top k per hour, etc. So redis will not be able to easily handle top k over time.
One solution is use a MQ like Kafka and feed the data to some Map Reduce functions which would give results in few hours. But if you want information in few minutes use count Min sketch algorithm. The problem with Min Sketch algorithm is you won’t get accurate results. If you want more accurate results  use more Hash functions

Remote Discover Server is a no-Sql (KV) in memory database. Again Through put is the key here. if during the interview, this term comes up or asked as one of the requirement, Kafka is the way. speed is different and trhoughput is different. Play accordingly.  quick read [here](https://tianpan.co/notes/61-what-is-apache-kafka)

This is usually called [lambda architecture](https://en.wikipedia.org/wiki/Lambda_architecture)

Most of those ideas were lifted from [this video](https://www.youtube.com/watch?v=kx-XDoPjoHw&t=1242s).

Btw this double system is actually mostly dead in the real world. Everyone just uses Flink or Spark. Most stream processing systems can take the place of map reduce now.

It's like the question "design typeahead". No one uses Trie, but it's totally accepted.

## Count Min Sketch

How Count Min Sketch will help? if we have upper bound limit 1K we don't need probabilistic structures at all. i mean we will have to use count min sketch in the tumbling windows. Lets say our key is consume 1000 bytes. So we just need 1000*1000*8 (size of key \* number of keys \* size of value) to keep our structure in memory.

What about size of Count Min Sketch for 1K?

## Searching & Auto-complete

When i type "obama barack" in youtube search they allso suggest "barack obama singing"  not "obama barack singing".

youtube most likely uses ML learning and other complex tools, not ES. So that's a very different system serving results. All the search engines from google use some complex model.

What do you think about Trie + Inverted Index for interview ? I mean to propouse use union of Trie + Inverted index

i will build Inverted Index only for whole word. i mean that it will keep relation between word and sentences: word -> [sentence1,sentences2,sentence3..] . so if i have a string s1 . i will take a Trie.get(s1) + InvertedIndex.get(s1). Most likely it will return something form Trie for any s1 and it will return from InvertedIndex only if s1 is a word.

Why? We get basically nothing out of that other than a more complex design that can do less for us. Now we need to handle trie construction AND inverted re-indexing. Now we need to keep them in sync. As a general rule of thumb, keep things simple, then optimize.

ES can do everything a Trie can do, and more. Plus it handles concerns like sharding, scalability, data integrity and supports complex query operations, all things we would need to implement for a Trie.

ES even has built-in prefix query support. You don't even need to generate it yourself.
[https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-prefix-query.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-prefix-query.html)

Mixing ES and Tries is just no good.

## Other References

- YT [System Design : Top 10 Songs, Top Trending songs, Top K listed](https://youtu.be/CA-ei3mOCf4)
- Google: min sketch algorithms
