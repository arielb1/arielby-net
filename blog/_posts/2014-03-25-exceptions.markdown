---
layout: post
title:  "On Exceptions"
date:   2014-03-25 20:13:36 +0200
categories: update
---

Another programming subject that tends to confuse people is Exceptions. It appears that each programming language (including *each* machine code architecture) and each operating system has its own subtly-incompatible version.

On the surface, the idea appears quite simple: sometimes exceptional situations occur, and the program must handle them. However, when you dig deeper, you find several similar but distinct ways of thinking about it. I’ll try to detail the ones I heard about. Note that people occasionally design one implementation but actually implement another!

The oldest way of thinking about exceptions is as return codes – like in C. They have the advantages of being standard within a language and containing more information than a typical error code, as well as not overloading the return output. This method looks quite fine on the surface, but it loses the explicitness of error codes, causing many a subtle bug.

The second way I found is the rather operational way of exceptions being a “longjmp to a stored handler”. This kind of thinking is generally fine when programming is side-effect-free but can cause quite a bit of a mess otherwise, especially if garbage-collection is missing.

The essential problem in these methods is that exceptions add many paths to a program that are rarely tested. This is especially pronounced in out-of-memory exceptions, which in many programming styles can essentially occur every second line, but in practice almost never happen.

Note that in many of these cases the program should just exit. It was noticed that all languages already have a similar “mechanism” to this – by the halting problem functions can always use an infinite amount of time before returning (observe that a common mechanism of dealing with OOM – paging/swapping – can, in particularly bad situations, cause functions to use a practically infinite amount of time and you can’t do much about it). In some ways this behaviour is not that different from a hard-reset of the computer (e.g. the power being pulled) – which may very well be a (user-caused) consequence of it happening to a critical program.

Papers typically call that behaviour divergence for rather obscure reasons, which is the name I’ll use in the rest of this post. I’ll like to note that C11 actually prohibits it, in clause 1.10/24:
  The implementation may assume that any thread will eventually do one of the following:
  - terminate,
  - make a call to a library I/O function,
  - access or modify a volatile object, or
  - perform a synchronization operation or an atomic operation

 

However, several programs have decided to use a divergence-like mechanism to handle (some kinds of) exceptions – a good example is most GUI toolkits, which like to abort on memory allocation failure. This has the advantage of essentially not having error paths to test.

However, this method has the big disadvantage of leaking the entire program on an exception. Often, this isn’t an issue: unlike what many CS instructors believe, the OS keeps track of a program’s resources and frees them when the program exits (in any way). But sometimes one wants only an operation to diverge – consider the case of a web browser with 30 tabs open, when the user enters a page with a badly-designed script that uses many gigabytes of memory – one (of course) won’t like to leak the entire tab, but one won’t like to close the entire browser either.

For these kinds of cases, one wants a cancellation method. This is quite similar to divergence, except it releases the resources used by the program. As I said earlier, typical operating systems already provide it if the program is separated into processes, and a similar mechanism, separating a program into disjoint heaps, is often used to have the advantage of this method without these issues.

However, canceling a tangled program is generally a tangled issue that I will leave for a later post.

 

CHANGES 2017/01/27 – fixed formatting
