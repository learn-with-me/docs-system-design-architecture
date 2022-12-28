# Design a Stock Exchange

Price of security can change every microsecond or nano second, technically it's not bound to time, but bid/offer match. And so the trigger not bounded to time if price reaches/crosses the threshold, action should be taken.

When price change, we can create an event that will take action on gtt priority queue similar to bid and offer priority queues. Also the price change is dependent on bid and offer match events.

And we can not have delay for triggering order as small delay can cause order not getting executed later (on same price there could be millions orders), orders on same price follow fifo)

If we have a requirement that latency should as fast as possible, we can do the following:

1. have a server that subscribes to the real time market data
2. on this server have some number of such rules and also have a subscription for updates of such rules
3. in this server for each symbol have a RB Tree of <Long, List<OrderId>>
4. when the update comes to the system, check the head of this rb tree, remove orderIds that is less that current price send those orderIds to the execution

- YT [Stock Exchange System Design](https://youtu.be/dUMWMZmMsVE)
  - YT [How to Build an Exchange](https://youtu.be/b1e4t2k2KJY)
- YT - [Building Low Latency Trading Systems](https://www.youtube.com/watch?v=yBNpSqOOoRk)
- T - [Event Sourcing & CQRS | Stock Exchange Microservices Architecture | System Design Primer](https://www.youtube.com/watch?v=E-7TBZxmkXE)

## Side Thoughts

i don't think that any real stock exchange system uses an ACID database (to register orders), Kafka( as a service bus), because of not an appropriate performance for this case. I hear that [KDB](https://en.wikipedia.org/wiki/Kdb%2B ) and [Aaron](https://github.com/real-logic/aeron)  are used by the real stock exchange system. Regarding performance requirements - "At the turn of the 21st century, HFT trades had an execution time of several seconds, whereas by 2010 this had decreased to milli- and even microseconds". So we need to have microseconds for end-to-end latency.

- [Zerodha](https://zerodha.tech/blog/hello-world/) - Zerodha's scale and tech stack. He kind of left in middle and didn't share exact tech used to handle ~16mn ticks/sec
