#! /usr/bin/perl

# mymirror.pl -- mymirror A B, make minimal operations on B, such as A=B
# $Id: mymirror.pl,v 2.1 1999/05/15 22:51:01 cdua Exp cdua $
# Carlos Duarte <cgd@mail.teleweb.pt>, 990430/990515

use strict; 

use File::Find;

sub usage {
	print<<EOF; 
Usage: $0 SOURCE_DIR DEST_DIR
EOF
	exit 2; 
}

## MAIN
my $a = shift or usage; 
my $b = shift or usage; 
shift and usage; 

-d $a || die "cannot access $a: $!";
-d $b || die "cannot access $b: $!";

my (@a,@b); 
my %where; 
sub wanted_a { $where{do_chop($a, $File::Find::name)} |= 1 }
sub wanted_b { $where{do_chop($b, $File::Find::name)} |= 2 }
find(\&wanted_a, $a); 
find(\&wanted_b, $b);

if ($b !~ /^\//) {
	my $cwd; 
	chomp($cwd = `pwd`);
	$b = "$cwd/$b"; 
}
chdir($a) or die "chdir '$a' failed: $!"; 

my (@to_cp, @to_rm); 
for (keys %where) {
	if ($where{$_} == 1) {
		# only on A
		push @to_cp, $_; 
	} elsif ($where{$_} == 2) {
		# only on B 
		push @to_rm, "$b/$_";
	} else {
		# both
		my @sa = stat "$_"; 
		my @sb = stat "$b/$_"; 
		# 9: mtime
		if ($sa[9] > $sb[9]) {
			push @to_cp, $_; 
		}
	}
}

#print "Copies:\n", join("\n", @to_cp) . "\n"; 
#print "Removes:\n", join("\n", @to_rm) . "\n";
@to_rm && do {
	system("rm", "-rf", @to_rm) == 0 or die "rm -rf @to_rm failed: $!"; 
}; 
@to_cp && do {
	open(CPIO, "|cpio -pdm -u $b 2>/dev/null") or die "cpio: $!"; 
	print CPIO join("\n", @to_cp) . "\n" or die "cpio'ing: $!";
	close(CPIO) or die "cpio might not finished correctly: $!"; 
}; 

## sub routines 

sub do_chop {
	my $prefix= shift; 
	local($_); 
	my @a; 
	while ($_ = shift) {
		$_ = substr($_, length($prefix)); 
		s#^/*##; 
		$_ eq "" and next; 
		push(@a, $_); 
	}
	return @a == 1 ? $a[0] : @a; 
}
