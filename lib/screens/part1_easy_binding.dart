// lib/screens/part1_easy_binding.dart
// UI Example for Part 1: Easy Binding with FFI-friendly C API

import 'dart:ffi' as ffi;
import 'package:flutter/material.dart';

import '../bindings/math_lib_bindings.dart';

class Part1EasyBindingScreen extends StatefulWidget {
  const Part1EasyBindingScreen({Key? key}) : super(key: key);

  @override
  State<Part1EasyBindingScreen> createState() => _Part1EasyBindingScreenState();
}

class _Part1EasyBindingScreenState extends State<Part1EasyBindingScreen> {
  final TextEditingController _aController = TextEditingController(text: '5');
  final TextEditingController _bController = TextEditingController(text: '3');
  final TextEditingController _radiusController = TextEditingController(
    text: '5.0',
  );
  final TextEditingController _nController = TextEditingController(text: '5');

  String _resultAdd = '';
  String _resultSubtract = '';
  String _resultMultiply = '';
  String _resultDivide = '';
  String _resultHypotenuse = '';
  String _resultCircleArea = '';
  String _resultFactorial = '';
  String _resultPoint = '';

  @override
  void initState() {
    super.initState();
    _initializeNativeLibrary();
  }

  Future<void> _initializeNativeLibrary() async {
    try {
      await MathLib.initialize();
      _log('Native library initialized successfully');
    } catch (e) {
      _log('Error initializing library: $e');
      setState(() {
        _resultAdd = 'ERROR: Failed to initialize native library: $e';
      });
    }
  }

  void _log(String message) {
    debugPrint('[Part1] $message');
  }

  void _testAdd() {
    try {
      final a = int.parse(_aController.text);
      final b = int.parse(_bController.text);
      final result = MathLib.add(a, b);
      setState(() {
        _resultAdd = '$a + $b = $result';
      });
      _log('add($a, $b) = $result');
    } catch (e) {
      setState(() {
        _resultAdd = 'Error: $e';
      });
    }
  }

  void _testSubtract() {
    try {
      final a = int.parse(_aController.text);
      final b = int.parse(_bController.text);
      final result = MathLib.subtract(a, b);
      setState(() {
        _resultSubtract = '$a - $b = $result';
      });
      _log('subtract($a, $b) = $result');
    } catch (e) {
      setState(() {
        _resultSubtract = 'Error: $e';
      });
    }
  }

  void _testMultiply() {
    try {
      final a = int.parse(_aController.text);
      final b = int.parse(_bController.text);
      final result = MathLib.multiply(a, b);
      setState(() {
        _resultMultiply = '$a × $b = $result';
      });
      _log('multiply($a, $b) = $result');
    } catch (e) {
      setState(() {
        _resultMultiply = 'Error: $e';
      });
    }
  }

  void _testDivide() {
    try {
      final a = double.parse(_aController.text);
      final b = double.parse(_bController.text);
      final result = MathLib.divide(a, b);
      setState(() {
        _resultDivide = '$a ÷ $b = ${result.toStringAsFixed(2)}';
      });
      _log('divide($a, $b) = $result');
    } catch (e) {
      setState(() {
        _resultDivide = 'Error: $e';
      });
    }
  }

  void _testHypotenuse() {
    try {
      final a = double.parse(_aController.text);
      final b = double.parse(_bController.text);
      final result = MathLib.hypotenuse(a, b);
      setState(() {
        _resultHypotenuse = 'hypotenuse($a, $b) = ${result.toStringAsFixed(4)}';
      });
      _log('hypotenuse($a, $b) = $result');
    } catch (e) {
      setState(() {
        _resultHypotenuse = 'Error: $e';
      });
    }
  }

  void _testCircleArea() {
    try {
      final radius = double.parse(_radiusController.text);
      final result = MathLib.circleArea(radius);
      setState(() {
        _resultCircleArea =
            'Area of circle (r=$radius) = ${result.toStringAsFixed(4)}';
      });
      _log('circleArea($radius) = $result');
    } catch (e) {
      setState(() {
        _resultCircleArea = 'Error: $e';
      });
    }
  }

  void _testFactorial() {
    try {
      final n = int.parse(_nController.text);
      final result = MathLib.factorial(n);
      setState(() {
        _resultFactorial = '$n! = $result';
      });
      _log('factorial($n) = $result');
    } catch (e) {
      setState(() {
        _resultFactorial = 'Error: $e';
      });
    }
  }

  void _testPoints() {
    try {
      // Create points in native memory (Stack-allocated via struct)
      final pointA = ffi.Struct.create<Point>();
      pointA.x = double.parse(_aController.text);
      pointA.y = double.parse(_bController.text);

      final pointB = ffi.Struct.create<Point>();
      pointB.x = 1.0;
      pointB.y = 2.0;

      // Add points
      final resultPoint = MathLib.addPoints(pointA, pointB);
      final distance = MathLib.pointDistance(pointA, pointB);

      setState(() {
        _resultPoint =
            'P1($pointA.x, $pointA.y) + P2($pointB.x, $pointB.y) = ($resultPoint.x, $resultPoint.y)\n'
            'Distance: ${distance.toStringAsFixed(4)}';
      });
      _log(
        'Points: A($pointA.x, $pointA.y), B($pointB.x, $pointB.y), Result($resultPoint.x, $resultPoint.y)',
      );
    } catch (e) {
      setState(() {
        _resultPoint = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _radiusController.dispose();
    _nController.dispose();
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
            'Part 1: Easy Binding (FFI-friendly C API)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Demonstrates FFI binding to a simple C library with types like int, double, and POD structs.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // Input fields
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
            controller: _radiusController,
            decoration: const InputDecoration(
              label: Text('Radius'),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nController,
            decoration: const InputDecoration(
              label: Text('N (for factorial)'),
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
                  onPressed: _testAdd,
                  child: const Text('Add'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _testSubtract,
                  child: const Text('Subtract'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _testMultiply,
                  child: const Text('Multiply'),
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
          if (_resultAdd.isNotEmpty)
            Text(
              _resultAdd,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (_resultSubtract.isNotEmpty)
            Text(
              _resultSubtract,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (_resultMultiply.isNotEmpty)
            Text(
              _resultMultiply,
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
          // Geometric operations
          const Text(
            'Geometric Operations:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _testHypotenuse,
                  child: const Text('Hypotenuse'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _testCircleArea,
                  child: const Text('Circle Area'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_resultHypotenuse.isNotEmpty)
            Text(
              _resultHypotenuse,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (_resultCircleArea.isNotEmpty)
            Text(
              _resultCircleArea,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 24),
          // Other operations
          const Text(
            'Other Operations:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _testFactorial,
                  child: const Text('Factorial'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _testPoints,
                  child: const Text('Test Points'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_resultFactorial.isNotEmpty)
            Text(
              _resultFactorial,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (_resultPoint.isNotEmpty)
            Text(
              _resultPoint,
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
