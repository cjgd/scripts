#! /usr/bin/perl

# img-play.pl -- play images 
# $Id$ 
# Carlos Duarte <cgd@mail.teleweb.pt>, 990923

# actually, a general player frontend.  
# this gets the files first, then chooses the appropriate player 
# for each file...

my %ext; 
$ext{'mpeg'} = 
$ext{'mpg'} = [ "plaympeg", "mpeg_play", "xanim" ]; 
$ext{'avi'} = [ "xanim" ]; 
$ext{'gif'} = 
$ext{'jpg'} = [ "xv", "xloadimage", "xli", "ee" ]; 
$ext{'mp1'} = 
$ext{'mp2'} = 
$ext{'mp3'} = 
$ext{'mp4'} = [ "amp", "mpg123", "splay", "xaudio" ]; 
$ext{'wav'} = [ "splay", "play" ]; 
$ext{'au'} =  [ "sfplay", "play" ]; 
$ext{'mid'} =  
$ext{'midi'} = [ "playmidi" ]; 

select_players(\%ext); 

sub usage {
	print<<EOM;
usage: $0 [-z] ] [-1] dir1 [dir2 ...]
 -z            shuffle list of files
 -1            run player one time per file (else collects all files 
		 each player can take, and run it)
EOM
	exit 1; 
}

my @player_opts; 
my %o; 
while ($ARGV[0] =~ /^-/) {
	my $opt = shift; 
	if ($opt eq "-z") {
		$o{'shuffle'}=1; 
	} elsif ($opt eq "-h") {
		usage(); 
	} elsif ($opt eq "-1") {
		$o{'one'}=1;
	} else {
		# pass unrecognized options to player
		# -b 2000 will not work, but -b2000 will
		push @player_opts, $opt; 
		next; 
	}
}

@ARGV==0 and usage();

my @sel; 
for (@ARGV) { s/'/'\\''/sg; $_ = "'$_'"; }
open FF, "find ${ \( join ' ', @ARGV) } -type f -print |" or die "find: $!"; 
while (<FF>) {
	chomp; 
	my $ext = get_ext($_); 
	exists $ext{$ext} or next; 
	push @sel, $_; 
}
close FF;

@sel or die "no files to play have been found"; 
$o{'shuffle'} and arr_shuffle(\@sel); 

$SIG{'__DIE__'} = \&tty_restore; 
tty_save(); 
tty_canon(); 
for (my $i=0; $i<@sel; $i++) {
	my $r; 
	print "(q)uit, (a)gain, (b)ack, (r)eshuffle, (*) next\r\n"; 

	if ($o{'one'}) {
		$r = play([ $sel[$i] ]); 
	} else {
		my (@a,$len); 
		$a[0] = $sel[$i++]; 
		while ($i<@sel && @a<8192 && $len < 20480 &&
		       		equiv(get_ext($sel[$i]), get_ext($a[0]))) {
			$len += length($sel[$i]); 
			push(@a, $sel[$i++]); 
		}
		$i--; ## compensate for incr
		$r = play(\@a); 
	}
	$r eq "q" and last; 
	$r eq "a" and $i--;
	$r eq "b" and $i -= 2; 
	$r eq "r" and do { arr_shuffle(\@sel); $i = -1; }; 
}
tty_restore(); 
exit; 

####

use POSIX ":sys_wait_h";

sub play {
	my $a = shift; 
	my $pid = fork; 
	die "fork: $!" unless (defined $pid); 

	if ($pid == 0) {
		my $p = $ext{get_ext($a->[0])}->[0]; 
		exec {$p} $p, @player_opts, @$a;
		die "couldnt exec $p: $!"; 
	}
	for (;;) {
		my $c; 
		my $rin = ''; my $rout; 
		vec($rin,fileno(STDIN),1) = 1;
		my $nfound = select($rout=$rin, undef, undef, 0.2);
		if ($nfound > 0) {
			kill 15, $pid; 
			$c = getc STDIN; 
			while (select($rout=$rin, undef, undef, 0.1)>0) {
				getc STDIN; 
			}
			kill 9, $pid;
		}
		# if child exited - next
		if (waitpid(-1,&WNOHANG) > 0) {
			my $status = $? >> 8; 
			my $sig = $? & 127; 
			if ($status == 0 && 
			    ($sig == 15 || $sig == 9 || $sig == 0)) {
				return lc $c; 
			}
			return 'q'; 
		}
	}
}

sub select_players {
	my $h = shift; 
	local $_; 

	for (keys %$h) {
		my $a = $h->{$_}; 
		while (@$a) {
			can_exec($a->[0]) and last; 
			splice @$a, 0, 1; 
		}
		@$a or delete $h->{$_};
	}
}

sub can_exec {
	local $_ = shift; 
	for my $p (split /:/, $ENV{"PATH"}) {
		-x "$p/$_" and return 1; 
	}
	return 0; 
}

sub arr_shuffle {
	local $_ = shift; 
	for (my $i = 0; $i < @{$_}; $i++) {
		my $j = int(rand(@$_ - $i)) + $i; 
		($_->[$i], $_->[$j]) = ($_->[$j], $_->[$i]); 
	}
}

sub get_ext {
	local $_ = shift; 
	s/^.*\.//; 
	return lc $_; 
}

sub equiv {
	my $ext1 = shift; 
	my $ext2 = shift; 
	return $ext{$ext1}->[0] eq $ext{$ext2}->[0]; 
}

my $tty_data; 
sub tty_save {
	$tty_data = `stty -g </dev/tty`;
	chomp $tty_data;
}

sub tty_canon {
	system "stty -icanon min 1 -echo </dev/tty";
}

sub tty_restore {
	$tty_data and system "stty $tty_data </dev/tty";
}

