# 🔧 Troubleshooting - FFI Native Library Issues

Common issues and solutions when working with FFI bindings.

## LateInitializationError: Field 'add' has not been initialized

### Symptom
```
LateInitializationError (LateInitializationError: Field 'add' has not been initialized.)
```

### Cause
The native library (`MathLib` or `CalculatorLib`) was not initialized before calling native functions.

### Solution

**Option 1: Initialize in main() (Recommended)**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'bindings/math_lib_bindings.dart';
import 'bindings/calculator_bindings.dart';

void main() async {
  // ← Add this
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize both native libraries
  try {
    await MathLib.initialize();
    await CalculatorLib.initialize();
  } catch (e) {
    debugPrint('Failed to initialize native libraries: $e');
  }

  runApp(const MyApp());
}
```

**Option 2: Initialize in Screen initState()**

Each screen initializes independently:

```dart
@override
void initState() {
  super.initState();
  _initializeNativeLibrary();
}

Future<void> _initializeNativeLibrary() async {
  try {
    await MathLib.initialize();
  } catch (e) {
    debugPrint('Error: $e');
  }
}
```

## "Library not found" or "Symbol not found"

### Symptom (Android)
```
DynamicLibraryError: Failed to load dynamic library 'libmath_lib.so'
Unable to load library
```

### Causes & Solutions

**1. Native library not compiled**

Check that CMake compiled the libraries:

```bash
# Build Android
flutter build apk

# Check build output
ls build/app/intermediates/cmake/release/obj/arm64-v8a/
# Should show: libmath_lib.so, libcalculator.so
```

**Solution**: Ensure CMakeLists.txt is correct and Android NDK is installed.

**2. Wrong library name**

Verify the name matches what CMake outputs:

```dart
// ✅ Correct
return ffi.DynamicLibrary.open('libmath_lib.so');  // Android
return ffi.DynamicLibrary.process();               // iOS

// ❌ Wrong
return ffi.DynamicLibrary.open('math_lib');        // Missing 'lib' prefix
return ffi.DynamicLibrary.open('libmath_lib.a');   // Wrong extension
```

**3. Architecture mismatch**

Verify APK contains compiled libraries for target architecture:

```bash
# Extract and check APK
unzip build/app/outputs/apk/release/app-release.apk
ls lib/arm64-v8a/

# Should contain: libmath_lib.so, libcalculator.so
```

If missing, check `android/build.gradle`:

```gradle
android {
  defaultConfig {
    ndk {
      abiFilters 'arm64-v8a', 'armeabi-v7a'
    }
  }
}
```

### Symptom (iOS)
```
Symbol not found in flat namespace
```

### Causes & Solutions

**1. Files not added to Xcode target**

Verify files are in Xcode and added to "Runner" target:

```bash
ls -la ios/Runner/Native/
# Should show symlinks or files
```

If empty, create symlinks:

```bash
bash ios/Runner/Scripts/link_native_sources.sh
```

**2. Files not in "Compile Sources"**

In Xcode:
1. Select "Runner" project
2. Select "Runner" target → "Build Phases"
3. Expand "Compile Sources"
4. All `.c` and `.cpp` files should be listed:
   - `math_lib.c`
   - `calculator.cpp`
   - `calculator_c_api.cpp`

If missing, add them:
1. Click "+" in "Compile Sources"
2. Add each file

**3. C++ language dialect not set**

Xcode might not compile `.cpp` files as C++17:

1. Select "Runner" project
2. Select "Runner" target → "Build Settings"
3. Search: "C++ Language Dialect"
4. Set to: `c++17`

## "Failed to initialize library"

### Symptom
```
Failed to initialize MathLib: Failed to load dynamic library
```

### Cause
The library loaded but functions couldn't be found.

### Solutions

**1. Check function names**

Ensure function names in `lookupFunction` match native code:

```c
// math_lib.h
int add(int a, int b);
```

```dart
// math_lib_bindings.dart
add = _nativeLib.lookupFunction<AddC, AddDart>('add');  // ✓ Correct
// NOT 'Add' or 'math_lib_add'
```

**2. Verify exports (C++ specific)**

For C++ code, functions must be wrapped in `extern "C"`:

```cpp
// ❌ Wrong - C++ name mangling
int calculator_sum(CalculatorHandle h, int a, int b) { ... }

// ✅ Correct
extern "C" {
  int calculator_sum(CalculatorHandle h, int a, int b) { ... }
}
```

Check with `nm` command:

```bash
# Android
nm -g build/app/intermediates/cmake/release/obj/arm64-v8a/libcalculator.so | grep calculator_sum
# Should show: 00000... T calculator_sum

# iOS
nm build/ios/Release-iphoneos/Runner.app/Runner | grep calculator_sum
# Should show: _calculator_sum
```

**3. Rebuild native libraries**

Clean and rebuild:

```bash
flutter clean
flutter pub get
flutter run --release
```

## App crashes when calling native functions

### Symptom
```
Thread 1: signal SIGABRT
```

### Common Causes

**1. Uninitialized data (struct/pointer)**

```dart
// ❌ Wrong
final point = Point();  // Not allocated
point.x = 1.0;         // Crash!

