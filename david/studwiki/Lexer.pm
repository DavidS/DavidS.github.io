#!/usr/bin/perl
#
## (C) Copyright 2003 by David Schmitt

package Lexer;

$| = 1;

use strict;
use warnings;
use Carp;
use Data::Dumper;

sub new
{
	my $new = bless {}, $_[0];
	$new->{recording} = 0;
	$new->clear_recorded();
	$new->{tokenpos} = 0;
	return $new;
}

sub position($)
{
	my $self = shift;
	return $self->{tokenpos} - 1;
}

sub ulist($$)
{
	my $stars = shift;
	return "\n\0ULI" . length($stars) . "\001\0";
}

sub clear_recorded($)
{
	my $self = shift;
	$self->{recorded} = [];
}

sub recorded($)
{
	my $self = shift;
	return $self->{recorded};
}

sub tokenizeFile($$)
{
	my $self = shift;
	my $filename = shift;
	#carp "tokenizing '$filename'";
	open (INPUT, $filename) or croak "Cannot open '$filename': $!";
	$/ = undef;
	my $file = <INPUT>;
	close INPUT;
	$self->tokenizeString($file);
}

sub tokenizeString($$)
{
	my $self = shift;
	my $file = shift;

	# clean unwanted characters
	$file =~ s/\0//g;
	$file =~ s/\001//g;
	$file =~ s/\r\n/\n/g;

	# Add things which are special at start of a line here
	$file =~ s/\n(\*+)\s*/ulist($1,$2)/eg;
	# not implemented $file =~ s/\n(\#+)\s*/olist($1)/eg;
	$file =~ s/\n(----*)\s*/\0HR\001\0/g;
	$file =~ s/\n\s*\n/\n\0EMPTY_LINE\001\0\n/g;
	$file =~ s/\b([[:upper:]]+[[:lower:]]+[[:upper:]]+\w*)\b/\0WIKI_NAME\001$1\0/g;

	# $file =~ s/\n/\0NL\001\n\0\n/g;
	# $file =~ s/ +/\0SPACE\001 \0/g;
	#$file =~ s/mailto:([\w\d_\.]*@[\w\d_\.]*)/\0MAILTO\001$1\0/g;
	$file =~ s/{/\0OPEN_BRACE\001{\0/g;
	$file =~ s/}/\0CLOSE_BRACE\001}\0/g;
	# $file =~ s/:/\0COLON\001:\0/g;
	$file =~ s/\0\0/\0/g;
	my @strings = split /\0/, $file;
	#print Dumper(\@strings);
	for my $token (@strings)
	{
		#print "t: '$token'\n";
		$token =~ m/^([^\001]*)(\001(.*)?)?$/;
		my ($type, $val) = ($1, $3);
		unless (defined($2))
		{
			($type, $val) = ("STRING", $type);
		}
		#print $type, "=>", $val, "\n";
		push(@{$self->{tokens}}, \{type => $type, val => $val});
	}
	$self->{tokenpos} = 0;
}

sub start_recording($)
{
	my $self = shift;
	if ($self->{recording}) { carp "already recording!"; };
	$self->{recording} = 1;
}

sub stop_recording($)
{
	my $self = shift;
	unless ($self->{recording}) { carp "wasn't recording!"; };
	$self->{recording} = 0;
}


sub yylex
{
	my $self = shift;
	my $verbose = $ENV{YYDEBUG} || shift ;
	#print Dumper($self);
	
	#print "Return token ", $self->{tokenpos}, "\n";
	my $tokenref = $self->{tokens}->[$self->{tokenpos}++];
	unless (defined($tokenref))
	{
		#croak "EOF reached";
		return undef;
	}

	my %tok = %{$$tokenref};
	if ($self->{recording})
	{
		push @{$self->{recorded}}, \%tok;
	}

	if (defined($tok{val}))
	{
		my ($ret_type, $ret_val) = (eval "use SW; \$SW::$tok{type}", $tok{val});
		print "(".($self->{tokenpos}-1).")$tok{type}>'$tok{val}'\n" if $verbose;
		#print "\t$ret_type>'$ret_val'\n" if $verbose;
		return ($ret_type, $ret_val);
	}
	else
	{
		print "(".($self->{tokenpos}-1).")$tok{type}>'\n" if $verbose;
		return $tok{type};
	}
}

1;
