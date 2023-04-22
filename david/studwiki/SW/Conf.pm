#!/usr/bin/perl
#
## (C) Copyright 2003 by David Schmitt

package SW::Conf;

use strict;
use warnings;

sub basedir()
{
	return "/home/david/local/studwiki/";
}

sub datadir()
{
	return basedir()."data/";
}

sub rcsdir()
{
	return datadir()."RCS/";
}

sub pageindex_location()
{
	return datadir(). "/__pageindex.pl";
}

1;
