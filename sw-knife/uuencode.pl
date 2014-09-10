#! /usr/bin/perl

# uuencode.pl -- uuencode written in perl
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990227

use strict 'vars'; 

sub usage { print "Usage: $0 [infile] remotefile\n"; exit; }

@ARGV==0 and usage; 
@ARGV> 2 and usage; 

if (@ARGV==1) {
	my $mode = 0666 & ~umask; 
	&do_enc(shift, $mode, \*STDIN); 
} else {
	my $file = shift; 
	open FILE, $file or die "opening $file, $!"; 
	my $mode = (stat $file)[2] & 0777; 
	&do_enc(shift, $mode, \*FILE); 
	close FILE; 
}

sub do_enc {
	my ($name,$mode,$fh) = @_; 
	printf "begin %s %s\n", sprintf("%03o", $mode), $name; 
	read ($fh, $b, 45) or die "$!"; 
	while (read($fh, $b, 45)) {
		print pack("u", $b); 
	}
	print "\`\nend\n"; 
}
