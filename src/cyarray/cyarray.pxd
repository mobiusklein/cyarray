
cdef enum VectorStateEnum:
    should_free = 1

include "src/cyarray/generated/double_vector.pxd"
include "src/cyarray/generated/long_vector.pxd"
include "src/cyarray/generated/size_t_vector.pxd"
include "src/cyarray/generated/interval_t_vector.pxd"
