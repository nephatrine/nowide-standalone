cmake_minimum_required(VERSION 2.8.5)
if(NOT CMAKE_VERSION VERSION_LESS "3.0")
    cmake_policy(SET CMP0048 OLD)
endif()
if(NOT CMAKE_VERSION VERSION_LESS "3.1")
    cmake_policy(SET CMP0054 OLD)
endif()
if(NOT CMAKE_VERSION VERSION_LESS "3.3")
    cmake_policy(SET CMP0063 NEW)
    set(HONOR_VISIBILITY TRUE)
else()
    set(HONOR_VISIBILITY FALSE)
endif()

#
# Project Definition
#

project(nowide CXX)
set(NOWIDE_TARGET_NAME nowide)
set(TARGET_VER 0.0.0_neph)
set(TARGET_ABI_VER 0)
set(TARGET_OUTPUT_NAME "${NOWIDE_TARGET_NAME}")

#
# CMake Modules
#

include(CheckCXXCompilerFlag)
include(CMakeDependentOption)
include(GNUInstallDirs)

#
# Include Files
#

include_directories("${PROJECT_SOURCE_DIR}/include")

#
# Project Options
#

option(NOWIDE_BUILD_SHARED "Build Shared Library" ON)
option(NOWIDE_BUILD_STATIC "Build Static Library" ON)
cmake_dependent_option(NOWIDE_BUILD_TESTS "Build NoWide Tests" ON "NOT CMAKE_TOOLCHAIN_FILE" OFF)

set(NOWIDE_HEADERS
	"${PROJECT_SOURCE_DIR}/include/nowide/config.hpp"
	"${PROJECT_SOURCE_DIR}/include/nowide/convert.hpp"
	"${PROJECT_SOURCE_DIR}/include/nowide/encoding_errors.hpp"
	"${PROJECT_SOURCE_DIR}/include/nowide/encoding_utf.hpp"
	"${PROJECT_SOURCE_DIR}/include/nowide/iostream.hpp"
	"${PROJECT_SOURCE_DIR}/include/nowide/scoped_ptr.hpp"
	"${PROJECT_SOURCE_DIR}/include/nowide/utf.hpp")

set(NOWIDE_SOURCE
	"${PROJECT_SOURCE_DIR}/src/iostream.cpp")

#
# Require C++11 Standard
#

if(NOT MSVC)
	if(NOT CMAKE_VERSION VERSION_LESS "3.1")
		set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
		set(CMAKE_CXX_STANDARD "11")
	else()
		check_cxx_compiler_flag("-std=gnu++11" _COMPILER_HAS_STD_GNUPP11)
		if(_COMPILER_HAS_STD_GNUPP11)
			set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11")
		else()
			check_cxx_compiler_flag("-std=c++11" _COMPILER_HAS_STD_CPP11)
			if(_COMPILER_HAS_STD_CPP11)
				set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
			endif()
		endif()
	endif()
endif()

#
# MSVC Runtime DLL
#

cmake_dependent_option(NOWIDE_USE_MSVC_RUNTIME "Use MSVC Runtime Library DLL" ON MSVC OFF)
if(MSVC AND NOT NOWIDE_USE_MSVC_RUNTIME)
	foreach(flag CMAKE_C_FLAGS
			CMAKE_C_FLAGS_DEBUG
			CMAKE_C_FLAGS_RELEASE
			CMAKE_C_FLAGS_MINSIZEREL
			CMAKE_C_FLAGS_RELWITHDEBINFO)
		string(REGEX REPLACE "/MDd" "/MTd" ${flag} "${${flag}}")
		string(REGEX REPLACE "/MD" "/MT" ${flag} "${${flag}}")
	endforeach()
endif()

#
# Compiler Flags
#

if(MSVC)
	add_definitions(-D_CRT_SECURE_NO_WARNINGS)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W3")
else()
	check_cxx_compiler_flag("-fno-strict-aliasing" _COMPILER_HAS_NO_STRICT_ALIASING)
	check_cxx_compiler_flag("-fvisibility=hidden" _COMPILER_HAS_VISIBILITY_HIDDEN)
	check_cxx_compiler_flag("-Wall" _COMPILER_HAS_WARN_ALL)
	check_cxx_compiler_flag("-Wextra" _COMPILER_HAS_WARN_EXTRA)
	check_cxx_compiler_flag("-Wno-unused-parameter" _COMPILER_HAS_NO_WARN_UNUSED_PARAMETER)
	if(_COMPILER_HAS_NO_STRICT_ALIASING)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-strict-aliasing")
	endif()
	if(_COMPILER_HAS_WARN_ALL)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
	endif()
	if(_COMPILER_HAS_WARN_EXTRA)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wextra")
	endif()
	if(_COMPILER_HAS_NO_WARN_UNUSED_PARAMETER)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-parameter")
	endif()
