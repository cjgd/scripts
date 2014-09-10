#! /usr/bin/python
# strings.py -- find text portions in files
# Carlos Duarte, 011018

OK="/.-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

def strings(fname): 
	file = open(fname)
	data = file.read()
	file.close() 
	loading=0
	mystr=""
	for x in data: 
		if not loading: 
			if x not in OK: 
				continue
			else: 
				loading = 1
				mystr=x
		else: 
			if x not in OK: 
				if len(mystr) > 3: 
					print mystr
				loading=0
			else: 
				mystr = mystr + x

if __name__ == "__main__": 
	import sys
	args = sys.argv[1:]
	if len(args) == 0: 
		print "usage: strings files"
		sys.exit(1)
	for filename in args: 
		strings(filename)
