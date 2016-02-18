---
layout: post
title: The polar plot of sine
---

A couple weeks ago a [friend](http://dannybendavid.com) asked for intuition as to why the (polar) graph of \\(r = \\sin\\theta\\) is a circle.  It's a fairly easy fact to prove algebraically, but neither he nor I had any intuition as to why it should be true, nor did the internet come to our aid.  I thought about it for a bit and came up with an explanation, and since I couldn't find it anywhere online I'm posting it here in case it's of interest to anyone else.

First off, this is easy enough to do algebraically -- we have \\(x = r \\cos\\theta\\) and \\(y = r \\sin\\theta\\), so multiplying both sides of \\(r = \\sin\\theta\\) by \\(r\\) we get \\[x^2 + y^2 = r^2 = r \\sin\\theta = y.\\]  We just rearrange and complete the square to get \\[x^2 + \\left(y - \frac12\\right)^2 = \frac14,\\] i.e., a circle of radius \\(\\frac12\\) centered at \\(\\left(0, \\frac12\\right)\\).  (Note that this technically only proves that the graph lies entirely on the circle, not that it traces the whole circle, but that's mostly what we're interested in anyway.)

But the goal was intuition.  By plugging in a few numbers it's not too hard to find the points where \\(\\theta\\) is a multiple of \\(\\frac\\pi4\\) and see that they indeed lie on the correct circle, but that's nothing resembling a proof.  The key observation turned out to be drawing the line from the point \\((r, \\theta)\\) to the point where the circle meets the \\(y\\)-axis, or \\((1, 0)\\) in rectangular coordinates:

<iframe scrolling="no" src="https://www.geogebra.org/material/iframe/id/yqZMrWXI/width/500/height/400/border/eeeeee/rc/false/ai/false/sdz/false/smb/false/stb/false/stbh/true/ld/false/sri/false/at/auto" width="500px" height="400px" style="border:0px;"> </iframe>

From here it's pretty easy: the triangle is right because it's inscribed in a semicircle; then the two marked angles are equal (and the one at the origin is by definition \\(\\theta\\)).  Since the hypotenuse of the triangle has length \\(1\\), we can just use the definition of sine to get that the lower chord has length \\(\\sin\\theta\\) and thus the circle forms the graph we wanted.

*Thanks to [Danny Ben-David](http://dannybendavid.com) for posing the question and reading a draft of this post.*
