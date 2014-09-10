#! /usr/bin/perl

# unread-tinlog.pl -- mark as unread, tin logged articles (produced by -S -c)
# $Id$
# Carlos Duarte <cgd@teleweb.pt>, 000225

use strict;

sub usage {
	print <<EOM;
usage: $0 -l logfile -f newsrc_file 
EOM
	@_ and print "\n", join("\n", @_), "\n";
	exit;
}

my %o; 
O: while (defined(my $opt = shift)) {
	$opt eq "-h" and usage;
	# option with one arg
	$opt =~ /^-f/ and do {
		$opt =~ s///; ($opt eq "" && !defined($opt = shift)) and usage;
		$o{NEWSRC} = $opt; 
		# use $opt
		next O; 
	}; 
	$opt =~ /^-l/ and do {
		$opt =~ s///; ($opt eq "" && !defined($opt = shift)) and usage;
		$o{LOGFILE} = $opt; 
		# use $opt
		next O; 
	}; 
	##
	$opt eq "--" and last O;
	$opt =~ /^-/ and usage; 
	unshift(@ARGV, $opt); 
	last O; 
}
@ARGV == 0 or usage; 
$o{LOGFILE} or usage("must define logfile"); 
$o{NEWSRC} or usage("must define newsrc"); 

my $log = read_log($o{LOGFILE}); 
update_newsrc($o{NEWSRC}, $log); 

### 

sub read_log {
	my $f = shift; 
	local (*F, $_, $.); 

	my %log; 
	my $ng; 

	open F, $f or die "can't read $f: $!"; 
	while (<F>) {
		chomp; 
		if (/^Saved /) {
			s///; 
			s/\.\.\.\s*$//;
			$ng = $_ ; 
			next; 
		}
		if (/^\[\s*(\d+)\]/) {
			push @{ $log{$ng} }, $1; 
		}
	}
	close F; 
	for (keys %log) {
		@{ $log{$_} } = sort { $a <=> $b } @{ $log{$_} }; 
	}
	return \%log; 
}

sub update_newsrc {
	my $f = shift; 
	my $log = shift; 

	my @out; 
	local (*F, $_, $.); 

	open F, $f or die "can't open $f: $_" ;
	while (<F>) {
		chomp; 
		my $i = index($_, ":"); 
		if ($i == -1) {
			push @out, $_; 
			next; 
		}
		my $ng = substr($_, 0, $i); 
		if (!exists $log->{$ng}) {
			push @out, $_; 
			next; 
		}
		$_ = substr($_, $i+1); 
		y/0-9,-//cd; 
		my @a; 
		for (split /,/) {
			my @x = split /-/; 
			if (@x==1) {
				$a[$x[0]] = 1; 
			} else {
				for ($i = $x[0]; $i <= $x[1]; $i++) {
					$a[$i] = 1; 
				}
			}
		}
		for (@{ $log->{$ng} }) {
			$a[$_] = 0; 
		}
		$_ = $ng.": "; 
		for ($i=0; $i<@a; $i++) {
			if ($a[$i] == 1) {
				/-$/ or $_ .= $i."-"; 
				next; 
			}
			/-$/ or next; 
			if ($i>=2 && $a[$i-1]==1 && $a[$i-2]==1) {
				$_ .= "$i,"; 
			} else {
				s/.$/,/; 
			}
		}
		chop; 
		push @out, $_; 
	}
	close F; 
	open F, ">$f" or die "can't open $f: $!"; 
	for (@out) {
		print F $_, "\n"; 
	}
	close F; 
}
