#! /usr/bin/python
# empty-dirs.py -- finds empty directories, in python
# Carlos Duarte, 011015

from stat import *
import sys, os

recursive = verbose = 0
def main(): 
	global recursive, verbose
	args = sys.argv[1:]
	while args: 
		if args[0] == "-v": 
			args.pop(0)
			verbose=1
			continue
		if args[0] == "-r":
			args.pop(0)
			recursive=1
			continue
		break

	if not args: 
		print "usage: empty-dirs [-r] [-v] path... "
		sys.exit(2)
	if recursive: 
		recurvive_check(args)
	else: 	
		just_check(args)

def just_check(args): 
	for path in args: 
		if os.listdir(path): 
			if verbose: print "%s: NOT empty" % path
		else:
			if verbose: print "%s: empty" % path
			else: print path

def recurvive_check(args): 
	for path in args: rec_check(path)

def rec_check(path): 
	""" return 1 if it is or will be empty, 0 if not """
	files = os.listdir(path)
	if not files: 
		print path
		return 1
	count = 0 
	for f in files: 
		count = count + 1
		full = path + "/" + f
		mode = os.lstat(full)[ST_MODE]
		if not S_ISDIR(mode): continue
		if not os.access(full, os.R_OK|os.X_OK): continue
		if rec_check(full): 
			count = count - 1
	if count == 0: 
		print path
		return 1
	return 0

if __name__ == "__main__": main()
