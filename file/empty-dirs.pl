#! /usr/bin/perl

# empty-dirs.pl -- find empty dirs 
# $Id$ 
# Carlos Duarte <cgd@mail.teleweb.pt>, 990923/021010

use strict; 

# enforce all arguments, as paths to find
for (@ARGV) {
	/^\// and next; 	# may start with /
	/^\.\// and next; 	# or ./
	/^\.\.(\/|$)/ and next;	# or ../
	s#^#./#; 		# else, add ./ to for a path interpretation
}

# replace a open "find @ARGV -type d|", but this works even if @ARGV
# contains elements separated by spaces
#
pipe IN, OUT or die "can't pipe: $!"; 
my $pid; 
defined($pid = fork) or die "can't fork: $!"; 
if ($pid == 0) {
	open STDOUT, ">&OUT" or die "dup OUT: $!"; 
	close IN; close OUT; 
	exec {"find"} "find", @ARGV, "-type", "d"; 
	exit; 
}
open STDIN, "<&IN" or die "dup IN: $!"; 
close IN; close OUT; 

while (<STDIN>) {
	chomp; 
	opendir D, $_ or next; 
	my $d = $_; 
	readdir D;
	readdir D; 
	# is empty
	print "$_\n" unless (defined scalar readdir D); 
	closedir D;  
}
