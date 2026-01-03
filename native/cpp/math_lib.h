// math_lib.h
// Simple C library with FFI-friendly API for Flutter

#ifndef MATH_LIB_H
#define MATH_LIB_H

// POD (Plain Old Data) struct - FFI compatible
typedef struct {
  double x;
  double y;
} Point;

// Simple arithmetic operations
int add(int a, int b);
int subtract(int a, int b);
int multiply(int a, int b);
double divide(double a, double b);

// Geometric operations
double hypotenuse(double a, double b);
double circle_area(double radius);

// Factorial
int factorial(int n);

// Point operations
Point add_points(Point a, Point b);
Point scale_point(Point p, double scale);
double point_distance(Point p1, Point p2);

#endif // MATH_LIB_H
