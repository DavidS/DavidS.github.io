#!/usr/bin/perl
#
## (C) Copyright 2003 by David Schmitt

use strict;
use warnings;
use SW;
use SW::Utils;
use Lexer;
use CGI;

my $q = new CGI;

print $q->header();

SW::Utils::render_page($q, $q->param('page'));
