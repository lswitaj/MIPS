#! /usr/bin/python3
# tab_adder.py - Program zamieniający format instrukcji
# [polecenie][spacja][rejestry] na [polecenie][tab][rejestry]
# wymagany podczas oddawania projektów z ARKO na EiTI PW

import re, fileinput

tabsAdder = re.compile(r'''(
	(.*?)
	([abdefghijlmoqrstvwuz]{1,5})
	(\ )
	(\$)
	(.*\n)
	)''', re.VERBOSE)

outFile = open('lswitaj_with_tabs.asm', 'w')
with open('lswitaj.asm', 'r') as inFile:
	for line in inFile:
		found = tabsAdder.search(line)
		try:
			outFile.write(found.group(2)+found.group(3)+'\t'+found.group(5)+found.group(6))
		except AttributeError:
			outFile.write(line)
		
