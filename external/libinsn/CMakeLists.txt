cmake_minimum_required(VERSION 3.19...3.24 FATAL_ERROR)
project(libinsn VERSION 1.0.0 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 20)

if("${CMAKE_HOST_SYSTEM_NAME}" MATCHES "Darwin" AND NOT "${CMAKE_C_COMPILER}" MATCHES "mingw")
    set(PROJECT_C_FLAGS "-fembed-bitcode=off -pthread -mrelax-all -Wno-deprecated-declarations -Wno-int-conversion")
    set(PROJECT_CXX_FLAGS "${PROJECT_C_FLAGS}")
    # Add C++ standard library include path
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/v1")
    include_directories(
        include
        /usr/local/include
    )
    link_directories(
        /usr/local/lib
    )
elseif("${CMAKE_HOST_SYSTEM_NAME}" MATCHES "Linux" AND NOT "${CMAKE_C_COMPILER}" MATCHES "mingw")
    set(PROJECT_C_FLAGS "-Wl,--allow-multiple-definition -pthread -mrelax-all -Wno-deprecated-declarations -Wno-int-conversion")
    set(PROJECT_CXX_FLAGS "${PROJECT_C_FLAGS}")
    include_directories(
        include
        /usr/local/include
    )
    link_directories(
        /usr/local/lib
    )
elseif("${CMAKE_HOST_SYSTEM_NAME}" MATCHES "MSYS" OR "${CMAKE_HOST_SYSTEM_NAME}" MATCHES "Windows" OR "${CMAKE_C_COMPILER}" MATCHES "mingw")
    set(PROJECT_C_FLAGS "-Wl,--allow-multiple-definition -pthread -fPIC -Wno-deprecated-declarations -Wno-int-conversion -DCURL_STATICLIB -Bstatic -O0")
    set(PROJECT_CXX_FLAGS "${PROJECT_C_FLAGS}")
    include_directories(
        include
        "${CMAKE_SOURCE_DIR}/dep_root/include"
        /usr/local/x86_64-w64-mingw32/include
        ${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/include
    )
    link_directories(
        "${CMAKE_SOURCE_DIR}/dep_root/lib"
        /usr/local/x86_64-w64-mingw32/lib
        ${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/lib
    )
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${PROJECT_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${PROJECT_CXX_FLAGS}")

add_library(insn STATIC
    libinsn/arm32_arm_decode.cpp
    libinsn/arm32_arm_encode.cpp
    libinsn/arm32_thumb_decode.cpp
    libinsn/arm32_thumb_encode.cpp
    libinsn/arm64_decode.cpp
    libinsn/arm64_encode.cpp
    libinsn/vmem.cpp
)

if("${CMAKE_C_COMPILER}" MATCHES "mingw")
    target_link_libraries(insn
        -lstdc++
        ${CMAKE_BINARY_DIR}/external/libgeneral/libgeneral.a
    )
else()
    target_link_libraries(insn
        -lstdc++
        general
    )
endif()

install(TARGETS insn
    DESTINATION "${CMAKE_INSTALL_PREFIX}/lib")

install(DIRECTORY include/libinsn
    DESTINATION "${CMAKE_INSTALL_PREFIX}/include")
