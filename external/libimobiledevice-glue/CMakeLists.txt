cmake_minimum_required(VERSION 3.16)
project(libimobiledevice-glue C)

set(CMAKE_C_STANDARD 99)

if (WIN32 AND MINGW)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_GNU_SOURCE -DWIN32 -DMINGW")
endif()

include_directories(include)

add_library(imobiledevice-glue STATIC
        src/socket.c
        src/thread.c
        src/collection.c
        src/tlv.c
        src/opack.c
        src/utils.c
        src/cbuf.c
        src/termcolors.c
        src/glue.c
        src/sha1.c
        src/sha256.c
        src/sha512.c
        src/nskeyedarchive.c
        )

target_include_directories(imobiledevice-glue PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        )

if (WIN32 AND MINGW)
    target_link_libraries(imobiledevice-glue PUBLIC
            ws2_32
            )
endif()
