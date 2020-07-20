
class MinDiff:
    name = 'mindiff'
    argc = (1, 2)

    def __init__(self):
        self.span = None
        self.values = []

    def step(self, value, span = 2):
        self.__set_once('span', span)
        self.__check_span_value(span)
        self.__check_value(value)
        self.values.append(value)

    def finalize(self):
        length = len(self.values)
        if length < self.span:
            return None

        self.values.sort()

        offset = self.span - 1
        values = self.values
        diffs = (values[i + offset] - values[i] for i in range(0, length - offset))
        result = min(diffs, default=None)

        return result

    def __set_once(self, key, value):
        current = getattr(self, key, None)
        if current is not None and current != value:
            msg = f'{key} has already been set - current: {current}; new: {value}'
            raise ValueError(msg)
        setattr(self, key, value)

    def __check_span_value(self, span):
        if not isinstance(span, int):
            raise TypeError(f'span must be an integer, got {span}')
        if span < 2:
            raise ValueError(f'span must be greater or equal to 2, got {span}')

    def __check_value(self, value):
        if not isinstance(value, (int, float)):
            raise TypeError(f'value must be an int or float, got {value}')
