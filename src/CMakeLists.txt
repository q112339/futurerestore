cmake_minimum_required(VERSION 3.19...3.24 FATAL_ERROR)
project(futurerestore VERSION 2.0.0 LANGUAGES C CXX)
add_executable(futurerestore
        main.cpp
        futurerestore.cpp)
target_include_directories(futurerestore PRIVATE
        "${CMAKE_SOURCE_DIR}/external/idevicerestore/src"
        "${CMAKE_SOURCE_DIR}/external/tsschecker/external/jssy/jssy"
        "${CMAKE_SOURCE_DIR}/external/tsschecker/tsschecker"
        "${CMAKE_SOURCE_DIR}/dep_root/include")
set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS}")
if("${CMAKE_C_COMPILER}" MATCHES "mingw")
    # For MinGW-w64, link all libraries statically
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
    # Add library paths
    link_directories(
        ${CMAKE_BINARY_DIR}/external/libgeneral
        ${CMAKE_BINARY_DIR}/external/libplist
        ${CMAKE_BINARY_DIR}/img4tool
        ${CMAKE_BINARY_DIR}/external/tsschecker
        ${CMAKE_BINARY_DIR}/external/idevicerestore
    )
    # Add include paths
    include_directories(
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src
        ${CMAKE_SOURCE_DIR}/external/tsschecker/external/jssy/jssy
        ${CMAKE_SOURCE_DIR}/external/tsschecker/tsschecker
    )
    # Link libraries in the correct order to avoid multiple definition errors
    target_link_libraries(futurerestore PRIVATE
        # Windows system libraries
        ws2_32
        iphlpapi
        setupapi
        bcrypt
        crypt32
        schannel
        advapi32
        pthread
        user32
        gdi32
        winmm
        wldap32
        shell32
        ole32
        oleaut32
        uuid
        secur32
        cryptui
        ncrypt
        ntdll
        mswsock
        kernel32
        winspool
        comdlg32
        odbc32
        odbccp32
        # Project dependencies
        ${CMAKE_BINARY_DIR}/external/libgeneral/libgeneral.a
        ${CMAKE_BINARY_DIR}/external/libplist/libplist-2.0.a
        ${CMAKE_BINARY_DIR}/external/idevicerestore/libidevicerestore.a
        ${CMAKE_BINARY_DIR}/img4tool/libimg4tool.a
        ${CMAKE_BINARY_DIR}/external/tsschecker/libtsschecker.a
        ${CMAKE_BINARY_DIR}/external/tsschecker/external/libjssy.a
        # External dependencies from dep_root
        ${CMAKE_SOURCE_DIR}/dep_root/lib/libtatsu.a
        ${CMAKE_SOURCE_DIR}/dep_root/lib/libirecovery-1.0.a
        ${CMAKE_SOURCE_DIR}/dep_root/lib/libfragmentzip.a
        ${CMAKE_SOURCE_DIR}/dep_root/lib/libimobiledevice-1.0.a
        ${CMAKE_SOURCE_DIR}/dep_root/lib/libimobiledevice-glue-1.0.a
        ${CMAKE_SOURCE_DIR}/dep_root/lib/libusbmuxd-2.0.a
        # External dependencies from vcpkg
        ${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/lib/libzlib.a
        ${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/lib/libcurl.a
        ${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/lib/libssl.a
        ${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/lib/libcrypto.a)
else()
    # For non-MinGW-w64, use pkg-config for linking
    pkg_check_modules(DEPS REQUIRED
            libzip
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
    target_include_directories(futurerestore PRIVATE "${DEPS_INCLUDE_DIRS}")
    target_link_directories(futurerestore PRIVATE "${DEPS_LIBRARY_DIRS}")
    target_link_libraries(futurerestore PRIVATE
            z
            zip
            png16
            crypto
            ssl
            plist-2.0
            tsschecker
            idevicerestore
            jssy
            curl
            imobiledevice-glue-1.0
            imobiledevice-1.0
            irecovery-1.0
            usbmuxd-2.0
            tatsu
            fragmentzip
            general
            img4tool
            pthread)
endif()
if("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin" AND NOT "${CMAKE_C_COMPILER}" MATCHES "mingw")
    target_link_libraries(futurerestore PRIVATE
            compression
            "-framework CoreFoundation"
            "-framework IOKit")
elseif("${CMAKE_SYSTEM_NAME}" MATCHES "Windows" AND NOT "${CMAKE_C_COMPILER}" MATCHES "mingw")
    target_link_directories(futurerestore PRIVATE "/clang64/lib")
    set(CMAKE_SYSTEM_LIBRARY_PATH "/clang64/lib")
    target_link_libraries(futurerestore PRIVATE
            idevicerestore
            curl
            tsschecker
            jssy
            irecovery-1.0
            imobiledevice-1.0
            usbmuxd-2.0
            imobiledevice-glue-1.0
            plist-2.0
            usb-1.0
            bz2
            lzma
            iphlpapi
            ws2_32
            setupapi
            bcrypt
            crypt32
            schannel
            advapi32)
else()
    if(NOT "${CMAKE_C_COMPILER}" MATCHES "mingw")
        target_link_libraries(futurerestore PRIVATE
                usb-1.0
                dl
                udev)
    endif()
endif()
if(NOT DEFINED VERSION_COMMIT_COUNT)
    execute_process(COMMAND git rev-list --count HEAD WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}" OUTPUT_VARIABLE VERSION_COMMIT_COUNT ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
if(NOT DEFINED VERSION_COMMIT_SHA)
    execute_process(COMMAND git rev-parse HEAD WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}" OUTPUT_VARIABLE VERSION_COMMIT_SHA ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
execute_process(COMMAND cat version.txt WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}" OUTPUT_VARIABLE VERSION_RELEASE ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
add_definitions(
        -DCUSTOM_LOGGING=<stdlib.h>
        -DVERSION_COMMIT_COUNT="${VERSION_COMMIT_COUNT}"
        -DVERSION_COMMIT_SHA="${VERSION_COMMIT_SHA}"
        -DVERSION_RELEASE="${VERSION_RELEASE}"
        -DPACKAGE_NAME="futurerestore"
        -DPACKAGE_VERSION="${VERSION_RELEASE} Build: ${VERSION_COMMIT_COUNT}\(${VERSION_COMMIT_SHA}\)")
if(DEFINED DESTDIR)
    set(CMAKE_INSTALL_PREFIX ${DESTDIR}${CMAKE_INSTALL_PREFIX})
endif()
install(TARGETS futurerestore
        DESTINATION "${CMAKE_INSTALL_PREFIX}/bin")