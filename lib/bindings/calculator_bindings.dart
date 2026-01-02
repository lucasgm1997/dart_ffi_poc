// lib/bindings/calculator_bindings.dart
// FFI bindings for calculator_c_api.c - Part 2: Complex binding with C++ wrapper

import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';

// ============================================================================
// FFI Type Definitions (matching C API in calculator_c_api.h)
// ============================================================================

// Opaque handle: typedef void* CalculatorHandle;
typedef CalculatorHandle = ffi.Pointer<ffi.Void>;

// ============================================================================
// FFI Function Declarations
// ============================================================================

// CalculatorHandle calculator_new(const char* name);
typedef CalculatorNewC = CalculatorHandle Function(ffi.Pointer<ffi.Char>);
typedef CalculatorNewDart = CalculatorHandle Function(ffi.Pointer<ffi.Char>);

// void calculator_free(CalculatorHandle handle);
typedef CalculatorFreeC = ffi.Void Function(CalculatorHandle);
typedef CalculatorFreeDart = void Function(CalculatorHandle);

// int calculator_sum(CalculatorHandle handle, int a, int b);
typedef CalculatorSumC = ffi.Int32 Function(
    CalculatorHandle, ffi.Int32, ffi.Int32);
typedef CalculatorSumDart = int Function(CalculatorHandle, int, int);

// int calculator_product(CalculatorHandle handle, int a, int b);
typedef CalculatorProductC = ffi.Int32 Function(
    CalculatorHandle, ffi.Int32, ffi.Int32);
typedef CalculatorProductDart = int Function(CalculatorHandle, int, int);

// double calculator_divide(CalculatorHandle handle, double a, double b);
typedef CalculatorDivideC = ffi.Double Function(
    CalculatorHandle, ffi.Double, ffi.Double);
typedef CalculatorDivideDart = double Function(
    CalculatorHandle, double, double);

// double calculator_average(CalculatorHandle handle, const double* values, int length);
typedef CalculatorAverageC = ffi.Double Function(
    CalculatorHandle, ffi.Pointer<ffi.Double>, ffi.Int32);
typedef CalculatorAverageDart = double Function(
    CalculatorHandle, ffi.Pointer<ffi.Double>, int);

// double calculator_max(CalculatorHandle handle, const double* values, int length);
typedef CalculatorMaxC = ffi.Double Function(
    CalculatorHandle, ffi.Pointer<ffi.Double>, ffi.Int32);
typedef CalculatorMaxDart = double Function(
    CalculatorHandle, ffi.Pointer<ffi.Double>, int);

// double calculator_min(CalculatorHandle handle, const double* values, int length);
typedef CalculatorMinC = ffi.Double Function(
    CalculatorHandle, ffi.Pointer<ffi.Double>, ffi.Int32);
typedef CalculatorMinDart = double Function(
    CalculatorHandle, ffi.Pointer<ffi.Double>, int);

// const char* calculator_description(CalculatorHandle handle);
typedef CalculatorDescriptionC = ffi.Pointer<ffi.Char> Function(
    CalculatorHandle);
typedef CalculatorDescriptionDart = ffi.Pointer<ffi.Char> Function(
    CalculatorHandle);

// void calculator_free_string(const char* str);
typedef CalculatorFreeStringC = ffi.Void Function(ffi.Pointer<ffi.Char>);
typedef CalculatorFreeStringDart = void Function(ffi.Pointer<ffi.Char>);

// int calculator_get_operation_count(CalculatorHandle handle);
typedef CalculatorGetOperationCountC = ffi.Int32 Function(CalculatorHandle);
typedef CalculatorGetOperationCountDart = int Function(CalculatorHandle);

// ============================================================================
// Native Library Loader
// ============================================================================

late ffi.DynamicLibrary _nativeLib;

ffi.DynamicLibrary _loadNativeLibrary() {
  if (Platform.isAndroid) {
    return ffi.DynamicLibrary.open('libcalculator.so');
  } else if (Platform.isIOS) {
    return ffi.DynamicLibrary.process();
  } else {
    throw UnsupportedError('Unsupported platform');
  }
}

void _initializeLibrary() {
  _nativeLib = _loadNativeLibrary();
}

// ============================================================================
// FFI Function Bindings - Wrapper Class
// ============================================================================

class CalculatorLib {
  static late CalculatorNewDart calculatorNew;
  static late CalculatorFreeDart calculatorFree;
  static late CalculatorSumDart calculatorSum;
  static late CalculatorProductDart calculatorProduct;
  static late CalculatorDivideDart calculatorDivide;
  static late CalculatorAverageDart calculatorAverage;
  static late CalculatorMaxDart calculatorMax;
  static late CalculatorMinDart calculatorMin;
  static late CalculatorDescriptionDart calculatorDescription;
  static late CalculatorFreeStringDart calculatorFreeString;
  static late CalculatorGetOperationCountDart calculatorGetOperationCount;

  static void initialize() {
    _initializeLibrary();

    calculatorNew =
        _nativeLib.lookupFunction<CalculatorNewC, CalculatorNewDart>(
            'calculator_new');
    calculatorFree =
        _nativeLib.lookupFunction<CalculatorFreeC, CalculatorFreeDart>(
            'calculator_free');
    calculatorSum = _nativeLib
        .lookupFunction<CalculatorSumC, CalculatorSumDart>('calculator_sum');
    calculatorProduct = _nativeLib.lookupFunction<CalculatorProductC,
        CalculatorProductDart>('calculator_product');
    calculatorDivide = _nativeLib.lookupFunction<CalculatorDivideC,
        CalculatorDivideDart>('calculator_divide');
    calculatorAverage = _nativeLib.lookupFunction<CalculatorAverageC,
        CalculatorAverageDart>('calculator_average');
    calculatorMax = _nativeLib
        .lookupFunction<CalculatorMaxC, CalculatorMaxDart>('calculator_max');
    calculatorMin = _nativeLib
        .lookupFunction<CalculatorMinC, CalculatorMinDart>('calculator_min');
    calculatorDescription = _nativeLib.lookupFunction<
        CalculatorDescriptionC,
        CalculatorDescriptionDart>('calculator_description');
    calculatorFreeString = _nativeLib.lookupFunction<
        CalculatorFreeStringC,
        CalculatorFreeStringDart>('calculator_free_string');
    calculatorGetOperationCount = _nativeLib.lookupFunction<
        CalculatorGetOperationCountC,
        CalculatorGetOperationCountDart>('calculator_get_operation_count');
  }
}
