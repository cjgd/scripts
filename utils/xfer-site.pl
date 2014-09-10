#! /usr/bin/perl

# xfer-site.pl -- transfers one dir to another, making changes on the files
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990523/990528

use strict; 
use File::Find;

sub VERB; 	# fwd decl 
sub usage {
	print <<EOM;
usage: $0 [-h] [-r] [-v] [-n] [-k] [-d] [-f] -c cfg_file 

  -h      this help
  -c cfg_file
          file with convertion mappings 
  -r      apply reverse mappings 
  -v      be verbose, say something while doing stuff
  -n      dont! do nothing
  -k      keep! never delete files or directories
  -d      dump cfg, and exits
  -f      force copy on same files

EOM
	exit;
}

my $cfg_file; 
my %opts = (
	'rev',	0, 
	'verb', 0, 
	'dont', 0, 
	'keep', 0, 
	'dump', 0, 
	'force', 0, 
); 

my ($opt); 
O: while (defined($opt = shift)) {
	$opt eq "-h" and usage;
	$opt eq "-r" and do { $opts{'rev'}++; next O; }; 
	$opt eq "-v" and do { $opts{'verb'}++; next O; }; 
	$opt eq "-n" and do { $opts{'dont'}++; next O; }; 
	$opt eq "-k" and do { $opts{'keep'}++; next O; }; 
	$opt eq "-d" and do { $opts{'dump'}++; next O; }; 
	$opt eq "-f" and do { $opts{'force'}++; next O; }; 
	$opt =~ /^-c/ and do {
		$opt =~ s///; ($opt eq "" && !defined($opt = shift)) and usage;
		$cfg_file = $opt; 
		next O; 
	}; 
	$opt eq "--" and last O;
	$opt =~ /^-/ and usage; 
	unshift(@ARGV, $opt); 
	last O; 
}

# dont accept any non-options args
@ARGV != 0 and usage; 
defined $cfg_file or usage; 

VERB "Loading \"$cfg_file\"..."; 
use vars '%cfg'; 
do "$cfg_file"; die $@ if $@; 

# now we have an %CFG, that contains: 
#	$->source_dir
#	$->dest_dir
#	@->select
#	@->reject
#	@->conv
#		@->cvts
#		@->sel
#		@->rej
#

$opts{rev} and do_rev(\%cfg);

($opts{'dump'} || $opts{verb}) and dump_cfg(\%cfg); 
$opts{'dump'} and exit; 

my @tmp_dirs; 
$SIG{__DIE__} = sub {
	cleanup(); 
	die $_[0]; 
}; 

# $a: local source dir, $b: local dest dir
my $a = do_mount($cfg{'source_dir'}); 
my $b = do_mount($cfg{'dest_dir'}); 

-d $a || die "cannot access $a: $!";
-d $b || die "cannot access $b: $!";

my %where; 
find(sub { my $fn = do_chop($a, $File::Find::name); $fn ne "" and 
	   filter($fn, $cfg{'select'}, $cfg{'reject'}) and 
	   $where{$fn} |= 1 }, $a); 
find(sub { my $fn = do_chop($b, $File::Find::name); $fn ne "" and 
	   $where{$fn} |= 2 }, $b);

if ($b !~ /^\//) {
	my $cwd; 
	chomp($cwd = `pwd`);
	$b = "$cwd/$b"; 
}
chdir($a) or die "chdir \"$a\" failed: $!"; 

my (@to_cp, @to_rm); 
for (keys %where) {
	if ($where{$_} == 1) {
		# only on A
		push @to_cp, $_; 
	} elsif ($where{$_} == 2) {
		# only on B 
		push @to_rm, "$b/$_";
	} else {
		# present on both
		if ($opts{'force'}) {
			push @to_cp, $_;
			next; 
		}
		if ( ! -f "$_"  or ! -f "$b/$_" ) {
			push @to_rm, "$b/$_";
			push @to_cp, "$_";
			next; 
		}
		my @sa = stat "$_"; 
		my @sb = stat "$b/$_"; 
		# 9: mtime
		# copies younger files
		if ($sa[9] > $sb[9]) {
			push @to_cp, $_; 
		}
	}
}

if ($opts{'dont'}) {
	local $_; 
	for (@to_rm) {
		print "removes: $_\n"; 
	}
	for (@to_cp) {
		print "copies : $_ -> $b\n"; 
	}
} else {
	do_rm(@to_rm)		unless $opts{keep}; 
	do_cp($b, @to_cp); 
	apply_conv($b, @to_cp); 
}

