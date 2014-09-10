#! /usr/bin/perl

# m4conv.pl -- converts standard M4 quotes and prefix builtins
# $Id$
# Carlos Duarte <cgd@teleweb.pt>, 000210

use strict;

my %o = (
	LQ => "\`", 
	RQ => "\'", 
	DEFAULT_PREFIX => 'm4_', 
); 

sub usage {
	print <<EOM;
usage: $0 [-h] [FILES...]

  -h           this help
  -w           emit warnings about potencial problems
  -q LQ,RQ     convert from standard ($o{LQ},$o{RQ}) quotes, to (LQ,RQ)
  -P [prefix]  convert from normal source, to specified prefix 
	       (if not give, use default $o{DEFAULT_PREFIX})
EOM
	@_ and print "\n", join("\n", @_), "\n";
	exit;
}

O: while (defined(my $opt = shift)) {
	$opt eq "-h" and usage;
	$opt eq "-w" and do { $o{WARN}++; next O; }; 
	$opt =~ /^-q/ and do {
		$opt =~ s///; ($opt eq "" && !defined($opt = shift)) and usage;
		($o{LQ}, $o{RQ}) = split /,/, $opt, 2; 
		$o{REQUOTE}++; 
		warn "empty left quote" if ($o{WARN} && $o{RQ} eq ""); 
		next O; 
	}; 
	$opt =~ /^-P/ and do {
		$opt =~ s///; 
		if ($opt eq "") {
			$opt = $ARGV[0]; 
			if (defined $opt && !($opt =~ /^-/)) {
				shift; 
			} else {
				$opt = ""; 
			}
		}
		$o{PREFIX} = $opt ? $opt : $o{DEFAULT_PREFIX}; 
		next O; 
	}; 
	##
	$opt eq "--" and last O;
	$opt =~ /^-/ and usage; 
	unshift(@ARGV, $opt); 
	last O; 
}

### MAIN
###

my $key_re = get_keys(); 
undef $_; undef $/;  
$o{REQUOTE} and $_ = "changequote($o{LQ},$o{RQ})dnl\n"; 
$_ .= <>; 
$o{REQUOTE} and do {
	s/\`/$o{LQ}/sg; 
	s/\'/$o{RQ}/sg; 
}; 
$o{PREFIX} and eval { 
	s/\b$key_re\b/$o{PREFIX}$&/sg; 
}; 
print; 
exit; 

sub get_keys {
	local ($_,$.); 
	my $k; 
	while (<DATA>) {
		s/\s*$//s; 
		$k .= quotemeta $_; 
		$k .= "|"; 
	}
	defined $k or return undef; 
	chop $k; 
	return "\\b($k)\\b"; 
}

__DATA__
builtin
changecom
changequote
changeword
debugfile
debugmode
decr
define
defn
divert
divnum
dnl
dumpdef
errprint
esyscmd
eval
__file__
format
__gnu__
ifdef
ifelse
include
incr
index
indir
len
__line__
m4exit
m4wrap
maketemp
patsubst
popdef
pushdef
regexp
shift
sinclude
substr
syscmd
sysval
traceoff
traceon
translit
undefine
undivert
unix
