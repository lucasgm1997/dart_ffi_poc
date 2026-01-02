# Flutter FFI PoC - Build Instructions

This document provides step-by-step instructions to build and run the Flutter FFI PoC examples on Android and iOS.

## Overview

This project demonstrates two FFI binding scenarios:

- **Part 1: Easy Binding** - Simple C library with FFI-friendly API (int, double, POD structs)
- **Part 2: Complex Binding** - C++ library with C wrapper API using std::string and std::vector internally

## Prerequisites

- Flutter SDK (latest)
- Android Studio with NDK/CMake (for Android builds)
- Xcode (for iOS builds)
- Basic knowledge of C/C++ and Dart

## Android Build Setup

### Step 1: Verify Android NDK Configuration

1. In Android Studio, go to **SDK Manager** → **SDK Tools**
2. Install (or verify installed):
   - NDK (version 21 or later)
   - CMake (version 3.10.2 or later)

3. Verify `android/local.properties` contains:
```properties
sdk.dir=/path/to/Android/sdk
ndk.dir=/path/to/Android/ndk/25.1.8937393  # or your NDK version
```

### Step 2: Android Gradle Configuration

The file `android/build.gradle` should already be configured to build native libraries. Key parts:

```gradle
android {
    defaultConfig {
        externalNativeBuild {
            cmake {
                cppFlags "-std=c++17"
                arguments "-DCMAKE_BUILD_TYPE=Release"
            }
        }
    }

    externalNativeBuild {
        cmake {
            path "src/main/cpp/CMakeLists.txt"
        }
    }
}
```

### Step 3: Building for Android

From the project root, run:

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build APK (which will compile native libraries)
flutter build apk

# Or for a development build:
flutter run --release
```

The CMake build will:
1. Compile `math_lib.c` into `libmath_lib.so`
2. Compile `calculator.cpp` and `calculator_c_api.cpp` into `libcalculator.so`
3. Package them into the APK for architecture(s) you're targeting

### Android Build Output

Native libraries are compiled for architectures specified in `defaultConfig`:
- `armeabi-v7a` (32-bit ARM)
- `arm64-v8a` (64-bit ARM)
- `x86`, `x86_64` (emulator support)

Libraries are placed in: `build/intermediates/cmake/release/obj/{abi}/`

## iOS Build Setup

### Step 1: Copy Native Files to iOS

iOS needs the native C/C++ files in the Xcode project. Two approaches:

#### Option A: Direct File Inclusion (Simpler)

1. Copy native files to iOS source directory:
```bash
# From project root
mkdir -p ios/Runner/Native
cp android/src/main/cpp/*.{h,c,cpp} ios/Runner/Native/
```

2. In Xcode, open `ios/Runner.xcworkspace` (NOT `.xcodeproj`):
   - Right-click on "Runner" project
   - Select "Add Files to Runner"
   - Select the files from `ios/Runner/Native/`
   - ✓ Check "Copy items if needed"
   - ✓ Check "Create folder references"
   - ✓ Select target "Runner"

#### Option B: Podspec Wrapper (Production-Style)

Create `ios/native_libs.podspec`:

```ruby
Pod::Spec.new do |s|
  s.name             = 'native_libs'
  s.version          = '1.0.0'
  s.summary          = 'Native C/C++ libraries for FFI'
  s.homepage         = 'https://example.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Your Name' => 'email@example.com' }
  s.source           = { :path => '.' }

  s.source_files = 'Runner/Native/**/*.{h,c,cpp}'
  s.public_header_files = 'Runner/Native/**/*.h'

  s.ios.deployment_target = '11.0'
  s.pod_target_xcconfig = { 'CLANG_CXX_LANGUAGE_DIALECT' => 'c++17' }
end
```

Then add to `ios/Podfile`:
```ruby
pod 'native_libs', :path => './'
```

And run: `cd ios && pod install`

### Step 2: Xcode Configuration

1. In Xcode, select the "Runner" target
2. Go to **Build Settings**
3. Search for "C++ Language Dialect"
4. Set it to `C++17` [-std=c++17]
5. Search for "Header Search Paths"
6. Add `$(SRCROOT)/Runner/Native` if needed

### Step 3: Build for iOS

From the project root:

```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Build for iOS (development)
flutter build ios --debug

