---
layout: post
title: My summer at Khan Academy, part 1a of n
---

This summer I was a software intern at [Khan Academy](https://khanacademy.org).  I worked on the infrastructure team, which mostly meant working on performance tuning and dev tools.  This is the first of what I hope will be several posts about the various projects I worked on.  And this is really only the first half of this post -- a non-technical overview.  So stay tuned.

At the beginning of the summer, the Khan Academy website looked something like this:

![](/files/ka-before.svg)

Before I show you how it looks now, let me explain what's going on there a little.  (Of course, this is a somewhat simplified picture.)  Khan Academy runs on [Google App Engine](https://developers.google.com/appengine/), which is Google's flavor of platform-as-a-service.  Our site runs on hundreds of separate servers, each running the same (python) code, and Google's magic infrastructure sends every request made to the site to one of those.

At any given time, there are a number of different things happening on those servers.  In our simplified version, we've got:

* several users loading exercises, each of which triggers the recommender to figure out what problem we should recommend next,
* a user editing the content on the website, which itself takes a lot of server CPU time, and triggers a publish, which takes a lot more,
* a teacher loading their coach report, which for a large class can also be quite slow to generate,
* and all of the above happening in Spanish, Portuguese, and many other languages.

This means that every server we run has to run all different kinds of tasks: it has to be able to do both the heavy lifting for publishes and such and the lighter workloads of many of our other background processes, and tries to keep as much of our content in as many languages as possible within easy reach.

Luckily, there's a feature of App Engine called [modules](https://developers.google.com/appengine/docs/python/modules/) that makes this easier.  Basically, it means we can split our servers up into different groups that get different requests and can have different performance characteristics:

![](/files/ka-after-1.svg)

We can put all of the normal content on one module:

![](/files/ka-after-2.svg)

For many of our background tasks, we don't care exactly how fast they complete, so we can put them on smaller, cheaper servers that would be too slow for anything served directly to users:

![](/files/ka-after-3.svg)

For things like content publishing, coach reports, and slow dev-only APIs, we can use larger, more expensive servers:

![](/files/ka-after-4.svg)

And we can use a whole separate set of servers to serve the translated sites, so that the other servers don't have to think about translations:

![](/files/ka-after-5.svg)

Each of these modules has a separate set of performance settings that we can tune -- the size of servers to use, how quickly to start up more servers if load increases, and so on.

So that was my primary project this summer!  Some of the work had already been started, but I did a lot of work analyzing performance and cost data.  Combined with other infrastructure team work, we were able to significantly reduce our Google App Engine bill, and also improve performance.
