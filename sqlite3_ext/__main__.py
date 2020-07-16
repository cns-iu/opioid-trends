import argparse
import csv
import sqlite3
import sys

from . import register_aggregates


parser = argparse.ArgumentParser(description='Execute sqlite')
parser.add_argument('database', nargs='?', default=':memory:', help='Database file')


if __name__ == '__main__':
    args = parser.parse_args()

    db = sqlite3.connect(args.database)
    db.row_factory = sqlite3.Row
    register_aggregates(db)

    # Sadly db.executescript cannot be used as it discards all results :(
    script = sys.stdin.read()
    results = []
    for statement in filter(None, script.split(';')):
        result = db.execute(statement).fetchall()
        results.append(result)

    # Ensure changes are commited
    db.commit()

    writer = csv.writer(sys.stdout)
    for result in filter(None, results):
        writer.writerow(result[0].keys())
        writer.writerows(result)

    # Ensure output is flushed
    sys.stdout.flush()
