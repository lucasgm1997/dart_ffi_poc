// calculator.hpp
// C++ calculator class using std::string and std::vector (NOT FFI-friendly directly)

#ifndef CALCULATOR_HPP
#define CALCULATOR_HPP

#include <string>
#include <vector>

class Calculator {
private:
    std::string name_;
    int operation_count_;

public:
    Calculator(const std::string& name);
    ~Calculator();

    // Arithmetic operations
    int sum(int a, int b);
    int product(int a, int b);
    double divide(double a, double b);

    // Statistics
    double average(const std::vector<double>& values);
    double max(const std::vector<double>& values);
    double min(const std::vector<double>& values);

    // Utility
    std::string description() const;
    int get_operation_count() const;
};

#endif // CALCULATOR_HPP
