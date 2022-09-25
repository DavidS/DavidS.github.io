---
title: "Universal Pipeline Compiler"
category: programming
tags: ci continuous-integration pipeline definition compiler python rust experiment design
---

## Introduction

What follows is a dramatic re-enactment of a couple of days of processing a lifetime of painful "second day" experiences with programming ecosystems.

While - or maybe because - my [last project](https://twitter.com/dev_el_ops/status/1573756127455608838) was specific to [CircleCI](https://circleci.com) one thought that didn't leave me was how annoying it was to set up the basic CI pipeline to get linting, testing and build the rust code when the project itself had no special needs. What can be done? It's weird how we have an automatic method for running services ([buildpacks](https://buildpacks.io/)), but - coming from an operational background (its inventors are PaaS privoders, now part of the [CNCF]) - I'm not surprised that they are absolutely lacking on the software development side. With Heroku's recent departure from the OSS field, I'm also not expecting any more innovation from that side. And finally, building a container and building a package (or binary for that matter) are different things. What can we do? 

Any solution would need to be modular to support a multitude of language ecosystems and CI providers. Even within a language ecosystem, there might be different linters, test framworks and buildprocesses (e.g. binary vs library) to contend with. Going down this path of considerations reminded me of the [debhelper](https://salsa.debian.org/debian/debhelper) set of scripts that is part of Debian's efforts to package up all software. The suite of dh scripts provides a single, configurable entrypoint to configure and build Linux packages. How would that work for for a development process?

Speaking of development process, another option discarded is integrating into an IDE like VSCode. As much as I enjoy VSCode for all my authoring needs, it is not universal by any stretch of the imagination.

## Pipelines

Looking back at various pipelines I've used and worked on over the years, there is an underlying pattern:

* **restore an artifact cache:** to accelerate the following steps, it is often advised to retain some kind of temporary artifact cache across pipeline runs. Downloading and unpacking a single archive from a CI-local store will always beat installing and recompiling dependencies (and intermediaries) from a public repo somewhere else.
* **configure package sources:** not as common in the FLOSS world, but very useful for proprietary developers. Now that I work for a package hosting provider, a reality I can't ignore.
* **select/install the correct base tooling (version):** previously a major hassle, today usually provided as docker images by either the CI provider (e.g. CircleCI's [convenience images](https://circleci.com/docs/circleci-images)) or the language ecosystem.
* **install dependencies:** headers, libraries, compilers, build-tools, documentation generators, syntax checkers, style checkers, security checkers, etc
* **compile everything:** depending on the ecosystem, but very important if necessary. This usually requires a bunch of CPU (and memory) in one place for fast results.
* **automated tests:** apply, execute and collect all results from the previously installed tools: unit testing, integration testing, acceptance testing, UI testing, end-to-end testing, style checking, etc. While each individual tool usually isn't able to use lots of CPUs, farming out jobs to multiple nodes is often useful to achieve fast turn-around times.
* **updating the cache:** capture the current state in the cache subsystem to re-use on the next pipeline execution.

While the basic shape is independent of the actual tooling used, rediscovering the details for each language is tedious. Similarly, CI Provider's offerings really aren't that different, except in the config language they use, and each's little walled garden of language ecosystem support-ish.

## Tooling

After complaining about the lackluster status quo for long enough, let's have a look at what could be done.

* Like buildpacks, the tool can detect which languages are in use in a repo.
* Like debhelper, the tool can provide sensible defaults from a single entrypoint.

* Because we can't guess everything, the tool provides a nice onboarding experience.
* Because CI systems are configured through files in the repository, the tool outputs (and commits) the unrolled configuration.
* Because everyone will have additional quirks to scratch, the tool provides a mechanism to inject additional commands into the configuration.
* Because today's world is complex, the tool supports multiple languages and nested projects in a single repository.
* Because projects evolve over time, te tool can deploy incremental changes to pipelines to cover new requirements.
* Because this project evolve over time, the tool can deploy incremental changes to piplines to integrate implementation improvements.
* Because language ecosystems sign-post good behaviour, the tool integrates into them on the calling side.

## Rust/Cargo Example

```
❯ ls
Cargo.lock Cargo.toml Dockerfile src/ 
❯ cargo pipeline
Which CI provider to you want to use?
* GitHub Actions (recommended based on git remotes)
  CircleCI
  GitLab CI/CD

Detected Ecosystems:
* Cargo (rust)
* Dockerfile

Configuring GitHub Actions Pipline:
* Linting: clippy (rust), hadolint (Dockerfile)
* Testing: cargo test
* Building: cargo build --release, docker buildx
* Releasing: crates.io (rust), Docker Hub

You can change the defaults by editing `.config/pipeline.conf` and re-running this command.
❯
```

## Python Example

```
❯ ls
src/ requirements.in requirements.txt
❯ pip pipeline
Which CI provider to you want to use?
  GitHub Actions
  CircleCI
* GitLab CI/CD (recommended based on git remotes)

Detected Ecosystems:
* pip venv (python)

Configuring GitHub Actions Pipline:
* Linting: black (python)
* Testing: pytest (python)
* Building: pip build (python)
* Releasing: PyPI (python)

You can change the defaults by editing `.config/pipeline.conf` and re-running this command.
❯
```