#! /usr/bin/perl

# caesar-add.pl -- primitive encryptation method
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990209

# adds a value to each byte of input
# eg: ./caesar-add.pl -n 126 < /etc/passwd | ./caesar-add.pl -n 130
# eg: ./caesar-add.pl -n 126 < /etc/passwd | ./caesar-add.pl -n -126

#use strict 'vars'; 
#use vars qw/$inc $file $did_one/; 

$inc = 12; 
($ARGV[0] eq "-n") and do {
	shift; 
	$inc = shift; 
}; 

if ($inc == 0) {
	print "usage: $0 [-n increment] files\n"; 
	exit; 
}

if (@ARGV != 0) {
	while (defined($file = shift)) {
		open F, $file or die "$file $!"; 
		&caesar_add(\*F); 
		close F; 
	}
} else {
	&caesar_add(\*STDIN); 
}

sub caesar_add {
	my $fh = shift; 
	my $b; 

	while (read($fh, $b, 4000) > 0) {
		$b =~ s/(.)/chr((ord($1)+$inc)%256)/ge;
		print $b; 
	}
}
