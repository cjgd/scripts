#!/usr/bin/perl 

# ls-l.pl -- do a 'ls -l' in perl 
# $Id$
# Carlos Duarte, 981215/990227

use strict 'vars'; 

my @dirs = @ARGV; 
scalar(@dirs) == 0 and @dirs = ( "." ); 
	
my @files; 
for my $dir (@dirs) {
	opendir D, $dir; 
	@files = readdir D; 
	closedir D; 

	foreach my $f (sort @files) {
		my @ret = stat "$dir/$f"; 

# -rwxr-xr-x   1 cdua     users         118 Dec 14 23:36 perl-ls*
		printf
"%s%s%4d %-8s %-8s %8d %s %s\n", 
file_type($ret[2]), 
file_perm($ret[2]), 
$ret[3]+0, 
scalar(getpwuid $ret[4]), 
scalar(getgrgid $ret[5]), 
$ret[7]+0, 
time_of($ret[9]), 
$f; 
	}
}

#
# 0 dev      device number of filesystem
# 1 ino      inode number
# 2 mode     file mode  (type and permissions)
# 3 nlink    number of (hard) links to the file
# 4 uid      numeric user ID of file's owner
# 5 gid      numeric group ID of file's owner
# 6 rdev     the device identifier (special files only)
# 7 size     total size of file, in bytes
# 8 atime    last access time since the epoch
# 9 mtime    last modify time since the epoch
# 10 ctime    inode change time (NOT creation time!) since the epoch
# 11 blksize  preferred block size for file system I/O
# 12 blocks   actual number of blocks allocated
#

sub file_type {
	my $mode = shift; 

	$mode >>= 12; 
	$mode &= 017; 

	$mode & 001 and return "p"; 
	$mode & 002 and return "c"; 
	$mode & 004 and return "d"; 
	$mode & 006 and return "b"; 
	$mode & 010 and return "-"; 
	$mode & 012 and return "l"; 
	$mode & 014 and return "s"; 
	return "?"; 
}

sub file_perm {
	my $mode = shift; 
	my $spec = $mode; 
	my (@str, $i); 

	$mode &= 0777; 
	$spec >>= 9; 
	$spec &= 07; 
	for $i (0 .. 8) {
		$str[$i] = "-"; 
	}
	$i = 9; 
	do {
		--$i; $mode & 01 and $str[$i] = "x";
		--$i; $mode & 02 and $str[$i] = "w";
		--$i; $mode & 04 and $str[$i] = "r";
		$mode >>= 3; 
	} while ($i > 0); 

	$spec & 01 and $str[8] = "t";  # sticky
	$spec & 02 and $str[5] = "s";  # gid
	$spec & 04 and $str[2] = "s";  # uid
	return join('', @str); 
}

my @monnam = (
	'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
	'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ); 

sub time_of {
	#   0     1    2     3     4    5     6     7      8
	# ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)
	my @date = gmtime shift; 

	return sprintf "%s %02d %02d:%02d", 
			$monnam[$date[4]], $date[3], $date[2], $date[1]; 

}
