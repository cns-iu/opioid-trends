from .min_diff import MinDiff


__all__ = ['AGGREGATES', 'register_aggregates']

AGGREGATES = [
    MinDiff
]

def register_aggregates(db, aggregates = AGGREGATES):
    for agg in aggregates:
        for argc in agg.argc:
            db.create_aggregate(agg.name, argc, agg)
