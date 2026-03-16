cmake_minimum_required(VERSION 3.16)
project(PackCom VERSION 0.75 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ---- Compiler warnings ----
if(MSVC)
    add_compile_options(/W4 /wd4996)
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# ---- Platform detection ----
if(WIN32)
    add_compile_definitions(PACKCOM_WINDOWS)
else()
    add_compile_definitions(PACKCOM_POSIX)
endif()

# ---- Source files ----
set(PACKCOM_SOURCES
    src/main.cpp
    src/platform.cpp
    src/serial.cpp
    src/terminal.cpp
    src/input.cpp
    src/config.cpp
    src/yapp.cpp
    src/fileops.cpp
    src/app.cpp
)

# ---- Include directories ----
include_directories(include)

# ---- Executable ----
add_executable(packcom ${PACKCOM_SOURCES})

# ---- Platform-specific linking ----
if(UNIX AND NOT APPLE)
    target_link_libraries(packcom pthread)
elseif(APPLE)
    target_link_libraries(packcom pthread)
elseif(WIN32)
    # No extra libs needed; conio.h and windows.h are implicit
endif()

# ---- Install ----
install(TARGETS packcom DESTINATION bin)

# ---- Optional: build a debug variant ----
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_definitions(packcom PRIVATE PACKCOM_DEBUG)
endif()

# ---- Summary ----
message(STATUS "PackCom ${PROJECT_VERSION} – target platform: ${CMAKE_SYSTEM_NAME}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
