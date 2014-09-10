#! /usr/bin/perl
# mkfiledb.pl -- like find >file && grep file, but file is kept shorter.
#		 a poor's man locate
# Carlos Duarte, 010928

use strict; 
use Getopt::Std; 
use IO::File;

sub usage {
	@_ and print "@_\n"; 
	local $_ = <<EOF; 
# usage: 
# fazer a db: mkfiledb -o file 
# procurar: mkfiledb -f file pattern 
# 
# -o file: faz um "find / -type f" e comprime o output 
# -f file pattern: procura por pattern no ficheiro especificado
#
EOF
	s/(^|\n)#\s?/$1/sg; 
	print; 
	exit(2); 
}

my %opts; 
getopts('o:f:', \%opts); 
if (exists $opts{'o'}) {
	my $dir = "/"; 
	@ARGV and $dir = "@ARGV"; 
	compress("find $dir -type f 2>/dev/null | sort |", $opts{'o'}); 
} else {
	exists $opts{'f'} or usage("need -f argument"); 
	@ARGV==1 or usage("need a pattern"); 
	search($opts{'f'}, $ARGV[0]); 
}
exit(0); 

####

sub common_len {
	my ($s, $t) = @_;
	my $len = length($s); 
	$len > length($t) and $len = length($t); 
	while ($len > 0) {
		substr($s, 0, $len) eq substr($t, 0, $len) and return $len; 
		$len -- ; 
	}
	return 0; 
}

sub compress {
	my ($infile, $outfile) = @_; 
	local (*IF, *OF); 
	my $if = $infile; 
	if (ref $infile eq "") {
		open IF, $infile or die "$infile: $!"; 
		$if = \*IF; 
	} 
	open OF, ">".$outfile or die "$outfile: $!"; 
	local $_; 
	my $last; 
	while (<$if>) {
		chomp; 
		my $n = common_len($_, $last); 
		if ($n > length(sprintf("%d",$n)+1)) {
			my $s = substr($_, $n); 
			printf OF "%d", $n; 
			$s =~ /^[0-9-]/ and print OF "-"; 
			print OF "$s\n"; 
		} else {
			print OF $_."\n"; 
		}
		$last = $_; 
	}
	close OF; 
	ref $infile eq "" and close IF; 
}

sub search {
	my ($infile, $pat) = @_; 
	local *IF; 
	open IF, $infile or die "$infile: $!"; 
	local $_; 
	my $last; 
	while (<IF>) {
		if (s/^([0-9]+)-?//) {
			my $n = $1;
			$n += 0; 
			$_ = substr($last, 0, $n) . $_; 
		}
		/$pat/o and print; 
		$last = $_; 
	}
	close IF; 
}

