#!/usr/bin/perl
#
## (C) Copyright 2003 by David Schmitt

use SW;
use Lexer;
use Carp;
use Data::Dumper;

my $lexer = Lexer->new();

$lexer->tokenizeFile($ARGV[0]);

my $parser = SW->createParser($lexer, \&Lexer::yylex, 0);

print $parser->yyparse();

#print Dumper($parser->{markups});
print;
