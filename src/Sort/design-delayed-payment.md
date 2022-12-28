# Design a system for delayed payment

__Interview question__: Say that if you deposit a check, the check balance will be available after 2 days after deposit.

I'd just use priority queues instead of regular fifo for account update events. Prioritized by current time - update time. Partition by account. Each update needs to write to a quorom and have the same transaction id. That way each partition can try to update the account database independently but only the first with the Id is applied. Any fancier ways of doing this?

The question is more about how to persist the future events and how to trigger at a big scale. `Robinhood` has a similar question. `Stripe` onsite had also a question similar to this one. It's a pretty fun question, because you basically touch every aspect of a large scale system.

If you want to nail the question you have to go through how to design a scalable `Executor Service` and `Executor Resource` in the article. The article doesn't go through it. evens, queues, executors, data storage, resiliency, fault tolerance, it's just a starting point, but once you have those pieces you can easily break the problem down. The excecutor service is more accurately an `excecutor cluster`. Every company has a `job runner` team and setup. Every company needs to `push notifications` to users or services

There's really 3 large parts: `execution cluster`, `triggering/scheduling cluster`, and `notification clusters`:

- [https://slack.engineering/scaling-slacks-job-queue/](https://slack.engineering/scaling-slacks-job-queue/) - It looks like backpressure
- [https://databricks.com/session/optimal-strategies-for-large-scale-batch-etl-jobs](https://databricks.com/session/optimal-strategies-for-large-scale-batch-etl-jobs)
- [https://www.alibabacloud.com/blog/alibaba-core-scheduling-system-job-scheduler-2-0---meeting-big-data-and-cloud-computing-scheduling-challenges_596557](https://www.alibabacloud.com/blog/alibaba-core-scheduling-system-job-scheduler-2-0---meeting-big-data-and-cloud-computing-scheduling-challenges_596557)

Depositing a check is just "as fast as we can verify. The reason the bank takes 2 days to process isn't some artificial delay, there's compliance checks and various regulations banks need to adhere to. So in the processing of a check, it's more like a series of checkpoints and not some kind of delayed event trigger system. SAGA architecture would work well here, where each step is gated by a service and transaction, which can be event driven.

Actually the interviewer told me that they hold the check for 2 days, and release the fund even if the validation with the other bank is not completed, to make customer happy. I think this is how the banks work and thats how most of the check frauds happen in US. They credit the amount to the account and if one has transferred from that amount and the check is found to be bogus the account holder is liable. It not clear why we need 2 days for each transaction. May its just for some specific cases.

## References

- If we're looking for enterprise scale event triggering, [quartz scheduler](http://www.quartz-scheduler.org/overview/) is a well known solution
  - [https://medium.com/javarevisited/how-to-cluster-effectively-quartz-jobs-9b097f5e1191](https://medium.com/javarevisited/how-to-cluster-effectively-quartz-jobs-9b097f5e1191)
