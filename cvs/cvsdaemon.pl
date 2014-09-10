#! /usr/bin/perl
# Carlos Duarte, 030423

# pserver setup
# 
# edit /cvsroot/CVSROOT/passwd
# add this line:
# weblogic:<crypt-hash>:weblogic
# 
# (format-- cvs_user:cvs_pass:real_user)

use strict;
use POSIX ":sys_wait_h"; 
use Socket;
use Carp;

if (@ARGV != 1) {
	print STDERR "usage: cvsdaemon repository-dir\n";
	exit 1; 
}
my $REPOSITORY = shift; 

my $pid;
$pid = fork(); 
defined $pid or die "could not fork: $!"; 
$pid and exit 0; 

open(STDIN, "</dev/null");
open(STDOUT, ">/dev/null");
open(STDERR, ">/dev/null");

my @script = qw( cvs -f --allow-root=REP pserver );
for (@script) { s/REP/$REPOSITORY/g; }
my $port = 2401;
my $proto = getprotobyname("tcp");

socket(Server, PF_INET, SOCK_STREAM, $proto)        || die "socket: $!";
setsockopt(Server, SOL_SOCKET, 
           SO_REUSEADDR, pack("l", 1))   || die "setsockopt: $!";
bind(Server, sockaddr_in($port, INADDR_ANY))        || die "bind: $!";
listen(Server,SOMAXCONN)                            || die "listen: $!";

my $paddr;
while ($paddr = accept(Client,Server)) {
	my($port,$iaddr) = sockaddr_in($paddr);
	my $name = gethostbyaddr($iaddr,AF_INET);

	# hostname -> $name
	# inet_ntoa($iaddr) -> its ip

	$pid = fork();
	if (!defined $pid) {
		warn "could not fork: $!";
		next;
	}
	if ($pid == 0) {
		close Server;
		open(STDIN, "<&Client");
		open(STDOUT, ">&Client");
		close Client;
		exec {$script[0]} @script;
		exit 6; 
	}
	close Client; 
	waitpid(-1, WNOHANG);
	#wait;
	#my $run_status = ($? >> 8);
}
