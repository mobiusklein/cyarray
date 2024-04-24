
cdef enum VectorStateEnum:
    should_free = 1

include "generated/double_vector.pxd"
include "generated/long_vector.pxd"
include "generated/size_t_vector.pxd"
include "generated/interval_t_vector.pxd"
