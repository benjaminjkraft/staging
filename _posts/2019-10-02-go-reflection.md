---
layout: post
title: Go Reflection in 10 Minutes
---

This is a quick explanation of the `reflect` package in Go, originally written for some of my coworkers, because I find the official [introduction](https://blog.golang.org/laws-of-reflection) a bit convoluted. This post assumes that you already know the basics of Go, including the usage of `interface{}`, and understand why you might want reflection. And a reminder: anything you can do without `reflect` is probably better done that way; and anything you can't might be better not done at all.

## Values and Types

There are two main types in `reflect`: `Value` and `Type`. These are fairly self-explanatory: they're `reflect`'s representation of Go's values and types, and we can create them by calling `reflect.ValueOf` and `reflect.TypeOf` on any Go value. Their methods are the bulk of the `reflect` package. For example:

```go
s := "I'm a string!"
sValue := reflect.ValueOf(s)
sValue.Len() // 13

stringType := reflect.TypeOf(s) // or sValue.Type()
stringType.Name() // "string"

type myStruct struct{
    foo int
    bar bool
}

reflect.ValueOf(myStruct{123, false}).Field(0) // reflect.ValueOf(123)
```

Most of the `reflect` package is methods on `Type` and `Value`: for example for a map type one can get the key and value types; and for a map value one can ask for the keys as a slice of `reflect.Value`.  (The [documentation](https://godoc.org/reflect), of course, has the details.)

To convert a `reflect.Value` back to an ordinary Go value, one uses `value.Interface()`; this returns an `interface{}` which the caller likely must cast to the expected type. (`reflect` provides helpers like `value.String()` to do this for common types.)

## Kinds

The last important type in `reflect` is `Kind`, which is used to tell which form of builtin a particular type is. (It's unrelated to the type-theoretic notion of "kind".) For example, a `Kind` tells us if we have a `map` or a `func` or an `int`, but not what the keys and values of the map are. It's probably best explained by listing the enum values:

```go
    Invalid
    Bool
    Int
    Int8
    Int16
    Int32
    Int64
    Uint
    Uint8
    Uint16
    Uint32
    Uint64
    Uintptr
    Float32
    Float64
    Complex64
    Complex128
    Array
    Chan
    Func
    Interface
    Map
    Ptr
    Slice
    String
    Struct
    UnsafePointer
```

Every `reflect.Type` fits into one of these, which we can check by `type.Kind()` or `value.Kind()`.

Note that almost everything in `reflect` will panic if given invalid data. For example, `reflect.Value(123).Field(0)` (getting a field on an int) will panic.

## What can it do?

In general, `reflect` is designed so that you can with `reflect` exactly that which you can do in ordinary Go, just more generally. (There are a few exceptions, like defining methods.) For example, it can:

- index into a slice or map (of arbitrary element type) using `reflect.Value.Index` or `reflect.Value.MapIndex`

- call a function (of arbitrary signature) using `reflect.Value.Call`

- create a channel (of arbitrary element type) using `reflect.MakeChan`

Values which can be set in ordinary Go can also be set with `reflect`; for example:

```go
s := []int{1, 2, 3}
v := reflect.ValueOf(s)
v.Index(1).Set(reflect.ValueOf(4))  // sets s[1] = 4
```

But values which are normally unsettable still are with `reflect`:

```go
v := reflect.ValueOf(3)
v.Set(reflect.ValueOf(4))  // panics: can't set a literal
```

So you can't use `reflect` to escape ordinary memory safety guarantees, for example, and access to unexported struct fields is limited.

## Interfaces

Interface types in `reflect` are a bit weird. Basically, for most purposes, `reflect` never looks at the interface, only at the underlying value, because all its constructors accept `interface{}`. For example:

```go
type Stringer interface{ String() string }
type Foo struct{}
func (foo Foo) String() string { return "it's a foo!" }

var v Stringer
v = Foo{}
reflect.TypeOf(v) // Foo, not Stringer
```

It's possible to get interface values in `reflect`, such as by looking at the element type of a `[]Stringer`, but it's uncommon.

## That's it!

I hope this makes `reflect` seem a bit less scary. While the code you write with it may be very abstract, `reflect` itself isn't too complicated. Use with care!
