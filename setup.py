from setuptools import setup, Extension, find_packages


try:
    from Cython.Build import cythonize
    cython_directives = {
        'embedsignature': True,
    }
    extensions = cythonize(
        [Extension("mkcyarray.cyarray", ["src/mkcyarray/cyarray.pyx"])]
    )
except ImportError:
    extensions = [Extension("mkcyarray.cyarray", ["src/mkcyarray/cyarray.c"])]

setup(
    name="mkcyarray",
    version="1.0.1",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    include_package_data=True,
    ext_modules=extensions,
)
