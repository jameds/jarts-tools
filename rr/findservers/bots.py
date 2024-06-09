#!/usr/bin/env python3

from zipfile import ZipFile
import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument('chars_pk3', help='chars.pk3 data file')
parser.add_argument('-o', default='bots.json', metavar='FILE', help='output JSON file (defaukt: bots.txt)')
args = parser.parse_args()

d = []
z = ZipFile(args.chars_pk3)
for name in filter(lambda name: name.split('/')[-1] == 'S_SKIN', z.namelist()):
	with z.open(name) as skin:
		while True:
			line = skin.readline().decode().strip()
			if not line:
				break
			parm = line.split(' = ')
			if parm[0] == 'realname':
				d.append(str(parm[1]).replace('_', ' '))
with open(args.o, 'w') as f:
	json.dump(d, f)
