// calculator.cpp
// Implementation of Calculator class

#include "calculator.hpp"
#include <algorithm>
#include <cmath>
#include <stdexcept>

Calculator::Calculator(const std::string& name)
    : name_(name), operation_count_(0) {}

Calculator::~Calculator() {}

int Calculator::sum(int a, int b) {
    operation_count_++;
    return a + b;
}

int Calculator::product(int a, int b) {
    operation_count_++;
    return a * b;
}

double Calculator::divide(double a, double b) {
    operation_count_++;
    if (b == 0.0) {
        return 0.0;
    }
    return a / b;
}

double Calculator::average(const std::vector<double>& values) {
    operation_count_++;
    if (values.empty()) {
        return 0.0;
    }
    double sum = 0.0;
    for (double v : values) {
        sum += v;
    }
    return sum / values.size();
}

double Calculator::max(const std::vector<double>& values) {
    operation_count_++;
    if (values.empty()) {
        return 0.0;
    }
    return *std::max_element(values.begin(), values.end());
}

double Calculator::min(const std::vector<double>& values) {
    operation_count_++;
    if (values.empty()) {
        return 0.0;
    }
    return *std::min_element(values.begin(), values.end());
}

std::string Calculator::description() const {
    return "Calculator '" + name_ + "' with " + std::to_string(operation_count_) + " operations";
}

int Calculator::get_operation_count() const {
    return operation_count_;
}
