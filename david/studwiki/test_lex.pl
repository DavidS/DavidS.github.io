#!/usr/bin/perl
#
## (C) Copyright 2003 by David Schmitt

use Lexer;

my $l = Lexer->new();

$l->tokenizeFile($ARGV[0]);

while (defined(my $tok = $l->yylex(1)))
{
}

print;
