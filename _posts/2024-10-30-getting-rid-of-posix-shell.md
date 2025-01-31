---
title: Getting rid of POSIX shell
slug: getting-rid-of-posix-shell
post:
  excerpt: "What do we get when we try to remove the crap from POSIX shell?"
date_published: 2024-10-30T07:00:37.000Z
date_updated: 2024-11-07T07:24:57.000Z
tags: oils, posix, shell
---

Imagine a fresh install of your favorite unix-like Desktop. Maybe Ubuntu Linux, a BSD - or most likely MacOS. You log in intending to start a Shell and set up the development environment. Except there is no shell! No `zsh`, no `bash` or `ksh`, not even `/bin/sh`! All you have is the *Settings App* and an *App Store*.

I honestly can't imagine that scenario. What is kinda "by design" in the Windows world feels like a car without steering wheel in the Unix World.

So no, we don't want to get rid of the POSIX shell.

However the shell is not really a pleasure to work with either:

- A *lot* of quoting to prevent the rarely used implicit globbing and splitting
- The (arguably mostly extended) [parameter expansions](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html) so unintuitive they could attract [gremlins](https://buttondown.com/hillelwayne/archive/raku-a-language-for-gremlins/).
- 3 overlapping ways to do `test`s.
- 3 ways to do arithmetics.
- Hard to use Error handling with bad defaults.
- *No ergonomic types!*

I could go on!

Yet many people say “Well, that’s *just shell*" and "it gets the job done 🤷”.

But I believe that’s not true. Shell can be nice and easy to work with. I believe it’s just *the 40 years of legacy* which make POSIX shell and it's extensions so hard. [Nushell](https://www.nushell.sh/) is a good example for a fun shell. Even modern Windows Powershell can be quite nice to work with!

The issue is not that shell is bad. The issue is that we’re stuck with it.

But why? Can’t we just replace it with something nice?

## The simple way

A very simple way to escape the legacy of the unix shell could be to just replace it with configfiles.

Systemd, the typical continuous integration tool, Kubernetes or Ansible are examples of this approach. It’s usually `yaml` coupled with some kind of templating language which is either Turing complete or annoyingly rigid.

Ironically more often than not these config files contain *some lines of shell* - which kinda defeats the point! And brings me to the next point.

## The viral infection

Shell is like herpes. You might not see it, but you got it.

Let me give you a few examples:

- `Makefiles` call shell
- Docker `RUN` is shell
- Almost every package manager definition *is* shell (Alpine, Gentoo, ...) or *uses* it either indirectly with e.g. `Makefiles` (deb based) or directly (rpm based, nix, ...)
- cron (but you should use `systemd-timers` instead!)
- SysVInit (Hello Devuan)
- Of course every file with the proper shebang, pre/post scripts, custom OS Hooks, a lot of OS automation...

The shell is embedded in the System!

These things could be rewritten to not rely on POSIX Shell anymore and use something like Nushell (or Python, JS, whatever). But if we’re rewriting 30-40 years of Unix OS building blocks we could also come up with a new and modern kernel that doesn’t rely on outdated APIs like exit codes as errors. Passing objects between processes instead of string arguments? That would make a new shell language fun! (Hello Powershell)

Apart from that, the one thing POSIX brings us is a common denominator. All Unixes use roughly the same thing. If every distro starts using a different shell, we’d be back to the 80ies when people were fighting over C-shell and Ksh/Bash/Zsh (which later got standardized in POSIX).

*Just replacing* the POSIX shell suddenly isn’t such a good plan anymore for getting rid of it.

## Changing POSIX

We could try to fix all the footguns in POSIX itself. But I don’t know. I mean coming up with `-print0` [in the 2024 standard](https://blog.toast.cafe/posix2024-xcu#the-null-option) - something implemented a *long time ago* by gnu find...

It *might* work. But we would still need to figure out how to properly fix the language. It would then take *ages* to get into POSIX - *if* it gets accepted. I’m not that patient!

Is there a way to approach it a bit more efficiently?

## Learning from the big players

So we’re not *replacing* our beloved POSIX-shell, nor are we fixing the standard. How about just removing the bad parts and “cleaning up” the language in our own implementation?

We just need to somehow get people to use our shell. 🤔

Luckily there’s a proven way how the big players - at least Microsoft - usually take over existing standards and make them their own!
[Embrace, Extend, Extinguish](https://en.m.wikipedia.org/wiki/Embrace,_extend,_and_extinguish) is a tool of the greedy. But maybe it can be used for the good as well?

We’re not trying to fuck people over, we just want to *extend* the shell (with safe and sane features) and we want to *extinguish* the unmaintainable footguns!

At some point it might make sense to come up with a POSIX alternative standard for our shell. But Bash is a good example that being POSIX compatible is apparently already enough for many people to adopt it.

## Embrace

So let’s start by reimplementing it then, like Microsoft would. And since we’re at it let’s also implement Bash because it is a bit of a defacto-standard.

In reality this would be extremely hard.

But in a hypothetical world this is super easy. Let’s just pretend aaand... **DONE**!

## Extend

While Microsoft usually extends the product, standard, or protocol in a proprietary way completely unmaintainable, incompatible and unusable for OSS, we kinda try to do the opposite. We want to make shell *easier* to understand and use.

Anyway, *how* do we extend it?

### Errors

The first and probably easiest improvement is to give a bit better error messages than bash. Since bash/shell does a really bad job at this, it’s probably not hard to improve the situation. It might also be a good argument to tell people to start using my new shell!

“Bash but more helpful” doesn’t sound bad for a start, right?
```bash
# Bad
$ if something;; fi
bash: syntax error near unexpected token ';;'

# Something like this is already much better!
$ if something;; fi
if something;; fi
             ^~
Expected word "then", got ";"
```

### Variables

POSIX and even more so Bash shell variables are crap. there are roughly speaking:

- strings
- integers which are actually strings
- bad arrays which are actually strings
- worse associative arrays which are actually strings
- errors which are actually integers are actually strings

So we want our own *types*. We just need to define (and use) them somehow.

Remember we can’t *break* shell syntax, we just *extend* it. Therefore suddenly using normal things like `myvar = 5` to create typed variables won’t work. A POSIX shell would think `myvar` is a command. What if a user wants to print out the files `=` and `5`? `cat = 5`. Ooops our shell can’t do that - the user got a variable `cat` instead!

So instead of having variable definitions and commands fight each other, let’s just create a single command `var` to define a variable. That also matches the “command argument” philosophy where `var` is the command.

But it doesn’t take string arguments like we’re used to from shell. It takes a “newly invented” (read “stolen from any sane programming language”) *expression syntax*:

```bash
# Strings *need* to be quoted now!
var mystring = "hello world!"
# Floats! Take that, POSIX!
var myvar = 3.826482
# since strings have to be quoted
# we don't need `$` to specify vars in our new expression mode!
var mylist = [ 1, 2, "hello", [ "nested"], myvar ]
# Dicts
var ainurs = {
  Melkor: 'He who rises in might',
  Manwe: 'The blessed one'
}

# booleans, bit operators... whatever the others have!
var mybool = myvar + mylist[0] > (1 << 2)
```

### Control Flow

We have the expressions, but how can we use them *without* breaking our shell?

Interestingly `if ( ... ) { ... }` is a *syntax error* in bash. Because it’s missing the `; then` (and `fi`).

Cool!

We can use what all the other languages use. That will also immediately tell people “we’re using an awesome modern shell here ;)“.

And the best: We can do the same for while and for loops!

```bash
while (myvar < 9000) {
  var myvar += 1
  echo "So much work! But already $myvar"
}
if (myvar > 9000) {
  echo "IT'S OVER NINE THOUSAND!!!"
}
# nope. bash will never have something remotely looking like this!
for ainur, translation in (ainurs) {
  echo "$ainur translates to '$translation'"
}
```

This already feels a lot more like Python or Javascript to me.

### Interpolation

Now shell has a *lot* of strings. Everything after a command is a string. And almost every line is a command (followed by strings).

Funny story:

| > The Thompson shell - the first unix shell - had exactly 6 “builtin” commands. Even `if` was an *external* command. So not only was *every* letter part of a command or string, 99.2% of all lines were *external files* being executed. |

Anyway, we want our sexy data types in these strings. Let our nice expressions & strings do some kissing!

Numbers (and strings, lol) are easy. We just use `“$what $we $already $now”`.

It’s just lists & dict’s that don’t work... 🤔

We could do automatic serialization. Always present them as json or something. But that’s not flexible!

Let’s ignore these two for now and just try to get *expressions which return a string* working. something `"like $(echo THIS BUT WITH EXPRESSIONS)"`.

...
`$[]` syntax is still unused in shell and up for sale?
*SOLD OUT!*

```shell
# Why not introduce a fancy way of creating string-only lists?
# POSIX can split. So can we!
# Expression mode is our land of freedom.
var ex = :| Just just just |
# same as ["Just", "just", "just"]

echo "$[ex[0]] as long as we $[ex[1]] get a string, expressions $[ex[3]] work this way"
# ah, so sexy. dot operator for dict elements. I'm Lovin' it!
echo "Hi, I am $[ainurs.Melkor]"

echo "$num1 + $num2 = $[num1 + num2]"
```

### Functions 1

Now to the other problem. We need a way to transform our lists and dicts into strings.

Maybe shell functions?

There are many things wrong with them, though:

- they only take positional arguments
- These arguments are only strings
- They can only return data in 3 weird ways:

- echo to stdout/stderr
- an exit code
- “leaking” variables by setting global variables or using `nameref`

- They are not *scoped* by default, so variables not pretended by `local` are always global.

Though parts of this (positionals, exit code, stdout/stderr) are not shells fault! This is just the Unix process interface. Maybe it makes sense if we keep this - in the end that’s what allows us to simply `pipe | things | around`!

Let’s start off by fixing the problems but still keep the “linux subprocess interface” somehow. It’s always good to be able to e.g. wrap an external command (`ls() { sl; }` :).

So our “optimal” still-linuxy function will:

- take positional strings
- use stdout/stderr and allow io redirections with `| > <`, etc.
- return an exit code
- be properly scoped

And just because we can, let’s dream a bit. It should also:

- take optional typed arguments

- positional and named

- just for the fun (and 💸), let’s also pass *blocks of code* to our function. That might turn out to be useful, you’ll see.

I think that may work. Like with `var`, we pretend that no one ever wants a command called `proc` and use that.

We will define our procs in a way they can be called with simple `mycommand arg1 arg2`. But we want optional typed data as well... 🤔

In the past we have `EXPRESSIONS` inside `$[]` (which *returns a string* so that doesn’t work), after the pattern `var X =` and inside the `()`  in control flow... So the kinda obvious pick would be `mycommand string arguments (my, typed, data)`.

What happens if the user wants to pass 3 strings `(my`, `typed,` and `data)`? I guess `mycommand "(my," typed, data)` would work! A little sacrifice for a big improvement. Quoting strings in shell is done unnecessarily often anyway.

Moving on to the definition of a proc. We’re to define `proc`s how we want. We *own* `proc` now!

So incorporating everything, a proc can be defined like this:

```bash
proc myproc (stringy, argument, list;
            positional, typed, args;
            named, typed, args;
            block) {
  echo "$typed, $argument, $[NAMED[0]]"
  echo "$stringy" >&2
  # looking scary, but it's actually not :)
  # our builtin taking a "block"
  eval (block)

  return 0
}
```

The different kinds of arguments are seperated by a `;` and of course everything is optional. So we can do stuff like this:

```bash
proc cddo (path;;block) {
  # we could use the "old style" x=$()
  var oldpw = $(pwd)
  cd "$path"
  eval (block)
}

# Sexy, isn't it?
cddo / { rm -rf * }

proc yoda-three (;mylist) {
  echo $[myllist[2]] $[myllist[1]] $[myllist[0]]
}

var l = :|shell is awesome|
yoda-three (l)

proc legacy (name, quote) {
  echo "and $name shall speak!"
  cowsay $quote
}
legacy "Eru" "You shall sing the song of the shell"
```

The `;` seem confusing but it you’ll get used to it.

### Functions 2

Phu, that took a bit of time... But let’s get to the other part.

> Now to the other problem. We need a way to transform our lists and dicts into strings.

Remember? The `proc` didn’t really get there... I couldn’t even come up with a reasonable example for typed data in a proc! So let’s do something *with typed data*. Like all the other languages.

We still have our expression mode, in which any unquoted word can only be a variable right now. Why not allow functions there as well? We only need another word to *define* them...
`func` is ALSO still free!

Shell is really easy to extend.

So nothing special there I guess, functions like in any other language:

```bash
# Nothing new if you know any popular "C-like" language
func join(list, sep=" ") {
  var x = ""
  for i in (list) {
    # concatenation is with ++ :)
    var x = x ++ sep ++ i
  }
  return (x)
}
var something = [
  "hello", 5, "worlds!"
]
echo "$[join(something, "-")]"
# even better. => to chain.
# Some of these funcs could be builtin!
echo $[something=>join()=>upper()=>trim()]
```

This will allow us to write proper functions to play with data.

I think it’s reasonable to specify that dicts & arrays are passed to `procs` and `funcs`*by reference* while strings & scalars are copied.

### Expressions to throw away

OK let’s quickly recall the places where `EXPRESSIONS` take place and what result is expected:

```bash
# whatever is returned will be stored in x
var x = EXPRESSION
func (x=EXPRESSION) { }

# Needs to be (convertable to) a string
echo $[EXPRESSION]

# Will be converted to a bool
# Everything converts to true except empty str/array/dict, 0 and `null`
if (EXPRESSION) { }
while (EXPRESSION) { }

# Wants a dict/list
for x, y, z in (EXPRESSION) { }
```

But is that enough?

What if we create a function which has a sideeffect but does NOT return anything? Or for debugging?

Let’s use up just two more “words” `call` and `=`:

```bash
# run expression and throw away result
call EXPRESSION
call myarray => append('elem')
call myarray => sendtoServer()
# Let's throw away the last element
call myarray => pop()

# print out the return value on the prompt!
= EXPRESSION
= 5 + 5
# => (Int) 10
= {a: 5} => toJson()
# => (Str) "{'a':5}"
= :|some words| => append('more')
# => (Null) null
# (it has a sideeffect but returns nothing)
```

I think that’s about it with our extensions for the moment. Of course there’s a lot more that *could* be done. But let’s instead focus on the next part, how do we *get rid of legacy code*?

## Extinguish

So let us remove all the stuff from the language that we replaced:

```bash
var=value
if ...; then ... fi
for ...; do ... done
while ...; do ... done
[[ ... ]]
[ ... ]
((SHELL EXPRESSION))
$((SHELL EXPRESSION))
let "SHELL EXPRESSION"
${variableEXPANSION}
```

How can we get rid of it while still being somewhat Bash/POSIX compliant?

As Sheldon from The Big Bang Theory would put it:

> Welcome to Fun With Flags!

Shell already has a bunch of flags to enable/disable stuff. And even normal Beings sometimes use this “You need it or your script will kill you”-idiom:

```bash
set -eo pipefail
```

It sets two flags: `errexit` and `pipefail` - exit if a command fails and a pipeline fails if any of its commands fail (not just the last). Sometimes an `u` is squeezed in between the `eo` to fail on undefined variables but you don’t really see the [other flags](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html).

Bash also has `shopt` to manage the flag stuff a bit more convenient. `shopt` is capable of printing out only a single flag and it’s value, or give an appropriate exit status depending on a flag being set or not. It can also set some additional flags POSIX doesn’t know about.

With the funcrionality already built-in, we can just come up with 2 new flags:

```bash
newshell:upgrade # enable new features
newshell:full # disable the legacy ways
```

And now we can do a nice trick used by [busybox](https://busybox.net/FAQ.html#getting_started) to get properly rid of bash/POSIX/etc: Symlinks.

We have our binary installed at `/bin/newshell` and create a symlink `/bin/bash -> newshell`. Running `/bin/bash` will run *our newshell*. Of course without the above mentioned flags enabled. But if we run directly `/bin/newshell` these flags will be set! The same can be done for `/bin/sh` to get rid of POSIX shells on my system as well.

Now we can go into any shell script, add `shopt -s newshell:upgrade` to start using our new fancy things.

Once all the old crap is gone we can use `shopt -s newshell:all` to stop ourselfs from falling into old patterns - or we change the shebang to `#!/bin/newshell` where we enable the flags by default.

## Let’s do it?!

Now you might say “cool, but this is a $#@-load of work!”.

Exactly.

It’s also possible that you already guessed it: I just showed you the basics of [Oils](https://oilshell.org/)!

So instead of dreaming, you can check out the project, install Oils, run Osh and start upgrading to Ysh!

A few important notes though:

- I’m not the author of Oils. I’m just a sysadmin and *super glad* that Andy Chu started this project around 2016
- I simplified some parts, [especially `flags`](http://www.oilshell.org/release/0.23.0/doc/options.html). In reality many changes can be turned on and off individually (see also the [gradual update docs](https://github.com/oils-for-unix/oils/wiki/Gradually-Upgrading-Shell-to-YSH))

- Oils also goes *much further*, e.g. disabling generally bad shell things that can be done better without new concepts. So just using the flag `strict:all` can help make a POSIX script better without giving up compatibility!
- Setting the flag `ysh:upgrade`[actually disables a few things](http://www.oilshell.org/release/0.23.0/doc/upgrade-breakage.html)
- `ysh:all` is subject to change and enables some things, but does NOT (yet) disable the things I said. It’s planned but low prio right now.

- Errors do look a bit differerent and are currently not always that nice. But it’s mainly missing [feedback/contributions](http://www.oilshell.org/release/0.23.0/doc/error-catalog.html#how-to-contribute) and will become better over time
- There are a few more things to [proc and funcs](http://www.oilshell.org/release/0.23.0/doc/proc-func.html) than I mentioned

- `=>` are only for non-mutating functions, while mutating funcs use `->` (e.g. `myarr->append()`)

- Ysh contains [many more new things](https://www.oilshell.org/release/latest/doc/ysh-tour.html), I just wanted to highlight one thing (expressions) as an example to explain the idea of the project
