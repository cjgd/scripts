#! /bin/perl

# ip-conv.pl -- several conversions on IP addresses (IPv4)
# $Id$
# Carlos Duarte <cgd@teleweb.pt>, 000713

use strict; 

sub usage {
	@_ and print "Error: ", @_; 
	print<<EOM;
usage: $0 options
  -value ip     produces numeric value of ip
  -value value  produces ip corresponding to value
EOM
	exit 1;
}

$_ = shift @ARGV; 
defined $_ or usage(); 

/value/i and do {
	local $_ = shift; 
	my @a = identify($_); 
	@a == 0 and usage "$_: not a valid ip?\n"; 
	if (@a == 1) {
		print join(".",value_to_ip($_)), "\n"; 
	} else {
		print ip_to_value(@a), "\n"; 
	} 
	exit;
}; 
usage("$_: bad option\n"); 
exit 1; 

####

sub identify {
	local $_ = shift; 
	/^\d+$/ and return ($_); 
	my @a = /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/; 
	@a and return @a; 
	return (); 
}

sub ip_to_value {
	my $s=0;
	for (my $i=0; $i<4; $i++) {
		$s += $_[3-$i]<<($i<<3); 
	}
	return $s; 
}

sub value_to_ip {
	local $_ = shift; 
	my @a;
	for (my $i=0; $i<4; $i++) {
		$a[3-$i] = ($_ >> ($i<<3)) & 0xff; 
	}
	return @a; 
}
