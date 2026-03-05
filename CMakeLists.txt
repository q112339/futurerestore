cmake_minimum_required(VERSION 3.19...3.24 FATAL_ERROR)
set(ignoreMe "${NO_PKGCFG} ${ASAN} ${ASAN_FLAGS} ${ARCH}")
option(SUBPROJECT_BUILD "Enables submodules to build as statically internally linked libs instead of binaries/tools" ON)
option(ASAN "Enable AddressSanatizer" OFF)
option(NO_PKGCFG "Disable pkgconfig searching of libs, use dep_root for linking" OFF)
#execute_process(COMMAND git submodule update --init --recursive WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}" OUTPUT_STRIP_TRAILING_WHITESPACE)

# Disable vcpkg for MinGW-w64 builds
# set(CMAKE_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake" CACHE STRING "Vcpkg toolchain file")
# set(VCPKG_TARGET_TRIPLET "x64-mingw-static" CACHE STRING "Vcpkg target triplet")

project(futurerestore VERSION 2.0.0 LANGUAGES C CXX)

# Set architecture to x86_64 explicitly
set(ARCH "x86_64")

# For MinGW-w64 builds, set NO_PKGCFG to avoid using pkg-config
if("${CMAKE_C_COMPILER}" MATCHES "mingw")
    set(NO_PKGCFG ON)
endif()