cleanup(); exit; 

## sub routines 

# do_chop /opt, /opt/foobar... -> foobar... 
sub do_chop {
	my $prefix= shift; 
	local $_; 
	my @a; 
	while ($_ = shift) {
		$_ = substr($_, length($prefix)); 
		s#^/*##; 
		$_ eq "" and next; 
		push(@a, $_); 
	}
	return wantarray ? @a : $a[0]; 
}

# do_mount $mount_point; return local dir
sub do_mount {
	local $_ = shift; 
	# canonize dir names
	s#/+#//#g; 
	s#/\./#/#g; 
	s#/+#/#g; 
	s#/*$##; 
	need_mount($_) and do {
		my $try = 1; 
		my $tmpd = "/tmp/mnt"; 
		while ( -e "$tmpd$try" ) { $try++ }
		$tmpd = "$tmpd$try"; 
		mkdir $tmpd, 0755 or 
			die "can not create temp dir \"$tmpd\": $!"; 
		push(@tmp_dirs, $tmpd); 
		VERB "do_mount: $_ is foreign, mouting $_ on $tmpd"; 
		system("mount $_ $tmpd")==0 or 
			die "can not mount '$_' on '$tmpd': $!"; 
		return $tmpd; 
	}; 
	VERB "do_mount: $_ is local"; 
	s/^.*?://; 
	return $_; 
}

# do_umount $mount_point; umount the guy 
sub do_umount {
	local $_ = shift; 
	need_mount($_) and do {
		VERB "do_umount: umounting $_..."; 
		system("umount $_")== 0 or
			warn "umount $_ failed: $!"; 
	}; 
}

# need_mount $mount_dir; ret 1 of mount_dir is a mount point, 0 if a local dir
sub need_mount {
	local $_ = shift; 

	/:/ or return 0; 
	my $host; 
	($host, undef) = split ":", $_, 2; 
	my $me = `hostname`; chomp $me; 
	for ($me, $host) {
		s/\..*$//;  # host.dom.domain -> host
		/\d\d$/ and $_ .= "i";  # host01 -> host01i, TW specific!
	}
	return lc($me) ne lc($host); 
}; 

# cleanup; clean up mess. currently rmdirs created temp dirs
sub cleanup {
	local $_; 
	do_umount($cfg{'source_dir'}); 
	do_umount($cfg{'dest_dir'}); 
	for (@tmp_dirs) {
		VERB "cleanup: rmdir $_"; 
		rmdir or warn "can not rmdir '$_': $!";
	}
}

# filter filename, $acc_ref, $rej_ref; ret 1 if acc, 0 if rej; 
# apply rules on cfg->select/reject
sub filter {
	local $" = " "; 
	local $_ = shift; 
	my @acc = @{ scalar shift }; 
	my @rej = @{ scalar shift }; 

	for my $re (@acc) {
		m#$re# && goto acc;
	}
	for my $re (@rej) {
		m#$re# && goto rej; 
	}
	@acc+@rej == 0 and goto acc; # no rules, defaults to yes
	@acc == 0      and goto acc; # no acc, rej passes -- ok
	@rej == 0      and goto rej; # no rej, acc passed -- bad

	# else did not match any rej, did not match any acc, defaults to ok
acc: 
	VERB "filter: accepts $_ on @acc, @rej"; 
	return 1; 
rej: 
	VERB "filter: rejects $_ on @acc, @rej"; 
	return 0; 
}

# do_rev; swaps cfg->conv->from,cfg->conv->to sense
sub do_rev {
	my $cf = shift; 
	local $_; 

	for (@{${%{$cf}}{conv}}) {
		my $i = 0; 
		while (defined ${${%$_}{cvts}}[$i]) {
			(${${%$_}{cvts}}[$i  ], ${${%$_}{cvts}}[$i+1]) = 
			(${${%$_}{cvts}}[$i+1], ${${%$_}{cvts}}[$i  ]); 
			$i += 2; 
		}
	}
	(${%{$cf}}{source_dir}, ${%{$cf}}{dest_dir}) =
	(${%{$cf}}{dest_dir}, ${%{$cf}}{source_dir}); 
}

# do_rm list; removes all files or directories on list
sub do_rm {
	local $_; 
	for (@_) {
		if ( -d $_ ) {
			rm_rf($_); 
		} elsif ( -e _ ) {
			VERB "do_rm: unlink $_"; 
			unlink or die "can not unlink \"$_\": $!"; 
		}
		# else was deleted already
	}
}

