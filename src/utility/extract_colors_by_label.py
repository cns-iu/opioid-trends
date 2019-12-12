'''Extract colors by label.
Used to create a scale with domain and range for pasting into chart.vl.json
'''

import argparse
import csv
import json
import operator

def extract(values):
  pairs = map(operator.itemgetter('LABEL', 'COLOR'), values)
  return zip(*pairs)

def setup_parser_arguments(parser = None):
  parser = parser or argparse.ArgumentParser(description='Extract colors by label')
  parser.add_argument('input', type=argparse.FileType('r'), nargs='?', default='-', help='Input file')
  parser.add_argument('output', type=argparse.FileType('w'), nargs='?', default='-', help='Output file')

  return parser

if __name__ == '__main__':
  ns = setup_parser_arguments().parse_args()
  with ns.input as infile, ns.output as outfile:
    domain, range_ = extract(csv.DictReader(infile))
    json.dump({ 'domain': list(domain), 'range': list(range_) }, outfile, indent=2)