# Or for release:
flutter build ios --release

# Or run directly on device/simulator:
flutter run -d <device_id>
```

To find connected devices:
```bash
flutter devices
```

### iOS Build Output

Native libraries are compiled as part of the app bundle:
- Debug: `build/ios/Debug-iphoneos/` (device) or `Debug-iphonesimulator/` (simulator)
- Release: `build/ios/Release-iphoneos/`

## Loading Native Libraries in Dart

### Android

```dart
// Platform-specific library loading
ffi.DynamicLibrary _loadNativeLibrary() {
  if (Platform.isAndroid) {
    return ffi.DynamicLibrary.open('libmath_lib.so');
  } else if (Platform.isIOS) {
    return ffi.DynamicLibrary.process();
  }
}
```

- **Android**: Use `DynamicLibrary.open()` with the `.so` filename
- **iOS**: Use `DynamicLibrary.process()` to load symbols from the app bundle

### iOS Note

For iOS, the native code is statically linked into the app binary. Use `DynamicLibrary.process()` to access symbols.

## Troubleshooting

### Android

**Problem**: NDK not found
```
CMake Error: Unable to find cmake file
```
**Solution**: Set `ndk.dir` in `local.properties` or install NDK via SDK Manager

**Problem**: CMake version mismatch
```
CMake 3.10.2 or higher is required
```
**Solution**: Update CMake in SDK Manager to version 3.22 or later

**Problem**: Architecture mismatch
```
error: undefined reference to 'add'
```
**Solution**: Ensure native libraries are compiled for the target architecture. Check `android:abiFilters` in `build.gradle`

### iOS

**Problem**: Symbol not found during runtime
```
Symbol not found in flat namespace
```
**Solution**:
- Verify files are added to the Runner target (in Xcode's "Target Membership")
- Check that header paths are correct in Build Settings
- Ensure C++17 is enabled

**Problem**: Linker errors for C++
```
undefined reference to 'std::string'
```
**Solution**: Set "C++ Language Dialect" to C++17 in Build Settings for the Runner target

**Problem**: Files not found during build
```
No such file or directory: ios/Runner/Native/math_lib.h
```
**Solution**: Copy the native files to `ios/Runner/Native/` and add them to the Xcode project

## Testing the Build

### Android

1. Connect an Android device or start an emulator
2. Run: `flutter run --release`
3. Navigate through the app to test Part 1 and Part 2 examples
4. Check logs: `flutter logs`

### iOS

1. Connect an iOS device or use the simulator
2. Run: `flutter run -d <device_id>`
3. Check logs: `flutter logs` or Xcode's Console

## Build Artifacts

### Android
- **libraries**: `android/src/main/cpp/`
- **CMakeLists.txt**: `android/src/main/cpp/CMakeLists.txt`
- **Compiled**: Embedded in APK/AAB

### iOS
- **libraries**: `ios/Runner/Native/` (after copying)
- **Build output**: Linked into app binary
- **Verification**: Use `strings` command to verify symbols in binary

## Performance Notes

- C library (Part 1) is faster due to simpler types
- C++ wrapper (Part 2) has minimal overhead - most time spent in native code
- String allocations in Part 2 use malloc/free - consider pooling for production
- Struct passing is efficient (stack-allocated in most cases)

## Next Steps

1. **Profiling**: Use Android Studio's Profiler or Instruments to measure native code performance
2. **Optimization**: Profile hot paths and optimize C/C++ code accordingly
3. **Testing**: Add unit tests for native code using gtest or similar
4. **Production**: Consider security hardening, error handling, and ABI stability

## References

- [Dart FFI Documentation](https://dart.dev/guides/libraries/c-interop)
- [Flutter FFI Best Practices](https://flutter.dev/docs/development/platform-integration/c-interop)
- [Android NDK Documentation](https://developer.android.com/ndk/docs)
- [iOS FFI Guidelines](https://developer.apple.com/documentation/uikit)
- [CMake Documentation](https://cmake.org/documentation/)
