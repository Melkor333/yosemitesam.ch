---
title: No more APK ADD
slug: no-more-apk-add
# For some reason just setting `excerpt` here is ignored. frustrating!
post:
  excerpt: "Don't use `apk add` in your CI or a Dockerfile anymore."
date_published: 2024-06-17T07:27:02.000Z
date_updated: 2024-06-17T07:27:59.000Z
---

Who doesn’t know something like this:

```Dockerfile
FROM alpine:latest

RUN apk add make
```
    

Just to then be able to specify somewhere in your CI

    make
    

`make` is just an example, but I often see containers with only one or two packages added.

These kinds of containers are usually used for a simple build step.

There are 2 typical approaches to install the necessary package, which both have their downside:

- I use a Containerfile as above to generate an image

  This means I need to build a container & upload it to a registry first.

  Building docker images in a CI is not always trivial (though it’s gotten better) and requires a bit of extra effort like an extra build/upload step in the CI, a registry I can upload it to, secrets to authenticate against the registry...
- I run the command directly in the CI.

  It has to run every time the CI runs - which means a lot of unnecessary compute & wait time!

  But given that the previous solution requires a bit of time to set up, this is the “lets’ get it done quickly” approach often taken

  Now let me introduce to you another way to solve this small annoyance.

# Nixery

[Nixery](https://github.com/tazjin/nixery) is a “container registry” which can produce a minimal container image with only the packages you need. For example when I pull the image `nixery.dev/bash/gnumake/musl` it will generate an image with the 3 specified packages `bash`, `gnumake` and `musl` ad-hoc. The packages are built from [Nixpkgs](https://nixos.wiki/wiki/Nixpkgs) and copied into the container including their own dependencies. This is done *on the server* at “pulltime”. That means all I do is specify the above container to pull and I don’t need any extra step.

So an example `gitlab-ci` task which I actually used to run an install step which just copies files into the `install` directory to be packaged in a later phase:

```yaml
build:
  stage: install
  image: nixery.dev/bash/gnumake/musl
  script:
    - make install
  artifacts:
    untracked: false
    paths:
      - install

...

stages:
  - install
  - package
```


What packages can I use that way? **MANY**! According to [repology](https://repology.org/repositories/graphs) it’s the repository with *by far* the most packages. There’s also a [search](https://search.nixos.org/packages?) where you can check if a package you require in your container is available (and how it’s called).

And if you’re a bit of a nerd; it’s not even *that* hard to add a new package [to the nixpkgs repository](https://github.com/NixOS/nixpkgs). At least much easier than getting a package into any of the major distributions.
