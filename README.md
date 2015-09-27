NoWide
======

|  Linux/GCC  |  Windows/MSVC  |  Binaries  |
| :---------: | :------------: | :--------: |
|  [![Linux Status](https://travis-ci.org/Nephatrine/nowide-standalone.svg?branch=master)](https://travis-ci.org/Nephatrine/nowide-standalone)  |  [![Windows Build Status](https://ci.appveyor.com/api/projects/status/sjgohhjyd42265r7?svg=true)](https://ci.appveyor.com/project/Nephatrine/nowide-standalone)  |  [![Binaries](https://img.shields.io/badge/bin-MS%20VC12-brightgreen.svg)](https://ci.appveyor.com/project/Nephatrine/nowide-standalone/build/artifacts)

Boost.Nowide is a library implemented by Artyom Beilis that makes cross platform
Unicode aware programming easier. This is a fork of his repository focusing on
the standalone (non-Boost) version of the code.

Features
--------

On Windows, this library provides an implementation of the C and C++ library
functions that is UTF8-aware and so you can ```fopen``` files with Unicode
filenames in the same way you would on Linux or moden UNIX systems. Normally,
you'd need to use the wide APIs and platform-specific code to use unicode on
Windows and have messy ```#ifdef```s and when writing cross-platform code. This
let's you simply use [UTF-8 Everywhere](http://utf8everywhere.org/) and have it
work the same on all platforms.

On other operating systems, these functions are merely wrappers around the
standard ones.

Building NoWide
---------------

You will need the following tools at a minimum in addition to the standard
compilers for your system (GCC, Xcode/Clang, MinGW, MSVC, etc.).

* CMake 2.8+
* PowerShell (Windows Environment Only)

Just compile as usual for a CMake project:

	mkdir build
	cd build
	cmake ..
	make && make test

and optionally:
	
	make install

Using NoWide
------------

Check the original [documentation](http://cppcms.com/files/nowide/html/) for
more information.

If you are using MSVC and have a **DLL** build of NoWide, you will need to
```#define NOWIDE_DLL``` prior to including the headers so the functions are
decorated with ```__declspec(dllimport)``` as needed. This is not required if
building with a ~~better~~different compiler such as MinGW GCC.
