# Design an Alert System

Build an alert system in which there was a stream of orderEvents. The orderEvents had different statuses like places/picked/completed. After the order was placed the should create an alert if time period of P seconds had passed but the order was still not completed. P was Inputted into the system. (Saw this question in leetcode).
The ask of the problem is to send out alert when P seconds have passed after order was placed but we did not receive picked/completed event.

What is the problem? if order events are delivered to the same host (by hash of orderId), that means that all updates are also here.
so every time you have a start of the transaction - you put that to a structure something like indexed queue  with a time in future when we want alert to be triggered.
so next time you have or completed event - remove that from the ds or time passes (you have a job that runs every second) and take all the events that have ts > now.

Lets just say we have 100s of 1000s  of records which would need to deleted from the data store so that (ts > now) returns only the orders not yet completed...Wouldnt it be an overkill?
Somehow we are trying to make a stream driven events into a batch processing events.

On every second, if we see that timestamp of data events present in our ds is greater than current timestamp, we would need to send out alerts...We would also need to delete those records from our ds so that the same records are not included in the next second results....The number of records that need to be deleted could be huge

One way to think of this problem is to inject auxiliary checkpoint data events containing (orderId,  checkPointType) into the stream (after P seconds of order event being received)...In this way, on the consumer end once we receive this type of event, we can check if the order has been completed...If not, then we can send alerts pertaining to that order individually instead of batch processing of events

I would say that solution depends on order numbers. In simple case we just need a queue with message status. I mean message status shoud be Waiting during N seconds and became Ready after N seconds. The queue should let do deque only Ready messages. As soon as we deque we can check order status. I am sure that oracle queue have such possibility. I dont know if its possible to build something similar in kafka.i mean kafka does not support wait in queue until particular time point.  As far as i remember oracle creates a time based index in order to support this functionality. I am thinking about system design of such distributed queue which support message delay like oracle:" A message enqueued with delay set will be in the WAITING state, when the delay expires the messages goes to the READY state. DELAY processing requires the queue monitor to be started. Note that delay is set by the producer who enqueues the message. NO_DELAY : the message is available for immediate dequeuing".

But really in the context of an alert, latency lag doesn't matter. Really 100ms for something that is basically an async ping that says "hey something is up" is fine. That level of accuracy is probably not required, although you're correct to say that's a product requirement. The alerting stuff is usually best effort, and you don't need to be milisecond accurate. Even for tools like grafana, data dog, etc they are certainly not that accurate.

If you waited for P duration, where P is significantly greater than the miliseconds delay, it is usually not a problem.
