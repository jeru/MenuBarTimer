import os.path
import sys

sep = '/'
makefile_name = 'L12N_Makefile'

def LangDir(lang):
	return lang + '.lproj'

all_objs = [makefile_name]

def Xib(src, lang):
	d, b = src.rsplit(sep, 1)
	obj = sep.join([d, LangDir(lang), b])
	strs = sep.join(['L12N', LangDir(lang), b + '.strings'])
	pattern = '''\
%(obj)s : %(src)s %(strs)s %(makefile)s
\t$(ENSURE_DIR)
\tibtool --strings-file $(SRCROOT)/%(strs)s $(SRCROOT)/%(src)s --write $@
'''
	print >>makefile, pattern \
		% {'obj': obj,
		   'src': src,
		   'strs': strs,
		   'makefile': makefile_name}
	all_objs.append(obj)

def Pre():
	pattern = '''\
.PHONY: all all_real

all: all_real

ENSURE_DIR=mkdir -p `dirname $@`
'''
	print >>makefile, pattern
	pattern = '''\
%(obj)s : %(src)s
\t/usr/bin/env python $(SRCROOT)/%(src)s > $@
\t/usr/bin/env make -f $@
\texit 0
''' 
	print >>makefile, pattern % {'obj': makefile_name, 'src': sys.argv[0]}
	pass

def Post():
	print >>makefile, 'all_real: %s\n' % ' '.join(all_objs)

def Main():
	globals()['makefile'] = sys.stdout
	Pre()
	Xib('Nibs/Main.xib', 'zh-Hans')
	Post()
	del globals()['makefile']

if __name__ == '__main__':
	Main()
