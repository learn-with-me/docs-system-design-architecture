# System Design Template

1. API for client, Synchronous vs async, concurrent or chunks, push or pull, back pressure
2. Queues – if client offline or for async operation or pub-sub (1:N, N:1, N:M)
3. App server - ?
4. DB/Storage – Schema, Consistency, RDMBS vs Wide col vs KeyVal vs ObjStore vs HDFS, write heavy
5. Scaling
  a. Load balancer w/secondary and sticky sessions
  b. Sharding
  c. Caching for CDN or DB or App along with LRU, consistent hashing and sync with primary DB
  d. multiple app servers
  e. Deprioritize some msgs during major known events like new year
6. Fault tolerance – Replication, monitoring, hot vs cold standby
7. clients - encryption, heartbeats

The challenge is knowing what areas to focus on in 40 minutes.

> Once you have a decent baseline and backing, you can end up in a too detailed design or too detailed world. Don't over do this part of preparation.

## Think about

Can you take a vague goal (”design Twitter”) and come up with a fully-developed proposal? Are you able to spot ambiguities in the requirements and ask good clarifying questions? Are you able to distinguish between features that really need to go into the MVP versus ones that are really extended/optional features that can be punted?

Do you proactively look for issues with your design, or do you need prodding from the interviewer?

Are you able to assess different options and make trade-offs, or are you attached to certain ways of doing things?

Do you have a good sense of what to prioritize, or do you get lost in the weeds?

Are you able to produce an actual deliverable within the timeframe you are given? Does your design meet all functional and non-functional requirements? In particular, does it scale? While you are not expected to produce an industry-grade design in 45 minutes ー this would be quite unreasonable to ask ー what you produce should be something that can be turned over to a product team for implementation.

Are you able to achieve the basic requirements quickly so that you have time to extend your design in an interesting way?

Are you able to use speech, notes, and diagrams to communicate your ideas clearly to someone else? Are you able to take feedback?

## Example writeup from someone

The MVP

The first order of business in a systems design interview is to achieve the functional requirements. This typically entails designing the API and the data model. Many interviewees insist on starting out with an MVP, but in the interest of speed, I would not literally build an MVP because, as a senior engineer, there is minimal signal to be communicated to the interviewer by doing so. If you spend too much time designing an MVP, you may not have enough time to completely scale out your design and inadvertently communicate that you’re more of an L4 as opposed to an L5/L6.

For example, if it is clear you will need a WebSockets endpoint, skip past the GET and POST endpoints and go straight to the WebSockets endpoint. If desired, you can use the time you saved to sketch out event dispatch code for your WebSockets endpoint, which will show that you really do know what you’re doing. And if you think you will eventually use NoSQL in your scaled-out design, feel free to skip past SQL and go straight there.

The case for starting with NoSQL from the beginning is actually stronger than ever. For example, not only does DynamoDB support tabular data, but as of 2018, it supports ACID, including strong consistency and serializable transactions. As you start to scale your system, many of the advantages of starting with SQL become moot because you end up having to denormalize and shard your data anyway.

Perhaps more importantly, data model design for SQL and NoSQL are different, so you actually do have to make this choice before designing your data model. For SQL, data model design is mostly about entities, constraints, and relationships. For NoSQL, it is about denormalization, partition keys, range keys, and secondary indices. In my experience, candidates rarely attempt a NoSQL data model, so not only would you be giving yourself a head start in scaling out your system by using NoSQL from the beginning, but you would also stand out from the other candidates.

After you’re done, make sure to go through all functional requirements and explain how they are achieved by your API and data model. This helps you find things you may have missed and helps the interviewer reach the conclusion that you are truly done with this phase.

Scaling Your Design

Next is scaling your design, that is, enhancing it so that it provides a good experience for millions of simultaneous users.

Working with a diagram as you iterate on your design slows you down significantly. If it is asked of you, push off drawing the diagram until after you have fully designed the system. Only draw along the way if the interviewer is having trouble following along with you, and even then, only sketch the bare minimum needed to convey your ideas. What you should attempt to deliver instead of a diagram is a bulleted list of notes for each component.

You can further increase your speed by offloading most of the work to speech. As you’re thinking through the different possibilities for each decision point, simply articulate them verbally as opposed to writing them down. Make sure to check in with the interviewer after each point to ensure they are truly following along. Only jot things down once you have finalized a particular aspect of your design. By using a combination of speech, notes, and diagrams, you can complete a scaled-out design in only 20 minutes, leaving you plenty of time remaining for you to showcase advanced systems design capabilities.

After you’re done with your design, go through all the non-functional requirements and explain how your design delivers on them. In addition to helping you to identify when you have missed something, this final step leaves no doubt in your interviewer’s mind that you have achieved all requirements before you move on to extending your design and shooting for that higher level.

Above and Beyond

Unlike other candidates, at this point, you’ve got a solid 20 minutes left to... just play. Starting logging things to a distributed file system. Push that data through a MapReduce pipeline. Throw in a peer-to-peer protocol (”Let’s say things have really gone south (haha) with North Korea, and they’ve used their ICBMs to take out all AWS data centers....”). Maybe you can use a blockchain or zero-knowledge protocol somehow. This is your time to really show off, and yes, be a little bit silly.

## Rubric

