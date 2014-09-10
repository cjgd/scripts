#! /usr/bin/perl

# file-date.pl -- date of a given file
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990211

$more_than_one = (@ARGV>1); 

for $file (@ARGV) {
	@info = stat($file) 
	  or warn "$file $!"; 
	@tt = gmtime($info[9]); # 9 for mtime
	$year = $tt[5]+1900; 
	$year =~ s/^.*(..)$/$1/;
	if ($more_than_one) {
		printf "%02d%02d%02d    %s\n", $year, $tt[4]+1, $tt[3], $file;
	} else {
		printf "%02d%02d%02d\n", $year, $tt[4]+1, $tt[3];
	}
}
