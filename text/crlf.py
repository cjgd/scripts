#! /usr/bin/python
# crlf.py -- another CRLF to LF converter
# Carlos Duarte, 011012

import tempfile

def crlf_to_lf(fname): 
	tf = tempfile.TemporaryFile()
	f = open(fname, "rb")
	changed=0
	while 1: 	
		line = f.readline()
		if not line: break
		if line[-1] == "\n": line = line[:-1]
		else: changed=1
		if line and line[-1] == "\r": line = line[:-1]; changed=1
		tf.write(line + "\n")
	f.close()
	if not changed: 
		tf.close()
		return None
	tf.flush()
	return tf

def lf_to_crlf(fname): 
	tf = tempfile.TemporaryFile()
	f = open(fname, "rb")
	changed=0
	while 1: 
		line = f.readline()
		if not line: break
		if line[-1] == "\n": line = line[:-1]
		else: changed=1
		if line and line[-1] == "\r": line = line[:-1]
		else: changed=1
		tf.write(line + "\r\n")
	f.close()
	if not changed: 
		tf.close()
		return None
	tf.flush()
	return tf

if __name__ == "__main__": 
	import sys
	args = sys.argv[1:]
	strip_mode = 0
	if len(args)>=1 and args[0] == "-strip": 
		args.pop(0)
		strip_mode = 1
	if len(args) == 0 or args[0][0] == "-": 
		print "usage: crlf [-strip] files...]"
		sys.exit(1)
	for f in args: 
		tf = None
		if strip_mode: 
			tf = crlf_to_lf(f)
		else:
			tf = lf_to_crlf(f) 
		if tf:
			w = open(f,"wb")
			tf.seek(0,0)
			w.write(tf.read())
			tf.close()
			w.close()