[How to Succeed in a System Design Interview](https://blog.pramp.com/how-to-succeed-in-a-system-design-interview-27b35de0df26)

## Other References

- Go through system design primer -> Grokking -> YT
  - Donne Martin - [System Design Primer](https://github.com/donnemartin/system-design-primer?trk=public_post_comment-text)
  - [Low Level Design primer](https://github.com/prasadgujar/low-level-design-primer/blob/master/solutions.md)
  - [Notion - SDI](https://www.notion.so/System-Design-Interview-42ba04ec67a9413fadad5b718fbd3e81) notes
  - [https://divyanshu-vibhu.gitbook.io/system-design/](https://divyanshu-vibhu.gitbook.io/system-design/)
  - [https://www.linkedin.com/posts/aditya-malshikhare_system-design-basics-handbook-ugcPost-6801799624563814400-jtT6](https://www.linkedin.com/posts/aditya-malshikhare_system-design-basics-handbook-ugcPost-6801799624563814400-jtT6)
  - [System Design Master doc](https://drive.google.com/file/d/16wtG6ZsThlu_YkloeyX8pp2OEjVebure/view)
  - [The Bible of Distributed System Design Interviews](https://www.thinksoftwarelearning.com/courses/SystemDesignBible)
- Reddit [System Design Framework](https://www.reddit.com/r/cscareerquestions/comments/kd13sx/sharing_the_system_design_framework_ive_used_that/)
  - [https://www.lewis-lin.com/blog/pedals-method](https://www.lewis-lin.com/blog/pedals-method)
- Example - [Design campaign to collect donations](https://excalidraw.com/#room=b7ee44759dcc9ba29156,nzgKYEVNtVCaP3CGHsGGUQ)
- [Distributed Scheduler](https://sre.google/sre-book/distributed-periodic-scheduling/) SRE book
  - [LeetCode](https://leetcode.com/discuss/general-discussion/1082786/System-Design%3A-Designing-a-distributed-Job-Scheduler-or-Many-interesting-concepts-to-learn)
- YT [System Design Interview](https://www.youtube.com/channel/UC9vLsnF6QPYuH51njmIooCQ) channel
- YT [Gaurav Sen series](https://youtube.com/playlist?list=PLMCXHnjXnTnvo6alSjVkgxV-VH6EPyvoX)
- YT [Notification Service System Design Interview Question to handle Billions of users & Notifications](https://www.youtube.com/watch?v=CUwt9_l0DOg)
- YT [David Malans cs75 scalability](https://youtu.be/-W9F__D3oY4)
- YT [david huffman's talk, scaling up talk](https://youtu.be/pjNTgULVVf4)
- YT - [Zoom System Design | WhatsApp / FB Video Calling System Design](https://youtu.be/G32ThJakeHk)
- [Scalability for dummies](https://www.lecloud.net/tagged/scalability)
- [Designing data intensive appliations](https://dataintensive.net/)
- [https://blog.interviewcamp.io/live-capacity-estimation-caching-levels/](https://blog.interviewcamp.io/live-capacity-estimation-caching-levels/)
- [How Facebook Live Streams to 800,000 Simultaneous Viewers - High Scalability](http://highscalability.com/blog/2016/6/27/how-facebook-live-streams-to-800000-simultaneous-viewers.html)
- [Facebook system design interview: 4 must watched videos](https://mlengineer.io/facebook-system-design-interview-4-must-watched-videos-212e07d4fbc2)
  - YT [Scaling Instagram Infrastructure](https://youtu.be/hnpzNAPiC0E)
  - YT [Scaling Live videos to billions of users](https://youtu.be/IO4teCbHvZw)
  - YT [Live commenting at facebook](https://youtu.be/ODkEWsO5I30)
  - YT [TAO: Facebook distributed data store for social graph](https://youtu.be/sNIvHttFjdI)
- YT Channels
  - YT [Defog Tech](https://www.youtube.com/c/DefogTech)
  - YT [Udit Agarwal](https://www.youtube.com/user/UDIT19911)
- GitHub
  - GitHub [System Architect Cheatsheet](https://github.com/NikAshanin/Software-Architect-Cheat-Sheet)
  - GitHub [Awesome CTO](https://github.com/kuchin/awesome-cto)
  - GitHub [Interview](https://github.com/Olshansk/interview) prep
- GitHub Designs
  - GitHub [Design KV Store](https://github.com/talent-plan/tinykv) course
  - GitHub [Mobile System design](https://github.com/weeeBox/mobile-system-design)
- [How to Use Consistent Hashing in a System Design Interview?](https://medium.com/codex/how-to-use-consistent-hashing-in-a-system-design-interview-b738be3a1ae3) - In a distributed system, any server responsible for a huge partition of data can become a bottleneck for the system. To handle these issues, Consistent Hashing introduces a new scheme of distributing the tokens to physical nodes. Instead of assigning a single token to a node, the hash range is divided into multiple smaller ranges, and each physical node is assigned several of these smaller ranges. Each of these subranges is considered a Vnode. Vnodes are randomly distributed across the cluster and are generally non-contiguous so that no two neighboring Vnodes are assigned to the same physical node or rack.
- [How we rebuilt the Walmart Autocomplete Backend](https://medium.com/walmartglobaltech/how-we-rebuilt-the-walmart-autocomplete-backend-10efe71d624a)
