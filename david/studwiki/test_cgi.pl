#!/usr/bin/perl
#
## (C) Copyright 2003 by David Schmitt

use strict;
use warnings;
use SW;
use Lexer;
use CGI;

my $q = new CGI;

print $q->header();


my $l = Lexer->new();
my $content = $q->param('editarea');
$l->tokenizeString($content);
my $parser = SW->createParser($l, \&Lexer::yylex, 0);
my $body = $parser->yyparse();

print "<html><head><title>input.sw</title></head><body>\n";
print "<table border=1>\n";
for my $key (keys(%{$parser->{specials}}))
{
	print "<tr><td>", $key, "<td>", $parser->{specials}->{$key}, "</tr>\n";
}
print "</table>\n\n";
print "$body\n";
print "</body></html>\n";