# Find dependencies for MinGW-w64 builds
if("${CMAKE_C_COMPILER}" MATCHES "mingw")
    # Use system-installed dependencies for MinGW-w64
    set(CMAKE_FIND_ROOT_PATH /usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64)
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
    
    # Bypass dependency finding for MinGW-w64
    set(ZLIB_FOUND TRUE)
    set(ZLIB_LIBRARY "z")
    set(ZLIB_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/external/libzip/lib")
    set(ZLIB_INCLUDE_DIRS "${ZLIB_INCLUDE_DIR}")
    set(ZLIB_LIBRARY_DIRS "")
    
    set(OPENSSL_FOUND TRUE)
    set(OPENSSL_CRYPTO_LIBRARY "crypto")
    set(OPENSSL_SSL_LIBRARY "ssl")
    set(OPENSSL_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/external/libzip/lib")
    
    set(CURL_FOUND TRUE)
    set(CURL_LIBRARY "curl")
    set(CURL_INCLUDE_DIR "/usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/x86_64-w64-mingw32/include")
    set(CURL_INCLUDE_DIRS "${CURL_INCLUDE_DIR}")
    set(CURL_LIBRARY_DIRS "/usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/x86_64-w64-mingw32/lib")
    
    include_directories(${ZLIB_INCLUDE_DIRS} ${OPENSSL_INCLUDE_DIR} ${CURL_INCLUDE_DIRS})
    link_directories(${ZLIB_LIBRARY_DIRS} ${CURL_LIBRARY_DIRS})
endif()

if("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin" AND NOT "${CMAKE_C_COMPILER}" MATCHES "mingw")
    set(CMAKE_OSX_ARCHITECTURES "${ARCH}")
    if((NOT DEFINED MINVER) AND NO_PKGCFG)
        set(CMAKE_OSX_DEPLOYMENT_TARGET 10.12)
    endif()
    if(DEFINED MINVER)
        set(CMAKE_OSX_DEPLOYMENT_TARGET "${MINVER}")
    endif()
    set(PROJECT_C_FLAGS "-fembed-bitcode=off -pthread -mrelax-all -Wno-deprecated-declarations -Wno-int-conversion")
    if(NOT "${CMAKE_BUILD_TYPE}" MATCHES "Debug" AND NOT "${CMAKE_BUILD_TYPE}" MATCHES "RelWithDebInfo")
        message("")
    else()
        set(CMAKE_CXX_COMPILE_OPTIONS_IPO "-fno-lto")
        set(CMAKE_C_COMPILE_OPTIONS_IPO "-fno-lto")
        set(_CMAKE_LTO_THIN FALSE)
        set(__lto_flags "-fno-lto")
    endif()
    set(PROJECT_CXX_FLAGS "${PROJECT_C_FLAGS}")
elseif("${CMAKE_SYSTEM_NAME}" MATCHES "Linux" AND NOT "${CMAKE_C_COMPILER}" MATCHES "mingw")
    set(PROJECT_C_FLAGS "-Wl,--allow-multiple-definition -pthread -mrelax-all -Wno-deprecated-declarations -Wno-int-conversion")
    set(PROJECT_CXX_FLAGS "${PROJECT_C_FLAGS}")
elseif("${CMAKE_SYSTEM_NAME}" MATCHES "Windows" OR "${CMAKE_C_COMPILER}" MATCHES "mingw")
    set(PROJECT_C_FLAGS "-Wl,--allow-multiple-definition -pthread -fPIC -Wno-deprecated-declarations -Wno-int-conversion -DCURL_STATICLIB -Bstatic -O0")
    set(PROJECT_CXX_FLAGS "${PROJECT_C_FLAGS}")
endif()
if(ASAN)
    set(ASAN ON)
    set(ASAN_FLAGS "-fsanitize=address -fsanitize-address-use-after-scope -fno-omit-frame-pointer ${ASAN_FLAGS}")
    set(CMAKE_C_LINK_LIBRARY_FLAG "${CMAKE_C_LINK_LIBRARY_FLAG} ${ASAN_FLAGS}")
    set(CMAKE_MACOSX_RPATH 1)
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH 1)
    set(CMAKE_BUILD_RPATH
            "/usr/local/lib"
            "/usr/lib"
            "/opt/procursus/lib"
            "/Library/Developer/CommandLineTools/usr/lib/clang/14.0.0/lib/darwin"
            "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/14.0.0/lib/darwin/"
            "/Applications/Xcode_14.1.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/14.0.0/lib/darwin/"
            "/Applications/Xcode_14.2.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/14.0.0/lib/darwin/")
    #hardcoded because actions never updates xcode
else()
    set(ASAN_FLAGS "")
endif()

# Remove problematic linker flags for MinGW-w64
if("${CMAKE_C_COMPILER}" MATCHES "mingw")
    set(CMAKE_EXE_LINKER_FLAGS "")
    set(CMAKE_SHARED_LINKER_FLAGS "")
    set(CMAKE_MODULE_LINKER_FLAGS "")
endif()

# Only use pkg-config if NO_PKGCFG is not set
if(NOT NO_PKGCFG AND NOT "${CMAKE_C_COMPILER}" MATCHES "mingw")
    find_package(PkgConfig REQUIRED FATAL_ERROR)
    pkg_check_modules(DEPS REQUIRED
            zlib
            libpng16
            libcrypto
            libssl
            libplist-2.0
            libimobiledevice-glue-1.0
            libimobiledevice-1.0
            libirecovery-1.0
            libusbmuxd-2.0
            libcurl
            libtatsu-1.0
            libfragmentzip
            libgeneral)
    include_directories(${DEPS_INCLUDE_DIRS})
    link_directories(${DEPS_LIBRARY_DIRS})
else()
    # For MinGW-w64 or when NO_PKGCFG is set, use system headers
    include_directories(/usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/x86_64-w64-mingw32/include)
endif()

# Add include directories for all targets
include_directories(
    ${CMAKE_SOURCE_DIR}/external/libgeneral/include
    ${CMAKE_SOURCE_DIR}/external/libfragmentzip/include
    ${CMAKE_SOURCE_DIR}/external/libplist/include
    ${CMAKE_SOURCE_DIR}/external/libzip/lib
)

# Add libzip from external directory
if("${CMAKE_C_COMPILER}" MATCHES "mingw")
    # For MinGW-w64 builds, use external/libzip
    # Disable zstd for MinGW builds
    set(ENABLE_ZSTD OFF CACHE BOOL "Enable use of Zstandard" FORCE)
    set(CMAKE_C_FLAGS_MINSIZEREL_INIT "${ADDITIONAL_C_FLAGS} ${PROJECT_C_FLAGS} ${CMAKE_C_FLAGS_MINSIZEREL_INIT}")
    set(CMAKE_C_FLAGS_RELEASE_INIT "${ADDITIONAL_C_FLAGS} ${PROJECT_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE_INIT}")
else()
    # For native builds, use external/libzip
    set(CMAKE_C_FLAGS_MINSIZEREL_INIT "${ADDITIONAL_C_FLAGS} -flto=thin ${PROJECT_C_FLAGS} ${CMAKE_C_FLAGS_MINSIZEREL_INIT}")
    set(CMAKE_C_FLAGS_RELEASE_INIT "${ADDITIONAL_C_FLAGS} -flto=thin ${PROJECT_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE_INIT}")
endif()
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "${ADDITIONAL_C_FLAGS} ${PROJECT_C_FLAGS} ${CMAKE_C_FLAGS_RELWITHDEBINFO_INIT}")
set(CMAKE_C_FLAGS_DEBUG_INIT "${ADDITIONAL_C_FLAGS} ${PROJECT_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG_INIT} ${ASAN_FLAGS}")

