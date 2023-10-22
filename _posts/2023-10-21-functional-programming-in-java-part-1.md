--- 
title: Part 1 - Functional Programming in Java (What and Why?)
date: 2023-10-21 00:00:00 +0530
categories: [Technology]
tags: [coding, functionalProgramming, java, firstBlog]
comments: true
---

 <div align="justify">
This blog aims to define what functional programming is and few very basic examples of the same. **Note: I will be posting another blog with in detail examples for functional programming in Java.**
 <br />
 <br />  
 In Java, we write lots of code to perform certain operations with each line representing a sub operation. This style is called imperative programming. Since Java 8, this has been simplified a bit further by introducing functional programming which aims to build the code as functions and apply arguments to it. This makes the code less complex, cleaner, maintainable, and easier to test.
 <br /> 
 <br />
Below are some examples of code snippets we may or may not have encountered in code which has the concept of functional programming. 
 </div>

## Iterating a list
### The imperative way
 <div align="justify">
Use case: Loop through a list and print its values. In the imperative world, a for statement would be used for the same like below and iterate each item.
</div>

```java
for(int i = 0; i < listOfNames.size(); i++) {                      
    System.out.println(listOfNames.get(i)); 
}
```

### The functional way
 <div align="justify">
Replace for loop statement with forEach() to use the functional way and this reduces the code to one line. 
</div>

```java
listOfNames.forEach((name) -> System.out.println(name));
```

## Transforming a list
### The imperative way
 <div align="justify">
Use case: Transforming through a list of names to contain all upper case names. In the imperative world, we would just use a for statement, iterate and add the upper case name to the newly created list. 
</div>

```java
List<String> uppercaseNames = new ArrayList<String>();
for(String name : listOfNames) { 
   listOfNames.add(name.toUpperCase()); 
}
```


### The functional way
 <div align="justify">
Replace with map() to perform this use case in the functional way. 
</div>

```java
List<String> uppercaseNames = listOfNames.stream() 
   .map(name -> name.toUpperCase()) 
   .collect(Collectors.toList());
```

## Finding elements in a collection

### The imperative way
 <div align="justify">
Use case: Find list of names that contains all names that starts with A. In the imperative world, you would just use a for statement and check if each item starts with letter A. 
</div>

```java
List<String> startsWithA = new ArrayList<String>(); 
for(String name : listOfNames) {
   if(name.startsWith("A")) { 
         startsWithA.add(name); 
   }
}
```

### The functional way
 <div align="justify">
Replace using for loop statements with filter() to perform this use case in the functional way in the below fashion.
</div>

```java
List<String> startsWithA =
   listOfNames.stream()
      .filter(name -> name.startsWith("A")) 
      .collect(Collectors.toList());
```

## Upcoming blog - Part 2
 <div align="justify">
I would be posting another blog with in detail examples for all the usages for functional programming in Java. Stay tuned! 
</div>
[Part 2 - Functional Programming in Java (Detailed Code Examples) - (Coming Soon!)](../functional-programming-in-java-part-1)
 <br />  
 <br />  
{% if site.disqus.shortname %}
  {% include disqus.html %}
{% endif %}