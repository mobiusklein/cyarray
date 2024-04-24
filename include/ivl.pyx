
cdef interval_t interval_from_tuple(tuple pair):
    cdef:
        interval_t value

    value.start = pair[0]
    value.end = pair[1]
    return value


cdef tuple tuple_from_interval(interval_t interval):
    return (interval.start, interval.end)
