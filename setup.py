from setuptools import setup, Extension, find_packages


try:
    from Cython.Build import cythonize
    cython_directives = {
        'embedsignature': True,
    }
    extensions = cythonize([
        Extension("cyarray.cyarray", ["src/cyarray/cyarray.pyx"])
    ])
except ImportError:
    extensions = [Extension("cyarray", ["src/cyarray/cyarray.c"])]

setup(
    name="cyarray",
    version="1.0.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    include_package_data=True,
    ext_modules=extensions,
)
