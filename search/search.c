/* search.c -- equivalent search function of mkfiledb: given a 
 *             "compressed" file list searches for a pattern
 */ 

/* Carlos Duarte, 010927 */

#include <stdio.h> 
#include <stdlib.h> 
#include <ctype.h> 
#include <string.h> 

struct {
	char *file; 
	char *pat; 
} o; 

void usage(void) 
{
	printf("usage: search -f file-lst pattern\n"); 
	exit(2); 
}

void search(char *file, char *p) 
{
#define S 256
	unsigned char buf[S], last[S]; 
	FILE *f; 

	f = fopen(file, "r"); 
	if (!f) {
		perror(file); 
		exit(1);
	}
	last[0] = '\0'; 
	while (fgets(buf, sizeof buf, f)) {
		if (isdigit(buf[0])) {
			char tmp[S]; 
			int n; 
			int i = 1; 
			tmp[0] = buf[0]; 
			for (i=1; isdigit(buf[i]); i++) 
				tmp[i] = buf[i]; 
			tmp[i] = 0; 
			if (buf[i] == '-')
				i++; 
			n = atoi(tmp); 
			strcpy(tmp, last); 
			strcpy(tmp+n, buf+i); 
			strcpy(buf, tmp); 
		}
		if (strstr(buf, p)) 
			fputs(buf, stdout); 
		strcpy(last, buf); 
	}
	fclose(f); 
}

int main(int argc, char *argv[]) 
{
	int c; 
	extern char *optarg; 
	extern int optind; 

	memset(&o, 0, sizeof o); 
	while ((c = getopt(argc, argv, "f:")) != EOF) {
		switch (c) {
		case 'f': 
			o.file = optarg; 
			break; 
		case '?':
		default: 
			usage(); 
		}
	}
	if (argc - optind != 1)
		usage(); 
	o.pat = argv[optind]; 
	search(o.file, o.pat); 
	return 0; 
}
