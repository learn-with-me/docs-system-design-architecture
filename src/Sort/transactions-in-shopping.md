# Transactions in Shopping

How would you solve a problem where you have a highly distributed system like Amazon and you need to implement shopping cart and ensure that ( ie if one item left in inventory) two or more users can't add that item to the cart? Let's say first user adds the item and gets a ten minute lock on it or else it's relinquished.

At first I'm thinking sql for atomic transactions and not allowing inventory count to go zero, but I feel the sql database may be a bottle neck at Amazon scale. Would nosql be the way to go? If so, how do you guarantee strong consistency of adding to cart in relation to inventory?
And I feel sql db will not scale because single write db would be a bottleneck.  Even if sharding by product ID or something like that, then you have to consider regions globally too.

Inventory count varies from regions, locations.

I think we should still allow users to place order, and the order processing system should fulfill order based on order placement time. And later the other user can be communicated about the lack of inventory and initiate the refund. It happened to me few times in amazon shopping. This depends on scale and it is very subjective. Discuss both options with the interviewer.

No SQL is a better approach. And rater than blocking allow users to add it to their cart and checkout. During payment, the first payment that succeeds gets the item, for rest we can issue a refund within next 2 minutes. At the payment page it acquires the lock for X mins and if payment fails or user haven't placed then the Thread lock will be released. If so we are dealing with at most once semantics in near real time and exactly once after some drift, it becomes a slightly simpler problem.

How do you implement the locking on inventory in distributed nosql? You should ask for read modify write type of support from systems. I.e don't take the data in memory (`Google photon` paper mentions it very briefly) and modify it and then write again. That's suboptimal strategy. If your db support read modify write pattern the computation happens in node itself. The challenge you'll run into if you go for non quorum based consistency. So each node has a different count now under network partitioning.

Well also need cleanup strategy for this which can happen at a later time. So the way it works a) increment-state-if(0) b) after puchase complete increment-state-if(1). System has a background job to cleanup if client crashed. You can optimize it by asking client to register some call-back for health checks.

How do you implement the locking on inventory in distributed nosql?
We won't need db transactions if we use optimistic locks.

`Optimistic locking` is just versioning. Not like we have an exclusive lock. On write, you check the version number you got on the read still the same. So you can have many people read (as is our use case) but only one guy will succeed in writing. So, no extra headers of traditional locking.

- YT [Transactions Internal implementation write ahead log and locks with banking examples](https://youtu.be/DR7j8b9LIhE)
