# Rate Limiting / Throttling

Specifically: denial of service attacks, overloading the system, attackers attempting to crack passwords

You can throttle (or rate-limit) by username, IP address, region, or even across the whole system, e.g. 10 RPS globally.

You can store rate-limiting info, e.g. the number of times a particular user has accessed a feature, in an in-memory database like Redis.

Rate-limiting can be done in a complex way: allow a user to access a service 0.5 s between requests but only 3x every 10 and only 10x in a single minute.

The response code for "too many requests" is 429.

Rate limiting is one aspect of throttling. The other is throughput limiting. For instance, your internet bandwidth FUP plans. Or your netflix subscription plans offering different video resolutions for different subscription fees

- [Throttling pattern - Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/patterns/throttling) - recommend this to complete newbie - nicely written and easy to understand (make sure to also check other links at end of this blog)
- [How Heroku added throttling](https://blog.heroku.com/rate-throttle-api-client)
- [https://github.com/zombocom/rate_throttle_client](https://github.com/zombocom/rate_throttle_client) - Very good implementation if you want to dig deep
- [Design and integration of rate limiter with gateway](https://konghq.com/blog/how-to-design-a-scalable-rate-limiting-algorithm/) - a very popular server side throttling pattern - gateways take the hit from user and do all throttling stuff so systems doing actual stuff don't have to worry about it
- [Throttling from scalability perspective](https://ably.com/blog/distributed-rate-limiting-scale-your-platform)
- [Sample implementation of Java client side throttling](https://java-design-patterns.com/patterns/throttling/) - this is popular where SDKs are provided to clients so that several checks like rate limiting can be done at client side
- [what-is-api-throttling-and-rate-limiting](https://www.beabetterdev.com/2020/12/12/what-is-api-throttling-and-rate-limiting/) - Another nice blog explaining how rate limiting can be handled at API header level
- [https://stripe.com/blog/rate-limiters](https://stripe.com/blog/rate-limiters)
- Cloudflare - [How we built rate limiting capable of scaling to millions of domains](https://blog.cloudflare.com/counting-things-a-lot-of-different-things/)
  - [AWS re:Invent 2018: Amazon DynamoDB Under the Hood: How We Built a Hyper-Scale Database (DAT321)](https://youtu.be/yvBR71D0nAQ)
- Figma - [An alternative approach to rate limiting](https://www.figma.com/blog/an-alternative-approach-to-rate-limiting/)
