#! /usr/bin/perl -i

# chop-c-comments.pl -- remove blocks of C comments
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990516

# this program, will delete comments whose contents match pattern 

sub usage {
	print "usage: $0 pattern [files] ...\n"; 
	exit 2; 
}

my $pat = shift or usage; 

undef $/; 
while (<>) {
	unless (s#^(.*?)/\*#/*#s) {
		# no comments left
		print; 
		next; 
	}
	print $1; 
	unless (/^.*?\*\//s) {
		# comment not terminated 
		/^.*?\n.*?\n.*?\n/s; # three lines
		my $ln = $&; $ln =~ s/\n*$//; 
		warn "$ARGV >>$ln<<\n\tstart of this comment not terminated";
		print; 
		next; 
	}
	my $c = $&; 
	unless ($c =~ /$pat/os) {
		# do not match criteria: print this comment
		print $c; 
	}
	$_ = substr($_, length($c)); 
	redo; 
}
