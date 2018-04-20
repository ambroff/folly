include(CheckCXXSourceCompiles)
include(CheckIncludeFileCXX)
include(CheckFunctionExists)

hunter_add_package(Boost COMPONENTS context chrono date_time filesystem program_options regex system thread)
find_package(Boost 1.51.0 MODULE
  COMPONENTS
    context
    chrono
    date_time
    filesystem
    program_options
    regex
    system
    thread
  REQUIRED
)

if (NOT APPLE)
  list(APPEND FOLLY_LINK_LIBRARIES atomic)
endif()

list(APPEND FOLLY_LINK_LIBRARIES ${Boost_LIBRARIES})
list(APPEND FOLLY_INCLUDE_DIRECTORIES ${Boost_INCLUDE_DIRS})

hunter_add_package(double-conversion)
find_package(double-conversion CONFIG REQUIRED)
list(APPEND FOLLY_LINK_LIBRARIES double-conversion::double-conversion)

set(FOLLY_HAVE_LIBGFLAGS OFF)

hunter_add_package(gflags)
find_package(gflags CONFIG QUIET)
if (gflags_FOUND)
  message(STATUS "Found gflags from package config")
  set(FOLLY_HAVE_LIBGFLAGS ON)
  if (TARGET gflags-shared)
    set(FOLLY_SHINY_DEPENDENCIES ${FOLLY_SHINY_DEPENDENCIES} gflags-shared)
  elseif (TARGET gflags)
    set(FOLLY_SHINY_DEPENDENCIES ${FOLLY_SHINY_DEPENDENCIES} gflags)
  else()
    message(FATAL_ERROR "Unable to determine the target name for the GFlags package.")
  endif()
  list(APPEND CMAKE_REQUIRED_LIBRARIES ${GFLAGS_LIBRARIES})
  list(APPEND CMAKE_REQUIRED_INCLUDES ${GFLAGS_INCLUDE_DIR})
else()
  find_package(GFlags MODULE)
  set(FOLLY_HAVE_LIBGFLAGS ${LIBGFLAGS_FOUND})
  list(APPEND FOLLY_LINK_LIBRARIES ${LIBGFLAGS_LIBRARY})
  list(APPEND FOLLY_INCLUDE_DIRECTORIES ${LIBGFLAGS_INCLUDE_DIR})
  list(APPEND CMAKE_REQUIRED_LIBRARIES ${LIBGFLAGS_LIBRARY})
  list(APPEND CMAKE_REQUIRED_INCLUDES ${LIBGFLAGS_INCLUDE_DIR})
endif()

set(FOLLY_HAVE_LIBGLOG OFF)
hunter_add_package(glog)
find_package(glog CONFIG QUIET)
if (glog_FOUND)
  message(STATUS "Found glog from package config")
  set(FOLLY_HAVE_LIBGLOG ON)
  set(FOLLY_SHINY_DEPENDENCIES ${FOLLY_SHINY_DEPENDENCIES} glog::glog)
else()
  find_package(GLog MODULE)
  set(FOLLY_HAVE_LIBGLOG ${LIBGLOG_FOUND})
  list(APPEND FOLLY_LINK_LIBRARIES ${LIBGLOG_LIBRARY})
  list(APPEND FOLLY_INCLUDE_DIRECTORIES ${LIBGLOG_INCLUDE_DIR})
endif()

hunter_add_package(Libevent)
find_package(Libevent CONFIG QUIET)
if(TARGET event)
  message(STATUS "Found libevent from package config")
  set(FOLLY_SHINY_DEPENDENCIES ${FOLLY_SHINY_DEPENDENCIES} event)
else()
  find_package(LibEvent MODULE REQUIRED)
  list(APPEND FOLLY_LINK_LIBRARIES ${LIBEVENT_LIB})
  list(APPEND FOLLY_INCLUDE_DIRECTORIES ${LIBEVENT_INCLUDE_DIR})
endif()

hunter_add_package(OpenSSL)
find_package(OpenSSL REQUIRED)
list(APPEND FOLLY_LINK_LIBRARIES ${OPENSSL_LIBRARIES})
list(APPEND FOLLY_INCLUDE_DIRECTORIES ${OPENSSL_INCLUDE_DIR})
list(APPEND CMAKE_REQUIRED_LIBRARIES ${OPENSSL_LIBRARIES})
list(APPEND CMAKE_REQUIRED_INCLUDES ${OPENSSL_INCLUDE_DIR})
check_function_exists(ASN1_TIME_diff FOLLY_HAVE_OPENSSL_ASN1_TIME_DIFF)

