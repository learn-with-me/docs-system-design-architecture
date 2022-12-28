# Design a Google Doc system

Designing a Google Doc system with focusing on searching through the Documents. It seems the interviewer was not happy with him choosing the ElasticSearch for indexing.

Elastic search might be an overkill. If you just need exact search, `inverted index` should be enough.

The interviewer does not wanted you to design the scalable inverted index itself. Spending time building a search engine from scratch is a separate interview. Maybe they wanted you to explain the pros and cons of different engine types.

Maybe ElasticSearch is too generic/easy for these types of questions and you kinda need to implement your own indexing architecture.

ES probably works fine for millions of documents but not hundreds of millions. So if you're looking for a solution for everyone at google scale, you probably need `map reduce` + `inverted index` generation. There are limits to what ES can do efficiently and it's not a universal solution.

Remember: A system design interview isn’t about giving a rote correct answer. It’s about showing your knowledge , discussing trade offs, explaining the why.

For timeline search i also used elastic search, i had follow up question on how u will be storing data and more. And feedback came as E4 may be because by using elastic search I abstracted details of how data is going be stored and scaling scenarios. But now I think I would have said inverted index, i would have given more details by myself to interviewer than he asking me, which might would have lead to different results.
You can say elastic search as long as you explain how it works. How it stores data. Common issues with the design decisions ES might have made. Etc. You can name drop an existing project as long as you can explain the ins and outs and pitfalls of it. You cant just say elastic search and move on without details as if it’s a quiz about who can name the most technologies to solve this design puzzle.

Instagram initially had Elastisearch and then they moved to FB [Unicorn](https://research.facebook.com/publications/unicorn-a-system-for-searching-the-social-graph/).
