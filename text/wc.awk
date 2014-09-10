#! /usr/bin/awk -f 

# wc.awk -- emulate unix wc, very crude
# $Id: wc.awk,v 1.1 1998/07/09 02:02:24 cdua Exp cdua $
# Carlos Duarte, 980708

# usage: ./wc.awk -- [-c -l -w] files... 

BEGIN {
	for (i=1; i<ARGC; i++) {
		if (ARGV[i] !~ /^-/)
			break
		if (ARGV[i] == "-c")
			doc++
		else if (ARGV[i] == "-w")
			dow++
		else if (ARGV[i] == "-l")
			dol++
		ARGV[i] = ""
	}
	if (dow+doc+dol == 0)
		dow=doc=dol=1

	if (ARGC-i > 1)
		p_tot++
}

function pr(l, w, c, tit) {
	if (dol) printf "%7d ", l
	if (dow) printf "%7d ", w
	if (doc) printf "%7d ", c
	print tit
}

function file_done() {
	if (cur_fn)
		pr(nl, nw, nc, cur_fn)
	totc += nc; nc = 0
	totl += nl; nl = 0
	totw += nw; nw = 0
	cur_fn = FILENAME
}

FNR==1 { file_done() }

{
	nc += length+1
	nw += NF
	nl++
}

END {
	file_done()
	if (p_tot)
		pr(totl, totw, totc, "total")
}