# rm_rf dir; remove directory $dir and all files and dirs in it (recur)
sub rm_rf {
	my $dir = shift; 
	local $_; 
	local *DIR; 

	opendir(DIR, $dir) || die "can not opendir \"$dir\": $!"; 
	for (readdir DIR) {
		$_ eq "." and next; 
		$_ eq ".." and next; 
		if ( -d "$dir/$_" ) {
			rm_rf("$dir/$_"); 
		} else {
			VERB "do_rm: unlink $dir/$_"; 
			unlink "$dir/$_" 
				or die "can not unlink \"$dir/$_\": $!"; 
		}
	}
	closedir DIR; 
	VERB "do_rm: rmdir $dir"; 
	rmdir $dir or die "can not rmdir \"$dir\": $!"; 
}

# do_cp $dest, @list; copies all stuff on @list to $dest (is a dir)
sub do_cp {
	my $dest = shift; 
	@_ or return; 

	VERB "do_cp: will execute 'cpio -pdm -u $dest'"; 
	$opts{'verb'} and do {
		local $_; 
		for (@_) {
			print "do_cp: $_ -> $dest\n"; 
		}
	}; 

	open(CPIO, "|cpio -pdm -u $dest 2>/dev/null") or die "cpio: $!";
	print CPIO join("\n", @_) . "\n" or die "cpio'ing: $!";
	close(CPIO) or die "cpio might not finished correctly: $!"; 

}

# apply_conv $dest, @list; apply cfg convertions on $dest/@list files
sub apply_conv {
	my $dest = shift; 
	local $_; 
	local $/; undef $/; 

	for my $f (@_) {
		VERB "apply_conv: studying $f..."; 
		my $fn = "$dest/$f"; 
		-T $fn or next; # only convert text files
		open F, $fn or die "can not open '$fn': $!"; 
		my $cont = <F>; 
		close F; 
		$_ = $cont; 

		for my $ch (@{$cfg{conv}}) {
			my %h = %$ch; 
			filter($f, $h{sel}, $h{rej}) or next; 

			my @map = @{$h{cvts}}; 
			while (@map) {
				my $from = shift @map; 
				my $to   = shift @map; 
				VERB "apply_conv: from - $from"; 
				VERB "apply_conv: to   - $to"; 
				$from = quotemeta $from; 
				$to   = quotemeta $to; 
				eval "s#$from#$to#gs"; 
			}
		}
		$_ eq $cont and do {
			VERB "apply_conv: $f not changed"; 
			next; 
		}; 
		VERB "apply_conv: writing new modified $f"; 
		really_write($fn, $_); 
	}
}

# really_write $filename, $contents; write $contents into $filename
sub really_write {
	my $path = $_[0]; 
	my $content = $_[1]; 
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

sub dump_cfg {
	my $cf = shift; 
	print "source dir: ", ${%{$cf}}{'source_dir'}, "\n"; 
	print "dest   dir: ", ${%{$cf}}{'dest_dir'}, "\n"; 
	print "\n"; 

	my $first; 
	print "selects on: "; 
	$first=1; 
	for (@{${%{$cf}}{'select'}}) {
		!$first and print ", "; 
		print "'$_'"; 
		$first and $first = 0; 
	}
	print "\n"; 

	print "rejects on: "; 
	$first=1; 
	for (@{${%{$cf}}{'reject'}}) {
		!$first and print ", "; 
		print "'$_'"; 
		$first and $first = 0; 
	}
	print "\n"; 

	for (@{${%{$cf}}{'conv'}}) {
		print "\n=======\n"; 

		my %h = %$_; 
		my @cvts = @{$h{cvts}}; 
		my ($ff, $tt); 
		while (defined($ff = shift @cvts)) {
			$tt = shift @cvts; 
			print "From : ", $ff, "\n"; 
			print "To   : ", $tt, "\n"; 
			print "\n"; 
		}

		print "selects on... "; 
		my @sel = @{$h{sel}}; for (@sel) { print "'$_', "; }
		print "\n"; 

		print "rejects on... "; 
		my @rej = @{$h{rej}}; for (@rej) { print "'$_', "; }
		print "\n"; 
	}
}

sub VERB {
	$opts{verb} or return;
	print @_; 
	local $_ = "@_"; 
	/\n$/ or print "\n";  
}
