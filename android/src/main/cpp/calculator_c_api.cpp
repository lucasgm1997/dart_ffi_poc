// calculator_c_api.cpp
// Implementation of C API wrapper for Calculator class

#include "calculator_c_api.h"
#include "calculator.hpp"
#include <cstring>
#include <cstdlib>

// Helper: cast opaque handle to Calculator*
static inline Calculator* handle_to_calc(CalculatorHandle handle) {
    return static_cast<Calculator*>(handle);
}

// Helper: cast Calculator* to opaque handle
static inline CalculatorHandle calc_to_handle(Calculator* calc) {
    return static_cast<CalculatorHandle>(calc);
}

// Factory - create a new Calculator instance
CalculatorHandle calculator_new(const char* name) {
    if (name == nullptr) {
        name = "Default";
    }
    return calc_to_handle(new Calculator(std::string(name)));
}

// Destructor - delete the Calculator instance
void calculator_free(CalculatorHandle handle) {
    if (handle != nullptr) {
        delete handle_to_calc(handle);
    }
}

// Arithmetic operations
int calculator_sum(CalculatorHandle handle, int a, int b) {
    Calculator* calc = handle_to_calc(handle);
    return calc->sum(a, b);
}

int calculator_product(CalculatorHandle handle, int a, int b) {
    Calculator* calc = handle_to_calc(handle);
    return calc->product(a, b);
}

double calculator_divide(CalculatorHandle handle, double a, double b) {
    Calculator* calc = handle_to_calc(handle);
    return calc->divide(a, b);
}

// Statistics - convert C array to std::vector
double calculator_average(CalculatorHandle handle, const double* values, int length) {
    if (values == nullptr || length <= 0) {
        return 0.0;
    }
    Calculator* calc = handle_to_calc(handle);
    std::vector<double> vec(values, values + length);
    return calc->average(vec);
}

double calculator_max(CalculatorHandle handle, const double* values, int length) {
    if (values == nullptr || length <= 0) {
        return 0.0;
    }
    Calculator* calc = handle_to_calc(handle);
    std::vector<double> vec(values, values + length);
    return calc->max(vec);
}

double calculator_min(CalculatorHandle handle, const double* values, int length) {
    if (values == nullptr || length <= 0) {
        return 0.0;
    }
    Calculator* calc = handle_to_calc(handle);
    std::vector<double> vec(values, values + length);
    return calc->min(vec);
}

// String operations
const char* calculator_description(CalculatorHandle handle) {
    Calculator* calc = handle_to_calc(handle);
    std::string desc = calc->description();

    // Allocate C string and copy
    char* result = static_cast<char*>(malloc(desc.length() + 1));
    if (result != nullptr) {
        strcpy(result, desc.c_str());
    }
    return result;
}

void calculator_free_string(const char* str) {
    if (str != nullptr) {
        free(const_cast<char*>(str));
    }
}

int calculator_get_operation_count(CalculatorHandle handle) {
    Calculator* calc = handle_to_calc(handle);
    return calc->get_operation_count();
}
