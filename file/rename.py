#! /usr/bin/python
# rename.py -- rename files by finding a fixed pattern and replace it by other, python version
# Carlos Duarte, 060328

import sys, re, os

def main():
	if len(sys.argv) <= 3: 
		print "usage: %s srcpat dstpat files..." % sys.argv[0]
		sys.exit(1)
	srcpat = sys.argv[1]
	dstpat = sys.argv[2]
	pat = re.compile(re.escape(srcpat))
	for fn in sys.argv[3:]: 
		newfn,n = pat.subn(dstpat, fn)
		if newfn == fn: continue
		print fn, "->", newfn
		os.rename(fn, newfn)

if __name__ == "__main__": main()
