#!/usr/bin/perl
#
## (C) Copyright 2003 by David Schmitt

use strict;
use warnings;
use SW;
use Lexer;
use SW::Utils;
use SW::Conf;
use CGI;
my $q = new CGI;

print $q->header();

my $content = $q->param('editarea');
my $page = SW::Utils::sanitize_page($q->param('page'));

my $filename = SW::Conf::datadir().$page.".sw";
open OUTPUT, ">$filename" or die "Saving: cannot open '$filename': $!";
print OUTPUT $content;
close OUTPUT;

{
	use Rcs qw(nonFatal Verbose);
	chdir SW::Conf::datadir();
	my $rcs = Rcs->new($filename);
	$rcs->rcsdir(SW::Conf::rcsdir());
	$rcs->ci('-l');
}

print "<hr><p>Seite $page gespeichert. Danke für Deine Aufmerksamkeit.</p><hr>\n";

SW::Utils::render_page($q, $page);
