---
layout: post
title:  "PSA: How to safely check buffer sizes in C"
date:   2014-04-23 20:13:36 +0200
categories: update
---

A common task in C is checking whether some data fits in a buffer. Unfortunately, doing it can be quite tricky, as [http://lwn.net/Articles/278137/] shows. Going by the standard, the problem is that in C creating a pointer beyond the end of an array is undefined behaviour – which means the compiler can do whatever it wants – including sending your customers’ credit card numbers to Russia (actually that’s quite a probable outcome, because, as the link shows, the compiler may introduce a security bug, which will be exploited and result in the credit card numbers being sent).

 
First, I’ll like to say that C does allow you to create a pointer to exactly-the-end-of-an-array (say, if A is an array of length 5, then you can create a pointer to (the non-existent) A[5], as long as you don’t dereference it).

 

The right thing to do is actually quite simple,

```size_t buffer_size = ...;
char * buffer = malloc(buffer_size);
if(!buffer) return NULL; // or something
...
unsigned int overhead = calculate_overhead_from_data();
unsigned int alleged_size = ask_data_what_the_size_is();
if(buffer_size < overhead ||
   buffer_size - overhead < alleged_size)
  fail();
```{: style="color: turquoise; display: block; font-family: monospace; white-space: pre;" }


Or, say, when getting a packet:

```// assume packet_end is the actual end of the packet
if(packet_end - p < 2*sizeof(unsigned int)) fail();
unsigned int len = read_uint(p);
p += sizeof(unsigned int);
﻿
unsigned int another_field = read_uint(p);
p += sizeof(unsigned int);
﻿
if(packet_end - p < len) fail();
DO_SOMETHING_WITH_REST_OF_PACKET
```{: style="color: blue; display: block; font-family: monospace; white-space: pre;" }


The things you must NEVER do are this:

```// CODE IS WRONG AND EVIL
// DO NOT USE UNLESS YOU ARE INTENTIONALLY INTRODUCING A BACKDOOR
// assume packet_end is the actual end of the packet
if(packet_end - p < 2*sizeof(unsigned int)) fail();
unsigned int len = read_uint(p);
p += sizeof(unsigned int);
﻿
```{: style="color: #800000; display: block; font-family: monospace; white-space: pre;" }
```// WRONG!
unsigned int another_field = read_uint(p);
p += sizeof(unsigned int);
if(p + len > packet_end) fail();
﻿
```{: style="color: #ff0000; display: block; font-family: monospace; white-space: pre;" }
```// ALSO WRONG!
if(packet_end - p < len + sizeof(unsigned int)) fail()
﻿
```{: style="color: #ff6600; display: block; font-family: monospace; white-space: pre;" }
```DO_SOMETHING_WITH_REST_OF_PACKET
```{: style="color: #800000; display: block; font-family: monospace; white-space: pre;" }

The code in red tests for overflow by first creating a pointer overflowing a buffer, which overflows a buffer and begets undefined behaviour, and then tries to check the length, but the check comes too late – the program’s behaviour is already undefined, and the compiler, knowing so, may remove the check.
The code in orange is slightly less wrong – the check is actually well-defined, because unsigned integer addition is defined as addition modulo `256^sizeof(size_t)` – however, it checks the wrong thing, because if an attacker puts, say, `len=(size_t)-sizeof(unsigned int)`, then `len+sizeof(unsigned int) = -4+4 = 0`, and the check will succeed and copy a huge amount of data off the end of the buffer, causing problems. I repeat, the red and orange codes are evil – use the blue or turquoise code unless you are introducing a backdoor.

 

Note that in these examples, `read_uint` is assumed to be a macro/function that reads `sizeof(unsigned int)=4` bytes from a `char*` as an unsigned integer (this isn’t the same as *(int*)packet, because of alignment and endianness issues) – there does not seem to be any standard here. Assuming data is big-endian (as in most network protocols), it can be defined as:

{% highlight C %}
inline unsigned int read_uint(char * p) {
  unsigned int r = 0;
  for(int i=0;i<4;i++) // casting because char is signed.
    r = ((unsigned int)p[i]) + (r<<8);
  return r;
}
{% endhighlight %}
