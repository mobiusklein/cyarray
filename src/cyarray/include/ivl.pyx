
cdef interval_t interval_from_tuple(tuple pair):
    cdef:
        interval_t value

    value.start = pair[0]
    value.end = pair[1]
    return value


cdef tuple tuple_from_interval(interval_t interval):
    return (interval.start, interval.end)


cdef inline int compare_value_size_t_direct(const size_t a, const size_t b) noexcept nogil:
    if a < b:
        return -1
    elif a == b:
        return 0
    else:
        return 1


cdef int compare_value_interval_t(const void* a, const void* b) noexcept nogil:
    cdef:
        interval_t* av
        interval_t* bv
        int flag
    av = (<interval_t*>a)
    bv = (<interval_t*>b)
    flag = compare_value_size_t_direct(av.start, bv.end)
    if flag == 0:
        return compare_value_size_t_direct(av.end, bv.end)
    return flag