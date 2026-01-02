# Flutter FFI Practical Study

A comprehensive, hands-on study of Flutter FFI (Foreign Function Interface) integration with native C and C++ libraries on Android and iOS.

## Overview

This project demonstrates two essential FFI binding patterns through complete, working examples:

### **Part 1: Easy Binding** (FFI-Friendly C API)
- Simple C library with basic types (`int`, `double`) and POD structs
- Direct FFI compatibility - no wrappers needed
- **Examples**: Math operations, struct manipulation, function calls
- **Best for**: Simple algorithms, stateless functions, performance-critical code

### **Part 2: Complex Binding** (C++ with C Wrapper)
- C++ library using `std::string`, `std::vector`, and class methods
- Exposed via C API wrapper for FFI compatibility
- Opaque handle pattern for object lifetime management
- **Examples**: Stateful operations, complex computations, resource management
- **Best for**: Reusing existing C++ libraries, object-oriented designs

## Quick Start (5 minutes)

### Prerequisites
- Flutter SDK
- Android NDK + CMake (for Android)
- Xcode (for iOS)

### Build & Run

```bash
# Get dependencies
flutter pub get

# Run on Android/iOS
flutter run

# Release build
flutter build apk    # Android
flutter build ios    # iOS
```

## Project Structure

```
lib/
├── bindings/              # FFI type mappings and native function loading
│   ├── math_lib_bindings.dart
│   └── calculator_bindings.dart
├── screens/               # Flutter UI examples for testing
│   ├── part1_easy_binding.dart
│   └── part2_cpp_wrapper.dart
└── main.dart

android/src/main/cpp/     # Native C/C++ source code
├── math_lib.h/c           # Part 1: Simple C library
├── calculator.hpp/cpp     # Part 2: C++ implementation
├── calculator_c_api.h/cpp # Part 2: C wrapper API
└── CMakeLists.txt

ios/Runner/Native/        # Copy native files here for iOS build
```

## Key Learning Outcomes

- ✅ Identify when a native library is "FFI-friendly"
- ✅ Create FFI bindings for C functions with Dart
- ✅ Handle POD structs between Dart and C
- ✅ Wrap non-trivial C++ code for FFI consumption
- ✅ Manage object lifetime with opaque handles
- ✅ Build native libraries for Android (NDK/CMake)
- ✅ Build native libraries for iOS (Xcode)
- ✅ Handle memory allocation/deallocation across language boundaries

## Documentation

### Essential Reading
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Design decisions, patterns, and explanations
- **[BUILD_INSTRUCTIONS.md](./BUILD_INSTRUCTIONS.md)** - Step-by-step Android/iOS build guide
- **[iOS_SETUP.md](./iOS_SETUP.md)** - Detailed iOS configuration and troubleshooting

### Code Comments
Each native file is documented with comments explaining:
- Why types are chosen (FFI-compatible or not)
- How to properly allocate/free memory
- Expected caller responsibilities
- Error handling strategies

## Part 1: Easy Binding Example

**C Code** (FFI-compatible):
```c
typedef struct { double x; double y; } Point;
Point add_points(Point a, Point b);
```

**Dart Binding**:
```dart
final class Point extends Struct {
  @Double() external double x;
  @Double() external double y;
}
typedef AddPointsDart = Point Function(Point, Point);
```

**Usage**:
```dart
final p1 = Struct.create<Point>();
p1.x = 1.0; p1.y = 2.0;
final result = MathLib.addPoints(p1, p2);
```

## Part 2: Complex Binding Example

**C++ Implementation** (Not FFI-friendly):
```cpp
class Calculator {
  std::string name;
  std::vector<double> history;
  double average(const std::vector<double>& values);
};
```

**C Wrapper** (FFI-friendly):
```c
typedef void* CalculatorHandle;
CalculatorHandle calculator_new(const char* name);
double calculator_average(CalculatorHandle h, const double* values, int length);
void calculator_free(CalculatorHandle h);
```

