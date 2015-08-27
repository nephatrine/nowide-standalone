NoWide
======

> Boost.Nowide is a library implemented by Artyom Beilis that make cross platform Unicode aware
> programming easier.
>
> The library provides an implementation of standard C and C++ library functions, such that their
> inputs are UTF-8 aware on Windows without requiring to use Wide API.

Build Requirements
------------------

[![Build Status](https://ci.appveyor.com/api/projects/status/sjgohhjyd42265r7?svg=true)](https://ci.appveyor.com/project/Nephatrine/nowide-standalone) [![Binaries](https://img.shields.io/badge/bin-MSVC%20x64-brightgreen.svg)](https://ci.appveyor.com/project/Nephatrine/nowide-standalone/build/artifacts)

This project uses CMake for its build system so you will definitely need that. There are no other requirements if in a Unix-like environment (Linux, OSX, MSYS, Cygwin, etc.). If using Windows without such an environment, you will need Microsoft PowerShell and will need to have it set to allow unsigned scripts to be run. PowerShell was used as the default Windows command shell lacks a *sed*-like tool.

Usage
-----

Check the original [Doxygen documentation](http://cppcms.com/files/nowide/html/) for more information.

If you are using a dynamic/shared build, you may need to define ```NOWIDE_DLL``` prior to including the headers for ```nowide::cin```, ```nowide::cout```, and ```nowide::cerr``` to function.

License
-------

Copyright (c) 2012 Artyom Beilis (Tonkikh)

Distributed under the
[Boost Software License, Version 1.0](http://www.boost.org/LICENSE_1_0.txt).
