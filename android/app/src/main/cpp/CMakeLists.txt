# android/src/main/cpp/CMakeLists.txt
# Android NDK build configuration for Flutter FFI PoC
# This includes the master CMakeLists.txt from the centralized native/ directory

cmake_minimum_required(VERSION 3.4.1)

project(dart_ffi_poc_android)

# Calculate path to central native directory
# From: android/app/src/main/cpp/CMakeLists.txt
# To:   native/CMakeLists.txt
get_filename_component(PROJECT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../../../../" ABSOLUTE)
set(NATIVE_CMAKE "${PROJECT_ROOT}/native/CMakeLists.txt")

# Include the master CMakeLists from the central location
include("${NATIVE_CMAKE}")

# Additional Android-specific configuration
message(STATUS "Building for Android NDK")
message(STATUS "Native sources: ${PROJECT_ROOT}/native/cpp")
