cmake_minimum_required(VERSION 3.19...3.24 FATAL_ERROR)
project(futurerestore VERSION 2.0.0 LANGUAGES C CXX)
add_executable(futurerestore
        main.cpp
        futurerestore.cpp
        # libgeneral source files
        ${CMAKE_SOURCE_DIR}/external/libgeneral/libgeneral/Event.cpp
        ${CMAKE_SOURCE_DIR}/external/libgeneral/libgeneral/GuardAccess.cpp
        ${CMAKE_SOURCE_DIR}/external/libgeneral/libgeneral/Manager.cpp
        ${CMAKE_SOURCE_DIR}/external/libgeneral/libgeneral/Mem.cpp
        ${CMAKE_SOURCE_DIR}/external/libgeneral/libgeneral/Utils.cpp
        ${CMAKE_SOURCE_DIR}/external/libgeneral/libgeneral/exception.cpp
        # idevicerestore source files
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/idevicerestore.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/common.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/fls.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/mbn.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/img3.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/img4.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/ftab.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/ipsw.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/normal.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/dfu.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/recovery.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/restore.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/asr.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/fdr.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/limera1n.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/download.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/locking.c
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src/ace3.c)
target_include_directories(futurerestore PRIVATE
        "${CMAKE_SOURCE_DIR}/external/idevicerestore/src"
        "${CMAKE_SOURCE_DIR}/external/tsschecker/external/jssy/jssy"
        "${CMAKE_SOURCE_DIR}/external/tsschecker/tsschecker"
        "${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/include"
        "${CMAKE_SOURCE_DIR}/dependencies/zlib-1.3.2/contrib/minizip"
        "${CMAKE_SOURCE_DIR}/external/libirecovery/include"
        "${CMAKE_SOURCE_DIR}/external/libgeneral/include"
        "${CMAKE_SOURCE_DIR}/img4tool/include"
        "${CMAKE_SOURCE_DIR}/img4tool/cmake-build-windows/dep_root/include"
        "${CMAKE_SOURCE_DIR}/external/libzip/lib/"
        "${CMAKE_BINARY_DIR}/external/libzip/"
        "${CMAKE_SOURCE_DIR}/external/libipatcher/include")
