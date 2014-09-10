#! /usr/bin/python
# catter.py -- blow up files to stdout. line by line or in full blocks
# Carlos Duarte, 011015

if __name__ == "__main__": 
	import sys
	args = sys.argv[1:]
	line_by_line = 0
	if args and args[0] == "-line": 
		line_by_line = 1
		args.pop(0)

	for x in args: 
		f = open(x, "rb")
		if line_by_line: 
			while 1: 
				line = f.readline()
				if not line: break
				sys.stdout.write(line)
		else: 
			sys.stdout.write(f.read())
		f.close()

