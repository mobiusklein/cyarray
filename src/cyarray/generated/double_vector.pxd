


cdef struct double_vector:
    double* v
    size_t used
    size_t size

cdef double_vector* make_double_vector_with_size(size_t size) noexcept nogil
cdef double_vector* make_double_vector() noexcept nogil
cdef int double_vector_resize(double_vector* vec) except -1 nogil
cdef int double_vector_append(double_vector* vec, double value) except -1 nogil
cdef int double_vector_reserve(double_vector* vec, size_t new_size) except -1 nogil
cdef void double_vector_reset(double_vector* vec) noexcept nogil

cdef void free_double_vector(double_vector* vec) noexcept nogil

cdef class DoubleVector(object):
    cdef __cythonbufferdefaults__ = {'ndim' : 1, 'mode':'c'}

    cdef:
        double_vector* impl
        int flags

    cdef int allocate_storage(self) noexcept nogil
    cdef int allocate_storage_with_size(self, size_t size) noexcept nogil

    cdef int free_storage(self) noexcept nogil
    cdef bint get_should_free(self) noexcept nogil
    cdef void set_should_free(self, bint flag) noexcept nogil

    cdef double* get_data(self) noexcept nogil

    @staticmethod
    cdef DoubleVector _create(size_t size)

    @staticmethod
    cdef DoubleVector wrap(double_vector* vector)

    cdef double get(self, size_t i) noexcept nogil
    cdef void set(self, size_t i, double value) noexcept nogil
    cdef size_t size(self) noexcept nogil
    cdef int cappend(self, double value) noexcept nogil

    cdef DoubleVector _slice(self, object slice_spec)

    cpdef DoubleVector copy(self)

    cpdef int append(self, object value) except *
    cpdef int extend(self, object values) except *

    cpdef int reserve(self, size_t size) except -1 nogil

    cpdef int fill(self, double value) noexcept nogil


    cpdef void sort(self, bint reverse=?) noexcept nogil

    cpdef object _to_python(self, double value)
    cpdef double _to_c(self, object value) except *