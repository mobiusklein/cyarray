


cdef struct long_vector:
    long* v
    size_t used
    size_t size

cdef long_vector* make_long_vector_with_size(size_t size) noexcept nogil
cdef long_vector* make_long_vector() noexcept nogil
cdef int long_vector_resize(long_vector* vec) except -1 nogil
cdef int long_vector_append(long_vector* vec, long value) except -1 nogil
cdef int long_vector_reserve(long_vector* vec, size_t new_size) except -1 nogil
cdef void long_vector_reset(long_vector* vec) noexcept nogil

cdef void free_long_vector(long_vector* vec) noexcept nogil

cdef class LongVector(object):
    cdef __cythonbufferdefaults__ = {'ndim' : 1, 'mode':'c'}

    cdef:
        long_vector* impl
        int flags

    cdef int allocate_storage(self) noexcept nogil
    cdef int allocate_storage_with_size(self, size_t size) noexcept nogil

    cdef int free_storage(self) noexcept nogil
    cdef bint get_should_free(self) noexcept nogil
    cdef void set_should_free(self, bint flag) noexcept nogil

    cdef long* get_data(self) noexcept nogil

    @staticmethod
    cdef LongVector _create(size_t size)

    @staticmethod
    cdef LongVector wrap(long_vector* vector)

    cdef long get(self, size_t i) noexcept nogil
    cdef void set(self, size_t i, long value) noexcept nogil
    cdef size_t size(self) noexcept nogil
    cdef int cappend(self, long value) noexcept nogil

    cdef LongVector _slice(self, object slice_spec)

    cpdef LongVector copy(self)

    cpdef int append(self, object value) except *
    cpdef int extend(self, object values) except *

    cpdef int reserve(self, size_t size) except -1 nogil

    cpdef int fill(self, long value) noexcept nogil


    cpdef void sort(self, bint reverse=?) noexcept nogil

    cpdef object _to_python(self, long value)
    cpdef long _to_c(self, object value) except *