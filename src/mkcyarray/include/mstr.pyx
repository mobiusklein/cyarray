from cpython.unicode cimport PyUnicode_FromStringAndSize, PyUnicode_AsUTF8AndSize

# mstr, a struct for holding externally owned string data

cdef mstr mstr_from_str(unicode pystring):
    cdef:
        mstr result
        Py_ssize_t size
    result.string = PyUnicode_AsUTF8AndSize(pystring, &size)
    result.size = size
    return result


cdef unicode mstr_as_str(mstr mystring):
    return PyUnicode_FromStringAndSize(mystring.string, mystring.size)
