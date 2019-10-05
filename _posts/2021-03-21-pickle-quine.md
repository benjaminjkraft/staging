---
layout: post
title: "Fun With Pickles: A Pickle Quine"
---

[Pickle](https://docs.python.org/3/library/pickle.html) is Python's all-purpose serialization format.  [Most Python objects](https://docs.python.org/3/library/pickle.html#what-can-be-pickled-and-unpickled) can be serialized and deserialized automatically.  It's a very convenient, albeit fragile and [insecure](https://www.python.org/dev/peps/pep-0307/#security-issues) way to store data, such as when caching.

While pickle is designed to encode Python objects, it's a quite flexible format: basically a tiny programming language.  This led me to the question: can one write a [quine](https://en.wikipedia.org/wiki/Quine_(computing)) in pickle?  That is, we want to create a (byte-)string which, if read as a pickle, deserializes to itself:
```python
quine == pickle.loads(quine)
```
In this post, we'll construct such a pickle quine, and learn a bit about the internals of pickle along the way.

## The pickle virtual machine

Let's take a look at a simple pickle: the tuple `(1, b'asdf')`.[^bytestrings]

[^bytestrings]: Throughout this post we'll be using bytestrings, because that's what we need for the quine.  Strings work roughly the same way.

```python
>>> pickle.dumps((1, b'asdf'), protocol=3)
b'\x80\x03K\x01C\x04asdfq\x00\x86q\x01.'
```

A pickle file consists of a series of instructions, each consisting of an opcode and perhaps some arguments.  The opcodes are described in detail in the [pickletools](https://github.com/python/cpython/blob/3.8/Lib/pickletools.py) source.  Let's take a look at our pickle, starting from the beginnning.

The first byte of our pickle is `0x80`, which is the `PROTO` opcode: it says the next byte, `0x03`, will tell us which pickle protocol we're using (in this case version 3).[^version]  Next is `K` (`0x4b`), or `BININT1`.  `BININT1` tells us that the next byte is a small integer, in this case `0x01`.

[^version]: We're using version 3 because it's a little simpler than [version 4](https://www.python.org/dev/peps/pep-3154/); handling framing wouldn't complicate things much, but would add one more thing to explain.

What do we do with this `1`?  A pickle decoder keeps its work in a stack: when we read an opcode like `BININT1`, we push its value onto the stack; other opcodes pop data off of the stack.  At the end of the processing, the value on the top of the stack is the value we'll return.

We can now continue on to the next opcode, `C` (`0x43`), which is `SHORT_BINBYTES`.  As the name implies, this encodes a bytestring.  The argument is a single byte `0x04`, which tells us the string is the next four bytes (`asdf`).

Next, we get a `BINPUT` opcode (`q` or `0x71`, with argument `0x00`).  This doesn't affect us just yet, so we'll revisit it when we need it.

Now our stack has two values, `b'asdf'` on top and `1` below it.  Our next opcode is `0x86`, `TUPLE2`, which says to take the top two values on the stack, and make them into a tuple, pushing it onto the stack.  (There are other opcodes for 0-, 1-, and 3-tuples; and a pair of opcodes `MARK` and `TUPLE` that let us build arbitrary-length tuples, but we won't need any of those today.)  Then we have another `BINPUT` with argument `0x01`, which we'll again skip for now.  Finally, we see `.` (`0x2e`) which is `STOP`: we're done, and we'll return the top value of the stack, `(1, b'asdf')`.

The pickletools module will save us having to remember all those opcode numbers:

```python
>>> pickletools.dis(pickle.dumps((1, b'asdf'), protocol=3))
    0: \x80 PROTO      3
    2: K    BININT1    1
    4: C    SHORT_BINBYTES b'asdf'
   10: q    BINPUT     0
   12: \x86 TUPLE2
   13: q    BINPUT     1
   15: .    STOP
```
The layout of this dump is similar to a disassembly: and indeed we can think of a pickle decoder as a simple virtual machine, which reads and executes instructions from the pickle file.

## A few more opcodes

Now that we know how a pickle decoder works, we can write the quine.  We'll need to know about a few more opcodes to do so.

The first is super simple: `NONE` (`N` or `0x4e`) pushes the value `None` onto the stack.

The next opcode, `GLOBAL` (`c` or `0x63`), is key to the pickle format: it says "look up the value from this module with this name".  This is how pickle encodes top-level functions and classes.  The way it formats its argument is a bit of a relic of pickle's original (version 0) text-based format: it has two arguments, each of which we read by looking up to the next newline.  We can see an example by pickling the `list` builtin:

```python
>>> pickle.dumps(list, protocol=3)
b'\x80\x03cbuiltins\nlist\nq\x00.'
```

After the version header, we have a `GLOBAL` opcode (`c`), then `builtins\nlist\n`: so we look up `builtins.list` and (again ignoring `BINPUT`) return it.

Third, we'll need `REDUCE`.  `REDUCE` is used to construct classes[^classes] and in a few other cases.  It requires two things to be on the stack: on top, a tuple of arguments, and below it, a callable; it calls `callable(*arguments)`.  This, plus `TUPLE2` lets us call a function with two arguments: we push the function onto the stack, followed by the two arguments, then call `TUPLE2` to make the arguments into a pair, and `REDUCE` to call them.

[^classes]: There are a few different ways to construct classes; in modern pickle versions `REDUCE` isn't as common, but it's still used in certain cases, and it's the simplest and most flexible.  For the really curious, search for `REDUCE` or read `save_reduce` in the [pickle source](https://github.com/python/cpython/blob/3.7/Lib/pickle.py).

Finally, it's time to revisit `BINPUT`.  The `pickletools` module tells us that this will "store the stack top into the memo".  Up until now, we've been storing all our work on the stack; the memo is pickle's other data structure.  It's just a big map of integer to object; `BINPUT` inserts into that map, using its argument as the key and the top of the stack as the value.  Its friend `BINGET` does the reverse: it uses its argument as a key, and pushes the value at that key onto the stack.  The memo is useful as an optimization -- `BINGET n` lets us re-use the object that was on top of the stack when `BINPUT n` was called -- and also allows us to pickle recursive objects.[^recursive]  As a simplification, the pickler adds most of the objects it creates to the memo, without knowing if they'll actually be used, which is why the above example could simply ignore the `BINPUT`s.

[^recursive]: Exercise to the reader: figure out why a memo-dict is so important to a recursive object.  Hint: think about what happens when you pickle the the value produced by `d = {}; d['self'] = d`.

As an aside: you now know all you need to write a Very Dangerous pickle that will execute arbitrary code; try it for yourself!  This is a great reminder to never depickle untrusted data.

# The quine

Our basic strategy will be a [typical one](https://en.wikipedia.org/wiki/Quine_(computing)#Constructive_quines) for writing quines:

1. Write code to define a string containing the entire program except for the string itself.
2. Write code that takes that string, splices it into itself at the right point, and returns it.

Let's walk through the pickle.  We'll build it up as a series of bytestrings (opcodes and their arguments) which we'll join together at the end.

First, the version header:

```python
    PROTO, b'\x03',
```

Now, we push the string; this will have some placeholders we'll figure out later.

```
    SHORT_BINBYTES, <1-byte length of the string>, <the string>,
```

Now, we have the string itself on the stack; we have to to construct the output we want, which is splicing that string into itself at index 4 (the number of bytes before where the string appears in the output pickle).  In Python, this is pretty simple: we just want

```python
return (
    the_string[:4]      # the part before where we splice
    + the_string        # the string itself
    + the_string[4:])   # the rest of the string
```

We just need to encode this in pickle.  For this, we'll need to know how to write everything in terms of builtin functions: pickle has no `PLUS` opcode.  The [operator](https://docs.python.org/3/library/operator.html) module comes to the rescue: we can use `operator.add(a, b)` for `a + b` and `operator.getitem(c, i)` for `c[i]`.

We do need one more trick here: we need to know how Python represents that `:4` and `4:`.  The answer is the little-known builtin `slice`: the syntax `c[a:b]` is just syntactic sugar for `c[slice(a, b)]`.  (Omitted values are passed as `None`.)  So we can rewrite our code as

```python
return (
    operator.add(
        operator.add(
            # the_string[:4]
            operator.getitem(the_string, slice(None, 4)),
            the_string),
        # the_string[4:]
        operator.getitem(the_string, slice(4, None))))
```

This will be easier to represent.  Back to constructing our pickle, we store the string in the memo (slot 0), since we'll need it a few times.

```python
    BINPUT, b'\x00',
```

Now, we load up each of the builtins we'll need, putting them in the memo dict.

```python
    GLOBAL, b'builtins\nslice\n',     # push slice builtin
    BINPUT, b'\x01',                  # store it in memo

    GLOBAL, b'operator\ngetitem\n',   # push operator.getitem
    BINPUT, b'\x02',                  # store it in memo

    GLOBAL, b'operator\nadd\n',       # push operator.add
    BINPUT, b'\x03',                  # store it in memo
```

Now, we start computing what we need.  In each case, we're going to follow the pattern we discussed above to call a function with two arguments, and we'll put the result in the memo.

```python
    <code to push function>,
    <code to push first argument>,
    <code to push second argument>,
    TUPLE2, REDUCE,
    BINPUT, <memo slot number>
```

First, we build each slice:

```python
    BINGET, b'\x01',                  # load slice
    NONE,                             # push None
    BININT1, b'\x04',                 # push 4
    TUPLE2, REDUCE,                   # call --> slice(None, 4)
    BINPUT, b'\x04',                  # store that in memo

    BINGET, b'\x01',                  # load slice again
    BININT1, b'\x04',                 # push 4
    NONE,                             # push None
    TUPLE2, REDUCE,                   # call --> slice(4, None)
    BINPUT, b'\x05',                  # store that in memo
```

Next, we use those slices to do the getitem calls:

```python
    BINGET, b'\x02',                  # load getitem
    BINGET, b'\x00',                  # load the string
    BINGET, b'\x04',                  # load slice(None, 4)
    TUPLE2, REDUCE,                   # call --> string[:4]
    BINPUT, b'\x06',                  # store that in memo

    BINGET, b'\x02',                  # load getitem again
    BINGET, b'\x00',                  # load the string again
    BINGET, b'\x05',                  # load slice(4, None)
    TUPLE2, REDUCE,                   # call --> string[4:]
    BINPUT, b'\x07',                  # store that in memo
```

Finally, we call add to glue everything together:

```python
    BINGET, b'\x03',                  # load operator.add
    BINGET, b'\x06',                  # load string[:4]
    BINGET, b'\x00',                  # load string
    TUPLE2, REDUCE,                   # call
    BINPUT, b'\x08',                  # store that in memo

    BINGET, b'\x03',                  # load operator.add again
    BINGET, b'\x08',                  # load string[:4] + string
    BINGET, b'\x07',                  # load string[4:]
    TUPLE2, REDUCE,                   # call
```

We've left the result on top of the stack, so a simple

```python
    STOP
```
will finish things up.

Except we're not quite done: we have to fill in those placeholders.  The length will be the total number of opcodes we've printing above (counting itself, not counting the placeholder for the string), which in this case is 117.  And then we just have to substitute in the string.  This gives us the pickle:

```python
quine = b'\x80\x03Cu\x80\x03Cuq\x00cbuiltins\nslice\nq\x01coperator\ngetitem\nq\x02coperator\nadd\nq\x03h\x01NK\x04\x86Rq\x04h\x01K\x04N\x86Rq\x05h\x02h\x00h\x04\x86Rq\x06h\x02h\x00h\x05\x86Rq\x07h\x03h\x06h\x00\x86Rq\x08h\x03h\x08h\x07\x86R.q\x00cbuiltins\nslice\nq\x01coperator\ngetitem\nq\x02coperator\nadd\nq\x03h\x01NK\x04\x86Rq\x04h\x01K\x04N\x86Rq\x05h\x02h\x00h\x04\x86Rq\x06h\x02h\x00h\x05\x86Rq\x07h\x03h\x06h\x00\x86Rq\x08h\x03h\x08h\x07\x86R.'
```

or run through `pickletools.dis`:

```python
    0: \x80 PROTO      3
    2: C    SHORT_BINBYTES b'\x80\x03Cuq\x00cbuiltins\nslice\nq\x01coperator\ngetitem\nq\x02coperator\nadd\nq\x03h\x01NK\x04\x86Rq\x04h\x01K\x04N\x86Rq\x05h\x02h\x00h\x04\x86Rq\x06h\x02h\x00h\x05\x86Rq\x07h\x03h\x06h\x00\x86Rq\x08h\x03h\x08h\x07\x86R.'
  121: q    BINPUT     0
  123: c    GLOBAL     'builtins slice'
  139: q    BINPUT     1
  141: c    GLOBAL     'operator getitem'
  159: q    BINPUT     2
  161: c    GLOBAL     'operator add'
  175: q    BINPUT     3
  177: h    BINGET     1
  179: N    NONE
  180: K    BININT1    4
  182: \x86 TUPLE2
  183: R    REDUCE
  184: q    BINPUT     4
  186: h    BINGET     1
  188: K    BININT1    4
  190: N    NONE
  191: \x86 TUPLE2
  192: R    REDUCE
  193: q    BINPUT     5
  195: h    BINGET     2
  197: h    BINGET     0
  199: h    BINGET     4
  201: \x86 TUPLE2
  202: R    REDUCE
  203: q    BINPUT     6
  205: h    BINGET     2
  207: h    BINGET     0
  209: h    BINGET     5
  211: \x86 TUPLE2
  212: R    REDUCE
  213: q    BINPUT     7
  215: h    BINGET     3
  217: h    BINGET     6
  219: h    BINGET     0
  221: \x86 TUPLE2
  222: R    REDUCE
  223: q    BINPUT     8
  225: h    BINGET     3
  227: h    BINGET     8
  229: h    BINGET     7
  231: \x86 TUPLE2
  232: R    REDUCE
  233: .    STOP
```

And that, truly, is it!
```
assert quine == pickle.loads(quine)
```

If you want to play with this further, I've posted [the complete code](https://github.com/benjaminjkraft/pickle-junk/blob/master/pickle_quine.py) to generate and check the pickle, as well as a version optimized to be as short as possible (suggestions welcome).

*Thanks to Benjamin Tidor for comments on an earlier draft.*
