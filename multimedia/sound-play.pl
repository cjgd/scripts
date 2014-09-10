#! /usr/bin/perl

# sound-play.pl -- simple audio file player
# $Id$ 
# Carlos Duarte <cgd@mail.teleweb.pt>, 990923

use strict;

# actually, a general player frontend.  
# this chooses one player, then get the files appropriate for it

my %players; 
$players{'mpg123'} = [ "mp1", "mp2", "mp3", "mp4" ]; 
$players{'splay'} = [ "mp1", "mp2", "mp3", "mp4", "wav" ]; 
$players{'soxplay'} = [ "au", "wav" ]; 
$players{'amp'} = [ "mp1", "mp2", "mp3", "mp4" ]; 
$players{'xv'} = [ "gif", "jpg" ]; 
$players{'xloadimage'} = [ "gif", "jpg" ]; 
$players{'xanim'} = [ "avi", "mov" ]; 

my $player = "mpg123"; 
my @player_opts; 
my %o; 
while ($ARGV[0] =~ /^-/) {
	my $opt = shift; 
	if ($opt eq "-p") {
		$opt = shift or usage(); 
		$player = $opt; 
	} elsif ($opt eq "-z") {
		$o{'shuffle'}=1; 
	} elsif ($opt eq "-b") {
		$o{'bg'}=1; 
	} elsif ($opt eq "-?") {
		usage(); 
	} else {
		# pass unrecognized options to player
		# -b 2000 will not work, but -b2000 will
		push @player_opts, $opt; 
	}
}

@ARGV==0 and usage(); 
exists $players{$player} or 
	usage("$player: invalid player -- choose one from: ".
	      join ' ', sort keys %players); 

my $allowed_exts = arr_to_hash($players{$player}); 

my @selected; 
open F, "find ${ \( join ' ', @ARGV) } -type f -print |" or die "find: $!"; 
while (<F>) {
	chomp; 
	my $ext = get_ext($_); 
	$allowed_exts->{$ext} or next; 
	push @selected, $_; 
}
close F; 

@selected or die "no files found for player: $player"; 

$o{'shuffle'} and arr_shuffle(\@selected); 
$o{'bg'} and do {
	my $pid = fork; 
	defined $pid or die "could not fork: $!"; 
	$pid and exit; 
};
for (my $i=0; $i<@selected; $i++) {
	my ($len, @a); 
	while ($i < @selected && @a < 8192 && $len < 20480) {
		$len += length($selected[$i]); 
		push @a, $selected[$i++]; 
	}
	$i--; ## compensate for() incr
	if (@a) {
		my $pid = fork; 
		$pid == -1 and die "fork: $!"; 
		if ($pid == 0) {
			exec {$player} $player, @player_opts, @a; 
			die "exec: $!"; 
		}
		wait; 
	}
}
exit;

##### 

sub usage {
	print<<EOM;
usage: $0 [-p player] [-z] [-b] dir1 [dir2 ...]
 -p player     use player for play files
 -z            shuffle list of files
 -b            goes background
EOM
	print @_, "\n" if @_;
	exit 1; 
}

sub arr_to_hash {
	local $_ = shift; 
	my %h; 
	for (my $i = 0; $i < @{$_}; $i++) {
		$h{$_->[$i]} = 1; 
	}
	return \%h; 
}

sub get_ext {
	local $_ = shift; 
	s/^.*\.//; 
	return lc $_; 
}

sub arr_shuffle {
	local $_ = shift; 
	for (my $i = 0; $i < @{$_}; $i++) {
		my $j = int(rand(@$_ - $i)) + $i; 
		($_->[$i], $_->[$j]) = ($_->[$j], $_->[$i]); 
	}
}
