#! /usr/bin/awk -f 

# rev-byte.awk -- print reversed bytes in binary... 

# $Id: rev-byte.awk,v 1.2 1998/07/09 02:29:42 cdua Exp cdua $
# Carlos Duarte, 970220/971017

BEGIN {
	for(i=0; i<256; ++i) {
		j=i
		if((j%2)==0) printf("0"); else printf("1"); j = int(j/2);
		if((j%2)==0) printf("0"); else printf("1"); j = int(j/2);
		if((j%2)==0) printf("0"); else printf("1"); j = int(j/2);
		if((j%2)==0) printf("0"); else printf("1"); j = int(j/2);
		if((j%2)==0) printf("0"); else printf("1"); j = int(j/2);
		if((j%2)==0) printf("0"); else printf("1"); j = int(j/2);
		if((j%2)==0) printf("0"); else printf("1"); j = int(j/2);
		if((j%2)==0) printf("0"); else printf("1"); j = int(j/2);
		print ""
	}
}
