--- 
title: Functional Interfaces in Java
tagline: Examples for functional interfaces.
categories: [Coding]
tags: [coding, java, functional-programming, functional-interface, technology]
date: 2023-10-28 00:00:00 +0530
name: Functional programming, Functional Interfaces
type: BlogPosting
last_modified_at: 2023-11-01 00:00:00 +0530
description: Functional Interfaces in Java
subType: Blog 
comments: true
---

Before moving to examples, do read the blog [Functional programming in Java - What and Why?](../functional-programming-in-java-what-and-why) to get more context on what is functional programming.

<div align="justify">
There are few other ways apart from lambdas, that uses the concept of functional programming and they are:
</div>
* Functional Interfaces 
* Monads - [Jump to Monads section](#monads)

## Functional Interfaces
<div align="justify">
Functional interfaces is an interface with one abstract method which can be used to implement different use cases. Below are some use cases that might be useful.
</div>

### Case 1: Single Parameter T and result R
#### `Function<T, R>` and `apply()`
Given a list of names, find the number the names in the list.
```java 
Function<List<String>, Integer> sizeOfList = (value) -> value.size();
logger.debug("Number of names : {}", sizeOfList.apply(names));
```

### Case 1.1: Nested functions
#### `Function<T, R>`, `andThen` and `apply()`
Given a list of names, find the number the names that starts with A.
```java 
// Function 1
Function<List<String>, List<String>> startsWithA = (value) -> value.stream()
      .filter(name -> name.startsWith("A")) 
      .collect(Collectors.toList());
// Function 2
Function<List<String>, Integer> sizeOfList = (value) -> value.size();
// Nesting : Function 1 andThen Function 2
Function<List<String>, List<String>> numberOfNamesStartsWithA = startsWithA.andThen(startsWithA);

logger.debug("Number of names that starts with A : {}", numberOfNamesStartsWithA.apply(names);
```

### Case 1.2: Function as parameter and result R
#### `Function<T, R>`, `compose()` and `apply()`
Given a number, add 10 to it and multiply by 20.
```java 
// Function 1
Function<Integer, Integer> multiplyBy20 = (value) -> value * 20;
// Function 2
Function<Integer, Integer> add10      = (value) -> value + 10;
// Function 2 instance passed as parameter to Function 1
Function<Integer, Integer> add10ThenMultiplyBy20 = multiplyBy20.compose(add10);
logger.debug(add10ThenMultiplyBy20.apply(30)); // (30 + 10) * 20 = 800
```

### Case 1.3: Two parameters (A and B) and result R
#### `BiFunction<A, B, R>` and  `apply()`
Given two numbers, find the sum of the numbers.
```java 
BiFunction<Integer, Integer, Integer> addTwoNumbers = (a, b) -> a + b;
logger.debug(addTwoNumbers.apply(30, 10)); // (30 + 10) = 40
```

### Case 1.4: Three parameters (A, B and C) and result R
#### `TriFunction<A, B, C, R>` and `apply()`
Given three numbers, find the sum of the numbers.
```java 
TriFunction<Integer, Integer> addThreeNumbers = (a, b, c) -> a + b + c;
logger.debug(addThreeNumbers.apply(30, 10, 40)); // (30 + 10+ 40) = 80
```

### Case 2: Single Parameter T and boolean result
#### `Predicate<T>` and `test()`
Given a number, find if the number is greater than 100 or not.
```java 
Predicate<Integer> isNumberGreaterThan100 = value -> (value > 100);  
logger.debug(isNumberGreaterThan100.test(10));  // false
logger.debug(isNumberGreaterThan100.test(200));  // true
```

### Case 3: Single Parameter T and no result
#### `Consumer<T>` and `accept()`
Given list of names, display all the names in the list.
```java 
Consumer<List<String>> displayNames = values -> values.stream().forEach(a -> logger.debug("{} ", name));
displayNames.accept(names);
```

### Case 3.1: Nesting of Functions with single Parameter T and no result
#### `Consumer<T>`, `andThen()` and `accept()`
Given list of names, display all the names in the list followed by the number of names.
```java 
Consumer<List<String>> displayNames = values -> values.stream().forEach(a -> logger.debug("{} ", name));
Consumer<Integer> printSizeOfList = values -> logger.debug("Total number of names : {}", values.size);
displayNames.andThen(printSizeOfList).accept(names);
```

### Case 4: No Parameters and result R
#### `Supplier<T>` and `get()`
Print a random number.
```java 
Supplier<Double> findRandomValue = () -> Math.random(); 
logger.debug(findRandomValue.get()); 
```

## Monads
[blog post on Monads](../functional-programming-monads).
