#! /usr/bin/perl
# class-version.pl -- detects current version of a classfile
# Carlos Duarte, 030226

while (defined($f=shift)) { 
	open F,$f and read F, $a, 8 and close F and $!=0;
	$! and die "$f: $!"; 
	@a=unpack("Nnn",$a); 
	$a[0]==0xcafebabe or next; 
	printf "$f version %d.%d\n",$a[2],$a[1]; 
}
