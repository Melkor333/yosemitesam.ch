---
title: Nyxt first impressions
slug: nyxt-first-impressions
date_published: 2023-11-08T06:26:36.000Z
date_updated: 2023-11-10T05:50:17.000Z
---

Recently I’ve been very unhappy with Firefox and Chrome. As a "power user" I think they're really limited and extensions like Vimium can't really be *that* polished.
I've used [Qutebrowser](https://qutebrowser.org/) before but somehow never stuck with it.
And for some reason I decided I want to give [Nyxt](https://nyxt.atlas.engineer/) a try now.

Conceptually it is very appealing to me, as it's inspired by Emacs and therefore extremely customizable.

And oh boy, I *love* the experience on this unicorn ride!

Here's a few things after a few days of using it.

## No clutter

Look at how freaking minimal this is! 2 lines at the bottom (and one of them usually empty).

![Screenshot of the Nyxt browser](/assets/images/nyxt_view.png)

**THATS**

**IT**

I’m not missing anything.

## Open anything, *very fast*

using `o` in vi mode (or `ctrl+l` in emacs/cua mode) runs the command `set-url`, which is just awesome. by default it will either open the URL you type or search for something (when it's not an url).
But in the prompt it will also show you e.g. the global history, already open buffers or bookmarks. you can jump between the types by using `m+n` and `m+p`. `ctrl+n` and `ctrl+p` are for navigating single entries.
I also like that it “previews” the buffer when I hover over an existing one (it also loads currently unloaded ones. Not sure I like that too much, though).

![Showcase of the workflow to open a new tab or existing buffer](/assets/images/2023-10-12-14-59_nyxt_awesome_open-1.gif)

# a *REAL* command prompt

There are omnibars for chrome/firefox. I’ve used some of them in the past. But the integration is always a bit... meh. Nyxt comes with a command prompt you would expect from a Emacs-inspired browser. It even shows the keybindings (though I still miss [which-key](https://github.com/justbur/emacs-which-key)):

![Showcase of the commandprompt](/assets/images/2023-10-12_13-17-08_nyxt_command_prompt.gif)

## MOOOODDEEESSS

There are already quite some modes implemented (in lisp) to show you what is possible:

- no-image-mode -> Don’t download images
- no-script-mode -> Don’t run scripts
- cruise-control-mode -> automatically scroll down
- dark-mode (see gif above!)
- force-https-mode
- proxy-mode (YES! PER BUFFER! there’s ways to make it global)
- repeat-mode
- and *many* more!

![Showcase of the cruise-control-mode](/assets/images/2023-10-12-15-25_nyxt_cruise_mode.gif)

## Extensibility

This is all just "builtin" stuff ready to be changed and extended, or "molded" as some emacsers would say.
I know it’s `common lisp`... But IMO still better than a new vimscript 😜

Btw. this whole blog post was written with only the below vi snippet in my configfile, so this is a topic I'll have to explore...

# Warts

The unicorn sadly does have a few warts I noticed.

## Vi mode everywhere? NO!

The documentation only shows you how to enable vi mode globally. This is really ugly. If you enable vi mode and then press e.g. `o` to open a new buffer, you’re still in vi-normal mode. This means you have to press `oi` to be able to start typing in the prompt. Like `:` in vim I expect to be in a more emacs-y mode when opening any prompt.

The proper snippet to fix this is (the `:web-buffer` is very important here):

    (define-configuration :web-buffer
      ((default-modes (append (list :vi-normal-mode) %slot-value%))))
    

## Enter the common lisp community

The editor is mostly written and extensible by using common lisp. This is fine (I guess). But be ready to embrace the common lisp world! I’m not there yet, which is why I’m still mostly confused from the best [example configuration](https://github.com/aartaka/nyxt-config).
I’m learning about [asdf](https://asdf.common-lisp.dev/), [quicklisp](https://www.quicklisp.org/) and have to look at stuff like [ace](https://github.com/atlas-engineer/nx-ace/tree/master) which I don’t really want to know about. (WHY do you want to transform a browser into an editor????).

Thinking about it though, this is no different than emacs/vim. My brain is full of all these emacs-specific things and (n)vim is even worse - the amount of package managers from vim is insane!

I'm used to a browser that *just works* ™️ and have to shift my mindset a bit.

## Enter passtrough mode - forever!

I use [silverbullet](https://silverbullet.md) to take notes (and write this blog) but when I enter the [passthrough-mode](https://nyxt.atlas.engineer/documentation#passthrough-mode) and type something, I just can’t exit passthrough mode anymore.

## Hidden links

One of the main features of this browser is the keyboard driven experience. This seems still a bit in it’s infancy though. I *really* like the idea of being able to search for the text OR be able to type a 2 letter shortcut (much better than qutebrowser, even if you have to type `Enter` to actually follow!), but when it’s underneath the prompt, well, bad luck, you will not see what you select.

![Showcase how links are invisible behind the prompt](/assets/images/2023-10-12-14-43_nyxt_bottom.gif)

## WTF is this buffer list

I really don’t get this ugly buffer list from such a “minimal” browser. Why all the margins? Why not make all Divs the same width?
This could be an issue of personal taste, though.

What I really don’t get is that it doesn’t even update automatically? You really want me to click the “Update” button after I’ve deleted a Buffer?
Isn’t the whole joke of this browser that there are all kinds of hooks to automatically do such things for me?

![Showcase of the very not-pretty buffer-list](/assets/images/2023-10-12_12-46-46_ugly_buffer_list.png)

## Random Freezes

It happened a few times that when i pressed `o` to open a new URL, the browser just froze. I had to shoot the process in the head. I have no clue what caused it - it seemed to happen at random times - but I hope that I’ll eventually see a pattern if it happens again. But given that my Firefox config had it’s own share of freezes (probably using too many extensions 😄), I’m sadly a bit used to this.

## Sloppy Search

I’m used to google search. It’s fast and VERY accurate. the default search [https://search.atlas.engineer](https://search.atlas.engineer) is neither. I’m sorry but the results are just horrible. I searched for a local company with “COMPANYNAME zurich” and it only gave me american stuff (and surprisingly many linkedin links).
I assume they have this as default search to hopefully gather some insights on who is using nyxt. And I thought I’ll try to get along with it. But I can’t.

## Broken in-document search

Searching in a document is very satisfying. *IF* it works. E.g. you can’t really search in a file opened on Github!
![Showcase of how I search for &quot;defvar&quot; and not get any results even though I should](/assets/images/2023-10-13_nyxt_search-1.gif)

# Conclusion

I *really* like Nyxt. The few awesome examples don't look like much, but they change the UX **completely**.
There are quite some pain points - but **most of them can be fixed with some configuration**.

The Pros *definitely* outweigh the cons! 

What will I do now?

- I will keep using Nyxt for my main browsing.
- Firefox will still be open most of the time for my note taking and other things which just don’t (yet) work, like J[itsi](https://jitsi.org/).
- I will hopefully go deeper down the rabbit hole and eventually learn more about [creating my own extensions](https://nyxt.atlas.engineer/article/nyxt-extensions-tutorial.org), features such as [annotations](https://nyxt.atlas.engineer/article/annotations.org), [hooks](https://nyxt.atlas.engineer/documentation#hooks), etc.
- And at some point, maybe, I will keep Firefox only as a “cold” backup

### And you?

I hope you enjoyed the read and if you like tinkering with such tools - give Nyxt a try as well! 🙂
