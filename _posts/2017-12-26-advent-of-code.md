---
layout: post
title: Advent of Code in 25 Languages
---

This year, I did [Advent of Code](https://adventofcode.com/)'s 25 daily Christmas-themed programming puzzles, in a different language every day.  It was a lot of fun!  You can see my solutions [on GitHub](https://github.com/benjaminjkraft/aoc2017/), or read on for (less spoilerful) thoughts on the languages I used.

Without further ado, the languages:

1. [Bash](http://tldp.org/LDP/abs/html/)
2. [J](http://www.jsoftware.com/)
3. [C](https://en.wikipedia.org/wiki/C_(programming_language))
4. [Logo (UCBLogo)](https://people.eecs.berkeley.edu/~bh/docs/html/usermanual.html)
5. [C++](https://en.wikipedia.org/wiki/C%2B%2B)
6. [Java](https://docs.oracle.com/javase/9/)
7. [Perl 5](https://www.perl.org/)
8. [Sed](http://www.grymoire.com/Unix/Sed.html)
9. [Vimscript](http://learnvimscriptthehardway.stevelosh.com/)
10. [Kotlin](https://kotlinlang.org/)
11. (Google) Spreadsheet [formulas](https://support.google.com/docs/table/25273?hl=en)
12. [Scala](https://www.scala-lang.org/)
13. [Clojure](https://clojure.org/)
14. [OCaml](https://ocaml.org/)
15. [Factor](http://factorcode.org/)
16. [R](https://www.r-project.org/)
17. [Crystal](https://crystal-lang.org/)
18. [PHP](https://secure.php.net/)
19. [Go](https://golang.org/)
20. [Rust](https://www.rust-lang.org/en-US/)
21. [Haskell](https://www.haskell.org/)
22. [Ruby](https://www.ruby-lang.org/en/)
23. Pencil and paper and a bit of [Mathematica](https://www.wolfram.com/mathematica/)
24. [JavaScript (ES6ish)](https://www.destroyallsoftware.com/talks/wat)
25. [Python 3](https://www.python.org/)

## General thoughts

Trying out a lot of languages quickly was a lot of fun!  I didn't really *learn* the languages I didn't already know, but I at least got a quick feel for most of them.  And it reminded me of just how much fun using different tools can be -- I had a blast with Clojure despite little desire to use it for large, serious projects.

Seeing so many languages so fast was a great reminder of just what is out there beyond the languages I use or even would seriously consider using for work.  And those differences aren't just between the typical categories of functional and imperative, or higher and lower level.  In some of those cases you can see the flow of ideas -- from Python to Go, for example.  And some ideas have come in over time -- the default semantics around imports and namespacing seems to be a great way to date a language, in that Clojure has more in common with Python than with almost any other functional language.

The role of language *design* in how a language feels was also clear.  I found the cleanly designed languages -- Clojure, Go, and Python most clearly, and to a lesser extent Kotlin, Ruby/Crystal, and Rust -- a lot easier and more fun to use than their less consistent counterparts like OCaml, R, and PHP.  Just having consistent APIs, whether formally as interfaces/typeclasses/overloading or just simply as consistently laid-out modules, is a huge first step.

I don't think I'll do it again -- suggestions welcome for next year's Fun Constraint -- but it was definitely a lot of fun.

## Sed

Ok, let's get it out of the way.  I did [day 8](https://github.com/benjaminjkraft/aoc2017/blob/master/day08.sed) using only `sed`.  Not shell scripting and grep and other utils -- that was [day 1](https://github.com/benjaminjkraft/aoc2017/blob/master/day01.sh) -- but rather a single sed script, run with `#!/bin/sed -nf` which output the answers.

The first thing to know is that yes, `sed` is easily Turing-complete: it has `GOTO`[^goto], `if`[^if], and of course `s`[^s], and you're off to the races.  There's a nice [blog post](http://www.catonmat.net/blog/proof-that-sed-is-turing-complete/) with a more formal proof, and [several](https://github.com/stedolan/bf.sed) [BF](https://github.com/svbatalov/bf.sed) [interpreters](https://github.com/izabera/bfsed) for a more hands-on proof.

[^goto]: `b label` jumps to an earlier `:label`.
[^if]: `/foo/ { ... }` executes the commands in the braces only if the regex `foo` matches.
[^s]: `s/foo/bar/g` replaces all the occurrences of the regex `foo` with `bar`.  Of course, with backreferences, this is much more powerful than your [theory](https://en.wikipedia.org/wiki/Regular_expression#Expressive_power_and_compactness) might lead you to expect.

But as anyone who's tried to write a turing machine by hand knows, Turing-complete doesn't mean practical.  The first problem, in this case, is that `sed` doesn't have any arithmetic built in.  I ended up working in unary, using tally marks, so `||||` is \\(4\\), and `-----` is \\(-5\\).  (Converting to and from the decimal inputs is left as an exercise to the reader, or you can find it at the [start](https://github.com/benjaminjkraft/aoc2017/blob/master/day08.sed#L24) and [end](https://github.com/benjaminjkraft/aoc2017/blob/master/day08.sed#L174) of my solution.)  In hindsight, I think the slightly greater effort involved in implementing (much faster) decimal arithmetic might have been worthwhile, but that will have to wait for a future project.

The second problem is that it's pretty slow -- you have only two string buffers (the pattern space and the hold space) and nearly anything you do will scan one of them.[^scan]  When you're representing a few dozen 4-digit numbers in unary, this gets slow fast.  The first two problems I tried to do were easier to implement, but just too slow to run.  [Day 5](https://github.com/benjaminjkraft/aoc2017/blob/master/incomplete_day05.sed) required jumping a certain number of lines ahead or behind, which I had to do by moving my marker one line at a time, scanning the buffer each time.  [Day 6](https://github.com/benjaminjkraft/aoc2017/blob/master/incomplete_day06.sed) required checking if the newly added line was unique, and \\(O\\!\\left(n^2\\right)\\) scans of the (length \\(n\\)) buffer were just too slow.  (It's possible by keeping the history sorted I could have done it; I didn't try.)  Finally, Day 8, with a somewhat smaller working set and a totally linear flow, worked; it took half an hour or so to run but that was okay with me.

[^scan]: An `s` without the `g` or a `/pattern/` that successfully matches will only scan as far as necessary, but that's not much better in many cases.

I could probably write a full blog post on some of the tricks involved; you'll just have to look at the source.  Plus, Bruce Barnett's [Sed Grymoire](http://www.grymoire.com/Unix/Sed.html), which I used as a reference, gives a much better explanation of the language as a whole than I ever could.

## The "weird" languages

I used several other esoteric or special-purpose languages, which were a lot of fun.

[Day 2](https://github.com/benjaminjkraft/aoc2017/blob/master/day02.j) was in J -- a whole 50 characters not counting input and comments.  I've used J for some Project Euler problems before.  It has a much deserved reputation for inscrutability due to the 1- and 2-character identifiers, but once you get beyond that, it's actually a pretty interesting language: it's array-focused (so `map` is often implicit: `1 + 1 2 3` evaluates to `2 3 4`), and has an unusual grammar where higher-order functions are "adverbs" that modify other functions ("verbs").  I'd love to see a less terse language in this style; the only similar ones I've used are Mathematica and R, and they still have normal grammars.  Anyway, J is just too hard to read for general use but it's worth playing around with.

I went back to 4th grade a bit with Logo (yeah, the one with the turtle) on [Day 4](https://github.com/benjaminjkraft/aoc2017/blob/master/day04.logo).  It's very primitive -- input reading was a huge pain -- and has some strange syntax, but in some ways it's surprisingly modern; you can see the Lisp influence really clearly.  The builtins and syntax are just too primitive for serious work, though.

As a Vim user I felt obligated to give Vimscript a try for [Day 9](https://github.com/benjaminjkraft/aoc2017/blob/master/day09.vim).  I expected it to be another painful special-purpose language missing normal functionality, but it turns out it's actually a very reasonable scripting language, in the general flavor of Python or Ruby, albeit with a couple of quirks.  This was actually one of the simplest solutions I wrote.

Spreadsheet formulas, like `sed`, took me a few tries because I had to find a suitable problem to avoid crashing my spreadsheet program, but [Day 11](https://docs.google.com/spreadsheets/d/1Stxs80LtqSoXDHMxUpyu_kf0ny8xyZMpL8jdlx5O2zQ/edit) was perfect for it: the number of steps was manageable, and the logic was simple once you figured out how to represent the hex grid.

Knowing [Benjamin Pollack](https://bitquabit.com/) meant I had to give Factor a try on [Day 15](https://github.com/benjaminjkraft/aoc2017/blob/master/day15.factor).  Since the problem involved a fairly linear iteration, I had no trouble handling the stack.  The number of different shuffle words and combinators involved in the average script is a bit much, though -- it seems like there are some conventions that would help but I haven't really caught on to those yet.  I almost think I'd love to embed it in a more normal language, so you can use traditional syntax to more conveniently express the overall control flow, but have the stack syntax to write the computations, or something.

And finally, just when I was a little worried I was coming up short a language or two, [Day 23](https://github.com/benjaminjkraft/aoc2017/blob/master/day23.txt) was a great problem to do mostly by hand.  I was a little miffed that I did have to resort to real code to compute the final result, but Mathematica did that just fine.

## C, C++, Go, and Rust

I don't do much lower-level programming, so languages like C, C++, Go, and Rust were a mostly new adventure for me.  Luckily, the problem I chose to do in C was simple enough that I didn't really have to think about pointers; in C++ I had to pass a few things around but didn't really have to worry about managing memory carefully.

I found both Go and Rust really interesting; I hear them get compared a lot, but they take very different approaches and feel very different for it.  I used Go first; it felt, to me, like a slightly lower-level Python.  I didn't use all the language features but I had no trouble wrapping my head around the basics quickly; I feel like I could be writing good quality real code in Go within a week.  The explicit error-checking gets a little annoying, but having automatic memory management and modern build tools, even without many other modern features, was enough to make it feel plenty usable while remaining a super simple language.  Meanwhile, Rust was the opposite: it felt very cutting-edge, but I had a lot of trouble wrapping my head around it.  I didn't really make sense of all the different behaviors of the borrow checker, and the differences between different types of references, and so on.  Once you get past those, on the other hand, it's a very full-featured functional language that just happens to give you very low-level capabilities.  Anyway, the two of those make me excited for the future of programming languages.

## What I didn't like

Lastly, a few languages I just didn't like.

I found Perl the hardest to understand of any of the general-purpose languages I tried.  There's so much magic: the `$` vs. `@` vs. `%` for variables (and the casts those do), for example.  It felt like someone took PHP -- which I actually found surprisingly reasonable, if a bit antiquated -- and tried to make it much more difficult to understand without adding much useful functionality (as far as I saw).  So, it keepts its place in string-processing one-liners, but I think I'll leave it there.

Scala I managed to get in dependency hell without installing any dependencies -- it didn't like my JDK 9, and so I installed JDK 8 and it still didn't like that, so I got a standalone install of the `sbt` build toolchain, but I couldn't really figure how to get that to pass stdin to my executable, so I ended up with a somewhat messy and inconsistent workflow.  I'm sure it's a fine language once you install it correctly, although from my limited use it didn't feel as nice as Kotlin.

OCaml I found nearly unusable.  The standard library is really simple, and apparently everybody uses one of several alternative ones, which I didn't realize until I was done.  But even beyond the weak standard library, it really felt like it's been superseded by more modern functional languages like Haskell.

The only two languages I seriously tried at and didn't end up using were assembly and Erlang.  Assembly I gave up on as soon as I realized I would need a nontrivial data structure for the problem.  The combination of strange syntax and different programming model of Erlang were just too much.  I had used Erlang before and found it fine, but by the time I finished parsing the input I wasn't really excited to continue, and I ended up doing the problem in Ruby.
