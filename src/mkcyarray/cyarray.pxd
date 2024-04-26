
cdef enum VectorStateEnum:
    should_free = 1

include "src/mkcyarray/generated/double_vector.pxd"
include "src/mkcyarray/generated/long_vector.pxd"
include "src/mkcyarray/generated/size_t_vector.pxd"
include "src/mkcyarray/generated/interval_t_vector.pxd"
include "src/mkcyarray/generated/mstr_vector.pxd"
