cimport cython

from libc.stdlib cimport malloc, realloc, free
from libc cimport *

from cpython.exc cimport PyErr_BadArgument
from cpython.mem cimport PyObject_Malloc, PyObject_Free

from cpython.sequence cimport (
    PySequence_Size, PySequence_Check, PySequence_Fast,
    PySequence_Fast_GET_ITEM, PySequence_Fast_GET_SIZE)
from cpython.number cimport PyNumber_Check, PyNumber_AsSsize_t
from cpython.slice cimport PySlice_GetIndicesEx
from cpython.exc cimport PyErr_SetString, PyErr_NoMemory


include "src/mkcyarray/include/mstr.pyx"


cdef extern from * nogil:
    int printf (const char *template, ...)
    void qsort (void *base, unsigned short n, unsigned short w, int (*cmp_func)(void*, void*))


DEF GROWTH_RATE = 2
DEF INITIAL_SIZE = 4


cdef mstr_vector* make_mstr_vector_with_size(size_t size) noexcept nogil:
    cdef:
        mstr_vector* vec

    vec = <mstr_vector*>malloc(sizeof(mstr_vector))
    vec.v = <mstr*>malloc(sizeof(mstr) * size)
    vec.size = size
    vec.used = 0

    return vec


cdef mstr_vector* make_mstr_vector() noexcept nogil:
    return make_mstr_vector_with_size(INITIAL_SIZE)


cdef int mstr_vector_resize(mstr_vector* vec) except -1 nogil:
    cdef:
        size_t new_size
        mstr* v
    new_size = vec.size * GROWTH_RATE
    v = <mstr*>realloc(vec.v, sizeof(mstr) * new_size)
    if v == NULL:
        with gil:
            PyErr_SetString(MemoryError, "mstr_vector_resize failed")
        return -1
    vec.v = v
    vec.size = new_size
    return 0


cdef int mstr_vector_append(mstr_vector* vec, mstr value) except -1 nogil:
    if (vec.used + 1) >= vec.size:
        if mstr_vector_resize(vec) == -1:
            return -1
    vec.v[vec.used] = value
    vec.used += 1
    return 0


cdef void free_mstr_vector(mstr_vector* vec) noexcept nogil:
    free(vec.v)
    free(vec)


cdef void mstr_vector_reset(mstr_vector* vec) noexcept nogil:
    vec.used = 0


cdef int mstr_vector_reserve(mstr_vector* vec, size_t new_size) except -1 nogil:
    cdef:
        mstr* v
    v = <mstr*>realloc(vec.v, sizeof(mstr) * new_size)
    if v == NULL:
        with gil:
            PyErr_SetString(MemoryError, "mstr_vector_reserve failed")
        return -1
    vec.v = v
    vec.size = new_size
    if new_size > vec.used:
        vec.used = new_size
    return 0





