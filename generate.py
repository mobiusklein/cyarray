import jinja2


pxds = []
pyxs = []

def fill_in_template(pytype, ctype, title, to_python_func, to_c_func, implementat_preamble=None, buffer_type_code=None):
    pxd_template = jinja2.Template(open("template.pxd", 'rt').read())
    if implementat_preamble is None:
        implementat_preamble = ''
    with open("generated/{}_vector.pxd".format(ctype), 'wt') as fh:
        fh.write(pxd_template.render(
            pytype=pytype, ctype=ctype, to_python_func=to_python_func,
            to_c_func=to_c_func, title=title))
        pxds.append(fh.name)
    pyx_template = jinja2.Template(open("template.pyx", 'rt').read())
    with open("generated/{}_vector.pyx".format(ctype), 'wt') as fh:
        fh.write(pyx_template.render(
            pytype=pytype, ctype=ctype, to_python_func=to_python_func,
            to_c_func=to_c_func, title=title, implementat_preamble=implementat_preamble,
            buffer_type_code=buffer_type_code))
        pyxs.append(fh.name)


fill_in_template("object", "double", "Double", "PyFloat_FromDouble",
                 "PyFloat_AsDouble",
                 "from cpython.float cimport PyFloat_FromDouble, PyFloat_AsDouble",
                 "d")
fill_in_template("object", "long", "Long", "PyInt_FromLong",
                 "PyInt_AsLong",
                 "from cpython.int cimport PyInt_FromLong, PyInt_AsLong",
                 "l")

with open("cyarray.pxd", 'wt') as fh:
    fh.write("""
cdef enum VectorStateEnum:
    should_free = 1

""")
    for pxd in pxds:
        fh.write("include \"%s\"\n" % pxd)
with open("cyarray.pyx", 'wt') as fh:
    for pyx in pyxs:
        fh.write("include \"%s\"\n" % pyx)
