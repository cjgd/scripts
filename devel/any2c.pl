#! /usr/bin/perl

# any2c.pl -- converts text/binary to C string/data 
# $Id$
# Carlos Duarte <cgd@teleweb.pt>, 000123

use strict;

sub usage {
	print <<EOM;
usage: $0 [-h] [input files]

  -h      this help
  -t      text: generate a C string
  -b      bin:  generate a C data array 
  -a      autodetect text/bin
  -n NAME use NAME_buf and NAME_len for produced variables
  -oh FN  generate FN .h file (default: gen .c file to stdout)
  -oc FN  generate FN .c file ("-" means stdout)
EOM
	@_ and print "\n", join("\n", @_), "\n";
	exit;
}

my %o; 
O: while (defined(my $opt = shift)) {
	$opt eq "-h" and usage;
	$opt eq "-t" and do { $o{'mode'} = "text"; next O; }; 
	$opt eq "-b" and do { $o{'mode'} = "bin"; next O; }; 
	$opt eq "-a" and do { undef $o{'mode'}; next O; }; 
	$opt =~ /^-n/ and do {
		$opt =~ s///; ($opt eq "" && !defined($opt = shift)) and usage;
		$o{'name'} = $opt; 
		next O; 
	}; 
	$opt =~ /^-oh/ and do {
		$opt =~ s///; ($opt eq "" && !defined($opt = shift)) and usage;
		$o{'hfile'} = $opt; 
		next O; 
	}; 
	$opt =~ /^-oc/ and do {
		$opt =~ s///; ($opt eq "" && !defined($opt = shift)) and usage;
		$o{'cfile'} = $opt; 
		next O; 
	}; 
	###
	$opt eq "--" and last O;
	$opt =~ /^-/ and usage; 
	unshift(@ARGV, $opt); 
	last O; 
}

$o{'name'} eq "" and $o{'name'} = "xxx"; 
if (!$o{'hfile'} && !$o{'cfile'}) {
	$o{'cfile_fh'} = \*STDOUT; 
} else {
	my $f; 
	if ($o{'hfile'} eq "-") {
		$o{'hfile_fh'} = \*STDOUT; 
	} elsif ($o{'hfile'}) {
		$f = ">".$o{'hfile'}; 
		$o{'hfile_fh'} = openit($f); 
		$o{'hfile_fh'} or die "can't open $f: $_"; 
	}
	if ($o{'cfile'} eq "-") {
		$o{'cfile_fh'} = \*STDOUT; 
	} elsif ($o{'cfile'}) {
		$f = ">".$o{'cfile'}; 
		$o{'cfile_fh'} = openit($f); 
		$o{'cfile_fh'} or die "can't open $f: $_"; 
	}
}

## h file
if (my $fh = $o{'hfile_fh'}) {
	print {$fh} "extern unsigned int *$o{'name'}_len; \n"; 
	print {$fh} "extern unsigned char *$o{'name'}_buf; \n"; 
	$fh ne \*STDOUT and close $fh; 
}

## c file
if (my $fh = $o{'cfile_fh'}) {
	undef $/; 
	my $inited=0; 
	my $len = 0; 
	my $bpos = 0; ## for bin mode
	while (<>) {
		if (!$o{'mode'}) {
			$o{'mode'} = detect(substr($_, 0, 100)); 
		}
		if (!$inited) {
			die "invalid mode: $o{'mode'}" 
				if ($o{'mode'} ne "text" && 
				    $o{'mode'} ne "bin"); 
			my @p = $o{'mode'} eq "text" ? 
				("*", "", "\"\\") : 
				("", "[]", "{");  ## } for vi
			print {$fh} 
			  "unsigned char $p[0]$o{'name'}_buf$p[1] = $p[2]\n"; 
			$inited++; 
		}
		$len += length; 
		if ($o{'mode'} eq "text") {
			s/[\000-\037\177-\377\\\"]/do {
				local $_ = $&; 
				if ($_ eq "\n") {
					"\\n\\\n";
				} elsif ($_ eq "\t") {
					"\\t"; 
				} elsif ($_ eq "\\") {
					"\\\\"; 
				} elsif ($_ eq "\"") {
					"\\\""; 
				} else {
					sprintf "\\%03o", ord($_); 
				}
			}/seg; 
		} else {
			s/./do {
				my $b; 
				if (++$bpos == 1) {
					$b .= "\t"; 
				} else {
					$b .= ", "; 
					# 8 is the nr of bytes per line
					# can be any other value
					$bpos%8==1 and $b .= "\n\t"; 
				}
				$b .= sprintf "0x%02X", ord($&); 
				$b; 
			}/seg; 
		}
		print {$fh} $_; 
	}
	print {$fh} $o{'mode'} eq "text" ? "\";\n" : "\n};\n"; 
	print {$fh} "unsigned int $o{'name'}_len = $len; \n"; 
	$fh ne \*STDOUT and close $fh; 
}
exit; 

###

sub openit {
	my $name = shift;
	local *FH;
	return open (FH, $name) ? *FH : undef;
}

sub detect {
	local $_ = shift; 
	my $tot = length; 
	y/ -~\n\t//d; # delete ascii
	my $n = length; 
	## less than 5% bin chars means text
	return $n<$tot/20 ? "text" : "bin";  
}
