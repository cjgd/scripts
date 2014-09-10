#! /usr/bin/perl

# who.pl -- emulates who (use attached C to detect utmp structure)
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990211/000402

use strict; 
use vars qw($user $line $host $time); 

format STDOUT_TOP = 
USER     TTY      FROM              LOGIN    
.
format = 
@<<<<<<<<@<<<<<<<<@<<<<<<<<<<<<<<<<<@*
$user,   $line,   $host,            $time
.

try(qw( /etc/utmp /var/run/utmp )) or die "couldn't find utmp file"; 

my $utmp_size = 384; 
for (;;) {
	my $buf; 
	my $n = read(UTMP, $buf, $utmp_size); 
	$n == $utmp_size or last; 

	$user = (unpack('a44 Z32', $buf))[1]; 
	$line = (unpack('a8 Z32', $buf))[1]; 
	$line or next; 
	$line ne "~" or next; 
	$host = (unpack('a76 Z256', $buf))[1]; 
	$time = (unpack('a340 L1', $buf))[1]; 
	$time = localtime $time;
	write; 
}
close UTMP; 

## 

sub try {
	for (@_) {
		-f $_ or next; 
		open(UTMP, $_) or die "$_: $!"; 
		return 1; 
	}
	return 0;
}

__END__ 


/* this C code can be run to detect the unpack lines inside the for loop
   and the utmp_size 
 */
#include <stdio.h>
#include <utmp.h>

#define s_offset(type, member) ((int)&((type *)0)->member)
#define x(type, member) s_offset(type,member), sizeof(((type *)0)->member)

void
out(int pos, int size, char *name, int size_per_elem)
{
	printf("$%s = (unpack('a%d %c%d', $buf))[1]; \n", 
			name, pos, size_per_elem==1 ? 'Z' : 'L', 
			size/size_per_elem); 
}

main()
{
	printf("my $utmp_size = %d; \n", sizeof(struct utmp)); 

	out(x(struct utmp, ut_user), "user", 1); 
	out(x(struct utmp, ut_line), "line", 1); 
	out(x(struct utmp, ut_host), "host", 1); 
	out(x(struct utmp, ut_time), "time", 4); 
}
