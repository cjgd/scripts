#! /usr/bin/perl

# get-desc.pl -- obtains the classical "--" beginned description of each file
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990620

my $b; 
while (<>) { 
	if (!eof && $. <= 10) {
		$b .= $_; 
		next; 
	}
	close ARGV; 
	my $fname = $ARGV; ## $fname =~ s#^.*/##; ## basename
	$_ = $b; 
	undef $b; 
	if (!s/^.*?\s+--\s+//s) {
		print $fname, "\t" x ntabs($fname, 24), "[no desc]", "\n"; 
		next; 
	}
	my $d;
	for (split /[ \t]*\n/) {
		s#\*/$## or s#-->$##;
		s/^#// or s#^/\*## or s#^//## or 
		s#^\s*\*## or s#^\"## or s#^<--##; 
		defined $d and !/^ *\t/ and !/^\s{6}/ and last; 
		s/^\s*//; s/\s*$//; 
		$d .= $_." "; 
	}
	$d eq " " and $d = "[no desc]"; 
	print $fname, "\t" x ntabs($fname, 24), $d, "\n"; 
}

# (str, ncols) -- 
# 	return number of tabs, needed to place in from of STR, to achieve 
#	NCOLS cols
sub ntabs {
	local $_ = shift; 
	my $n = shift; 
	length >= $n and return 1; 
	return ($n - 1 - length)/8+1; 
}
