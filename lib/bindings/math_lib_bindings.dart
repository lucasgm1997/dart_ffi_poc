// lib/bindings/math_lib_bindings.dart
// FFI bindings for math_lib.c - Part 1: Easy binding example

import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

// ============================================================================
// FFI Type Definitions (matching C API in math_lib.h)
// ============================================================================

// POD struct: typedef struct { double x; double y; } Point;
final class Point extends ffi.Struct {
  @ffi.Double()
  external double x;

  @ffi.Double()
  external double y;

  @override
  String toString() => 'Point(x: $x, y: $y)';
}

// ============================================================================
// FFI Function Declarations
// ============================================================================

typedef AddC = ffi.Int32 Function(ffi.Int32, ffi.Int32);
typedef AddDart = int Function(int, int);

typedef SubtractC = ffi.Int32 Function(ffi.Int32, ffi.Int32);
typedef SubtractDart = int Function(int, int);

typedef MultiplyC = ffi.Int32 Function(ffi.Int32, ffi.Int32);
typedef MultiplyDart = int Function(int, int);

typedef DivideC = ffi.Double Function(ffi.Double, ffi.Double);
typedef DivideDart = double Function(double, double);

typedef HypotenuseC = ffi.Double Function(ffi.Double, ffi.Double);
typedef HypotenuseDart = double Function(double, double);

typedef CircleAreaC = ffi.Double Function(ffi.Double);
typedef CircleAreaDart = double Function(double);

typedef FactorialC = ffi.Int32 Function(ffi.Int32);
typedef FactorialDart = int Function(int);

typedef AddPointsC = Point Function(Point, Point);
typedef AddPointsDart = Point Function(Point, Point);

typedef ScalePointC = Point Function(Point, ffi.Double);
typedef ScalePointDart = Point Function(Point, double);

typedef PointDistanceC = ffi.Double Function(Point, Point);
typedef PointDistanceDart = double Function(Point, Point);

// ============================================================================
// Native Library Loader
// ============================================================================

late ffi.DynamicLibrary _nativeLib;
bool _initialized = false;

ffi.DynamicLibrary _loadNativeLibrary() {
  try {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('libmath_lib.so');
    } else if (Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    } else {
      throw UnsupportedError(
        'Unsupported platform: ${Platform.operatingSystem}',
      );
    }
  } catch (e) {
    throw Exception('Failed to load native library: $e');
  }
}

void _initializeLibrary() {
  if (_initialized) {
    return; // Already initialized
  }

  try {
    _nativeLib = _loadNativeLibrary();
    _initialized = true;
  } catch (e) {
    _initialized = false;
    rethrow;
  }
}

// ============================================================================
// FFI Function Bindings - Wrapper Class
// ============================================================================

class MathLib {
  static late AddDart add;
  static late SubtractDart subtract;
  static late MultiplyDart multiply;
  static late DivideDart divide;
  static late HypotenuseDart hypotenuse;
  static late CircleAreaDart circleArea;
  static late FactorialDart factorial;
  static late AddPointsDart addPoints;
  static late ScalePointDart scalePoint;
  static late PointDistanceDart pointDistance;

  /// Initialize the native library and load all functions
  /// Call this once at app startup, before using any native functions
  static Future<void> initialize() async {
    if (_initialized) {
      return; // Already initialized
    }

    try {
      _initializeLibrary();

      add = _nativeLib.lookupFunction<AddC, AddDart>('add');
      subtract = _nativeLib.lookupFunction<SubtractC, SubtractDart>('subtract');
      multiply = _nativeLib.lookupFunction<MultiplyC, MultiplyDart>('multiply');
      divide = _nativeLib.lookupFunction<DivideC, DivideDart>('divide');
      hypotenuse = _nativeLib.lookupFunction<HypotenuseC, HypotenuseDart>(
        'hypotenuse',
      );
      circleArea = _nativeLib.lookupFunction<CircleAreaC, CircleAreaDart>(
        'circle_area',
      );
      factorial = _nativeLib.lookupFunction<FactorialC, FactorialDart>(
        'factorial',
      );
      addPoints = _nativeLib.lookupFunction<AddPointsC, AddPointsDart>(
        'add_points',
      );
      scalePoint = _nativeLib.lookupFunction<ScalePointC, ScalePointDart>(
        'scale_point',
      );
      pointDistance = _nativeLib
          .lookupFunction<PointDistanceC, PointDistanceDart>('point_distance');
    } catch (e) {
      _initialized = false;
      throw Exception('Failed to initialize MathLib: $e');
    }
  }

  /// Check if the library has been initialized
  static bool get isInitialized => _initialized;
}