find_package(PThread MODULE)
set(FOLLY_HAVE_PTHREAD ${LIBPTHREAD_FOUND})
if (LIBPTHREAD_FOUND)
  list(APPEND CMAKE_REQUIRED_LIBRARIES ${LIBPTHREAD_LIBRARIES})
  list(APPEND CMAKE_REQUIRED_INCLUDES ${LIBPTHREAD_INCLUDE_DIRS})
  list(APPEND FOLLY_INCLUDE_DIRECTORIES ${LIBPTHREAD_INCLUDE_DIRS})
  list(APPEND FOLLY_LINK_LIBRARIES ${LIBPTHREAD_LIBRARIES})
endif()

hunter_add_package(ZLIB)
find_package(ZLIB CONFIG)
set(FOLLY_HAVE_LIBZ ${ZLIB_FOUND})
if (ZLIB_FOUND)
  list(APPEND FOLLY_LINK_LIBRARIES ZLIB::zlib)
endif()

hunter_add_package(BZip2)
find_package(BZip2 CONFIG)
set(FOLLY_HAVE_LIBBZ2 ${BZIP2_FOUND})
if (BZIP2_FOUND)
  list(APPEND FOLLY_INCLUDE_DIRECTORIES ${BZIP2_INCLUDE_DIRS})
  list(APPEND FOLLY_LINK_LIBRARIES ${BZIP2_LIBRARIES})
endif()

hunter_add_package(lzma)
find_package(lzma CONFIG REQUIRED)
list(APPEND FOLLY_LINK_LIBRARIES lzma::lzma)

hunter_add_package(lz4)
#find_package(LZ4 MODULE)
find_package(lz4 CONFIG)
set(FOLLY_HAVE_LIBLZ4 ${LZ4_FOUND})
if (LZ4_FOUND)
  list(APPEND FOLLY_INCLUDE_DIRECTORIES ${LZ4_INCLUDE_DIR})
  list(APPEND FOLLY_LINK_LIBRARIES ${LZ4_LIBRARY})
endif()

hunter_add_package(zstd)
find_package(zstd REQUIRED)
set(FOLLY_HAVE_LIBZSTD ${ZSTD_FOUND})
if(ZSTD_FOUND)
  list(APPEND FOLLY_LINK_LIBRARIES zstd::zstd)
endif()

hunter_add_package(Snappy)
find_package(Snappy CONFIG)
set(FOLLY_HAVE_LIBSNAPPY ${SNAPPY_FOUND})
if (SNAPPY_FOUND)
  list(APPEND FOLLY_LINK_LIBRARIES Snappy::snappy)
endif()

find_package(LibDwarf)
list(APPEND FOLLY_LINK_LIBRARIES ${LIBDWARF_LIBRARIES})
list(APPEND FOLLY_INCLUDE_DIRECTORIES ${LIBDWARF_INCLUDE_DIRS})
CHECK_INCLUDE_FILE_CXX(libdwarf/dwarf.h FOLLY_HAVE_LIBDWARF_DWARF_H)

find_package(Libiberty)
list(APPEND FOLLY_LINK_LIBRARIES ${LIBIBERTY_LIBRARIES})
list(APPEND FOLLY_INCLUDE_DIRECTORIES ${LIBIBERTY_INCLUDE_DIRS})

find_package(LibAIO)
list(APPEND FOLLY_LINK_LIBRARIES ${LIBAIO_LIBRARIES})
list(APPEND FOLLY_INCLUDE_DIRECTORIES ${LIBAIO_INCLUDE_DIRS})

find_package(LibURCU)
list(APPEND FOLLY_LINK_LIBRARIES ${LIBURCU_LIBRARIES})
list(APPEND FOLLY_INCLUDE_DIRECTORIES ${LIBURCU_INCLUDE_DIRS})

list(APPEND FOLLY_LINK_LIBRARIES ${CMAKE_DL_LIBS})
list(APPEND CMAKE_REQUIRED_LIBRARIES ${CMAKE_DL_LIBS})
