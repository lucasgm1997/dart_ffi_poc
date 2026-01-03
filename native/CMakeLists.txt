# native/CMakeLists.txt
# Master CMake configuration for FFI libraries
# This is the source of truth for native library compilation

cmake_minimum_required(VERSION 3.10)

project(ffi_libraries)

# Set C++ standard globally
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Get the native directory (where this file is)
# Use CMAKE_CURRENT_LIST_DIR to get the directory of THIS file, not the including file
set(NATIVE_DIR "${CMAKE_CURRENT_LIST_DIR}")

# ============================================================================
# Part 1: Math Library (C - FFI-friendly)
# ============================================================================

add_library(math_lib SHARED
    "${NATIVE_DIR}/cpp/math_lib.c"
)

target_include_directories(math_lib PRIVATE "${NATIVE_DIR}/cpp")

# Link math library for sqrt, etc.
target_link_libraries(math_lib m)

# ============================================================================
# Part 2: Calculator Library (C++ with C wrapper)
# ============================================================================

add_library(calculator SHARED
    "${NATIVE_DIR}/cpp/calculator.cpp"
    "${NATIVE_DIR}/cpp/calculator_c_api.cpp"
)

target_include_directories(calculator PRIVATE "${NATIVE_DIR}/cpp")

set_target_properties(calculator PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
)

target_link_libraries(calculator m)

# ============================================================================
# Build options
# ============================================================================

# Enable visibility control (hide internal symbols)
if(APPLE)
    # macOS/iOS
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
    set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)
elseif(ANDROID)
    # Android - let NDK handle it
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
    set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)
endif()

# Optional: Sanitizers for testing
if(BUILD_WITH_ASAN)
    add_compile_options(-fsanitize=address -fsanitize=undefined)
    add_link_options(-fsanitize=address -fsanitize=undefined)
endif()
