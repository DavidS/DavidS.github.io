#!/usr/bin/perl
#
## (C) Copyright 2003 by David Schmitt

use strict;
use warnings;
use SW::Utils;
use CGI;

my $q = new CGI;

print $q->header();

my $page = SW::Utils::sanitize_page($q->param('page'));

print <<"HEADER"
<html>
<head>
<title>Editiere $page</title>
</head>
<body>
<form method=post action=\"/sw/save.pl?page=$page\" encoding=\"application/x-url-encoded\">
<input type=hidden name=page value=\"$page\">
<textarea name=editarea rows=20 cols=65 style="width:100%" wrap="virtual">
HEADER
;
{
	open (INPUT, "/home/david/local/studwiki/data/$page.sw");
	local $/ = '';
	print <INPUT>;
	close INPUT;
}

print <<"FOOTER"
</textarea>
<input type=submit value=Speichern value=Speichern>
</form>
</body>
</html>
FOOTER

;
