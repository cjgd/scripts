#! /usr/bin/perl

# fmt.pl -- a simple perl based (classical) formatter
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990228

$/ = ''; 
while (<>) {
	$len = 0; 
	@w= split; 
	for (@w) {
		
		if ($len+length() > 66) {
			print "\n"; 
			$len = 0; 
			$nl=1; 
		}
		print $_ . " "; 
		$len += length()+1;
		$nl=0; 
	}
	print "\n" if (!$nl++); 
	print "\n"; 
}