**Dart Binding & Usage**:
```dart
final calc = Calculator("MyCalc");
final avg = calc.average([1.5, 2.3, 3.1]);
calc.dispose();  // Cleanup
```

## Build Configuration

### Android
- **Build system**: CMake
- **C++ Standard**: C++17
- **Target architectures**: arm64-v8a, armeabi-v7a (configurable)
- **CMakeLists.txt**: Configures compilation of both libraries

### iOS
- **Method**: Xcode build system
- **C++ Standard**: C++17
- **Files location**: ios/Runner/Native/
- **Linking**: Statically linked into app binary

## Testing & Examples

The app includes interactive UI for testing both parts:

### Part 1 Tests
- Basic arithmetic (add, subtract, multiply, divide)
- Geometric operations (hypotenuse, circle area)
- Factorial calculation
- Point struct operations

### Part 2 Tests
- Calculator creation with names
- Arithmetic with operation counting
- Statistical operations (average, min, max)
- String descriptions with memory management

## Important Concepts

### FFI-Friendly Types
✅ `int`, `double`, `float`, `bool`, `void*`
✅ POD structs with primitive fields
✅ C function pointers
❌ `std::string`, `std::vector`
❌ Classes, virtual methods
❌ Exceptions

### Memory Management Patterns
- **Stack allocation**: Use for small, temporary data
- **Caller allocation**: C code responsible for freeing
- **Handle-based**: Opaque pointers managed by wrapper

### Error Handling
- Return values for simple errors (0 = error, -1 = ok)
- Operation counting for debugging
- String descriptions with explicit cleanup

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| "Symbol not found" on iOS | Verify files added to Xcode target |
| C++17 errors | Set C++ Language Dialect to c++17 in build settings |
| NDK not found (Android) | Set ndk.dir in android/local.properties |
| Malloc/free crashes | Ensure matching memory allocation/deallocation sites |

See detailed troubleshooting in [BUILD_INSTRUCTIONS.md](./BUILD_INSTRUCTIONS.md) and [iOS_SETUP.md](./iOS_SETUP.md).

## Performance Notes

- C function calls: ~50-100ns (negligible)
- Struct passing: Very fast (stack-allocated)
- Memory allocation: ~1-10μs (avoid in tight loops)
- Recommend batching operations where possible

## Production Recommendations

1. **Error handling**: Use return codes or error callbacks
2. **ABI versioning**: Include version info in C API
3. **Testing**: Add unit tests for native code
4. **Profiling**: Use Android Studio Profiler and Xcode Instruments
5. **Code signing**: Configure proper signing for iOS distribution
6. **Visibility**: Use `-fvisibility=hidden` in production

## References

- [Dart FFI Documentation](https://dart.dev/guides/libraries/c-interop)
- [Flutter Platform Integration](https://flutter.dev/docs/development/platform-integration/c-interop)
- [Android NDK Documentation](https://developer.android.com/ndk/docs)
- [Xcode Documentation](https://help.apple.com/xcode/)
- [C++ ABI Stability](https://gcc.gnu.org/onlinedocs/libstdc++/manual/abi.html)

## Project Status

✅ Part 1: Easy binding (C) - Complete and working
✅ Part 2: Complex binding (C++ wrapper) - Complete and working
✅ Android build system (CMake) - Configured
✅ iOS setup guide - Comprehensive instructions
✅ Dart FFI bindings - Full implementation
✅ Flutter UI examples - Interactive testing interface

## License

MIT License - Free for educational and commercial use.

## Author

Created as a practical study guide for Flutter FFI integration.

---

**Quick Links**:
- [Architecture & Design](./ARCHITECTURE.md)
- [Build Instructions](./BUILD_INSTRUCTIONS.md)
- [iOS Setup Guide](./iOS_SETUP.md)
- [Dart FFI Docs](https://dart.dev/guides/libraries/c-interop)