set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT " ${ADDITIONAL_CXX_FLAGS} ${PROJECT_CXX_FLAGS} ${CMAKE_CXX_FLAGS_MINSIZEREL_INIT}")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "${ADDITIONAL_CXX_FLAGS} ${PROJECT_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE_INIT}")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "${ADDITIONAL_CXX_FLAGS} ${PROJECT_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT}")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "${ADDITIONAL_CXX_FLAGS} ${PROJECT_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG_INIT} ${ASAN_FLAGS}")

set(CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL_INIT}")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE_INIT}")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO_INIT}")
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG_INIT}")
set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL_INIT}")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE_INIT}")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT}")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG_INIT}")

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 20)

# Add C++ standard library include path
if(NOT "${CMAKE_C_COMPILER}" MATCHES "mingw")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/v1")
else()
    # Remove macOS-specific linker flags for MinGW
    set(CMAKE_SHARED_LINKER_FLAGS "")
    set(CMAKE_MODULE_LINKER_FLAGS "")
    set(CMAKE_EXE_LINKER_FLAGS "")
    # Add MinGW-specific include paths without removing standard includes
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -I/usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/x86_64-w64-mingw32/include")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -I/usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/lib/gcc/x86_64-w64-mingw32/15.2.0/include")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I/usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/x86_64-w64-mingw32/include")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I/usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/lib/gcc/x86_64-w64-mingw32/15.2.0/include")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I/usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/lib/gcc/x86_64-w64-mingw32/15.2.0/include/c++")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I/usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/lib/gcc/x86_64-w64-mingw32/15.2.0/include/c++/x86_64-w64-mingw32")
endif()

add_subdirectory(external/libgeneral)
add_subdirectory(external/libplist)
add_subdirectory(external/libimobiledevice)
add_subdirectory(external/libirecovery)
add_subdirectory(external/libimobiledevice-glue)
add_subdirectory(external/libtatsu)
add_subdirectory(external/libfragmentzip)
add_subdirectory(external/libinsn)
add_subdirectory(external/liboffsetfinder64)
add_subdirectory(external/tsschecker)
add_subdirectory(external/idevicerestore)
add_subdirectory(external/libipatcher)
add_subdirectory(external/libzip)
add_subdirectory(img4tool)
add_subdirectory(src)

#SET(CMAKE_EXPORT_COMPILE_COMMANDS 1)
#get_cmake_property(_variableNames VARIABLES)
#list (SORT _variableNames)
#foreach (_variableName ${_variableNames})
#    message(STATUS "${_variableName}=${${_variableName}}")
#endforeach()
