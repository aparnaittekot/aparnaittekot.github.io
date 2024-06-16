--- 
title: Monads in Java
categories: [Coding]
tagline: Introduction to monads in Java.
tags: [monads, java, functional-programming, coding, technology]
date: 2023-11-01 00:00:00 +0530
name: Functional programming, Monads
type: BlogPosting
last_modified_at: 2023-11-01 00:00:00 +0530
---

## Pre-read blogs:
1. [Functional Programming in Java - What and Why?](../functional-programming-in-java-what-and-why)
2. [Functional Interface examples (Functional programming)](../functional-programming-in-java-examples)


## Monads
Let me take a very simple concept of doing 3 operations one after the other with the output of one fed to another.

```java
Integer firstOutput = firstOperation(firstInput)
Integer secondOutput = secondOperation(firstOutput)
Integer thirdOutput = thirdOperation(secondOutput)
```

In the above set of operations, we might encounter a `Null` in any of the operations.

In the `verbose` way, we ideally would do the following to avoid `NullPointerException`:
```java
Integer firstOutput = firstOperation(firstInput)
if (firstOutput != null) {
    Integer secondOutput = secondOperation(firstOutput)
    if (secondOutput != null) {
        Integer thirdOutput = thirdOperation(secondOutput)
    }
}
```

The above code is not that intuitive at all. 

Let's look at the `monad` way of doing things to make it clear.

Note: `Optional.of()` wraps a value and returns `Optional.none()` if the value is null.

```java
Optional<Integer> firstOutput = Optional.of(firstOperation(firstInput))
Optional<Integer> secondOutput = firstOutput.map(output -> secondOperation(output)).orElse(Optional.none())
Optional<Integer> thirdOutput = firstOutput.map(output -> thirdOperation(output)).orElse(Optional.none())
```

Simplified as:

```java
Optional<Integer> finalResult = Optional.of(firstOperation(firstInput))
                                        .map(firstOutput -> Optional.of(secondOperation(firstOutput)))
                                        .map(secondOutput -> Optional.of(thirdOperation(secondOutput))
                                        .orElse(Optional.none())
```

Monads help in simplifying code and avoids the infamous `NullPointerException` in the production code.

<br />
{% if site.disqus.shortname %}
  {% include disqus.html %}
{% endif %}