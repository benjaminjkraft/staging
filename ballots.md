---
layout: default
---

<h1>Ballots</h1>

For a few years now I've been writing an informal voter guide for some friends. It's basically a byproduct of my own decision process: I need to figure out how to vote, and I may as well tell you. I'm now publishing it for anyone who finds it helpful.

<ul>
{% for post in site.ballot reversed %}
  <li><a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>
