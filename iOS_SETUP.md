# iOS Setup Guide for Flutter FFI PoC

This guide provides detailed instructions for setting up and building the Flutter FFI PoC on iOS.

## Prerequisites

- Xcode 12.0 or later
- iOS deployment target 11.0 or later
- iPhone with iOS 11+ or iOS Simulator
- Flutter SDK configured for iOS development

## Quick Setup (5 minutes)

### 1. Copy Native Files

```bash
# From project root
mkdir -p ios/Runner/Native
cp android/src/main/cpp/{*.h,*.c,*.cpp} ios/Runner/Native/

# Verify
ls ios/Runner/Native/
# math_lib.h, math_lib.c
# calculator.hpp, calculator.cpp
# calculator_c_api.h, calculator_c_api.cpp
```

### 2. Configure Xcode

1. Open iOS project:
```bash
open ios/Runner.xcworkspace
```

**Important**: Use `.xcworkspace`, NOT `.xcodeproj`

2. In Xcode:
   - Select "Runner" in Project Navigator (left sidebar)
   - Select "Runner" under TARGETS
   - Go to **Build Settings** tab

3. Search for "C++ Language Dialect":
   - Set to `C++17` (or `-std=c++17` if custom)

4. Add native files to project:
   - Right-click "Runner" folder in Project Navigator
   - Select "Add Files to Runner..."
   - Navigate to `ios/Runner/Native/`
   - Select all `.h`, `.c`, and `.cpp` files
   - ✓ Check "Copy items if needed"
   - ✓ Check "Create folder references"
   - ✓ Select target "Runner"
   - Click "Add"

### 3. Verify Build

```bash
# From project root
flutter clean
flutter pub get

# Build for iOS
flutter build ios

# If successful, you'll see:
# ✓ Built build/ios/Release-iphoneos/Runner.app
```

## Detailed Setup Steps

### Step 1: Prepare Native Files

Create the native files directory:

```bash
mkdir -p ios/Runner/Native
```

Copy the native source files:

```bash
cp android/src/main/cpp/math_lib.h ios/Runner/Native/
cp android/src/main/cpp/math_lib.c ios/Runner/Native/
cp android/src/main/cpp/calculator.hpp ios/Runner/Native/
cp android/src/main/cpp/calculator.cpp ios/Runner/Native/
cp android/src/main/cpp/calculator_c_api.h ios/Runner/Native/
cp android/src/main/cpp/calculator_c_api.cpp ios/Runner/Native/
```

Verify the files:

```bash
$ ls -la ios/Runner/Native/
total 56
-rw-r--r--  calculator.cpp
-rw-r--r--  calculator.hpp
-rw-r--r--  calculator_c_api.cpp
-rw-r--r--  calculator_c_api.h
-rw-r--r--  math_lib.c
-rw-r--r--  math_lib.h
```

### Step 2: Add Files to Xcode Project

1. Open Xcode:
```bash
open ios/Runner.xcworkspace
```

2. In Xcode Project Navigator (left panel):
   - Expand "Runner" folder
   - Right-click on "Runner"
   - Select "Add Files to Runner..."

3. Navigate to:
   - `ios/Runner/Native/`

4. Select all files:
   - Hold Cmd and click: `math_lib.h`, `math_lib.c`, `calculator.hpp`, `calculator.cpp`, `calculator_c_api.h`, `calculator_c_api.cpp`

5. Ensure these checkboxes are checked:
   - ☑ Copy items if needed
   - ☑ Create folder references
   - ☑ Add to target "Runner"

6. Click **Add**

### Step 3: Configure C++ Standard

1. In Xcode, select "Runner" project (top of Project Navigator)
2. Select "Runner" under TARGETS
3. Go to **Build Settings** tab
4. Click "All" (to show all settings)
5. Search for: `C_PLUS_PLUS_LANGUAGE_DIALECT` or `GCC_CXX_LANGUAGE_DIALECT`
6. Set the value to:
   ```
   c++17  (or gnu++17)
   ```

### Step 4: Verify Header Search Paths

Some projects may need explicit header search paths:

1. Go to **Build Settings**
2. Search for: `HEADER_SEARCH_PATHS`
3. Add: `$(SRCROOT)/Runner/Native`
4. For Pods: `$(SRCROOT)/Pods/Headers/Public`

