// lib/screens/part2_cpp_wrapper.dart
// UI Example for Part 2: Complex Binding with C++ and C Wrapper

import 'dart:ffi' as ffi;
import 'package:flutter/material.dart';
import 'package:ffi/ffi.dart' as ffi_lib;

import '../bindings/calculator_bindings.dart';

class Part2CppWrapperScreen extends StatefulWidget {
  const Part2CppWrapperScreen({super.key});

  @override
  State<Part2CppWrapperScreen> createState() => _Part2CppWrapperScreenState();
}

class _Part2CppWrapperScreenState extends State<Part2CppWrapperScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'MyCalc',
  );
  final TextEditingController _aController = TextEditingController(text: '10');
  final TextEditingController _bController = TextEditingController(text: '5');
  final TextEditingController _valuesController = TextEditingController(
    text: '1.5 2.3 3.1 4.8 5.2',
  );

  CalculatorHandle? _currentCalc;
  String _resultSum = '';
  String _resultProduct = '';
  String _resultDivide = '';
  String _resultAverage = '';
  String _resultMax = '';
  String _resultMin = '';
  String _resultDescription = '';
  String _resultOperationCount = '';

  @override
  void initState() {
    super.initState();
    _initializeNativeLibrary();
  }

  Future<void> _initializeNativeLibrary() async {
    try {
      await CalculatorLib.initialize();
      _log('Calculator library initialized successfully');
    } catch (e) {
      _log('Error initializing library: $e');
      setState(() {
        _resultDescription = 'ERROR: Failed to initialize native library: $e';
      });
    }
  }

  void _log(String message) {
    debugPrint('[Part2] $message');
  }

  void _createCalculator() {
    try {
      // Free existing calculator if any
      if (_currentCalc != null) {
        CalculatorLib.calculatorFree(_currentCalc!);
        _currentCalc = null;
      }

      // Create new calculator with the given name
      final name = _nameController.text;
      final namePtr = name.toNativeUtf8();
      _currentCalc = CalculatorLib.calculatorNew(namePtr.cast());
      ffi_lib.malloc.free(namePtr);

      setState(() {
        _resultDescription = 'Calculator "${_nameController.text}" created!';
      });
      _log('Created calculator: $name');
    } catch (e) {
      setState(() {
        _resultDescription = 'Error creating calculator: $e';
      });
    }
  }

  void _testSum() {
    if (_currentCalc == null) {
      _showError('Create a calculator first!');
      return;
    }

    try {
      final a = int.parse(_aController.text);
      final b = int.parse(_bController.text);
      final result = CalculatorLib.calculatorSum(_currentCalc!, a, b);
      setState(() {
        _resultSum = '$a + $b = $result';
      });
      _log('sum($a, $b) = $result');
      _updateDescription();
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _testProduct() {
    if (_currentCalc == null) {
      _showError('Create a calculator first!');
      return;
    }

    try {
      final a = int.parse(_aController.text);
      final b = int.parse(_bController.text);
      final result = CalculatorLib.calculatorProduct(_currentCalc!, a, b);
      setState(() {
        _resultProduct = '$a × $b = $result';
      });
      _log('product($a, $b) = $result');
      _updateDescription();
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _testDivide() {
    if (_currentCalc == null) {
      _showError('Create a calculator first!');
      return;
    }

    try {
      final a = double.parse(_aController.text);
      final b = double.parse(_bController.text);
      final result = CalculatorLib.calculatorDivide(_currentCalc!, a, b);
      setState(() {
        _resultDivide = '$a ÷ $b = ${result.toStringAsFixed(2)}';
      });
      _log('divide($a, $b) = $result');
      _updateDescription();
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _testStatistics() {
    if (_currentCalc == null) {
      _showError('Create a calculator first!');
      return;
    }

    try {
      // Parse the values
      final valuesStr = _valuesController.text;
      final valuesList = valuesStr
          .split(' ')
          .map((v) => double.parse(v))
          .toList();

      // Allocate native double array
      final valuesPtr = ffi_lib.calloc<ffi.Double>(valuesList.length);
      for (int i = 0; i < valuesList.length; i++) {
        valuesPtr[i] = valuesList[i];
      }

      // Calculate statistics
      final avg = CalculatorLib.calculatorAverage(
        _currentCalc!,
        valuesPtr,
        valuesList.length,
      );
      final max = CalculatorLib.calculatorMax(
        _currentCalc!,
        valuesPtr,
        valuesList.length,
      );
      final min = CalculatorLib.calculatorMin(
        _currentCalc!,
        valuesPtr,
        valuesList.length,
      );

      // Free the allocated memory
      ffi_lib.malloc.free(valuesPtr);

      setState(() {
        _resultAverage = 'Average: ${avg.toStringAsFixed(4)}';
        _resultMax = 'Max: ${max.toStringAsFixed(4)}';
        _resultMin = 'Min: ${min.toStringAsFixed(4)}';
      });
      _log('Statistics - Avg: $avg, Max: $max, Min: $min');
      _updateDescription();
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _updateDescription() {
    if (_currentCalc == null) return;

    try {
      final descPtr = CalculatorLib.calculatorDescription(_currentCalc!);
      final description = descPtr.cast<ffi_lib.Utf8>().toDartString();
      CalculatorLib.calculatorFreeString(descPtr);

      setState(() {
        _resultDescription = description;
      });
      _log('Description: $description');
    } catch (e) {
      _log('Error getting description: $e');
    }
  }

  void _getOperationCount() {
    if (_currentCalc == null) {
      _showError('Create a calculator first!');
      return;
    }

    try {
      final count = CalculatorLib.calculatorGetOperationCount(_currentCalc!);
      setState(() {
        _resultOperationCount = 'Total operations: $count';
      });
      _log('Operation count: $count');
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      _resultDescription = message;
    });
  }

  @override
  void dispose() {
    // Clean up the calculator instance
    if (_currentCalc != null) {
      CalculatorLib.calculatorFree(_currentCalc!);
      _currentCalc = null;
    }

    _nameController.dispose();
    _aController.dispose();
    _bController.dispose();
    _valuesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Part 2: Complex Binding (C++ with C Wrapper)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Demonstrates FFI binding to a C++ library exposed via a C API wrapper. '
            'The library uses std::string, std::vector, and class methods internally.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // Calculator creation
          const Text(
            'Create Calculator:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    label: Text('Calculator name'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _createCalculator,
                child: const Text('Create'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_resultDescription.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _resultDescription,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 24),
          // Input parameters
          const Text(
            'Input Parameters:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _aController,
                  decoration: const InputDecoration(
                    label: Text('a'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _bController,
                  decoration: const InputDecoration(
                    label: Text('b'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valuesController,
            decoration: const InputDecoration(
              label: Text('Values (space-separated)'),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          // Arithmetic operations
          const Text(
            'Arithmetic Operations:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _testSum,
                  child: const Text('Sum'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _testProduct,
                  child: const Text('Product'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _testDivide,
                  child: const Text('Divide'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_resultSum.isNotEmpty)
            Text(
              _resultSum,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (_resultProduct.isNotEmpty)
            Text(
              _resultProduct,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (_resultDivide.isNotEmpty)
            Text(
              _resultDivide,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 24),
          // Statistics
          const Text(
            'Statistics:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _testStatistics,
            child: const Text('Calculate Statistics'),
          ),
          const SizedBox(height: 8),
          if (_resultAverage.isNotEmpty)
            Text(
              _resultAverage,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (_resultMax.isNotEmpty)
            Text(
              _resultMax,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (_resultMin.isNotEmpty)
            Text(
              _resultMin,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 24),
          // Utility
          const Text('Utility:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _getOperationCount,
            child: const Text('Get Operation Count'),
          ),
          const SizedBox(height: 8),
          if (_resultOperationCount.isNotEmpty)
            Text(
              _resultOperationCount,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
