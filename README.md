# cyarray

An exercise in templating fast, resizable arrays for Cython that incur less Python overhead
than the array module and expose a pure C representation which does not require any Python
interaction.

# Why not just use C++'s `std::vector`?

The templated `std::vector` type in C++ is superior to these types in all ways but one, these
typed arrays support [Python's buffer protocol](https://docs.python.org/3/c-api/buffer.html).
This means that you can accumulate values in a `nogil` C context and then immediately pass
them along to NumPy without copying.