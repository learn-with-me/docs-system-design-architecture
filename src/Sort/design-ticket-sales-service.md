# Design Ticket Sales service

Design ticket sales service where there is a spike of sales from time to time.

example cases:

- 90% of customers. small event happening in your city, selling 100 seats and usually around 100 person is interested in
- more difficult case to scale: Apple wants to use this service to sell tickets for their upcoming conference where there are 50k seats and 1M people are interested in buying
- another difficult case from business perspective: you have 50k seats, ~60k people are interested. why this is difficult case, lets assume you put everyone in FIFO queue and 10k people are waiting, 50k people started doing checkout process, but 10k of them couldn't finish on time and dropped from checkout (some didn't want, some didn't have enough money), in the meantime, in the waiting queue of 10k people, 5k left getting bored of waiting, now at most you have 45k people attending your event, from business perspective this is loss of profit, which should be minimized.

For the 10K waiting part of the problem, i wonder if they do some sort of overbooking similar to airlines. Using previous data you can figure out how many ppl you expect to drop out of the process, and oversell by that amount. Probably statisticians figure this out I guess.

Overbooking in airlines is possible because:

1. Seats aren't assigned at the time of booking -- applicable for a conference/ media event
2. There typically are other flights flying that route where you could adjust the overflow, and make alternative arrangements
3. Flights being a large scale operation, there's enough stats of passenger footfall and patterns available to model and optimize the overbooking factor.

If there's only 60k people interested in an event that has 50k capacity, it's highly unlikely that there will be a long queue.. unless there's a very small window of time when booking is open.

If you have 60k people interested in 50k event this already means there is small window of time for bookings. what I have seen in the past (my peers trying to attend some conferences) for some conferences people are restarting page constantly to start booking when booking window is open, because they will be sold quite fast.
If you give 10min for checkout process, this is quite long period, lots of people on waiting queue will leave, if you give 30sec then it might be quite small and a lot of people can't finish checkout

You will have deep queues if..

- theres a significantly large number of people interested in an event compared to the capacity.
- Or there's a modeet number of people strongly interested in the event.

My assumption in both cases is that you will not have a large number of drops. If people are so excited to get into an event that they will start queing at the first moment of booking opening, rest assured they will not drop out from a 10 minute waiting. From an engineer's stand point, there is still an opportunity for the underlying technology challenges to be discussed, regardless of whether the problem statement is real or hypothetical.

Send notification to all registered users after window period. Over charging user and refunding in case tickets were already sold.

> Seats allocation depends on how fast he/she will book.

I think this has 2 problems:

1. Unfair system, you can write bot who can buy all tickets because they can finish faster, in case of if we have queue, still bots can finish faster, but at least humans have chance based on their click of Book button earlier than some bots.
2. for 50k event with 60k interests, refunding might be ok, you don't get lots of complains on Twitter, imagine what happens with Apple conference, 950.000 people get refund and if 5% start complaining, you get network effect of complains and this hurts company image, so next time Apple won't be your customer

## Tokens Model

My thoughts regarding handling spike, I was initially thinking about `tokens` model. Overview of design:

- store 2 lists in redis for each event
  - List 1. token per available seat with TTL of time when event starts
  - List 2. tokens where currently someone finishing checkout
- when book clicked, take token from 1st list, put into other list and return token to user (pop from list and put into other is in transaction, using Lua)
- when purchase finished. client sends token (or it comes as part of payment provider webhook) token is stored in RDBMS (or any persistent storage), token is deleted from Redis (remember this, we will come back here)
- if purchase wasn't finished, for users who are still retrying backend takes token from 2nd list if time to finish checkout is expired, assign it to user and return to user, now user can do checkout

There are multiple issues with this solution.

- lets assume token is 24bytes, you have 100k events, on average offering 1k seats. on redis you will have 100M * 24 bytes of data, not much but still to keep in mind
- if redis crashes (case 1) you should have reliable way of regenerating all these tokens (or enable persistence for redis, get slightly slower performance), consider also what kind of issues might arise if you have enabled redis replication
- remember this part. if you have already noticed we are relying on payment provider to send us token so we can mark that token is taken, what if there are some issues happening on webhook part of payment provider? your tokens will be used multiple times, effectively selling 1M tickets, which are not available.

Not sure if this good solution, just borrowed some ideas from rate limiter, one big difference is rate limiter doesn't need to be accurate all the time, but in bookmyshow case we should be accurate as much as possible.
