
{{definition_preamble}}

cdef struct {{ctype}}_vector:
    {{ctype}}* v
    size_t used
    size_t size

cdef {{ctype}}_vector* make_{{ctype}}_vector_with_size(size_t size) noexcept nogil
cdef {{ctype}}_vector* make_{{ctype}}_vector() noexcept nogil
cdef int {{ctype}}_vector_resize({{ctype}}_vector* vec) except -1 nogil
cdef int {{ctype}}_vector_append({{ctype}}_vector* vec, {{ctype}} value) except -1 nogil
cdef int {{ctype}}_vector_reserve({{ctype}}_vector* vec, size_t new_size) except -1 nogil
cdef void {{ctype}}_vector_reset({{ctype}}_vector* vec) noexcept nogil

cdef void free_{{ctype}}_vector({{ctype}}_vector* vec) noexcept nogil

cdef class {{title}}Vector(object):
    cdef __cythonbufferdefaults__ = {'ndim' : 1, 'mode':'c'}

    cdef:
        {{ctype}}_vector* impl
        int flags

    cdef int allocate_storage(self) noexcept nogil
    cdef int allocate_storage_with_size(self, size_t size) noexcept nogil

    cdef int free_storage(self) noexcept nogil
    cdef bint get_should_free(self) noexcept nogil
    cdef void set_should_free(self, bint flag) noexcept nogil

    cdef {{ctype}}* get_data(self) noexcept nogil

    @staticmethod
    cdef {{title}}Vector _create(size_t size)

    @staticmethod
    cdef {{title}}Vector wrap({{ctype}}_vector* vector)

    cdef {{ctype}} get(self, size_t i) noexcept nogil
    cdef void set(self, size_t i, {{ctype}} value) noexcept nogil
    cdef size_t size(self) noexcept nogil
    cdef int cappend(self, {{ctype}} value) noexcept nogil

    cdef {{title}}Vector _slice(self, object slice_spec)

    cpdef {{title}}Vector copy(self)

    cpdef int append(self, {{pytype}} value) except *
    cpdef int extend(self, object values) except *

    cpdef int reserve(self, size_t size) except -1 nogil

    cpdef int fill(self, {{ctype}} value) noexcept nogil

{% if sort_fn is not none %}
    cpdef void sort(self, bint reverse=?) noexcept nogil
{%- endif %}

    cpdef object _to_python(self, {{ctype}} value)
    cpdef {{ctype}} _to_c(self, object value) except *
