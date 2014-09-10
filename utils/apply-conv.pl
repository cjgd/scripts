#! /usr/bin/perl 

# apply-conv.pl -- apply conversions to files 
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990627

use strict; 
use File::Find; 

# set of conversions to apply
my @conv = (
	'www.teleweb.pt', 'www-dev.teleweb.pt', 
	'smartview.teleweb.pt', 'smartview-dev.teleweb.pt:8080', 
	'registration.teleweb.pt', 'registration-dev.teleweb.pt', 
	'webmail.teleweb.pt', 'webmail-dev.teleweb.pt', 
);

my %o; 
@ARGV == 0 and usage(); 
O: while ($ARGV[0] =~ /^-/) {
	my $opt = shift;
	if ($opt eq "-r") {
		$o{'rev'}++; 
		next O; 
	}
	if ($opt eq "-d") {
		$o{'dump'}++; 
		next O; 
	}
	if ($opt eq "-l") {
		my $f = shift; 
		defined $f or usage(); 
		$o{'load'} = $f;
		next O; 
	}
	usage(); 
}

if (defined $o{'load'}) {
	local *F; 
	open F, $o{'load'} or die "can't open $o{'load'}: $!"; 
	undef @conv; 
	while (<F>) {
		chomp; 
		push @conv, $_; 
	}
	close F; 
	if (@conv%2 != 0) {
		die "must specify EVEN number of conversions (from -> to)"; 
	}
}

if ($o{'rev'}) {
	for (my $i=@conv-1; $i>0; $i -= 2) {
		($conv[$i-1], $conv[$i]) = ($conv[$i], $conv[$i-1]); 
	}
}

if ($o{'dump'}) {
	for (my $i=0; $i<@conv; $i += 2) {
		printf "%s -> %s\n", $conv[$i], $conv[$i+1];
	}
	exit;
}

my @files; 
find(sub { -T $_ and push(@files,$File::Find::name) }, @ARGV); 

undef $/; 
for my $f (@files) {
	open F, $f or next; 
	$_ = <F>; 
	close F; 
	my $save = $_;

	for (my $i=0; $i<@conv; $i += 2) {
		my $a = quotemeta $conv[$i];	$a =~ s/#/\\#/sg; 
		my $b = quotemeta $conv[$i+1];	$b =~ s/#/\\#/sg;
		eval "s#$a#$b#gs"; 
	}
	$_ ne $save and really_write($f, $_); 
}

exit; 

######################################################################

sub usage {
	print <<EOM; 
usage: $0 [-r] -[d] [-l file] dirs... 

-r   reverse conv
-d   dump conv
-l file
     load conv from file
EOM
	exit; 
}

# really_write $filename, $contents; write $contents into $filename
sub really_write {
	my $path = $_[0]; 
	my $content = $_[1]; 
	local *F; 
	open F, ">$path" and goto skip_mkdir; 

	my @pp = split('/', $path); pop @pp; 
	local $_; 
	my $dd; 
	for (@pp) {
		if (!defined($dd)) {
			($path =~ /^\//) and $dd = "/"; 
			$dd .= $_; 
		} else {
			$dd = "$dd/$_"; 
		}
		(-d $dd) or mkdir($dd,0755) or die "could not mkdir $dd: $!"; 
	}
	open F, ">$path" or die "could not open $path for writing: $!"; 
skip_mkdir:
	print F $content or die "can not write into $path: $!"; 
	close F or die "can not close $path: $!"; 
}
