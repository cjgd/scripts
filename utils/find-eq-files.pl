#! /usr/bin/perl

# find-eq-files.pl -- find equal files 
# $Id: find-eq-files.pl,v 1.4 1999/09/23 16:33:58 cgd Exp cgd $
# Carlos Duarte <cgd@mail.teleweb.pt>, 990218/990220

use strict; 
use constant BUF_SIZE => 4096; 

## should be aprox eq to the max number of files, with same size
use constant CACHE_LIMIT => 15; 

sub usage {
	print <<EOM;
usage: $0 [-h] -i [-0] [-d delim] [files... ]
usage: $0 [-h]    [-0] [-d delim] dirs [find-options]

  -h          this help
  -d delim    use DELIM, as the delimeter for filenames
	      (default is newline)
  -0          use NUL as the delimeter
  -i          use SDTIN, or files passed as arguments, to read files from

if -i is given, $0 reads filenames from input or given files, else
(default), $0 run find on DIRS, with FIND-OPTIONS prepended to get the
files to scan.

each filename is separated by DELIM, which defaults to newline. 
with the collected files, $0 finds those that have exactly the same
contents.

All these do the same, with \"normal\" filenames.

eg: find -i ~/sources ~/tmp -name \\*.c -type f | $0 
    find -i ~/sources ~/tmp -name \\*.c -type f -print0 | $0 -0 

eg: $0 ~/sources ~/tmp -name \\*.c -type f 
    $0 -0 ~/sources ~/tmp -name \\*.c -type f -print0 
EOM
	exit;
}

my $delim = "\n"; 
my $take_input; 

my ($opt); 
O: while (defined($opt = shift)) {
	$opt eq "-h" and usage;
	$opt eq "-i" and do { $take_input = "yes"; next O; }; 
	$opt eq "-0" and do { 
		$delim = "\0"; 
		next O; 
	}; 
	$opt =~ /^-d/ and do {
		$opt =~ s///; ($opt eq "" && !defined($opt = shift)) and usage;
		$delim = $opt; 
	}; 
	$opt eq "--" and last O;
	$opt =~ /^-/ and usage; 
	unshift(@ARGV, $opt); 
	last O; 
}

if ($take_input eq "yes") {
	if (@ARGV == 0) {
		do_it("");
	} else {
		my $file; 
		do_it($file) while (defined($file = shift)); 
	}
} elsif (@ARGV == 0) {
	usage(); 
} else {
	my $cmd = "find " . join(' ', map("'$_'", @ARGV)) . "|"; 
	do_it($cmd); 
}

sub do_it {
	local($.,$_,$/); 

	$/ = $delim; 
	my $open_arg = shift; 
	my $FH = \*STDIN; 

	if ($open_arg ne "") {
		open(F, $open_arg) or die "opening $open_arg: $!"; 
		$FH = \*F; 
	}

	my %s; 
	while (<$FH>) {
		chop; 
		unless (-f $_) {
			## silently ignore this... 
			#warn "$fn: not a file"; 
			next; 
		}
		push(@{ $s{ -s _ } }, $_); 
	}

	if ($open_arg ne "") {
		close($FH) or warn "closing $open_arg: $!"; 
	}

	my $pos=0; 
	my @eq_set; 
	my ($size, $set); 
	while (($size, $set) = each %s) {
		@{ $set } <= 1 and next; 
		my @set = @{ $set }; 

		my $first; 
		while (defined($first = shift @set)) { 
			my $other; 
			my @tmp; 
			push(@{$eq_set[$pos]}, $first); 
			while (defined($other = shift @set)) {
				if (do_cmp($first, $other, $size)) {
					push(@{$eq_set[$pos]}, $other); 
				} else {
					push(@tmp, $other); 
				}
			}
			@set = @tmp; 
			$pos++; 
		}
	}
	undef %s; 

	$" = "\n"; 
	for my $set (@eq_set) {
		@{ $set } <= 1 and next; 
		my @set = @{ $set }; 
		print "=====\n@set\n"; 
	}
}

#sub do_cmp {
#	my $a = shift; 
#	my $b = shift; 
#	for $_ ($a, $b) {
#		s/\'/'\\''/g;
#	}
#	return !system("cmp '$a' '$b' 2>/dev/null >/dev/null"); 
#}

## return 1 if files are equal, else return 0
my %c_data; 
my @c_files; 
sub do_cmp {
	my $af = shift; 
	my $bf = shift; 
	my $size = shift; 
	my ($ah, $bh); 
	my ($ad, $bd); 
	my $ret = 0; 

	# load cache
	unless (exists $c_data{$af}) {
		open FF, $af or die "can not open '$af' for read: $!"; 
		$ah = \*FF; 
		$ad = readn(\*FF, BUF_SIZE); 
		defined $ad or die "couldn't read from $af: $!"; 
		$c_data{$af} = $ad; 
		unshift(@c_files, $af); 
	}
	unless (exists $c_data{$bf}) {
		open FO, $bf or die "can not open '$bf' for read: $!";; 
		$bh = \*FO; 
		$bd = readn(\*FO, BUF_SIZE); 
		defined $bd or die "couldn't read from $bf: $!"; 
		$c_data{$bf} = $bd; 
		unshift(@c_files, $bf); 
	}
	# compare cache now
	defined($ad) or $ad = $c_data{$af}; 
	defined($bd) or $bd = $c_data{$bf}; 

	if ($ad eq $bd) {
		$ret = 1; 
		if (length($ad) < $size) {
			unless(defined($ah)) {
				open FF, $af 
				  or die "can't open '$af' for read: $!"; 
				$ah = \*FF; 
			}
			unless(defined($bh)) {
				open FO, $bf
				  or die "can't open '$bf' for read: $!"; 
				$bh = \*FO; 
			}
			seek $ah, length($ad), 0 or 
			  die "can't seek '$af' ${ \length($ad) } bytes: $!"; 
			seek $bh, length($bd), 0 or
			  die "can't seek '$bf' ${ \length($bd) } bytes: $!"; 
			for (;;) {
				$ad = readn($ah, BUF_SIZE); 
				defined $ad or die "couldn't read from $af: $!";
				$bd = readn($bh, BUF_SIZE); 
				defined $bd or die "couldn't read from $bf: $!";
				if ($ad ne $bd) { $ret = 0; last; }
				last if ($ad eq ""); 
			}
		}
	}
	defined($ah) and close $ah; 
	defined($bh) and close $bh; 

	@c_files >= CACHE_LIMIT and delete $c_data{pop(@c_files)};
	@c_files >= CACHE_LIMIT and delete $c_data{pop(@c_files)};

	return $ret; 
}

# readn $fh, $nbytes; return buffer with next $nbytes read from $fh file
sub readn {
	my $fh = shift; 
	my $nn = shift; 
	my ($data, $b, $n); 

	for (;;) {
		$n = read $fh, $b, $nn; 
		defined $n or return undef; 
		$data .= $b; 
		return $data if ($n == 0 || $n == $nn); 
		$nn -= $n; 
	}
}
