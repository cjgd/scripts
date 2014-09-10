#! /usr/bin/python
# find-eq-files.py -- finds equal files (w.r.t contents)
# Carlos Duarte, 011016

from stat import *
import sys, os, getopt

verbose = False
def main(): 
	global verbose
	try: 
		opts, args = getopt.getopt(sys.argv[1:], "hv", ["help", "verbose"])
	except:
		usage()
	if not args: usage()
	for o,a in opts:
		if o == '-v': verbose = True
		elif o == '-h': usage()
	find_eq(args) 

def usage(): 
	print "usage: find-eq-files path... "
	sys.exit(2)

class FileHolder: 
	def __init__(self): 
		self.paths = []
		self.sizes = []
	def add(self, path, size): 
		self.paths.append(path)
		self.sizes.append(size)
	def equals(self): 
		return_array = []
		size_map = {}
		for path,size in map(None, self.paths, self.sizes): 
			key = str(size)
			if not size_map.has_key(key): 
				size_map[key] = []
			size_map[key].append(path)
		for k in size_map.keys(): 
			slot = []
			for file in size_map[k]: 
				is_equal = 0
				for s in slot: 
					if file_in(s, file): 
						s.append(file)
						is_equal = 1
						break
				if not is_equal: 
					slot.append([ file ])
			for s in slot: 
				if len(s)<2: continue
				return_array.append(s)
		return return_array

cache_name = []
cache_data = []
def cmpfile(fn1, fn2): 
	if verbose: print "comparing %s with %s ... " % (fn1, fn2)
	my_data1 = my_data2 = None
	for name,data in map(None, cache_name, cache_data): 
		if name == fn1: my_data1 = data
		if name == fn2: my_data2 = data
	if my_data1 == None: 
		my_data1 = open(fn1).read()
		cache_name.append(fn1)
		cache_data.append(my_data1)
	if my_data2 == None: 
		my_data2 = open(fn2).read()
		cache_name.append(fn2)
		cache_data.append(my_data2)
	if len(cache_name) > 12: 
		cache_name.pop(0)
		cache_data.pop(0)
	return my_data1 == my_data2

def file_in(arr, file): 
	for xfile in arr: 
		if cmpfile(xfile,file): 
			return 1
	return 0

def find_eq(args): 
	fh = FileHolder()
	find_eq_rec(fh, args) 
	# r -> [ [eqfiles-set1], [eqfiles-set2] ... ]
	if verbose: print "starting comparison ..."
	r = fh.equals()
	for set in r: 
		print "====="
		for file in set: 
			print file

def find_eq_rec(fh, files): 
	for f in files: 
		if verbose: print "stating %s ..." % (f)
		st = os.lstat(f)
		mode = st[ST_MODE]
		if S_ISREG(mode) and os.access(f, os.R_OK): 
			fh.add(f, st[ST_SIZE])
		elif S_ISDIR(mode) and os.access(f, os.R_OK|os.X_OK): 
			find_eq_rec(fh, 
			    map(lambda x,dir=f: dir+"/"+x, os.listdir(f)))

if __name__ == "__main__": main()