set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS}")
if("${CMAKE_C_COMPILER}" MATCHES "mingw")
    # For MinGW-w64, link all libraries statically
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
    # Add library paths
    link_directories(
        ${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/lib
        ${CMAKE_BINARY_DIR}/external/libgeneral
        ${CMAKE_BINARY_DIR}/external/libplist
        ${CMAKE_BINARY_DIR}/external/libimobiledevice-glue
        ${CMAKE_BINARY_DIR}/img4tool
        ${CMAKE_BINARY_DIR}/external/tsschecker
        ${CMAKE_BINARY_DIR}/external/idevicerestore
    )
    # Use dep_root libraries only
    set(NO_PKGCFG ON)
    # Add include paths
    include_directories(
        ${CMAKE_SOURCE_DIR}/external/idevicerestore/src
        ${CMAKE_SOURCE_DIR}/external/tsschecker/external/jssy/jssy
        ${CMAKE_SOURCE_DIR}/external/tsschecker/tsschecker
        ${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/include
    )
    # Add dependencies on other targets to ensure correct build order
    add_dependencies(futurerestore
        libgeneral
        img4tool
        libplist
        imobiledevice-glue
        imobiledevice
        irecovery
        idevicerestore
        ipatcher
        fragmentzip
        tatsu)
    
    # Link libraries in the correct order to avoid multiple definition errors
    target_link_libraries(futurerestore PRIVATE
        # Main application code
        -Wl,--start-group
        # C++ standard library
        -lstdc++
        # libgeneral library
        ${CMAKE_BINARY_DIR}/external/libgeneral/libgeneral.a
        # libzip library
        zip
        # Main libraries (depend on external dependencies)
        ${CMAKE_BINARY_DIR}/external/libimobiledevice-glue/libimobiledevice-glue.a
        ${CMAKE_BINARY_DIR}/img4tool/libimg4tool.a
        ${CMAKE_BINARY_DIR}/external/libplist/libplist-2.0.a
        ${CMAKE_BINARY_DIR}/external/libirecovery/libirecovery.a
        ${CMAKE_BINARY_DIR}/external/libtatsu/libtatsu.a
        ${CMAKE_BINARY_DIR}/external/libfragmentzip/libfragmentzip.a
        ${CMAKE_BINARY_DIR}/external/libimobiledevice/libimobiledevice.a
        ${CMAKE_BINARY_DIR}/external/tsschecker/libtsschecker.a
        ${CMAKE_BINARY_DIR}/external/libipatcher/libipatcher.a
        ${CMAKE_BINARY_DIR}/external/liboffsetfinder64/liboffsetfinder64.a
        ${CMAKE_BINARY_DIR}/external/libinsn/libinsn.a
        # jssy library
        ${CMAKE_BINARY_DIR}/external/tsschecker/external/libjssy.a
        # External dependencies (use project-local libraries)
        ${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/lib/libcurl.a
        ${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/lib/libssl.a
        ${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/lib/libcrypto.a
        ${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/lib/libusbmuxd-2.0.a
        ${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-mingw-static/lib/libbz2.a
        ${CMAKE_SOURCE_DIR}/dependencies/zlib-1.3.2/libz.a
        # Windows system libraries
        ws2_32
        wsock32
        mswsock
        iphlpapi
        setupapi
        bcrypt
        crypt32
        schannel
        advapi32
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
        kernel32
        winspool
        comdlg32
        odbc32
        odbccp32
        wininet
        rpcrt4
        shlwapi
        pthread
        -Wl,--end-group)
elseif(NOT NO_PKGCFG)
    # For non-MinGW-w64 and when NO_PKGCFG is not set, use pkg-config for linking
    find_package(PkgConfig REQUIRED)
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
            libgeneral
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
        -DVERSION_COMMIT_COUNT="${VERSION_COMMIT_COUNT}"
        -DVERSION_COMMIT_SHA="${VERSION_COMMIT_SHA}"
        -DVERSION_RELEASE="${VERSION_RELEASE}"
        -DPACKAGE_NAME="futurerestore"
        -DPACKAGE_VERSION="${VERSION_RELEASE} Build: ${VERSION_COMMIT_COUNT}\(${VERSION_COMMIT_SHA}\)"
        -DPACKAGE_URL="https://github.com/futurerestore/futurerestore"
        -DPACKAGE_BUGREPORT="https://github.com/futurerestore/futurerestore/issues"
        -DLIBPLIST_STATIC
        -DLIBIRECOVERY_STATIC
        -DIRECV_STATIC
        -DLIBIMOBILEDEVICE_STATIC
        -DLIBIMOBILEDEVICE_GLUE_STATIC
        -DLIMD_GLUE_STATIC
        -DLIBUSBMUXD_STATIC
        -DCURL_STATICLIB
        -DOPENSSL_STATIC
        -DLIBZIP_STATIC
        -DIDEVICERESTORE_NOMAIN=1
        -DTSSCHECKER_NOMAIN=1
        -DLIBTATSU_STATIC
        -DLIBFRAGMENTZIP_STATIC
        -DHAVE_IDEVICE_E_TIMEOUT=1
        -DHAVE_RESTORE_E_RECEIVE_TIMEOUT=1
        -DHAVE_ENUM_IDEVICE_CONNECTION_TYPE=1
        -DHAVE_REVERSE_PROXY=1
        -DHAVE_OPENSSL=1
        -DSTATIC_BUILD=1
        -DNO_PKGCFG=1
        -DLIBSHARED_STATIC=1
        -DGENERAL_STATIC
        -DIMG4TOOL_STATIC
        -DLIBGENERAL_STATIC
        -DHAVE_LIBIPATCHER
        -DHAVE_LIBOFFSETFINDER64
        -DHAVE_IMG4TOOL)
if(DEFINED DESTDIR)
    set(CMAKE_INSTALL_PREFIX ${DESTDIR}${CMAKE_INSTALL_PREFIX})
endif()
install(TARGETS futurerestore
        DESTINATION "${CMAKE_INSTALL_PREFIX}/bin")