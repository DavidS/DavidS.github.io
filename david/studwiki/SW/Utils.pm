#!/usr/bin/perl
#
## (C) Copyright 2003 by David Schmitt

package SW::Utils;

use strict;
use warnings;

use SW::Conf;
use Data::Dumper;

sub read_pageindex()
{
	opendir(DIR, SW::Conf::datadir());
	my $result;
	for my $dir (grep { /\.sw$/ && -f SW::Conf::datadir().$_ } readdir (DIR))
	{
		$dir =~ s/\.sw$//;
		$result->{$dir} = 1;
	}
	return $result;
}

sub sanitize_page($)
{
	my $page = shift;
	$page = "StartSeite" unless defined($page);
	$page =~ s/^.*?(\w*).*$/$1/;
	return $page;
}

sub render_page($$)
{
	my $q = shift;
	my $page = shift;

	$page = sanitize_page($page);

	my $l = Lexer->new();
	$l->tokenizeFile(SW::Conf::datadir()."$page.sw");
	my $parser = SW->createParser($l, \&Lexer::yylex, 0);
	my $body = $parser->yyparse();

	print "<html><head><title>input.sw</title></head><body>\n";
	print "<a href=\"/sw/show.pl?page=StartSeite\">StartSeite</a> | <a href=\"/sw/register.pl\">Registrieren</a> | <a href=\"/sw/edit.pl?page=$page\">Editieren</a>\n<hr>\n";
	print "<table border=1>\n";
	for my $key (keys(%{$parser->{specials}}))
	{
		print "<tr><td>", $key, "<td>", $parser->{specials}->{$key}, "</tr>\n";
	}
	print "</table>\n\n";
	print "$body\n";
	print "</body></html>\n";

}

1;
