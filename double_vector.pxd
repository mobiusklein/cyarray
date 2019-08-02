
cdef struct double_vector:
    double* v
    size_t used
    size_t size

cdef double_vector* make_double_vector_with_size(size_t size) nogil
cdef double_vector* make_double_vector() nogil
cdef int double_vector_resize(double_vector* vec) nogil
cdef int double_vector_append(double_vector* vec, double value) nogil
cdef void free_double_vector(double_vector* vec) nogil
cdef void print_double_vector(double_vector* vec) nogil
cdef void reset_double_vector(double_vector* vec) nogil

cdef class DoubleVector(object):
    cdef __cythonbufferdefaults__ = {'ndim' : 1, 'mode':'c'}

    cdef:
        double_vector* impl
        int flags

    cdef int allocate_storage(self) nogil
    cdef int allocate_storage_with_size(self, size_t size) nogil

    @staticmethod
    cdef DoubleVector _create(size_t size)

    @staticmethod
    cdef DoubleVector wrap(double_vector* vector)

    cdef double get(self, size_t i) nogil
    cdef void set(self, size_t i, double value) nogil
    cdef size_t size(self) nogil
    cdef int cappend(self, double value) nogil

    cdef DoubleVector _slice(self, object slice_spec)

    cpdef DoubleVector copy(self)

    cpdef int append(self, object value) except *
    cpdef int extend(self, object values) except *

    cpdef object _to_python(self, double value)
    cpdef double _to_c(self, object value) except *