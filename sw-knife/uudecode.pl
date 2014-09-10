#! /usr/bin/perl

# uudecode.pl -- uudecode written in perl
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990227

use strict 'vars'; 

my ($mode, $name); 

S1: {
	$_ = <>; 
	exit unless (defined $_); 
	redo unless (/^begin/); 
	redo unless ($mode, $name) = /^begin\s*([^ ]*)\s*(.*)$/; 
}

S2: {
	$mode = oct($mode); 
	open(FILE, ">$name") or die "openning $name, $!"; 
}

S3: {
	$_ = <>; 
	last unless (defined $_); 
	last if (/^end/); 
	redo unless (/^M/ || (((ord($_)-32)%64+2)/3 != (length($_)-1)/4)); 

	print FILE unpack("u", $_); 
	redo;
}

S4: {
	close(FILE); 
	chmod($mode, $name); 
	unless (/^end/) {
		print STDERR "$name may be truncated\n"; 
	}
	goto S1 if (defined $_); 
}

exit; 