endif()

#
# Linker Flags
#

if(NOT MSVC)
	set(OLD_CMAKE_REQUIRED_FLAGS ${CMAKE_REQUIRED_FLAGS})

	set(CMAKE_REQUIRED_FLAGS "-Wl,--no-undefined")
	check_cxx_compiler_flag("" _LINKER_HAS_NO_UNDEFINED)
	if (_LINKER_HAS_NO_UNDEFINED)
		set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--no-undefined ${CMAKE_SHARED_LINKER_FLAGS}")
	endif()

	if (MINGW)
		set(CMAKE_REQUIRED_FLAGS "-Wl,--nxcompat")
		check_cxx_compiler_flag("" _LINKER_HAS_DEP)
		if (_LINKER_HAS_DEP)
			set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--nxcompat ${CMAKE_SHARED_LINKER_FLAGS}")
		endif()
		set(CMAKE_REQUIRED_FLAGS "-Wl,--dynamicbase")
		check_cxx_compiler_flag("" _LINKER_HAS_ASLR)
		if (_LINKER_HAS_ASLR)
			set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--dynamicbase ${CMAKE_SHARED_LINKER_FLAGS}")
		endif()
		set(CMAKE_REQUIRED_FLAGS "-Wl,--high-entropy-va")
		check_cxx_compiler_flag("" _LINKER_HAS_64ASLR)
		if (_LINKER_HAS_64ASLR)
			set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--high-entropy-va ${CMAKE_SHARED_LINKER_FLAGS}")
		endif()
	endif()
	
	set(CMAKE_REQUIRED_FLAGS ${OLD_CMAKE_REQUIRED_FLAGS})
endif()

#
# Build Targets
#

set(NOWIDE_TARGET_BUILT "")
set(NOWIDE_TARGET_TYPES "")

if(NOWIDE_BUILD_SHARED)
	list(APPEND NOWIDE_TARGET_TYPES "shared")
	add_library("${NOWIDE_TARGET_NAME}_shared" SHARED ${NOWIDE_SOURCE} ${NOWIDE_HEADERS})
	if(WIN32 OR ANDROID OR MSYS)
		set_target_properties("${NOWIDE_TARGET_NAME}_shared" PROPERTIES
			OUTPUT_NAME "${TARGET_OUTPUT_NAME}${TARGET_ABI_VER}")
	else()
		set_target_properties("${NOWIDE_TARGET_NAME}_shared" PROPERTIES
			OUTPUT_NAME "${TARGET_OUTPUT_NAME}")
	endif()
	if(NOT ANDROID)
		set_target_properties("${NOWIDE_TARGET_NAME}_shared" PROPERTIES
			VERSION "${TARGET_VER}"
			SOVERSION "${TARGET_ABI_VER}")
	endif()
	set_target_properties("${NOWIDE_TARGET_NAME}_shared" PROPERTIES
		COMPILE_DEFINITIONS "NOWIDE_DLL")
endif()

if(NOWIDE_BUILD_STATIC)
	list(APPEND NOWIDE_TARGET_TYPES "static")
	add_library("${NOWIDE_TARGET_NAME}_static" STATIC ${NOWIDE_SOURCE} ${NOWIDE_HEADERS})
	if(MSVC)
		set_target_properties("${NOWIDE_TARGET_NAME}_static" PROPERTIES
			OUTPUT_NAME "${TARGET_OUTPUT_NAME}${TARGET_ABI_VER}_static")
	else()
		set_target_properties("${NOWIDE_TARGET_NAME}_static" PROPERTIES
			OUTPUT_NAME "${TARGET_OUTPUT_NAME}${TARGET_ABI_VER}")
	endif()
endif()

foreach(NOWIDE_TARGET_TYPE ${NOWIDE_TARGET_TYPES})
	list(APPEND NOWIDE_TARGET_BUILT "${NOWIDE_TARGET_NAME}_${NOWIDE_TARGET_TYPE}")
	if(NOT MSYS)
		target_link_libraries("${NOWIDE_TARGET_NAME}_${NOWIDE_TARGET_TYPE}" ${CMAKE_DL_LIBS})
	endif()
	if(HONOR_VISILIBITY)
		set_target_properties("${NOWIDE_TARGET_NAME}_${NOWIDE_TARGET_TYPE}" PROPERTIES
			C_VISIBILITY_PRESET hidden)
	elseif(_COMPILER_HAS_VISIBILITY_HIDDEN)
		set_target_properties("${NOWIDE_TARGET_NAME}_${NOWIDE_TARGET_TYPE}" PROPERTIES
			COMPILE_FLAGS "-fvisibility=hidden")
	endif()
	set_target_properties("${NOWIDE_TARGET_NAME}_${NOWIDE_TARGET_TYPE}" PROPERTIES
		POSITION_INDEPENDENT_CODE ON)
endforeach()
