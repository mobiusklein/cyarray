
cdef struct {{ctype}}_vector:
    {{ctype}}* v
    size_t used
    size_t size

cdef {{ctype}}_vector* make_{{ctype}}_vector_with_size(size_t size) nogil
cdef {{ctype}}_vector* make_{{ctype}}_vector() nogil
cdef int {{ctype}}_vector_resize({{ctype}}_vector* vec) nogil
cdef int {{ctype}}_vector_append({{ctype}}_vector* vec, {{ctype}} value) nogil
cdef void free_{{ctype}}_vector({{ctype}}_vector* vec) nogil
cdef void print_{{ctype}}_vector({{ctype}}_vector* vec) nogil
cdef void reset_{{ctype}}_vector({{ctype}}_vector* vec) nogil

cdef class {{title}}Vector(object):
    cdef __cythonbufferdefaults__ = {'ndim' : 1, 'mode':'c'}

    cdef:
        {{ctype}}_vector* impl
        int flags

    cdef int allocate_storage(self) nogil
    cdef int allocate_storage_with_size(self, size_t size) nogil

    @staticmethod
    cdef {{title}}Vector _create(size_t size)

    @staticmethod
    cdef {{title}}Vector wrap({{ctype}}_vector* vector)

    cdef {{ctype}} get(self, size_t i) nogil
    cdef void set(self, size_t i, {{ctype}} value) nogil
    cdef size_t size(self) nogil
    cdef int cappend(self, {{ctype}} value) nogil

    cdef {{title}}Vector _slice(self, object slice_spec)

    cpdef {{title}}Vector copy(self)

    cpdef int append(self, {{pytype}} value) except *
    cpdef int extend(self, object values) except *

    cpdef object _to_python(self, {{ctype}} value)
    cpdef {{ctype}} _to_c(self, object value) except *
