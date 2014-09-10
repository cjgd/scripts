#! /usr/bin/perl

# rcsmove.pl -- move source-files and theirs ,v if any, into other dir
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990922

use strict; 

my %opts; 

O: 
if ($ARGV[0] eq "-v") { $opts{'verb'} = 1; shift; goto O; } 
if ($ARGV[0] eq "-n") { $opts{'dont'} = 1; 
                        $opts{'verb'} = 1; shift; goto O; } 
@ARGV == 0 and usage(); 

my $dest = pop @ARGV; 

my ($dest_is_dir, $dest_dir, $dest_file); 
if ( -d $dest ) {
	$dest_is_dir = 1; 
	$dest =~ s#/*$##;
	$dest ne "/" and $dest .= "/"; 
	$dest_dir = $dest; 
} else {
	$dest_dir = $dest; 
	$dest_dir =~ s#[^/]*$##;

	$dest_file = $dest; 
	$dest_file =~ s#^.*/##;
}

if (@ARGV > 1 && ! $dest_is_dir ) {
	usage("when moving more than 1 file, ", 
	      "last component must be a directory\n"); 
}

for my $full_path (@ARGV) {
	$full_path =~ s#/*$##;

	if ( ! -f $full_path ) {
		warn "$0: $full_path: $!"; 
		next; 
	}

	local $_ = $full_path; 
	s#[^/]*$##; 
	my $path = $_; 

	$_ = $full_path; 
	s#^.*/##; 
	my $file = $_; 

	if ($dest_is_dir) {
		$dest_file = $file; 
	}

	$_ = "${path}RCS/$file,v";	
	-f $_ and do_move($_, "${dest_dir}RCS/$dest_file,v"); 


	$_ = "${path}$file,v";		
	-f $_ and do_move($_, "${dest_dir}$file,v"); 

	do_move($full_path, "${dest_dir}$dest_file"); 
}

## 

sub usage {
	print "usage: $0 [-n] files [...] dir\n";
	print "usage: $0 [-n] file dest-file\n";
	print "   -n   show only what would be done\n"; 
	print @_ if (@_); 
	exit 1; 
}

sub do_move {
	my $src = shift; 
	my $dst = shift; 

	ensure_path($dst); 

	print "moving $src -> $dst\n" if ($opts{'verb'}); 
	return if ($opts{'dont'}); 
	rename $src, $dst or die "rename $src, $dst: $!"; 
}

my %ens_cache; 
sub ensure_path {
	local $_ = shift; 

	my @d; 
	while (s#/[^/]*$## && $_ ne "") {
		$ens_cache{$_} and last; 

		m#(^|/)\.\.$# and next; 
		m#(^|/)\.$# and next; 
		push @d, $_; 
	}
	for (reverse @d) {
		print "mkdir $_\n" if ($opts{'verb'});

		if (!$opts{'dont'}) {
			-d $_ or mkdir($_,0755) or die "mkdir $_: $!"; 
			$ens_cache{$_}++; 
		}
	}
	return 1; 
}
