#! /usr/bin/env python
# Carlos Duarte, 060525

import sys
import SOAPpy

def main():
	wsdl,function_name,function_parms = get_args()
	proxy = SOAPpy.WSDL.Proxy(wsdl)
	if not proxy.methods.has_key(function_name):
		if function_name: print "%(function_name)s not available" % locals()
		print "the following can be used:\n ",  "\n  ".join(proxy.methods.keys())
		sys.exit(1)
	print proxy.__getattr__(function_name)(**function_parms)

def get_args():
	fname = None
	wsdl = None
	args = {}
	arg = None
	val = None
	for i in xrange(1,len(sys.argv)): 
		s = sys.argv[i]
		if i==1: 
			wsdl = s
			continue
		if i==2: 
			fname = s
			continue
		if i%2 == 1:
			arg = s
			continue
		if s.startswith('<'):
			val = file(s[1:]).read()
		else:
			val = s
		args[arg] = val

	if wsdl is None:
		usage()
	return wsdl,fname,args

def usage():
	print '''\
usage: wsdlcall {wsdl-file|wsdl-url} service-name [arg1 val1 [arg2 val2 ...]]
val can be literal or <file, where file contents are read
''', 
	sys.exit(2)

if __name__ == "__main__": 
	main()

