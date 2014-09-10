#! /usr/bin/awk -f 

# column.awk -- print input lines with columns aligned
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990322/990402

function usage() { 
	printf "Usage: awk -f script.awk -- \
[-max #nr_lines] [-fs field_separator] [-gut #col_sep] [files...]\n"

	exit(2); 
}

BEGIN {
	## scan for options
	i=0
	while (++i< ARGC) {
		s = ARGV[i]
		if (s !~ /^-/) break
		if (s == "--") {
			++i
			break
		}
		if (s == "-max") {
			if ((nr_to_swallow = ARGV[++i]) == "") usage(); 
			continue
		}
		if (s == "-fs") {
			if ((FS = ARGV[++i]) == "") usage(); 
			continue
		}
		if (s == "-gut") {
			if ((gut = ARGV[++i]) == "") usage();
			continue; 
		}
		printf "%s -- unrecognized option\n", substr(s, 2); 
		usage(); 
		exit; 
	}

	## remap ARGC/ARGV without seen options
	j=0; 
	while (i<ARGC) 
		ARGV[++j] = ARGV[i++]
	i = j; 
	while (++j < ARGC)
		ARGV[j] = ""
	ARGC = i+1

	### here: ARGV[0] - name of the program (awk)
	### here: ARGV[1..ARGC-1] - remaining args

	if (gut == 0) gut = 1
	if (nr_to_swallow == 0) nr_to_swallow = 100
	if (FS == "") FS = " "; 
}

## USER CODE 

NR <= nr_to_swallow {
	x[nr++] = $0;
	for (i=1; i<=NF; i++)
		if (length($i) > nf[i])
			nf[i] = length($i)
	next
}

function pr(line,	j, save) {
	save = $0
	$0 = line
	for (j=1; j<=NF; j++)
		printf "%-*s%*s" , nf[j], $j, gut, ""
	print ""
	$0 = save
}

{
	if (nr) {
		for (i=0; i<nr; i++) 
			pr(x[i])
		nr=0
	}
	pr($0)
}

END {
	for (i=0; i<nr; i++)
		pr(x[i])
}
