---
title: "DavidS' CV"
description: "A quick overview of the projects I've worked on over the years"
permalink: '/cv/index.html'
layout: default
---

<div style="float: right">
<img src="{% link /assets/2020-12-david.jpg %}" height=250 style="max-width: 100%; border-radius: 5%; margin: 3em;"  />
</div>

Throughout my career I've approached new projects with curiosity and the desire to improve the product, the process and myself.

# Major Projects

* 2021 (ongoing): Puppet Native Testing - Move fast, without breaking things. Principal Software Engineer at Puppet, Inc.

  A regular complaint of customers and the open source community is Puppet's requirement for writing infrastructure tests in Ruby and RSpec.
  This is a major adoption blocker for newcomers to infrastructure automation. This year I could initiate a new project to address this.
  Puppet Native Testing combines new and existing components under a new Developer Experience tool.

  With Puppet Native Testing, customers can get documentation, unit testing and system integration testing from a single test case definition written in the Puppet DSL they already know.
  Removing Ruby and RSpec from the pipelines reduces onboarding cost and provides an improved CI/CD experience as part of Puppet's paid offerings.

  Skills and technologies used: Product Design, UX Research, Ruby, Puppet internals, CI/CD


* 2021: node/NestJS/TypeORM backend on AWS. Backend Engineer at pre-seed Startup

  As part of a fixed-scope, fixed-term, fixed-cost contract I joined the engineering team of a pre-seed Startup to build out the infrastructure and backend for a mobile app.
  My main responsibility was bootstrapping and implementing a new node-based GraphQL service using NestJS and TypeORM to manage and access the database.
  This included regular syncs with the frontend engineer to align the data model and API to the needs of the mobile app.

  As the project progressed, I also implemented Stripe Payments, backend observability with honeycomb, continuous deployment of the backend service into AWS Fargate, continuous build and deployment of the react-native based app through expo.io, and a number of data import and ETL jobs to seed the database.

  Technologies used: TypeScript, yarn, node, NestJS, TypeORM, postgres, honeycomb.io, AWS (CodeBuild, ECS, Fargate, ECR, Secrets Manager, IAM), react native, expo.io, CI/CD


* 2019-2021: Reduce CI cycle time and improve reliability. Principal Software Engineer at Puppet, Inc.

  As part of my team's open source maintainer responsibilities, we review and merge community contributions across ~70 public repositories.
  A major part of this work was maintaining complex CI scripts on a private Jenkins instance with limited resources.
  The weak CI system meant a lot of churn and rework as problems only surfaced after merges or through customer reports.

  To address these issues we formed a small task force (myself and two senior engineers) and re-built the entire CI process on top of Github Actions with a custom service on GCP to provision ephemeral compute resources for our required system integration tests.
  The new CI pipelines use a mix of docker containers and full GCP-hosted VMs (for licensed systems) for system integration testing.
  Now all our public Open Source repos have fully automated CI responses within 20 minutes, nightly scheduled builds and less than 2% overall failure rates for about 20 USD per day.
  Through full integration with honeycomb.io we get real-time, easy to query insights across service and test health.

  Throughout the project I drove technical direction, system and API design, cloud strategy (services, environments, deployment), collaborated on project management with the engineering manager, and assisted my team members to skill up on the new technologies.

  Skills and technologies used: Ruby, sinatra, RSpec, terraform, GCP (Cloud Build, Cloud Run, Container Registry, Firestore, Compute Engine, Cloud Storage, networking), Swagger/OpenAPI, honeycomb.io, Github Actions, system-level testing, CI/CD

