# CMakeLists.txt
# Build configuration for native C/C++ libraries in Flutter FFI PoC

cmake_minimum_required(VERSION 3.4.1)

project(dart_ffi_poc)

# Set C++ standard for calculator library
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Create library for Part 1 - Simple C math operations (FFI-friendly)
add_library(
    math_lib
    SHARED
    math_lib.c
)

# Include directories for math_lib
target_include_directories(
    math_lib
    PRIVATE
    ${CMAKE_SOURCE_DIR}
)

# Link math library
target_link_libraries(
    math_lib
    m  # libm for math functions (sqrt, etc)
)

# Create library for Part 2 - C++ calculator with C wrapper
add_library(
    calculator
    SHARED
    calculator.cpp
    calculator_c_api.cpp
)

# Include directories for calculator
target_include_directories(
    calculator
    PRIVATE
    ${CMAKE_SOURCE_DIR}
)

# C++ properties for calculator
set_target_properties(
    calculator
    PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
)

# Link standard C++ library (libstdc++ or libc++)
target_link_libraries(
    calculator
    m  # libm for math functions
)
