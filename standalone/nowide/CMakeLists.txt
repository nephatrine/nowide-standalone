cmake_minimum_required(VERSION 2.8)
project(nowide)

#
# Project Options
#

option(BUILD_SHARED_LIBS "Build Shared Libraries" OFF)
option(NOWIDE_BUILD_TESTS "Build NoWide Test Programs" ON)

if (MSVC)
    option(USE_MSVC_RUNTIME_LIBRARY_DLL "Use MSVC runtime library DLL" ON)
endif()

#
# COMPILER FLAGS
#

if (MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    if (NOT USE_MSVC_RUNTIME_LIBRARY_DLL)
        foreach (flag CMAKE_CXX_FLAGS
                        CMAKE_CXX_FLAGS_DEBUG
                        CMAKE_CXX_FLAGS_RELEASE
                        CMAKE_CXX_FLAGS_MINSIZEREL
                        CMAKE_CXX_FLAGS_RELWITHDEBINFO)
            if (${flag} MATCHES "/MD")
                string(REGEX REPLACE "/MD" "/MT" ${flag} "${${flag}}")
            endif()
            if (${flag} MATCHES "/MDd")
                string(REGEX REPLACE "/MDd" "/MTd" ${flag} "${${flag}}")
            endif()
        endforeach()
    endif()
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc /W3")
else()
    include(CheckCCompilerFlag)

    add_definitions(-Wall)

	set(CMAKE_REQUIRED_FLAGS "-fvisibility=hidden")
	check_c_compiler_flag("" _NOWIDE_HAS_VISIBLITYHIDDEN)
	if (_NOWIDE_HAS_VISIBLITYHIDDEN)
		add_definitions(-fvisibility=hidden)
	endif()

	if (MINGW)
		set(CMAKE_REQUIRED_FLAGS "-Wl,--nxcompat")
		check_c_compiler_flag("" _NOWIDE_HAS_DEP)
		if (_NOWIDE_HAS_DEP)
			set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--nxcompat ${CMAKE_SHARED_LINKER_FLAGS}")
		endif()
		set(CMAKE_REQUIRED_FLAGS "-Wl,--dynamicbase")
		check_c_compiler_flag("" _NOWIDE_HAS_ASLR)
		if (_NOWIDE_HAS_ASLR)
			set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--dynamicbase ${CMAKE_SHARED_LINKER_FLAGS}")
		endif()
		set(CMAKE_REQUIRED_FLAGS "-Wl,--high-entropy-va")
		check_c_compiler_flag("" _NOWIDE_HAS_64ASLR)
		if (_NOWIDE_HAS_64ASLR)
			set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--high-entropy-va ${CMAKE_SHARED_LINKER_FLAGS}")
		endif()
	endif()
endif()

#
# Custom Commands
#

if (WIN32 AND NOT MSYS)
add_custom_command (
	OUTPUT
		${PROJECT_SOURCE_DIR}/src/iostream.cpp
		${PROJECT_SOURCE_DIR}/test/test_convert.cpp
		${PROJECT_SOURCE_DIR}/test/test_env.cpp
		${PROJECT_SOURCE_DIR}/test/test_fstream.cpp
		${PROJECT_SOURCE_DIR}/test/test_iostream.cpp
		${PROJECT_SOURCE_DIR}/test/test_stdio.cpp
		${PROJECT_SOURCE_DIR}/test/test_system.cpp
	WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/../
	COMMAND powershell -NoProfile -File convert.ps1
)
else()
add_custom_command (
	OUTPUT
		${PROJECT_SOURCE_DIR}/src/iostream.cpp
		${PROJECT_SOURCE_DIR}/test/test_convert.cpp
		${PROJECT_SOURCE_DIR}/test/test_env.cpp
		${PROJECT_SOURCE_DIR}/test/test_fstream.cpp
		${PROJECT_SOURCE_DIR}/test/test_iostream.cpp
		${PROJECT_SOURCE_DIR}/test/test_stdio.cpp
		${PROJECT_SOURCE_DIR}/test/test_system.cpp
	WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/../
	COMMAND ./convert
)
endif()

#
# Library Target
#

set(NOWIDE_LIB_NAME nowide0)
set(NOWIDE_LIB_TYPE STATIC)
if (BUILD_SHARED_LIBS)
	set(NOWIDE_LIB_TYPE SHARED)
	if (UNIX)
		set(NOWIDE_LIB_NAME nowide)
	endif()
endif()

include_directories(.)
add_library(nowide ${NOWIDE_LIB_TYPE} src/iostream.cpp)
set_target_properties(nowide PROPERTIES
                      OUTPUT_NAME "${NOWIDE_LIB_NAME}"
                      VERSION 0.0.0
                      SOVERSION 0
                      POSITION_INDEPENDENT_CODE ON)


#
# Test Executables
#

if(NOWIDE_BUILD_TESTS)
	enable_testing()

	add_executable(test_convert test/test_convert.cpp)
	target_link_libraries(test_convert nowide)
	add_test(test_convert test_convert)

	add_executable(test_stdio test/test_stdio.cpp)
	target_link_libraries(test_stdio nowide)
	add_test(test_stdio test_stdio)

	if(NOT APPLE)
		# OSX fstream is bugged?
		add_executable(test_fstream test/test_fstream.cpp)
		target_link_libraries(test_fstream nowide)
		add_test(test_fstream test_fstream)
	endif()

	add_executable(test_iostream test/test_iostream.cpp)
	target_link_libraries(test_iostream nowide)
	add_test(test_iostream test_iostream)

	add_executable(test_env_proto test/test_env.cpp)
	target_link_libraries(test_env_proto nowide)
	add_test(test_env_proto test_env_proto)

	if(WIN32 OR MSYS)
		add_executable(test_env_win test/test_env.cpp)
		set_target_properties(test_env_win PROPERTIES COMPILE_DEFINITIONS NOWIDE_USE_WINDOWS_H)
		target_link_libraries(test_env_win nowide)
		add_test(test_env_win test_env_win)
	endif()

	if(NOT MSYS)
		# This test fails on MSYS2 MinTTY
		add_executable(test_system test/test_system.cpp)
		target_link_libraries(test_system nowide)
		add_test(test_system_n test_system "-n")
		add_test(test_system_w test_system "-w")
	endif()
endif()

#
# Install NoWide
#

install(TARGETS nowide
	RUNTIME DESTINATION bin
	LIBRARY DESTINATION lib
	ARCHIVE DESTINATION lib)
install(DIRECTORY nowide DESTINATION include)

