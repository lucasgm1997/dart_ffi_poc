# Flutter FFI PoC - Architecture Documentation

This document explains the architecture and design decisions of the Flutter FFI Practical Study project.

## Project Structure

```
dart_ffi_poc/
├── android/
│   └── src/main/cpp/           # Native C/C++ source files
│       ├── math_lib.h          # Part 1: Simple C API header
│       ├── math_lib.c          # Part 1: Implementation
│       ├── calculator.hpp      # Part 2: C++ class (NOT FFI-friendly)
│       ├── calculator.cpp      # Part 2: C++ implementation
│       ├── calculator_c_api.h  # Part 2: C wrapper API header
│       ├── calculator_c_api.cpp# Part 2: C wrapper implementation
│       └── CMakeLists.txt      # Build configuration
│
├── ios/
│   └── Runner/
│       └── Native/             # Copy C/C++ files here for iOS
│
├── lib/
│   ├── bindings/               # FFI bindings from Dart to native
│   │   ├── math_lib_bindings.dart
│   │   └── calculator_bindings.dart
│   │
│   ├── screens/                # Flutter UI examples
│   │   ├── part1_easy_binding.dart
│   │   └── part2_cpp_wrapper.dart
│   │
│   └── main.dart              # App entry point and navigation
│
├── BUILD_INSTRUCTIONS.md       # Step-by-step build guide
├── ARCHITECTURE.md             # This file
└── README.md                   # Project overview
```

## Part 1: Easy Binding (FFI-Friendly C API)

### Why "FFI-Friendly"?

The C API in `math_lib.h` uses only types that map directly to Dart FFI types:

```c
// ✓ FFI-friendly types
int add(int a, int b);           // int32 ↔ Int32
double hypotenuse(double a, double b);  // f64 ↔ Double

// ✓ POD struct
typedef struct { double x; double y; } Point;  // maps to Struct in Dart
```

### Design Decisions

**No opaque pointers**: All data structures are value types or POD structs. Dart creates/manages them directly.

**No string handling**: Functions don't return strings (complicates ABI). If needed, return length + pointer.

**No dynamic memory**: All allocations are stack-based or managed by the caller.

### Dart Binding Pattern

```dart
// 1. Define typedef for C function signature
typedef AddC = int32 Function(int32, int32);

// 2. Map to Dart type
typedef AddDart = int Function(int, int);

// 3. Look up function in native library
late AddDart add = nativeLib.lookupFunction<AddC, AddDart>('add');

// 4. Use directly
int result = add(5, 3);  // result = 8
```

### Struct Example

```dart
// Dart side - mirrors C struct
final class Point extends Struct {
  @Double()
  external double x;

  @Double()
  external double y;
}

// C side
typedef Point Function(Point, Point);
```

## Part 2: Complex Binding (C++ with C Wrapper)

### The Problem with Direct C++ Binding

C++ features that break FFI compatibility:

| Feature | Problem | Solution |
|---------|---------|----------|
| `std::string` | Non-standard memory layout, not ABI-stable | Use `const char*` + `malloc`/`free` |
| `std::vector` | Templated, non-standard size/alignment | Use `double* array + int length` |
| Classes | Virtual tables, member layout not guaranteed | Use opaque `void*` handle pattern |
| Exceptions | FFI doesn't support C++ exceptions | Check return values, use error codes |
| Templates | Monomorphized at compile-time, no runtime type info | Instantiate specific types in C++ |

### The Solution: C API Wrapper

Instead of exposing C++ directly:

```cpp
// C++ Implementation (calculator.hpp)
class Calculator {
  std::string name_;
  std::vector<double> history_;

  double average(const std::vector<double>& values);
};

// C Wrapper (calculator_c_api.h)
extern "C" {
  typedef void* CalculatorHandle;

  CalculatorHandle calculator_new(const char* name);
  void calculator_free(CalculatorHandle h);
  double calculator_average(CalculatorHandle h, const double* values, int length);
};
```

### Design Principles

**1. Opaque Handles**
```cpp
// Internally: Cast to C++ object
Calculator* calc = static_cast<Calculator*>(handle);

// From Dart: Just a Pointer<Void>
typedef CalculatorHandle = Pointer<Void>;
```

**2. Explicit Memory Management**
```cpp
// C wrapper handles allocation/deallocation
const char* calculator_description(CalculatorHandle h) {
    std::string desc = calc->description();
    char* result = malloc(desc.length() + 1);
    strcpy(result, desc.c_str());
    return result;  // Caller must free
}

void calculator_free_string(const char* str) {
    free(const_cast<char*>(str));
}
```

**3. Array Parameters Instead of Vectors**
```cpp
// C++ original: std::vector<double>
double average(const std::vector<double>& values);

// C wrapper: C-style array
double calculator_average(CalculatorHandle h, const double* values, int length) {
    std::vector<double> vec(values, values + length);
    return h->average(vec);
}
```

### Dart Binding Pattern

