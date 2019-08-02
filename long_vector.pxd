
cdef struct long_vector:
    long* v
    size_t used
    size_t size

cdef long_vector* make_long_vector_with_size(size_t size) nogil
cdef long_vector* make_long_vector() nogil
cdef int long_vector_resize(long_vector* vec) nogil
cdef int long_vector_append(long_vector* vec, long value) nogil
cdef void free_long_vector(long_vector* vec) nogil
cdef void print_long_vector(long_vector* vec) nogil
cdef void reset_long_vector(long_vector* vec) nogil

cdef class LongVector(object):
    cdef __cythonbufferdefaults__ = {'ndim' : 1, 'mode':'c'}

    cdef:
        long_vector* impl
        int flags

    cdef int allocate_storage(self) nogil
    cdef int allocate_storage_with_size(self, size_t size) nogil

    @staticmethod
    cdef LongVector _create(size_t size)

    @staticmethod
    cdef LongVector wrap(long_vector* vector)

    cdef long get(self, size_t i) nogil
    cdef void set(self, size_t i, long value) nogil
    cdef size_t size(self) nogil
    cdef int cappend(self, long value) nogil

    cdef LongVector _slice(self, object slice_spec)

    cpdef LongVector copy(self)

    cpdef int append(self, object value) except *
    cpdef int extend(self, object values) except *

    cpdef object _to_python(self, long value)
    cpdef long _to_c(self, object value) except *