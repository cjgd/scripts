#! /usr/bin/perl

# jpg-opt.pl -- optimize jpeg images 
# Carlos Duarte <cgd@mail.teleweb.pt>, 991014

use strict; 
use File::Copy;

sub usage {
	print <<EOM;
usage: $0 
	[-h] 
	[-d done_file] 
	[-cmd xloadimage|jpegtran] 
	-r dirs | files
EOM
	exit;
}

my $cmd = "xloadimage"; 
my ($recursive, $done_file, $opt); 
O: while (defined($opt = shift)) {
	$opt eq "-h" and usage;

	$opt eq "-r" and do { $recursive++; next O; }; 

	$opt =~ /^-cmd/ and do {
		$opt =~ s///; ($opt eq "" && !defined($opt = shift)) and usage;
		$cmd = $opt; 
		next O; 
	}; 

	$opt =~ /^-d/ and do {
		$opt =~ s///; ($opt eq "" && !defined($opt = shift)) and usage;
		$done_file = $opt; 
		next O; 
	}; 

	$opt eq "--" and last O;
	$opt =~ /^-/ and usage; 
	unshift(@ARGV, $opt); 
	last O; 
}

my @cvt_cmd; 
$_ = $cmd; 
SW: {
	/jpegtran/ and do {
		# jpegtran -opt -outfile new.jpg old.jpg
		@cvt_cmd = ("jpegtran", "-opt", "-outfile", "_dest_", 
			    "_source_");
		last SW; 
	}; 

	/xloadimage/ and do {
		# xloadimage image_name -dump jpeg new_image.jpg
		@cvt_cmd = ("xloadimage", "_source_", "-dump", "jpeg", 
			    "_dest_"); 
		last SW; 
	}; 
}

# if _must_ accept arguments, after options
@ARGV == 0 and usage; 
@cvt_cmd == 0 and usage; 

# get done files into $done{file} = 1
my %done; 
if ($done_file ne "" and open FF, $done_file) {
	while (<FF>) {
		chomp; 
		$done{$_}++; 
	}
	close FF; 
}

# get list of not done files into @lst
my @lst; 
if ($recursive) {
	local $" = " "; 
	open FF, "find @ARGV -type f -print|" or die $!; 

	while (<FF>) {
		chomp; 
		$done{$_} and next; 
		push @lst, $_; 
	}
	close FF or die $!; 
} else {
	for (@ARGV) {
		$done{$_} and next; 
		push @lst, $_; 
	}
}

# run file(1) on selected files, and select img files
my @img_lst; 
while (@lst) {
	my $n = 0; 
	my @l; 
	while ($n < 20480) {
		$_ = shift @lst; 
		defined $_ or last; 
		$n += length; 
		push @l, $_; 
	}
	pipe IN, OUT or die $!; 
	my $p = fork; 
	die $! unless (defined $p); 
	if ($p == 0) {
        	open STDOUT, ">&OUT" or die "dup OUT: $!";
        	close IN; close OUT;
		exec {'file'} 'file', @l; 
		die $!; 
	}
	close OUT; 
	while (<IN>) {
		chomp; 
		/\bJPEG\b/ and goto ok; 
		/\bGIF\b/ and goto ok; 
		next; 
	ok: 
		s/:.*$//; 
		push @img_lst, $_; 
	}
	close IN; 
	waitpid $p, 0; 
}
undef @lst; 

## convert files not done yet with xloadimage
my $dest = sprintf "/tmp/xl.%d.", $$; 
for (@img_lst) {
	print "processing: $_\n"; 
	my $p = fork; 
	die $! if $p == -1; 
	if (!$p) {
		for my $arg (@cvt_cmd) {
			$arg =~ s/_dest_/$dest/; 
			$arg =~ s/_source_/$_/; 
		}
		exec {$cvt_cmd[0]} @cvt_cmd; 
		die $!; 
	}
	waitpid $p, 0; 
	if ( -s $dest > 0) {
		s/\.[^.]*$/.jpg/i; ## file is now a jpeg...
		print "$dest -> $_\n"; 
		move($dest, $_);
		$done{$_}++; 
	}
}

## save converted files on log file
if ($done_file ne "") {
	open(FF, ">".$done_file) or die $!; 
	for (keys %done) {
		print FF "$_\n"; 
	}
	close FF;
}
