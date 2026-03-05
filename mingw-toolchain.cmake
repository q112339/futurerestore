# MinGW-w64 toolchain file for cross-compiling to Windows

# Set the cross-compiler
SET(CMAKE_C_COMPILER "x86_64-w64-mingw32-gcc")
SET(CMAKE_CXX_COMPILER "x86_64-w64-mingw32-g++")
SET(CMAKE_RC_COMPILER "x86_64-w64-mingw32-windres")

# Set the target system
SET(CMAKE_SYSTEM_NAME "Windows")
SET(CMAKE_SYSTEM_PROCESSOR "x86_64")

# Set the search paths
SET(CMAKE_FIND_ROOT_PATH "/usr/local/opt/mingw-w64")

# Adjust the default behavior of the FIND_XXX() commands:
# Search programs in the host environment
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# Search headers and libraries in the target environment
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Set compiler flags
SET(CMAKE_C_FLAGS "-static -static-libgcc -static-libstdc++")
SET(CMAKE_CXX_FLAGS "-static -static-libgcc -static-libstdc++")
SET(CMAKE_EXE_LINKER_FLAGS "-static -static-libgcc -static-libstdc++")

# Set NO_PKGCFG for MinGW-w64 builds
SET(NO_PKGCFG ON)