// ✅ Correct
final point = Struct.create<Point>();
point.x = 1.0;
```

**2. Memory management mismatch**

Ensure malloc/free pairs match:

```dart
// ✅ Correct
final ptr = malloc<Double>(10);
// ... use ...
malloc.free(ptr);

// ❌ Wrong
final ptr = malloc<Double>(10);
// ... use ...
calloc.free(ptr);  // Wrong allocator!
```

**3. Calling without initialization**

```dart
// ❌ Wrong
MathLib.add(5, 3);  // Crashes if MathLib not initialized

// ✅ Correct
await MathLib.initialize();
MathLib.add(5, 3);
```

## Android: CMake errors

### Symptom
```
CMake Error: Unable to find cmake file
```

### Solutions

**1. NDK not found**

Set NDK path in `android/local.properties`:

```properties
sdk.dir=/Users/yourname/Library/Android/sdk
ndk.dir=/Users/yourname/Library/Android/sdk/ndk/25.1.8937393
```

Or install via Android Studio:
1. Android Studio → Preferences → SDK Manager
2. SDK Tools → NDK → Install

**2. CMakeLists.txt not found**

Verify build.gradle references correct path:

```gradle
android {
  externalNativeBuild {
    cmake {
      path "src/main/cpp/CMakeLists.txt"  // ← Correct path
    }
  }
}
```

**3. Wrong CMake version**

Update via SDK Manager to version 3.22+:

```bash
# Verify version
cmake --version  # Should be 3.22 or higher
```

## iOS: File linking errors

### Symptom
```
Undefined symbol: _add
Linker command failed
```

### Solutions

**1. Symlinks broken**

```bash
# Check symlinks
ls -la ios/Runner/Native/
# Should show: lrwxr-xr-x ... math_lib.h -> ...

# If broken, recreate
bash ios/Runner/Scripts/link_native_sources.sh
```

**2. Symlinks as hard links (Windows)**

On Windows, symbolic links might not work. Use copies instead:

```bash
# Copy instead of symlink
cp native/cpp/*.{h,c,hpp,cpp} ios/Runner/Native/
```

**3. Build cache issues**

Clean Xcode build cache:

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
flutter clean
flutter pub get
flutter build ios
```

## Memory leaks

### Symptom (iOS/Android profiler)
Memory keeps increasing when repeatedly calling native functions.

### Causes

**1. Forgetting to free strings**

```dart
// ❌ Memory leak
final descPtr = CalculatorLib.calculatorDescription(_calc);
final desc = descPtr.cast<ffi_lib.Utf8>().toDartString();
// ← Forgot to free!

// ✅ Correct
final descPtr = CalculatorLib.calculatorDescription(_calc);
final desc = descPtr.cast<ffi_lib.Utf8>().toDartString();
CalculatorLib.calculatorFreeString(descPtr);  // ← Free!
```

**2. Forgetting to free arrays**

```dart
// ❌ Memory leak
final arr = calloc<Double>(100);
final avg = calc.average(arr, 100);
// ← Array not freed!

// ✅ Correct
final arr = calloc<Double>(100);
final avg = calc.average(arr, 100);
malloc.free(arr);  // ← Free!
```

**3. Forgetting to dispose handles**

```dart
// ❌ Memory leak
final calc = Calculator("test");
// ... use ...
// ← Forgot to dispose!

// ✅ Correct
final calc = Calculator("test");
// ... use ...
calc.dispose();  // ← Cleanup!
```

### How to find leaks

**Android**:
1. Android Studio → Profiler
2. Memory tab
3. Record and look for sustained increases

**iOS**:
1. Xcode → Product → Profile
2. Leaks instrument
3. Record and check for red leaks

## Build size increased

### Symptom
APK/IPA size increased significantly.

### Cause
Debug symbols included in native libraries.

### Solution

**Android**: Add to `build.gradle`:

```gradle
android {
  buildTypes {
    release {
      ndk {
        debugSymbols false  // ← Strip symbols
      }
    }
  }
}
```

**iOS**: Already handled by Flutter build system.

---

## Debugging Tips

### Enable verbose logging

```bash
# Android
flutter run -v

# Look for CMake output and library loading
```

### Check what symbols are exported

```bash
# Android
nm -g build/app/intermediates/cmake/release/obj/arm64-v8a/libmath_lib.so

# iOS
nm build/ios/Release-iphoneos/Runner.app/Runner | grep -i math
```

### Test with print statements

```dart
// Add logging to binding
print('Native lib initialized: ${MathLib.isInitialized}');
print('Calling add(5, 3)...');
final result = MathLib.add(5, 3);
print('Result: $result');
```

---

If issues persist, check:
1. **Logs**: Run with `-v` flag and look for actual error messages
2. **File structure**: Verify files are in correct locations
3. **Compilation**: Check that native libraries actually compiled
4. **Initialization**: Ensure `initialize()` called before using functions

