# Design an application

Design a basic architecture design for an application which can

1. downloads instagram posts
2. store in a database ( fields like post url, timestamp, likes)
3. show them in a web app to user

All sync apis. Have to download whole instagram timeline for a given user. Assume an api already exists, which gives batches of images.

Proposed to have a microservice which downloads the posts backed by mongodb or ddb. Have a graphql layer to show those posts and have them filter over a web app.

Take a look how twitter designed their app. the point that is that the feed usually has to be precomputed already in a majority of case. Celebrities has a different access pattern.

I would not think of Mongo or even a no-sql to begin with. I'd gather more requirements first and build a system that scales 3-5x of that. Think of scrapers, caching, DNS load balancing, parse bots, storage. When it gets to fast read write stores, the discussion moves ahead.

> Sounds like a crawler

There is just an additional component to show downloaded content to a user. As i understan the application have to download all  posts which were created before today. As for me the main question here is how to find out next post and how to parallelize it.