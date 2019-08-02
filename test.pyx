from cython.parallel cimport prange

from cyarray cimport LongVector

cdef LongVector x = LongVector._create(10000)
cdef:
    long i

with nogil:
    for i in range(100000):
        LongVector.cappend(x, 10 * i)
    for i in prange(10000):
        x.set(i, x.get(i) / 10)
print(x)