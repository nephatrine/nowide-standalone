NoWide
======

> Boost.Nowide is a library implemented by Artyom Beilis that make cross platform Unicode aware
> programming easier.
>
> The library provides an implementation of standard C and C++ library functions, such that their
> inputs are UTF-8 aware on Windows without requiring to use Wide API.

Build Requirements
------------------

This project uses CMake for its build system so you will definitely need that. There are no other requirements if in a Unix-like environment (Linux, OSX, MSYS, Cygwin, etc.). If using Windows without such an environment, you will need Microsoft PowerShell and will need to have it set to allow unsigned scripts to be run. PowerShell was used as the default Windows command shell lacks a *sed*-like tool.

License
-------

Copyright (c) 2012 Artyom Beilis (Tonkikh)

Distributed under the
[Boost Software License, Version 1.0](http://www.boost.org/LICENSE_1_0.txt).
