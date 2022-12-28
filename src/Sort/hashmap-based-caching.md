# HashMap based caching

Simple HashMap based caching in java.

I have 4 Maps where the data is stored and there are significantly more reads than writes. When there is an refresh from the db, all the maps are updated together and no read operation can be allowed during this time over any map as the data in one map is related to the other map. Read cannot be allowed during an inconsistent state.

What would be the best approach to do tackle this?

- Using simple HashMaps with ReadWriteLock or synchronisation when updating?
- Using ConcurrentHashMap?
- Using volatile maps?
- Fetching data in temporary mals and then assigning them when the slow db operations are done?
- How long does the refresh take?
- Is the read request sync or async?

Read can not be allowed..
What is the expected behavior if a read request happens during the reload? Block? Throw error?

Solution 1: Multi thread asynchronous processes for read write with thread safety.

Solution 2: I would go with last approach (fetching data in temp...), if additional memory is available for those 4 hash maps. You can have 2 sets of these 4 hash maps. Call the first set current set and second set staging set. When you have refresh event, update values in staging set hash maps. Once refresh work is over, Make staging set current set and and old current set as staging set. During this time, you can continue to serve read request from current set, while your refresh event is preparing staging set hash maps. This brings down bottle neck to one flip operation from current set to stage set.
