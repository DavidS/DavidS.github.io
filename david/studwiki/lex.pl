#!/usr/bin/perl
#
## (C) Copyright 2003 by David Schmitt

use strict;
use warnings;

$| = 1;

my @tokens;
my $tokenpos;

sub ulist($)
{
	my $stars = shift;
	return "\n\0ULI " . length($stars) . "\001\0";
}

BEGIN
{
	$/ = undef;
	my $file = <>;
	$file =~ s/\0//g;
	$file =~ s/\001//g;
	$file =~ s/\n(\*+)/ulist($1)/eg;
	$file =~ s/^\s*\n/\n\0EMPTYLINE\001\0\n/g;
	$file =~ s/\n\s*\n/\n\0EMPTYLINE\001\0\n/g;
	# $file =~ s/\n/\0NL\0\n/g;
	# $file =~ s/ +/\0SPACE\0/g;
	$file =~ s/([{}:])/\0SPEC\001$1\0/g;
	$file =~ s/\0\0/\0/g;
	my @strings = split /\0/, $file;
	for my $token (@strings)
	{
		#print "t: '$token'\n";
		$token =~ m/^([^\001]*)(\001(.*)?)?$/;
		#print "1: $1, 2: $2, 3: $3\n";
		my ($type, $val) = ($1, $3);
		unless (defined($2))
		{
			($type, $val) = ("STRING", $type);
		}
		#print $type, "=>", $val, "|";
		push(@tokens, \{type => $type, val => $val});
	}
	$tokenpos = 1;
}

sub yylex
{
	if (defined($$$tokens[$tokenpos++]{val}))
	{
		return ($$$tokens[$tokenpos++]{type}, $$$tokens[$tokenpos++]{val});
	}
	else
	{
		return $$$tokens[$tokenpos++]{type};
	}
}

