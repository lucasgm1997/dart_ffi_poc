// calculator_c_api.h
// C API wrapper for Calculator class - FFI-friendly interface
// This is the header that Dart/FFI will see and use

#ifdef __cplusplus
extern "C" {
#endif

// Opaque handle to Calculator instance (from Dart perspective, it's Pointer<Void>)
typedef void* CalculatorHandle;

// Factory function - creates a new Calculator instance
// Returns a handle that must be freed with calculator_free
CalculatorHandle calculator_new(const char* name);

// Destructor - frees the Calculator instance
void calculator_free(CalculatorHandle handle);

// Arithmetic operations
int calculator_sum(CalculatorHandle handle, int a, int b);
int calculator_product(CalculatorHandle handle, int a, int b);
double calculator_divide(CalculatorHandle handle, double a, double b);

// Statistics on array of doubles
// Note: the caller passes a pointer to double array and length
double calculator_average(CalculatorHandle handle, const double* values, int length);
double calculator_max(CalculatorHandle handle, const double* values, int length);
double calculator_min(CalculatorHandle handle, const double* values, int length);

// String operations
// Important: the returned string is allocated by the library
// the caller MUST free it with calculator_free_string
const char* calculator_description(CalculatorHandle handle);
void calculator_free_string(const char* str);

// Get operation count
int calculator_get_operation_count(CalculatorHandle handle);

#ifdef __cplusplus
}
#endif
