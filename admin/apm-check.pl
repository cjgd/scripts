#! /usr/bin/perl

# Carlos Duarte <cgd@mail.teleweb.pt>, 991102

use strict; 

my $cur; 
for (;;) {
	my @a = `apm`; 
	if ($a[0] ne $cur) {
		my @text = ( "apm status is " ); 
		local $_ = $a[0]; 
		s/^.*://; 
		s/^\s*//; s/\s*$//; 
		push @text, $_; 
		if (!fork) {
			exec {'xmessage'} 'xmessage', @text; 
			die "exec: $!"; 
		}
		wait; 

		$cur = $a[0]; 
	}
	sleep 10; 
}	

