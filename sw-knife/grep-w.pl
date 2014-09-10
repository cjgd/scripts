#! /usr/bin/perl

# grep-w.pl -- emulation of grep -w
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990203

# called as: xx pat files, acts as: grep -w -n pat files /dev/null

$p=shift; 
while (<>) {
	/\b($p)\b/ && print "$ARGV:$.:$_"; 
	eof && close(ARGV);
}