### Step 5: Check for Compiler Warnings

If you see warnings about C++ syntax:

1. Select each `.cpp` and `.h` file in Project Navigator
2. In File Inspector (right panel), under "Target Membership"
3. Ensure "Runner" is checked ✓

## Building the Project

### Development Build (Debug)

```bash
flutter run
```

Xcode will:
1. Compile the C/C++ files with the project
2. Link them into the app binary
3. Install on device/simulator
4. Launch the app

### Release Build

```bash
flutter build ios --release
```

### Building for Device

Connect your iOS device and:

```bash
flutter run -d <device_id>
```

Find device ID:
```bash
flutter devices
```

Example output:
```
Connected devices:
iPhone 13 Pro • ABC123DEF456 • ios • iOS 15.1
Simulator • ABC123DEF456 • ios • com.apple.CoreSimulator.CoreSimulator.iPhone-13-pro
```

## Troubleshooting

### Issue: "Symbol Not Found" Runtime Error

**Error Message**:
```
dyld: Symbol not found in flat namespace '_add'
```

**Solutions**:

1. Verify files are in Xcode project:
   - Click "Runner" in Project Navigator
   - Look for "Native" folder with files
   - If missing, re-do Step 2

2. Check Target Membership:
   - Select each `.c`, `.cpp`, `.h` file
   - In File Inspector (right), ensure "Runner" is checked

3. Verify symbols are exported:
   ```bash
   nm -g build/ios/Release-iphoneos/Runner.app/Runner | grep add
   ```
   Should show: `_add`

### Issue: C++17 Compiler Errors

**Error Message**:
```
'std::string' is not a known type
'std::vector' is not a known type
```

**Solutions**:

1. Set C++ Language Dialect to C++17:
   - Build Settings → Search "C_PLUS_PLUS_LANGUAGE_DIALECT"
   - Set to `c++17`

2. Ensure `.cpp` files are marked as C++:
   - Select file
   - File Inspector (right) → File Type
   - Should be "C++ Source" or "Objective-C++ Source"

3. If still issues, try:
   ```bash
   flutter build ios --verbose
   ```
   Look for compiler flags to verify `-std=c++17` is present

### Issue: "Cannot Find Native Module"

**Error Message**:
```
error: Unable to open [project]/ios/Runner/Native: No such file or directory
```

**Solution**:

```bash
# Make sure directory exists
mkdir -p ios/Runner/Native

# Copy files
cp android/src/main/cpp/{*.h,*.c,*.cpp} ios/Runner/Native/

# Verify
ls ios/Runner/Native/
```

### Issue: Xcode Project Structure Issues

If things still don't work:

1. **Clean everything**:
   ```bash
   flutter clean
   cd ios && rm -rf Pods Podfile.lock .symlinks/ Flutter/Flutter.framework
   cd .. && flutter pub get
   ```

2. **Reset Xcode**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```

3. **Rebuild**:
   ```bash
   flutter build ios
   ```

### Issue: Memory Errors (malloc/free crashes)

**Symptoms**: App crashes when calling calculator functions

**Cause**: Memory management issues between Dart and C++

**Solution**:

1. Verify `calculator_free_string` is called after getting description:
   ```dart
   final descPtr = CalculatorLib.calculatorDescription(_currentCalc!);
   final description = descPtr.cast<ffi_lib.Utf8>().toDartString();
   CalculatorLib.calculatorFreeString(descPtr);  // ← Don't forget this!
   ```

2. Verify `CalculatorHandle` is freed:
   ```dart
   @override
   void dispose() {
     if (_currentCalc != null) {
       CalculatorLib.calculatorFree(_currentCalc!);
       _currentCalc = null;
     }
     super.dispose();
   }
   ```

## Testing on Device

### Step 1: Build and Install

```bash
# Connect your iPhone
flutter devices  # Find the device ID

# Build and run
flutter run -d <device_id>
```

### Step 2: Test the App

1. Navigate to Part 1 (Easy Binding)
   - Enter numbers in the input fields
   - Click buttons to test math operations
   - Verify results display correctly

2. Navigate to Part 2 (Complex Binding)
   - Create a calculator with a name
   - Test arithmetic operations (sum, product, divide)
   - Test statistics (average, min, max)
   - Verify operation count increments

### Step 3: View Logs

```bash
# In terminal
flutter logs