```dart
// 1. Define raw FFI types
typedef CalculatorNewC = Pointer<Void> Function(Pointer<Char>);
typedef CalculatorNewDart = Pointer<Void> Function(Pointer<Char>);

// 2. Load function
late CalculatorNewDart calculatorNew =
    lib.lookupFunction<CalculatorNewC, CalculatorNewDart>('calculator_new');

// 3. Wrap in higher-level Dart class for ergonomics
class Calculator {
  final Pointer<Void> _handle;

  Calculator(String name) {
    final namePtr = name.toNativeUtf8();
    _handle = calculatorNew(namePtr.cast());
    malloc.free(namePtr);
  }

  double average(List<double> values) {
    final ptr = malloc<Double>(values.length);
    for (int i = 0; i < values.length; i++) {
      ptr[i] = values[i];
    }
    final result = calculatorAverage(_handle, ptr, values.length);
    malloc.free(ptr);
    return result;
  }

  void dispose() => calculatorFree(_handle);
}
```

## Memory Management Patterns

### Part 1: Stack Allocation
```dart
final point = Struct.create<Point>();
point.x = 1.0;
point.y = 2.0;
// Automatic cleanup on scope exit
```

### Part 2: Explicit Handle-Based Lifecycle
```dart
final calc = Calculator("MyCalc");

// Use calculator...
calc.sum(5, 3);

// Manual cleanup required
calc.dispose();  // Calls calculator_free
```

## Thread Safety

### Current Implementation: Single-Threaded

- No synchronization primitives used
- Safe for single-threaded Dart/Flutter execution
- For multi-threaded access: add mutexes in C++ code, expose through C API

### Example: Thead-Safe Wrapper

```cpp
// In calculator_c_api.cpp
#include <mutex>

static std::mutex calc_mutex;

double calculator_average(CalculatorHandle h, const double* values, int length) {
    std::lock_guard<std::mutex> lock(calc_mutex);
    Calculator* calc = static_cast<Calculator*>(h);
    // ... rest of function
}
```

## Error Handling

### Part 1: Simple Return Values
```c
double divide(double a, double b) {
    if (b == 0.0) return 0.0;  // Error convention
    return a / b;
}
```

### Part 2: Operation Counting
```cpp
// Track operations for debugging
int calculator_get_operation_count(CalculatorHandle h) {
    return static_cast<Calculator*>(h)->get_operation_count();
}
```

**Production**: Would add error codes/exceptions:
```c
// Better error handling
typedef enum {
    CALC_OK = 0,
    CALC_NULL_HANDLE = 1,
    CALC_INVALID_INPUT = 2,
    CALC_MEMORY_ERROR = 3
} calc_error_t;

calc_error_t calculator_average(
    CalculatorHandle h,
    const double* values,
    int length,
    double* out_result
);
```

## Performance Considerations

### Function Call Overhead

- **C functions**: ~50-100ns (negligible for most use cases)
- **Struct passing**: Stack-allocated, very fast
- **Memory allocation**: `malloc`/`free` ~1-10μs (avoid in tight loops)

### Optimization Strategies

1. **Batch operations**: Call native code once per batch, not per item
2. **Allocate once, reuse**: For example, allocate double array once, reuse for multiple calculations
3. **Minimize string conversions**: Cache converted strings when possible
4. **Profile first**: Use Android Studio Profiler or Xcode Instruments

## Future Extensions

### 1. Error Codes

```cpp
typedef enum { OK = 0, ERROR = 1 } result_t;

result_t safe_divide(double a, double b, double* out) {
    if (b == 0) return ERROR;
    *out = a / b;
    return OK;
}
```

### 2. Callbacks

```c
// Progress callback during long operations
typedef void (*progress_callback)(int percent, void* user_data);

result_t long_operation(progress_callback cb, void* user_data);
```

### 3. Resource Management

```c
// Explicit resource cleanup
typedef void* ResourceHandle;
ResourceHandle resource_acquire();
void resource_release(ResourceHandle h);
```

### 4. Version Management

```c
const char* native_lib_version();
int native_lib_abi_version();  // For binary compatibility checking
```

## Building Production Code

### Recommendations

1. **Use `-fvisibility=hidden`** in CMakeLists.txt to hide internal symbols
2. **Add ABI version info** for forward compatibility
3. **Implement error callbacks** for debugging
4. **Use valgrind** or ASAN to check for memory leaks
5. **Add comprehensive tests** for C/C++ code
6. **Document assumptions** about caller responsibilities (memory, threading)
7. **Version the C API** separately from implementation

### Example Production CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.10)
project(calculator)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

# Enable sanitizers for testing
if(BUILD_WITH_ASAN)
  add_compile_options(-fsanitize=address -fsanitize=undefined)
  add_link_options(-fsanitize=address -fsanitize=undefined)
endif()

add_library(calculator SHARED
  calculator.cpp
  calculator_c_api.cpp
)

# Version information
set_target_properties(calculator PROPERTIES
  VERSION 1.0.0
  SOVERSION 1
)
```

## References

- [Dart FFI Documentation](https://dart.dev/guides/libraries/c-interop)
- [Flutter Platform Channels](https://flutter.dev/docs/development/platform-integration)
- [C++ ABI Stability](https://gcc.gnu.org/onlinedocs/libstdc++/manual/abi.html)
- [Memory Management Best Practices](https://www.cplusplus.com/articles/DEN36Up4/)
