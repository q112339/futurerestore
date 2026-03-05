cmake_minimum_required(VERSION 3.19...3.24 FATAL_ERROR)
project(img4tool VERSION 1.0 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 20)



if("${CMAKE_HOST_SYSTEM_NAME}" MATCHES "Darwin" AND NOT "${CMAKE_C_COMPILER}" MATCHES "mingw")
    set(PROJECT_C_FLAGS "-fembed-bitcode=off -pthread -mrelax-all -Wno-deprecated-declarations -Wno-int-conversion")
    set(PROJECT_CXX_FLAGS "${PROJECT_C_FLAGS}")
    # Add C++ standard library include path
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/v1 -I/usr/local/include")
    link_directories(
        /usr/local/lib
        /usr/local/Cellar/openssl@1.1/1.1.1w/lib
        /usr/local/Cellar/libplist/2.7.0/lib
    )
elseif("${CMAKE_HOST_SYSTEM_NAME}" MATCHES "Linux" AND NOT "${CMAKE_C_COMPILER}" MATCHES "mingw")
    set(PROJECT_C_FLAGS "-Wl,--allow-multiple-definition -pthread -mrelax-all -Wno-deprecated-declarations -Wno-int-conversion")
    set(PROJECT_CXX_FLAGS "${PROJECT_C_FLAGS}")
    link_directories(
        /usr/local/lib
    )
elseif("${CMAKE_C_COMPILER}" MATCHES "mingw")
    set(PROJECT_C_FLAGS "-Wl,--allow-multiple-definition -pthread -fPIC -Wno-deprecated-declarations -Wno-int-conversion -DCURL_STATICLIB -Bstatic -O0")
    set(PROJECT_CXX_FLAGS "${PROJECT_C_FLAGS}")
    include_directories(
        include
        /usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/x86_64-w64-mingw32/include
        /usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/lib/gcc/x86_64-w64-mingw32/15.2.0/include
        /usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/lib/gcc/x86_64-w64-mingw32/15.2.0/include/c++
        /usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/lib/gcc/x86_64-w64-mingw32/15.2.0/include/c++/x86_64-w64-mingw32
        ${CMAKE_SOURCE_DIR}/dep_root/include
        /usr/local/Cellar/openssl@1.1/1.1.1w/include
    )
    link_directories(
        ${CMAKE_BINARY_DIR}/external/libgeneral
        ${CMAKE_BINARY_DIR}/external/libplist
        /usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/x86_64-w64-mingw32/lib
        /usr/local/Cellar/mingw-w64/13.0.0_2/toolchain-x86_64/lib/gcc/x86_64-w64-mingw32/15.2.0
        ${CMAKE_SOURCE_DIR}/dep_root/lib
    )
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${PROJECT_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${PROJECT_CXX_FLAGS}")

add_library(img4tool STATIC
    img4tool/ASN1DERElement.cpp
    img4tool/img4tool.cpp
    img4tool/lzssdec.c
    ../external/libgeneral/libgeneral/Mem.cpp
)

# Add include directories
target_include_directories(img4tool PRIVATE
    include
    ${CMAKE_SOURCE_DIR}/dep_root/include
    ${CMAKE_SOURCE_DIR}/external/libgeneral/include
)

# Add HAVE_PLIST definition
target_compile_definitions(img4tool PRIVATE HAVE_PLIST LIBPLIST_STATIC CURL_STATICLIB HAVE_MEMMEM)

# For MinGW-w64, ensure we use static linking for all dependencies
if("${CMAKE_C_COMPILER}" MATCHES "mingw")
    # For MinGW-w64, use static linking
    target_compile_definitions(img4tool PRIVATE STATIC)
    # Force static linking for all dependencies
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -static")
    set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -static")
    # For MinGW-w64, we need to include the libgeneral header files
    target_include_directories(img4tool PRIVATE
        ${CMAKE_SOURCE_DIR}/dep_root/include
    )
    # Link against static libraries
    target_link_libraries(img4tool PRIVATE
        -Wl,--whole-archive
        ${CMAKE_BINARY_DIR}/external/libgeneral/libgeneral.a
        ${CMAKE_BINARY_DIR}/external/libplist/libplist-2.0.a
        -Wl,--no-whole-archive
        ${CMAKE_SOURCE_DIR}/dep_root/lib/libcrypto.a
        ${CMAKE_SOURCE_DIR}/dep_root/lib/libssl.a
        ws2_32
        iphlpapi
        setupapi
        bcrypt
        crypt32
        schannel
        advapi32
    )
else()
    target_link_libraries(img4tool PRIVATE
        crypto
        ssl
        plist-2.0
        /usr/local/lib/libgeneral.dylib
    )
endif()

install(TARGETS img4tool
    DESTINATION "${CMAKE_INSTALL_PREFIX}/lib")

install(DIRECTORY include/img4tool
    DESTINATION "${CMAKE_INSTALL_PREFIX}/include")