# Or in Xcode
# View → Debug Area → Show Console
```

Look for:
- `[Part1] Native library initialized successfully`
- `[Part2] Calculator library initialized successfully`
- Operation results and descriptions

## Performance Testing

### Using Xcode Instruments

1. From Xcode menu: **Product** → **Profile** (Cmd+I)
2. Choose a profiling tool:
   - **Time Profiler**: See where time is spent
   - **Allocations**: Track memory usage
   - **Leaks**: Find memory leaks

3. Record a profile while using the app
4. Analyze results

### Expected Performance

- **Part 1 operations**: < 1ms
- **Part 2 calculator creation**: < 10ms
- **Statistics on 1000 values**: < 5ms
- **Memory per calculator instance**: < 100 bytes

## Production Considerations

### Code Signing

```bash
# Automatic signing (recommended for development)
flutter build ios

# Manual signing (for distribution)
flutter build ios --release \
  --export-options-template=ExportOptions.plist
```

### App Store Submission

For distribution:

1. **Ensure all symbols are properly exported**
2. **Strip debug symbols** (done automatically by Flutter)
3. **Test on multiple iOS versions** (11, 12, 13, 14, 15, 16+)
4. **Check for platform-specific issues**:
   - ARM64 support (remove armv7 if not needed)
   - Bitcode (usually disabled in Flutter)

### Strip Symbols Command

```bash
# Verify symbols are present
xcrun symbols -nodsym build/ios/Release-iphoneos/Runner.app/Runner

# Strip if needed
strip -x build/ios/Release-iphoneos/Runner.app/Runner
```

## Advanced: Custom Build Configuration

If you need more control, create an iOS build script:

**ios/build_native.sh**:
```bash
#!/bin/bash

# Navigate to iOS folder
cd "$(dirname "$0")"

# Define paths
NATIVE_DIR="Runner/Native"
BUILD_DIR="build/native"

# Create build directory
mkdir -p "$BUILD_DIR"

# Build with explicit compiler flags
xcrun clang++ \
  -std=c++17 \
  -fPIC \
  -arch arm64 \
  -c "$NATIVE_DIR/calculator.cpp" \
  -o "$BUILD_DIR/calculator.o"

xcrun clang++ \
  -std=c++17 \
  -fPIC \
  -arch arm64 \
  -c "$NATIVE_DIR/calculator_c_api.cpp" \
  -o "$BUILD_DIR/calculator_c_api.o"

# Create library
xcrun libtool \
  -static "$BUILD_DIR/"*.o \
  -o "$BUILD_DIR/libcalculator.a"

echo "Build complete: $BUILD_DIR/libcalculator.a"
```

Make executable:
```bash
chmod +x ios/build_native.sh
```

## Common File Structure After Setup

```
ios/
├── Runner/
│   ├── Native/                 # Native source files
│   │   ├── math_lib.h
│   │   ├── math_lib.c
│   │   ├── calculator.hpp
│   │   ├── calculator.cpp
│   │   ├── calculator_c_api.h
│   │   └── calculator_c_api.cpp
│   ├── GeneratedPluginRegistrant.h
│   ├── GeneratedPluginRegistrant.m
│   ├── Info.plist
│   └── Main.storyboard
│
├── Runner.xcodeproj
├── Runner.xcworkspace
├── Podfile
└── Podfile.lock
```

## Next Steps

1. **Build the project** (follow Quick Setup above)
2. **Run on simulator**: `flutter run`
3. **Test both parts** of the example
4. **Check logs** for initialization messages
5. **Modify and experiment** with the native code
6. **Profile** using Xcode Instruments

## References

- [iOS Development with Flutter](https://flutter.dev/docs/development/ios-project-setup)
- [Xcode Help](https://help.apple.com/xcode/)
- [Apple Clang Documentation](https://clang.llvm.org/docs/)
- [iOS Deployment Target](https://developer.apple.com/documentation/xcode/configuring-the-build-settings-of-a-target)
