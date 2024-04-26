

include "src/mkcyarray/include/mstr.pxd"


cdef struct mstr_vector:
    mstr* v
    size_t used
    size_t size

cdef mstr_vector* make_mstr_vector_with_size(size_t size) noexcept nogil
cdef mstr_vector* make_mstr_vector() noexcept nogil
cdef int mstr_vector_resize(mstr_vector* vec) except -1 nogil
cdef int mstr_vector_append(mstr_vector* vec, mstr value) except -1 nogil
cdef int mstr_vector_reserve(mstr_vector* vec, size_t new_size) except -1 nogil
cdef void mstr_vector_reset(mstr_vector* vec) noexcept nogil

cdef void free_mstr_vector(mstr_vector* vec) noexcept nogil

cdef class StringVector(object):
    cdef __cythonbufferdefaults__ = {'ndim' : 1, 'mode':'c'}

    cdef:
        mstr_vector* impl
        int flags

    cdef int allocate_storage(self) noexcept nogil
    cdef int allocate_storage_with_size(self, size_t size) noexcept nogil

    cdef int free_storage(self) noexcept nogil
    cdef bint get_should_free(self) noexcept nogil
    cdef void set_should_free(self, bint flag) noexcept nogil

    cdef mstr* get_data(self) noexcept nogil

    @staticmethod
    cdef StringVector _create(size_t size)

    @staticmethod
    cdef StringVector wrap(mstr_vector* vector)

    cdef mstr get(self, size_t i) noexcept nogil
    cdef void set(self, size_t i, mstr value) noexcept nogil
    cdef size_t size(self) noexcept nogil
    cdef int cappend(self, mstr value) noexcept nogil

    cdef StringVector _slice(self, object slice_spec)

    cpdef StringVector copy(self)

    cpdef int append(self, unicode value) except *
    cpdef int extend(self, object values) except *

    cpdef int reserve(self, size_t size) except -1 nogil

    cpdef int fill(self, mstr value) noexcept nogil



    cpdef object _to_python(self, mstr value)
    cpdef mstr _to_c(self, object value) except *