# @(#)yaccpar 1.8 (Berkeley) 01/20/91 (JAKE-P5BP-0.6 04/26/98)
package SW;
#line 2 "sw.y"

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

#line 161 "SW.pm"
$ULI1=257;
$ULI2=258;
$ulist3=259;
$HR=260;
$EMPTY_LINE=261;
$STRING=262;
$OPEN_BRACE=263;
$CLOSE_BRACE=264;
$WIKI_NAME=265;
$YYERRCODE=256;
@yylhs = (                                               -1,
    0,    0,    0,    3,    4,    4,    4,    4,    4,    4,
    5,    5,    5,    5,    5,    5,    5,    2,    2,    2,
    2,    6,    6,    6,    6,    1,    1,    1,    1,    1,
    1,
);
@yylen = (                                                2,
    0,    2,    2,    3,    1,    1,    1,    2,    2,    2,
    0,    1,    1,    1,    2,    2,    2,    2,    1,    3,
    2,    2,    1,    3,    2,    1,    1,    1,    1,    1,
    1,
);
@yydefred = (                                             1,
    0,    0,    0,   23,   28,   27,   30,    0,   31,   29,
    2,    0,   26,    0,   13,   14,   12,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,   25,   16,   17,
   15,    4,    0,    0,    0,    0,    0,
);
@yydgoto = (                                              1,
   11,   12,   17,   23,   18,   14,
);
@yysindex = (                                             0,
 -199, -236, -236,    0,    0,    0,    0, -231,    0,    0,
    0, -211,    0, -204,    0,    0,    0, -195, -195,    0,
    0,    0, -256, -191, -236, -204, -236,    0,    0,    0,
    0,    0,    0,    0,    0, -195, -195,
);
@yyrindex = (                                             0,
    0,   25,   25,    0,    0,    0,    0,    0,    0,    0,
    0,   16,    0,    1,    0,    0,    0,   33,   41, -260,
 -250, -243,    0,    0,   25,   10,   25,    0,    0,    0,
    0,    0, -225, -220, -212,   49,   57,
);
@yygindex = (                                             0,
    0,    0,   -1,    0,    3,   -3,
);
$YYTABLESIZE=321;
@yytable = (                                             13,
   19,   13,   13,    6,   13,   19,   22,   32,   26,   21,
   24,   14,   14,    7,   14,    3,   31,   31,   12,   12,
    5,   12,   35,    0,   11,   15,    8,   36,   16,   37,
   20,    8,   18,   21,   31,   31,   16,   16,    9,   16,
   22,   17,   17,   10,   17,   25,    3,    4,   20,   15,
   15,    8,   15,   27,   28,    0,   24,    2,    3,    4,
    5,    6,    7,    8,    9,   10,   29,    8,    0,   30,
   33,    8,    0,   34,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,   19,    0,    0,
   19,   19,   19,   19,   19,   19,   21,    0,    0,   21,
   21,   21,   21,   21,   21,    3,    3,    3,    3,    3,
    3,   11,   11,   11,   11,   11,    0,    0,   11,   18,
   18,   18,   18,   18,    0,    0,   18,   22,   22,   22,
   22,   22,    0,    0,   22,   20,   20,   20,   20,   20,
    0,    0,   20,   24,   24,   24,   24,   24,    0,    0,
   24,
);
@yycheck = (                                              1,
    0,  262,  263,  264,  265,    3,    8,  264,   12,    0,
    8,  262,  263,  264,  265,    0,   18,   19,  262,  263,
  264,  265,   24,   -1,    0,  262,  263,   25,  265,   27,
  262,  263,    0,  265,   36,   37,  262,  263,  264,  265,
    0,  262,  263,  264,  265,  257,  258,  259,    0,  262,
  263,  264,  265,  258,  259,   -1,    0,  257,  258,  259,
  260,  261,  262,  263,  264,  265,  262,  263,   -1,  265,
  262,  263,   -1,  265,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  257,   -1,   -1,
  260,  261,  262,  263,  264,  265,  257,   -1,   -1,  260,
  261,  262,  263,  264,  265,  260,  261,  262,  263,  264,
  265,  257,  258,  259,  260,  261,   -1,   -1,  264,  257,
  258,  259,  260,  261,   -1,   -1,  264,  257,  258,  259,
  260,  261,   -1,   -1,  264,  257,  258,  259,  260,  261,
   -1,   -1,  264,  257,  258,  259,  260,  261,   -1,   -1,
  264,
);
$YYFINAL=1;
#ifndef YYDEBUG
#define YYDEBUG 0
#endif
$YYMAXTOKEN=265;
#if YYDEBUG
@yyname = (
"end-of-file",'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',
'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',
'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',
'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',
'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',
'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',
'','','','','','','','','','','','','','','','','','','','','','','',"ULI1","ULI2","ulist3","HR",
"EMPTY_LINE","STRING","OPEN_BRACE","CLOSE_BRACE","WIKI_NAME",
);
@yyrule = (
"\$accept : text",
"text :",
"text : text simple_text_part",
"text : text ulist1",
"markup : OPEN_BRACE markup_content CLOSE_BRACE",
"markup_content : markup",
"markup_content : STRING",
"markup_content : WIKI_NAME",
"markup_content : list_string markup",
"markup_content : list_string STRING",
"markup_content : list_string WIKI_NAME",
"list_string :",
"list_string : markup",
"list_string : STRING",
"list_string : WIKI_NAME",
"list_string : list_string markup",
"list_string : list_string STRING",
"list_string : list_string WIKI_NAME",
"ulist1 : ULI1 list_string",
"ulist1 : ulist2",
"ulist1 : ulist1 ULI1 list_string",
"ulist1 : ulist1 ulist2",
"ulist2 : ULI2 list_string",
"ulist2 : ulist3",
"ulist2 : ulist2 ULI2 list_string",
"ulist2 : ulist2 ulist3",
"simple_text_part : markup",
"simple_text_part : EMPTY_LINE",
"simple_text_part : HR",
"simple_text_part : WIKI_NAME",
"simple_text_part : STRING",
"simple_text_part : CLOSE_BRACE",
);
#endif
sub yyclearin {
  my  $p;
  ($p) = @_;
  $p->{yychar} = -1;
}
sub yyerrok {
  my  $p;
  ($p) = @_;
  $p->{yyerrflag} = 0;
}
sub new {
  my $p = bless {}, $_[0];
  $p->{yylex} = $_[1];
  $p->{yyerror} = $_[2];
  $p->{yydebug} = $_[3];
  return $p;
}
sub YYERROR {
  my  $p;
  ($p) = @_;
  ++$p->{yynerrs};
  $p->yy_err_recover;
}
sub yy_err_recover {
  my  $p;
  ($p) = @_;
  if ($p->{yyerrflag} < 3)
  {
    $p->{yyerrflag} = 3;
    while (1)
    {
      if (($p->{yyn} = $yysindex[$p->{yyss}->[$p->{yyssp}]]) && 
          ($p->{yyn} += $YYERRCODE) >= 0 && 
          $p->{yyn} <= $#yycheck &&
          $yycheck[$p->{yyn}] == $YYERRCODE)
      {
        warn("yydebug: state " . 
                     $p->{yyss}->[$p->{yyssp}] . 
                     ", error recovery shifting to state" . 
                     $yytable[$p->{yyn}] . "\n") 
                       if $p->{yydebug};
        $p->{yyss}->[++$p->{yyssp}] = 
          $p->{yystate} = $yytable[$p->{yyn}];
        $p->{yyvs}->[++$p->{yyvsp}] = $p->{yylval};
        next yyloop;
      }
      else
      {
        warn("yydebug: error recovery discarding state ".
              $p->{yyss}->[$p->{yyssp}]. "\n") 
                if $p->{yydebug};
        return(undef) if $p->{yyssp} <= 0;
        --$p->{yyssp};
        --$p->{yyvsp};
      }
    }
  }
  else
  {
    return (undef) if $p->{yychar} == 0;
    if ($p->{yydebug})
    {
      $p->{yys} = '';
      if ($p->{yychar} <= $YYMAXTOKEN) { $p->{yys} = 
        $yyname[$p->{yychar}]; }
      if (!$p->{yys}) { $p->{yys} = 'illegal-symbol'; }
      warn("yydebug: state " . $p->{yystate} . 
                   ", error recovery discards " . 
                   "token " . $p->{yychar} . "(" . 
                   $p->{yys} . ")\n");
    }
    $p->{yychar} = -1;
    next yyloop;
  }
0;
} # yy_err_recover

