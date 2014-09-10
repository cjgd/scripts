#! /usr/bin/perl

# about_cache.pl -- handle about:cache netscape output (saved as text)
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 991129


use strict; 
my $file_name; 
my $cache; 
my $size; 

my $last = 1; 
while (<>) {
	my @a; 
	for (;;) {
		s/\s*$//s; 
		@a = split /: /; 
		@a != 1 and last; 
		my $n = <>; defined $n or last; 
		$_ .= " $n"; 
	}
	/URL:/ and do {
		$file_name = $a[1]; 
		$file_name =~ s#^.*/##; 
		$file_name =~ s#\?.*$##; 
		next; 
	}; 
	/Content Length:/ and do {
		$size = $a[1]; 
		next; 
	}; 
	/Local filename:/ and do {
		$_ = $a[1]; ## cache file location
		$size >= 14000 or  next; 
		/\.jpg$/i and goto OK; 
		/\.jpeg$/i and goto OK; 
		/\.jpe$/i and goto OK; 
		/\.gif$/i and goto OK; 
		/\.mpg$/i and goto OK; 
		/\.mpeg$/i and goto OK; 
		/\.mpe$/i and goto OK; 
		/\.avi$/i and goto OK; 
		/\.mov$/i and goto OK; 
		/\.qt$/i and goto OK; 
		next; 
	OK: 
		if ($file_name eq "") {
			my ($ext) = /\.([^.]+)$/; 
			$file_name = "xxx$last";
			$last++; 
			$ext ne "" and $file_name .= $ext; 
		}
		print "cp /.netscape/cache/$_ $file_name\n"; 
		next; 
	}; 
}
