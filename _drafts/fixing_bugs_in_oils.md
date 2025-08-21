### Getting it to 5%

This blog post could continue for a bunch of chapters. But the few people who read until here should soon be rewarded with the achievement of finishing it! Thanks for your interest :-)

We're at 84%, this means we need to fix 11%! If we cheat a little bit and take 10.5% as good enough, it's 165 packages, exactly the first 5 categories!

Some of these categories don’t seem like Oils bugs, and especially 2 of them I immediately fixed:
- `29 abuild - cant fetch package index`
  - This happened due to a network issue, `abuild` couldn’t download the source for the package
  - The fix was to just rerun the builds :)
- `15 build timeout`
  - As already pointed out, there was an infinite loop. So I set an arbitrary timeout of 1800 seconds in the `buildrepo` shell script. It just executes `abuild` for every package and I changed it to `timeout 1800 abuild`
  - I just reran them with a timeout of 18000 seconds, which allowed the GCC, Node, LLVM, etc. to build but still stopped the infinite loops at some point

With these things fixed I did another categorization. The top ten only slightly changed. Most importantly I now know that there are 4 packages which all use `gpgrt-config` and run into the same bug :)

```
     59 ifs=\\
     39 broken testsuite
     25 cmake error - compatibility unsupported
     15 libtool invalid word while parsing
     11 mkdir: unrecognized option: /
     10 config.status compile error
     10 abuild dependency issue (e.g. depends on busybox-binsh)
      9 abuild - fetch source issue
      6 (( .. ) .. )
      5 atf-test-program fail
      4 gpgrt-config timeout
      ...
```

Now it’s *finally* time to look into bugs! 🎉🎉🎉

# Chäferfescht

> Chäferfescht is a swiss term that literally translates to "bug party". It is used to describe a small irrelevant event. "You’re really going to this party? What a chäferfescht"

The top issue `ifs=\\` is a known bug in Oils I already found in 2024 when I tried to build nixpkgs with Oils ([zulip thread](https://oilshell.zulipchat.com/#narrow/channel/307442-nix/topic/mpfr.20package.20build.20failure.20-.20DLT_OBJDIR/with/477522248)). It’s *really hard to fix* thus required a [(still open) PR](https://github.com/oils-for-unix/oils/pull/2353) from a [nuclear physicist](https://akinomyoga.github.io/). 😛

> Koichi Murase is the author of one of the biggest bash scripts - [the line editor ble.sh](https://github.com/akinomyoga/ble.sh) - has sent patches to Bash and has been active in the Oils zulip chat for a long time. He also fixed various bash incompatibilities and added some bash specific features.

We’re very glad that at least for the `main` repo, we already almost fixed the biggest bug!

