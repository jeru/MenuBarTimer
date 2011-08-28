#!/bin/bash
FN=Localizable.strings
mkdir -p build/i18n
find . -type f | grep '\.m$' | xargs genstrings -au -o build/i18n
iconv -f utf-16 -t utf-8 build/i18n/${FN} > build/i18n/${FN}2

if [ "X$1" = "X" ]; then
	lang=en
else
	lang=$1
fi
python -c '
import re
import sys

def ReadFile(filename):
	f  = open(filename, "r")
	ret = {}
	while True:
		a = [f.readline() for i in range(3)]
		if not a[0] or not a[1]: break
		if not a[2]: a[2] = "\n"
		val = "".join(a)
		pat = r"""^"(?P<k>.*)" = ".*"(.|$)"""
		key = re.search(pat, a[1]).group("k")
		ret[key] = val
	return ret

s = ReadFile(sys.argv[2])
d = ReadFile(sys.argv[1])
for k in d:
	if k not in s:
		sys.stdout.write(d[k])
' build/i18n/${FN}2 L12N/${lang}.lproj/${FN}
