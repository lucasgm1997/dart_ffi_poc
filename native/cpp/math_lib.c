// math_lib.c
// Implementation of math_lib - Simple FFI-friendly math operations

#include "math_lib.h"
#include <math.h>
#include <stdint.h>

// Simple arithmetic operations
int add(int a, int b) {
    return a + b;
}

int subtract(int a, int b) {
    return a - b;
}

int multiply(int a, int b) {
    return a * b;
}

double divide(double a, double b) {
    if (b == 0.0) {
        return 0.0;  // Handle division by zero
    }
    return a / b;
}

// Geometric operations using standard math library
double hypotenuse(double a, double b) {
    return sqrt(a * a + b * b);
}

double circle_area(double radius) {
    return 3.14159265359 * radius * radius;
}

// Factorial - recursive with base case
int factorial(int n) {
    if (n <= 0) return 1;
    if (n == 1) return 1;
    return n * factorial(n - 1);
}

// Point operations
Point add_points(Point a, Point b) {
    Point result;
    result.x = a.x + b.x;
    result.y = a.y + b.y;
    return result;
}

Point scale_point(Point p, double scale) {
    Point result;
    result.x = p.x * scale;
    result.y = p.y * scale;
    return result;
}

double point_distance(Point p1, Point p2) {
    double dx = p2.x - p1.x;
    double dy = p2.y - p1.y;
    return sqrt(dx * dx + dy * dy);
}
