---
title: 'Ruby on Rails on Windows'
tags: ruby rails windows debian bootstrap programming
---

There is the [RubyInstaller](http://rubyinstaller.org/) project, which is
really nice installer, with ruby 1.9 and 2.0. To install native extensions, it
has a separate DevKit package. Which is a self-extracting archive, that spills
its guts into the Downloads\\ directory without event attempting to link it
into the provided shell environment.

Then there is the [RailsInstaller](http://railsinstaller.org/en). The
RubyInstaller packs ruby 1.9, git, rails 3.2, bundler, a few libs and the
DevKit into a really nice installer. Native extensions install out of the box,
except for [libv8](https://rubygems.org/gems/libv8), which is required by
therubyracer, which is required by less-rails, which is required by
twitter-bootstrap-rails, which is my [preferred bootstrap
gem](http://black.co.at/posts/2014-08-18-bootstrap-shootout/), which
has a build dependency on Python 2. Libv8, that is. Libv8 has a build
dependency on python2. [Isn't it
ironic?](https://www.youtube.com/watch?v=Jne9t8sHpUc)

As a final solution we've settled on
[supplying](https://github.com/DavidS/hrdb/commit/439ab45c4d6eb12f3a550299f29470acf4c41a3f)
a [Vagrant](http://vagrantup.com)file and setup script to fetch and provision
ruby-on-[wheezy](https://www.debian.org/releases/wheezy/) which runs fine in
[Virtualbox](http://www.virtualbox.org) and has all the required bits.

That's enough [yak
shaving](http://www.hanselman.com/blog/YakShavingDefinedIllGetThatDoneAsSoonAsIShaveThisYak.aspx) for now.
