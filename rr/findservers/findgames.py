#!/usr/bin/env python3

from termcolor import colored
from urllib.request import urlopen
import argparse
import itertools
import json
import pyperclip
import re
import time

parser = argparse.ArgumentParser()
group = parser.add_argument_group('Download options')
group.add_argument('-r', action='store_true', help='force refresh')
group.add_argument('-s', action='store_true', help='prevent refresh')
group = parser.add_argument_group('Search options')
group.add_argument('-a', action='store_true', help='show servers with addons')
group.add_argument('-e', action='store_true', help='show empty servers')
group.add_argument('-f', action='store_const', const='full', default='joinable', help='show full servers')
group.add_argument('-c', type=int, metavar='id', help='copy server address to clipboard, implies -s')
args = parser.parse_args()

bots = []
try:
	with open('bots.json') as f:
		bots = json.load(f)
except Exception:
	pass

d = None

def load():
	global d
	with open('list.json') as f:
		d = json.load(f)

if not args.r and not args.s and not args.c:
	try:
		load()
		if time.time() - d['time'] > 60:
			args.r = True
	except Exception:
		pass

if args.r:
	print('Refreshing...', end='\r')
	try:
		with urlopen('https://ms.kartkrew.org/list.json') as r:
			data = r.read()
			d = json.loads(data)
			with open('list.json', 'wb') as f:
				f.write(data)
	except Exception:
		pass

if d is None:
	load()

def pcount(n):
	return colored(n, 'red' if n >= 8 else None)

def pwr_sort(n):
	return 0 if n == 'disabled' else n

def spectators(players):
	n = len([p for p in players if p['team'] == 'spectator'])
	return f'(+{n} spectating)' if n else ''

def fcount(files):
	return f'{len(files)} files' if len(files) else ''

def pwr(n):
	if isinstance(n, str):
		return n
	if n < 1300:
		color = 'dark_grey'
	elif n > 2000:
		color = 'red'
	else:
		color = 'green'
	return colored(n, color)

def svip(addr):
	text = ':'.join(map(str, s['address']))
	return colored(text, attrs=['underline']) + ' ' * (21 - len(text))

def svname(text):
	colors = {
		'^1': 'magenta',
		'^2': 'yellow',
		'^3': 'green',
		'^4': 'blue',
		'^5': 'red',
		'^6': 'grey',
		'^7': 'red',
		'^8': 'cyan',
		'^9': 'magenta',
		'^A': 'yellow',
		'^B': 'cyan',
		'^C': 'magenta',
		'^D': 'red',
		'^E': 'red',
		'^F': 'grey',
	}
	return ''.join(
		colored(v, colors.get(k, 'white'), attrs=['bold'])
		for k, v in re.findall(r'(\^[0-9A-F])?(.*?)(?=\^[0-9A-F]|$)', text)
	)

def is_bot(p):
	return p['skin'] < len(bots) and bots[p['skin']] == p['name']

def bcount(players):
	n = len([p for p in players if is_bot(p)])
	return f'(+{n} bots)' if n else ''

for s in d['servers']:
	if not 'error' in s:
		s['num_playing'] = s['num_humans'] - len([p for p in s['players'] if p['team'] == 'spectator'])

servers = [s for s in d['servers']
	if not 'error' in s
	and s['joinable_state'] == args.f
	and (
		s['num_playing'] == 0 or
		s['avg_pwr'] == 0 # probably all bots
	) == args.e
	and bool(len(s['files'])) == args.a]

servers = sorted(
	sorted(
		sorted(
			servers,
			key=lambda s: (s['num_playing'], s['max_connections']), reverse=True),
		key=lambda s: pwr_sort(s['avg_pwr'])),
	key=lambda s: len(s['files']),
	reverse=True)

def out(i, s):
	w = max(max(len(p['name']) for p in s['players']) + 2, 8) if s['players'] else 0
	players = itertools.batched(
		[colored(p['name'].ljust(w), 'blue' if p['team'] == 'player' else 'dark_grey')
		for p in sorted(s['players'], key=lambda p: p['team']) if not is_bot(p)], 4
	)
	print(f'''
Server: (id:{i}) {svip(s['address'])}\t{svname(s['server_name'])}
Players: {pcount(s['num_playing'])} / {pcount(s['max_connections'])} {spectators(s['players'])} {bcount(s['players'])}
{'\n'.join(map('\t'.join, players))}
AVG PWR: {pwr(s['avg_pwr'])}
{fcount(s['files'])}
	'''.rstrip() + '\n')

if args.c is not None:
	if args.c <= len(servers):
		s = servers[args.c - 1]
		out(args.c, s)
		ip = ':'.join(map(str, s['address']))
		pyperclip.copy(ip)
		print(f'{ip} ({re.sub(r'\^[0-9A-F]', '', s['server_name'])}) copied to clipboard!')
else:
	for i, s in enumerate(servers, 1):
		out(i, s)
	print(f'Showing {len(servers)} / {len(d['servers'])} servers')

print('Last updated ' + time.strftime('%X', time.localtime(d['time'])))