sub yyparse {
  my  $p;
  my $s;
  ($p, $s) = @_;
  if ($p->{yys} = $ENV{'YYDEBUG'})
  {
    $p->{yydebug} = int($1) if $p->{yys} =~ /^(\d)/;
  }

  $p->{yynerrs} = 0;
  $p->{yyerrflag} = 0;
  $p->{yychar} = (-1);

  $p->{yyssp} = 0;
  $p->{yyvsp} = 0;
  $p->{yyss}->[$p->{yyssp}] = $p->{yystate} = 0;

yyloop: while(1)
  {
    yyreduce: {
      last yyreduce if ($p->{yyn} = $yydefred[$p->{yystate}]);
      if ($p->{yychar} < 0)
      {
        if ((($p->{yychar}, $p->{yylval}) = 
            &{$p->{yylex}}($s)) < 0) { $p->{yychar} = 0; }
        if ($p->{yydebug})
        {
          $p->{yys} = '';
          if ($p->{yychar} <= $#yyname) 
             { $p->{yys} = $yyname[$p->{yychar}]; }
          if (!$p->{yys}) { $p->{yys} = 'illegal-symbol'; };
          warn("yydebug: state " . $p->{yystate} . 
                       ", reading " . $p->{yychar} . " (" . 
                       $p->{yys} . ")\n");
        }
      }
      if (($p->{yyn} = $yysindex[$p->{yystate}]) && 
          ($p->{yyn} += $p->{yychar}) >= 0 && 
          $p->{yyn} <= $#yycheck &&
          $yycheck[$p->{yyn}] == $p->{yychar})
      {
        warn("yydebug: state " . $p->{yystate} . 
                     ", shifting to state " .
              $yytable[$p->{yyn}] . "\n") if $p->{yydebug};
        $p->{yyss}->[++$p->{yyssp}] = $p->{yystate} = 
          $yytable[$p->{yyn}];
        $p->{yyvs}->[++$p->{yyvsp}] = $p->{yylval};
        $p->{yychar} = (-1);
        --$p->{yyerrflag} if $p->{yyerrflag} > 0;
        next yyloop;
      }
      if (($p->{yyn} = $yyrindex[$p->{yystate}]) && 
          ($p->{yyn} += $p->{'yychar'}) >= 0 &&
          $p->{yyn} <= $#yycheck &&
          $yycheck[$p->{yyn}] == $p->{yychar})
      {
        $p->{yyn} = $yytable[$p->{yyn}];
        last yyreduce;
      }
      if (! $p->{yyerrflag}) {
        &{$p->{yyerror}}('syntax error', $s);
        ++$p->{yynerrs};
      }
      return(undef) if $p->yy_err_recover;
    } # yyreduce
    warn("yydebug: state " . $p->{yystate} . 
                 ", reducing by rule " . 
                 $p->{yyn} . " (" . $yyrule[$p->{yyn}] . 
                 ")\n") if $p->{yydebug};
    $p->{yym} = $yylen[$p->{yyn}];
    $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}+1-$p->{yym}];
if ($p->{yyn} == 1) {
#line 172 "sw.y"
{ $p->{yyval} = ""; }
}
if ($p->{yyn} == 2) {
#line 173 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-1] . $p->{yyvs}->[$p->{yyvsp}-0]; }
}
if ($p->{yyn} == 3) {
#line 174 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-1] . $p->handle_ulist($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 4) {
#line 177 "sw.y"
{
		#print "markup: ", Dumper($2), "\n";
		$p->{yyval} = $p->handle_markup($p->{yyvs}->[$p->{yyvsp}-1]);
	}
}
if ($p->{yyn} == 5) {
#line 183 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-0]; }
}
if ($p->{yyn} == 6) {
#line 184 "sw.y"
{ $p->{yyval} = $p->handle_string($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 7) {
#line 185 "sw.y"
{ $p->{yyval} = $p->handle_wikiname($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 8) {
#line 186 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-1] . $p->{yyvs}->[$p->{yyvsp}-0]; }
}
if ($p->{yyn} == 9) {
#line 187 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-1] . $p->handle_string($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 10) {
#line 188 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-1] . $p->handle_wikiname($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 12) {
#line 201 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-0]; }
}
if ($p->{yyn} == 13) {
#line 202 "sw.y"
{ $p->{yyval} = $p->handle_string($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 14) {
#line 203 "sw.y"
{ $p->{yyval} = $p->handle_wikiname($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 15) {
#line 204 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-1] . $p->{yyvs}->[$p->{yyvsp}-0]; }
}
if ($p->{yyn} == 16) {
#line 205 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-1] . $p->handle_string($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 17) {
#line 206 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-1] . $p->handle_wikiname($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 18) {
#line 209 "sw.y"
{ $p->{yyval} = "<li>" . $p->{yyvs}->[$p->{yyvsp}-0] . "</li>\n"; }
}
if ($p->{yyn} == 19) {
#line 210 "sw.y"
{ $p->{yyval} = $p->handle_ulist($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 20) {
#line 211 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-2] . "<li>" . $p->{yyvs}->[$p->{yyvsp}-0] . "</li>\n"; }
}
if ($p->{yyn} == 21) {
#line 212 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-1] . $p->handle_ulist($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 22) {
#line 215 "sw.y"
{ $p->{yyval} = "<li>" . $p->{yyvs}->[$p->{yyvsp}-0] . "</li>\n"; }
}
if ($p->{yyn} == 23) {
#line 216 "sw.y"
{ $p->{yyval} = $p->handle_ulist($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 24) {
#line 217 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-2] . "<li>" . $p->{yyvs}->[$p->{yyvsp}-0] . "</li>\n"; }
}
if ($p->{yyn} == 25) {
#line 218 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-1] . $p->handle_ulist($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 26) {
#line 221 "sw.y"
{ $p->{yyval} = $p->{yyvs}->[$p->{yyvsp}-0]; }
}
if ($p->{yyn} == 27) {
#line 222 "sw.y"
{ $p->{yyval} = "<p>\n"; }
}
if ($p->{yyn} == 28) {
#line 223 "sw.y"
{ $p->{yyval} = $p->handle_hr(); }
}
if ($p->{yyn} == 29) {
#line 224 "sw.y"
{ $p->{yyval} = $p->handle_wikiname($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 30) {
#line 225 "sw.y"
{ $p->{yyval} = $p->handle_string($p->{yyvs}->[$p->{yyvsp}-0]); }
}
if ($p->{yyn} == 31) {
#line 226 "sw.y"
{ $p->{yyval} = "<b>}</b>"; }
}
#line 599 "SW.pm"
    $p->{yyssp} -= $p->{yym};
    $p->{yystate} = $p->{yyss}->[$p->{yyssp}];
    $p->{yyvsp} -= $p->{yym};
    $p->{yym} = $yylhs[$p->{yyn}];
    if ($p->{yystate} == 0 && $p->{yym} == 0)
    {
      warn("yydebug: after reduction, shifting from state 0 ",
            "to state $YYFINAL\n") if $p->{yydebug};
      $p->{yystate} = $YYFINAL;
      $p->{yyss}->[++$p->{yyssp}] = $YYFINAL;
      $p->{yyvs}->[++$p->{yyvsp}] = $p->{yyval};
      if ($p->{yychar} < 0)
      {
        if ((($p->{yychar}, $p->{yylval}) = 
            &{$p->{yylex}}($s)) < 0) { $p->{yychar} = 0; }
        if ($p->{yydebug})
        {
          $p->{yys} = '';
          if ($p->{yychar} <= $#yyname) 
            { $p->{yys} = $yyname[$p->{yychar}]; }
          if (!$p->{yys}) { $p->{yys} = 'illegal-symbol'; }
          warn("yydebug: state $YYFINAL, reading " . 
               $p->{yychar} . " (" . $p->{yys} . ")\n");
        }
      }
      return ($p->{yyvs}->[1]) if $p->{yychar} == 0;
      next yyloop;
    }
    if (($p->{yyn} = $yygindex[$p->{yym}]) && 
        ($p->{yyn} += $p->{yystate}) >= 0 && 
        $p->{yyn} <= $#yycheck && 
        $yycheck[$p->{yyn}] == $p->{yystate})
    {
        $p->{yystate} = $yytable[$p->{yyn}];
    } else {
        $p->{yystate} = $yydgoto[$p->{yym}];
    }
    warn("yydebug: after reduction, shifting from state " . 
        $p->{yyss}->[$p->{yyssp}] . " to state " . 
        $p->{yystate} . "\n") if $p->{yydebug};
    $p->{yyss}[++$p->{yyssp}] = $p->{yystate};
    $p->{yyvs}[++$p->{yyvsp}] = $p->{yyval};
  } # yyloop
} # yyparse
1;
