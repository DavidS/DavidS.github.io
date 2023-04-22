%{

# (C) Copyright 2003 by David Schmitt

use Carp;
use SW::Utils;
use Data::Dumper;

$| = 1;

sub createParser($$$$)
{
	my $self = shift;
	my $lexer = shift;
	my $yylex = shift;
	my $yydebug = shift;
	my $parser = SW->new(
		sub { return $yylex->($lexer, @_) },
		sub { confess "At token ", $lexer->position(), ": ", @_; },
		$yydebug);
	$parser->{lexer} = $lexer;
	$parser->{markups} = {};
	$parser->{pages} = SW::Utils::read_pageindex();
	return $parser;
}

sub handle_wikiname($$)
{
	my $self = shift;
	my $name = shift;
	if (defined($self->{pages}->{$name}))
	{	
		return "<a href=\"/sw/show.pl?page=$name\">$name</a>";
	}
	else
	{	
		return "$name<a href=\"/sw/edit.pl?page=$name\">?</a>";
	}
}

sub extract_url($)
{
	my $string = shift;
	$string =~ s/(https?:\/\/[^\s,]*)/ /g;
	return ($string, $1);
}

sub handle_string($)
{
	my $self = shift;
	my $string = shift;
	#print "XXX: handling '$s'\n";
	for my $page (%{$parser->{pages}})
	{
		$string =~ s/$page/<a href="\/sw\/show.pl?page=$page">$page<\/a>/g;
	}
	$string =~ s/((https?:\/\/|mailto:)[^\s,]*)/<a href="$1">$1<\/a>/gi;
	return $string;
}

sub handle_ulist($)
{
	my $self = shift;
	my $string = shift;
	return "<ul>$string</ul>\n";
}

sub handle_markup_with_param($$$)
{
	my $self = shift;
	my $key = shift;
	my $param = shift;
	return $self->handle_link($param) if $key =~ m/link/i;
	if ($key =~ m/lva|titel|studienplan|Vortragender?|Institut|Standardtermin|Termin/i)
	{
		$self->{specials}->{$key} = $param;
		return "";
	}
	return "{$key:$param}";
}

sub handle_link($$)
{
	my $self = shift;
	my $param = shift;
	my ($text, $url) = extract_url($param);
	$text =~ s/^\s*(.*?)\s*$/$1/;
	return "<a href=\"$url\">$text</a>";
}

sub close_markup_text($)
{
	my $self = shift;
	unless (defined($self->{current_markup}))
	{
		return "";
	}

	$self->{lexer}->stop_recording();
	$self->{markups}->{$self->{current_markup}} = $self->{lexer}->recorded();
	$self->{lexer}->clear_recorded();
	$self->{current_markup} = undef;
	return "<td><tr></table>\n";
}

sub open_markup_text($$)
{
	my $self = shift;
	if (defined($self->{current_markup}))
	{
		warn "closing dangling markup_text";
		$self->close_markup_text();
	}
	$self->{current_markup} = shift;
	$self->{lexer}->start_recording();
	return "";
}

sub handle_markup_with_text($$)
{
	my $self = shift;
	my $title = shift;
	my $result = $self->close_markup_text();
	$result .= $self->open_markup_text($title);
	return $result . "<table border=1><tr><td><h1>$title</h1>\n";
}

sub handle_anmerkungen($)
{
	my $self = shift;
	$self->handle_markup_with_text("Anmerkungen");
}

sub handle_links($)
{
	my $self = shift;
	$self->handle_markup_with_text("Links");
}

sub handle_lehrziel($)
{
	my $self = shift;
	$self->handle_markup_with_text("Lehrziel");
}

sub handle_hr($)
{
	my $self = shift;
	return $self->close_markup_text() . "<hr>" ;
}

sub handle_markup($$)
{
	my $self = shift;
	my $key = shift;
	return $self->handle_markup_with_param($1,$2) if $key =~ (m/^\s*([^:]*):(.*)/i);
	return $self->handle_markup_with_text($1) if $key =~ (m/^\s*(.*?)\s*$/i);
	return "{$key}";
}

%}

%token ULI1 ULI2 ulist3 #fake token
%token HR

%token EMPTY_LINE STRING
%token OPEN_BRACE CLOSE_BRACE
%token WIKI_NAME

%%

#all:	text	{ print $1; } ;

text: /* empty */			{ $$ = ""; }
	| text simple_text_part		{ $$ = $1 . $2; }
	| text ulist1			{ $$ = $1 . $p->handle_ulist($2); }
	;

markup: OPEN_BRACE markup_content CLOSE_BRACE	{
		#print "markup: ", Dumper($2), "\n";
		$$ = $p->handle_markup($2);
	}
	;

markup_content: markup			{ $$ = $1; }
	| STRING			{ $$ = $p->handle_string($1); }
	| WIKI_NAME			{ $$ = $p->handle_wikiname($1); }
	| list_string markup		{ $$ = $1 . $2; }
	| list_string STRING		{ $$ = $1 . $p->handle_string($2); }
	| list_string WIKI_NAME		{ $$ = $1 . $p->handle_wikiname($2); }
	;
/*
markup_content: markup			{ $$ = [ { type => "MARKUP", val => $1} ]; }
	| STRING			{ $$ = [ { type => "STRING", val => $p->handle_string($1) } ]; }
	| WIKI_NAME			{ $$ = [ { type => "WIKI_NAME", val => $p->handle_wikiname($1) } ]; }
	| list_string markup		{ $$ = [ $1, { type => "MARKUP", val => $2 } ]; }
	| list_string STRING		{ $$ = [ $1, { type => "STRING", val => $p->handle_string($2) } ]; }
	| list_string WIKI_NAME		{ $$ = [ $1, { type => "WIKI_NAME", val => $p->handle_wikiname($2) } ]; }
	;
*/

list_string: # empty
	| markup			{ $$ = $1; }
	| STRING			{ $$ = $p->handle_string($1); }
	| WIKI_NAME			{ $$ = $p->handle_wikiname($1); }
	| list_string markup		{ $$ = $1 . $2; }
	| list_string STRING		{ $$ = $1 . $p->handle_string($2); }
	| list_string WIKI_NAME		{ $$ = $1 . $p->handle_wikiname($2); }
	;

ulist1: ULI1 list_string		{ $$ = "<li>" . $2 . "</li>\n"; }
	| ulist2			{ $$ = $p->handle_ulist($1); }
	| ulist1 ULI1 list_string	{ $$ = $1 . "<li>" . $3 . "</li>\n"; }
	| ulist1 ulist2			{ $$ = $1 . $p->handle_ulist($2); }
	;

ulist2: ULI2 list_string		{ $$ = "<li>" . $2 . "</li>\n"; }
	| ulist3			{ $$ = $p->handle_ulist($1); }
	| ulist2 ULI2 list_string	{ $$ = $1 . "<li>" . $3 . "</li>\n"; }
	| ulist2 ulist3			{ $$ = $1 . $p->handle_ulist($2); }
	;

simple_text_part: markup		{ $$ = $1; }
	| EMPTY_LINE			{ $$ = "<p>\n"; }
	| HR				{ $$ = $p->handle_hr(); }
	| WIKI_NAME			{ $$ = $p->handle_wikiname($1); }
	| STRING			{ $$ = $p->handle_string($1); }
	| CLOSE_BRACE			{ $$ = "<b>}</b>"; }
	;

%%