@cython.final
@cython.freelist(512)
cdef class StringVector(object):
    """
    The :class:`StringVector` is a resize-able sequence-like data type storing a C `mstr`
    values in a raw array. 
    """

    @staticmethod
    cdef StringVector _create(size_t size):
        cdef:
            StringVector self
        self = StringVector.__new__(StringVector)
        self.flags = 0
        self.allocate_storage_with_size(size)
        return self

    @staticmethod
    cdef StringVector wrap(mstr_vector* vector):
        cdef:
            StringVector self
        self = StringVector.__new__(StringVector)
        self.flags = 0
        self.impl = vector
        self.set_should_free(False)
        return self

    def __init__(self, seed=None):
        """
        Create a new :class:`StringVector` instance, optionally from an iterable of coercable types,
        or an integer to pre-allocate empty capacity.
        """
        cdef:
            size_t n
        self.flags = 0
        if seed is not None:
            if PyNumber_Check(seed):
                n = PyNumber_AsSsize_t(seed, IndexError)
                self.allocate_storage_with_size(n)
            elif PySequence_Check(seed):
                n = len(seed)
                self.allocate_storage_with_size(n)
                self.extend(seed)
            else:
                raise TypeError("Must provide a Sequence-like object or an integer")
        else:
            self.allocate_storage()

    cdef int allocate_storage_with_size(self, size_t size) noexcept nogil:
        if self.impl != NULL:
            if self.flags & VectorStateEnum.should_free:
                free_mstr_vector(self.impl)
        self.impl = make_mstr_vector_with_size(size)
        self.flags |= VectorStateEnum.should_free
        return self.impl == NULL

    cdef int allocate_storage(self) noexcept nogil:
        if self.impl != NULL:
            if self.flags & VectorStateEnum.should_free:
                free_mstr_vector(self.impl)
        self.impl = make_mstr_vector()
        self.flags |= VectorStateEnum.should_free
        return self.impl == NULL

    cdef int free_storage(self) noexcept nogil:
        free_mstr_vector(self.impl)

    cdef bint get_should_free(self) noexcept nogil:
        return self.flags & VectorStateEnum.should_free

    cdef void set_should_free(self, bint flag) noexcept nogil:
        self.flags &= VectorStateEnum.should_free * flag

    cdef mstr* get_data(self) noexcept nogil:
        return self.impl.v

    cdef mstr get(self, size_t i) noexcept nogil:
        return self.impl.v[i]

    cdef void set(self, size_t i, mstr value) noexcept nogil:
        self.impl.v[i] = value

    cdef size_t size(self) noexcept nogil:
        return self.impl.used

    cdef int cappend(self, mstr value) noexcept nogil:
        return mstr_vector_append(self.impl, value)

    cpdef int append(self, unicode value) except *:
        """Append a Python coerce-able value to the array."""
        cdef:
            mstr cvalue
        cvalue = self._to_c(value)
        return self.cappend(cvalue)

    cpdef int extend(self, object values) except *:
        """Incrementally append `values` to the array."""
        cdef:
            size_t i, n
            object fast_seq
        if not PySequence_Check(values):
            raise TypeError("Must provide a Sequence-like object")

        fast_seq = PySequence_Fast(values, "Must provide a Sequence-like object")
        n = PySequence_Fast_GET_SIZE(values)

        for i in range(n):
            if self.append(<object>PySequence_Fast_GET_ITEM(fast_seq, i)) != 0:
                return 1

    cpdef int reserve(self, size_t size) except -1 nogil:
        """Reserve `size` capacity or shrink to fit."""
        return mstr_vector_reserve(self.impl, size)

    cpdef int fill(self, mstr value) noexcept nogil:
        """
        Fill all positions with `value`.

        Leaves unused capacity unaffected.
        """
        cdef:
            size_t i, n
        n = self.size()
        for i in range(n):
            self.set(i, value)
        return 0

    cpdef StringVector copy(self):
        """Make a copy of this array with separate memory storage"""
        cdef:
            StringVector dup
            size_t i, n
        n = self.size()
        dup = StringVector._create(n)
        for i in range(n):
            dup.cappend(self.get(i))
        return dup

    cdef StringVector _slice(self, object slice_spec):
        cdef:
            StringVector dup
            Py_ssize_t length, start, stop, step, slice_length, i
        PySlice_GetIndicesEx(
            slice_spec, self.size(), &start, &stop, &step, &slice_length)
        dup = StringVector._create(slice_length)
        i = start
        while i < stop:
            dup.cappend(self.get(i))
            i += step
        return dup

    def __dealloc__(self):
        if self.get_should_free():
            self.free_storage()

    def __len__(self):
        return self.size()

    def __iter__(self):
        cdef:
            size_t i, n
        n = self.size()
        for i in range(n):
            yield self._to_python(self.get(i))

    def __getitem__(self, i):
        cdef:
            Py_ssize_t index
            size_t n
        if isinstance(i, slice):
            return self._slice(i)
        index = i
        n = self.size()
        if index < 0:
            index = n + index
        if index > n or index < 0:
            raise IndexError(index)
        return self._to_python(self.get(index))

    def __setitem__(self, i, value):
        cdef:
            Py_ssize_t index
            size_t n
        if isinstance(i, slice):
            raise TypeError("Does not support slice-assignment yet")
        n = self.size()
        index = i
        if index < 0:
            index = n + index
        if index > self.size() or index < 0:
            raise IndexError(i)
        self.set(index, self._to_c(value))

    def __repr__(self):
        return "{self.__class__.__name__}({members})".format(self=self, members=list(self))





    cpdef object _to_python(self, mstr value):
        return mstr_as_str(value)

    cpdef mstr _to_c(self, object value) except *:
        return mstr_from_str(value)