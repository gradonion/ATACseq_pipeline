import argparse
parser = argparse.ArgumentParser(prog='do_remove_dup_reads.py', description='''
    Merge count by region
''')
parser.add_argument('--cmd')
parser.add_argument('--o')
parser.add_argument('--i')
args = parser.parse_args()

import os, re

cmd = re.sub('\\\\', '', args.cmd)

cmd = cmd.format(input = args.i, output = args.o)
# print(cmd)
os.system(cmd)