* 2019-2021: Cheesy::Gallery - simple management of large galleries. Personal Project

  For my [partner's website](https://www.cheesy.at) I've implemented a new [jekyll photo gallery](https://github.com/DavidS/cheesy-gallery) that allows my partner to handle ~30k (~45GB) pictures in her blog and galleries.
  This project also included migrating ~900 posts, and 1500 galleries from the previous Wordpress site.

  Skills and technologies used: Ruby, jekyllrb, wordpress, migration, ETL, nokogiri.

* 2019: Improving Puppet's Network Automation Offerings. Principal Software Engineer at Puppet, Inc.

  To catch up with a competitor's offering, a new team was formed to improve Puppet's Network Device Automation offerings.
  During a year of development, building on the previous success of the Resource API (see below), the team built a backend service for the new commercial product feature, supported the frontend team to build out the UI for this, integrated into the existing installer and authorization framework, solved a couple of structural problems, implemented support for several device families, and liaised with a device vendor's team to bring their agent-based code forward to the newer agent-less solution.

  Skills and technologies used: Ruby, sinatra, API design, Developer Experience Design, cross-team collaboration, systems programming


* 2017: Resource API. Senior Software Engineer at Puppet, Inc.

  Designed, implemented, documented and integrated a convenient wrapper around the existing low-level API to build native Puppet integrations.
  The low-level API (for which official docs, a lot of blogs and several books exist) has been described regularly as "ok, but needs docs."
  With the Resource API, attendees to a workshop could build a working Puppet integration inside of two hours, following the hands-on-lab that I wrote.

  Skills and technologies used: Puppet-internals, ruby, technical writing, API design, README-driven development.


* 2015-2018 **Senior Software Engineer**; Puppet, Inc.; [Modules Team](https://forge.puppet.com/supported),
  [PDK](https://puppet.com/docs/pdk/1.x/pdk.html)

* 2014-2015  **Puppetwrangler**;
  *Jumio Software Development GmbH*;
  Puppet, collectd, opentsdb, python, mongodb

* 2008-2015  **Puppetwrangler**;
  *Boehringer-Ingelheim RCV GmbH*; Puppet, RHEL5, RHEL6,
  Scientific Linux 6, PostgreSQL, The Foreman, PuppetDB,
  ruby, libvirt/KVM, apache, tomcat, SGE/OGS, ganglia,
  icinga, kickstart, MediaWiki, Chiliproject, gitlab

  > David unterstützt uns flexibel und innovativ bei der Verbesserung und
  > Beschleunigung interner Abläufe. Die entwickelten Lösungen ersparen
  > unseren Mitarbeitern täglich Zeit.
  >
  > **Erhard Wais, System Manager, Boehringer-Ingelheim**

* 2007-2013  **Founder, Softwaredevelopment, UX, DB**;
  *[dasz.at OG](http://dasz.at)*; C#, MSSQL, PostgreSQL, NHibernate,
  jenkins, NUnit, WPF, WCF, Autofac, FogBugz, Windows Server, Mono

* 2006    **Applicationdeveloper**;
  *ERES NET Consulting – Immobilien.NET GmbH*;
  C#, ASP.NET, MSSQL

  > Using his invaluable skill set and experience, David quickly became
  > an indispensable team member and gave the project a real boost. His
  > extraordinary expertise and competence makes him an outstanding
  > colleague with whom it was a pleasure to work.
  >
  > **Josef Pfleger**

* 2005    **Internship: Merbershipmanager**;
  PHP, postgresql, data recovery

* 2001-present  **Web/Mail/DNS [Hosting](https://github.com/DavidS/dasz-configuration/tree/master/modules/hosting)**;
  *[edv-bus.at](http://www.edv-bus.at/)*; Debian, apache, nginx, exim, bind,
  puppet, systemd, SSL, openvpn, libvirt/KVM, linux-vserver, mysql, postgresql,
  php, ruby

* 2001-2010  **Sysadmin, Development**;
  *ZID der Universität für Angewandte Kunst*;
  Debian, apache, exim3, exim4, Cisco, Puppet, Asterisk, nagios, munin,
  openldap, postgresql, openvpn, backup, samba, RHEVM, Hardware, ruby,
  [puppet-networkdevice](https://github.com/uniak/puppet-networkdevice)

* 2000  **Internship: Developer**;
    *ace GmbH*; Java, C++, Microsoft

* 1999  **Implementierung einer Kunden- und Produktverwaltung für einen Kabel-ISP**
    / **Implement customer and product management for a cable ISP**;
    *HEIRU*; PHP, mysql, perl, Debian

* 1999  **Internship: Developer**
    *Coco Software*; Java, XML

* 1996-2001 **First-Level Support for students in the PC pools**;
    *Technical University of Vienna*;
    Windows, Linux, Internet

# Ausbildung / Education

* 2007  **Dipl.-Ing.** der *Technischen Informatik an der TU Wien* /
  **Master of Engineering** at the *Technical University of Vienna*

* 1998  Bundesheer / Army Service

* 1997  Matura (Mathematik, Englisch, Deutsch, Informatik) BRG8 Albertgasse
