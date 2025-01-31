---
title: "Shell - a stream processing language"   
author: Samuel Hierholzer
---

I saw the [following post](https://bsky.app/profile/cyberciti.biz/post/3lffkfje3fk2e) on bluesky yesterday and immediately had to optimize it:

```bash
wget ftp.gnu.org/gnu/bash/bash-5.2.tar.gz &>/dev/null \
&& tar -xz bash-5.2.tar.gz \
&& grep -A2 Birthdate bash-5.2/shell.c \
&& rm -rf bash-5.2*
```

The whole thing can be optimized to not use the filesystem at all, be shorter and faster!

```bash
curl -s ftp.gnu.org/gnu/bash/bash-5.2.tar.gz | tar -xzO | grep -A2 -m1 Birthdate
```

After I posted my optimization something wouldn’t go out of my head anymore. This is a prime example of using shell for stream processing; Download a tarball, unpack it and search for a string. Stop everything once the first occurence is found.

Shell makes it super easy to start such streams, even concurrently in the background when a single `&` is added. Almost any other language makes it hard to do concurrency.

But it’s rather hard to actually write concurrent *functions*. Using `read` to loop over lines of input isn’t completely trivial and shell by itself is generally not an easy language for text manipulation (which is a bit ironic given strings are pretty much the only data type). It’s also unbuffered, thus super slow.

But this is only true for all the POSIX shells with concepts from the 90ies like Bash, Ksh, Zsh, *ash, etc. Modern shells like Nushell or Ysh (Oils-for-Unix) have more datatypes, simpler ways to loop over lines and more comfortable text manipulation. They also know buffered reads.

I believe modern shells don’t just remove warts and unnecessary complexity in old shells. They allow newer programming styles! I’m off now, writing more stream-focussed code in Ysh!

Btw. the output of the initial snippet is:

```bash
  Birthdate:
  Sunday, January 10th, 1988.
  Initial author: Brian Fox
```
