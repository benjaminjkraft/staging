---
layout: post
title: Five Minutes of Make
---

If you've ever compiled a large software project, you've probably used [`make`](https://www.gnu.org/software/make/).  If you're like me, you probably think that `make` is some arcane tool that only fifty-year-olds with giant beards know how to use.  This summer, I learned I was totally wrong, and `make` is actually really simple and really useful.  I'm still not an expert, but all of the tutorials I could find online would have taken me five hours, and I think knowing five minutes[^firestorm] of `make` now is way more useful than knowing five hours of `make` "someday".

[^firestorm]: I originally taught the above in exactly five minutes (enforced by boffer swords and pool noodles) for [MIT ESP](https://esp.mit.edu)'s Firestorm, where we teach 5-minute classes on all manner of topics to MIT freshmen.

As an example, we'll write a simple `Makefile` for a hypothetical site using [Jekyll](//jekyllrb.com).  In the project root, make a new file called `Makefile`, and put the following[^watch] in it:

[^watch]: Those who have used Jekyll may notice that we could have just run `jekyll build --watch` once and been done.  For the sake of the tutorial, pretend that that isn't possible -- it certainly doesn't support all of the things we'll be doing.

{% highlight make %}
build:
  jekyll build
{% endhighlight %}

Now to build, just run `make build`.  Now let's say that we add a Javascript file `some-js.js`, and we want to use [`browserify`](http://browserify.org/) to build it.  We just add another rule:

{% highlight make %}
scripts:
  mkdir -p js
  browserify some-js.js -o js/bundle.js
{% endhighlight %}

Now `make scripts` will build our Javascript and stick it in `js/bundle.js`.  Except now we have a problem: we need to run two commands, `make scripts` and `make build`, whenever we update things.  That's silly, and `make` has a solution.  We just tell it that in order to `make build` it had better `make scripts` first, by modifying the first rule to read:

{% highlight make %}
build: scripts
  jekyll build
{% endhighlight %}

This, though, has the disadvantage that we always have to recompile the Javascript even if we didn't modify it.  Here's where `make` really shines: instead of calling our `make` target `scripts`, we just name it after the file that's generated, and put the Javascript source file as a dependency.

{% highlight make %}
build: js/bundle.js
  jekyll build

js/bundle.js: some-js.js
  mkdir -p js
  browserify some-js.js -o js/bundle.js
{% endhighlight %}

Now the Javascript bundle will only get updated when it needs to be.  Lastly, to be safe, we should tell make that `build` is *not* an actual file, and therefore it need not check for a file of that name.  We do this with the fake target `.PHONY`:

{% highlight make %}
.PHONY: build
{% endhighlight %}

Lastly, `make` has variables that work somewhat similarly to shell variables.  This is useful to make it easy to add more build dependencies.  We use them like this:

{% highlight make %}
JSFILES=some-js.js some-more-js.js

js/bundle.js: $(JSFILES)
  mkdir -p js
  browserify $(JSFILES) -o bundle.js
{% endhighlight %}

Now if we add another javascript file to be compiled, we don't need to list it separately.  So here's our complete `Makefile`:

{% highlight make %}
JSFILES=some-js.js some-more-js.js

build: js/bundle.js
  jekyll build

js/bundle.js: $(JSFILES)
  mkdir -p js
  browserify $(JSFILES) -o bundle.js

.PHONY: build
{% endhighlight %}

There's a lot more to learn about `make`: there are default rules that, for example, let one specify that all files of a particular extension should be treated the same way, and various other useful macros, but hopefully this is enough to be useful and enough to learn more.
