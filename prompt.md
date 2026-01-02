
# Prompt — Estudo prático de FFI em Flutter (C e C++)

## Objetivo geral

Estudar, na prática, como integrar bibliotecas nativas C e C++ em um app Flutter usando FFI. Gerar exemplos completos cobrindo:

- Um caso de *binding fácil* (API em C “FFI-friendly").
- Um caso de *binding não tão fácil* (biblioteca C++ com classes/STL exposta via wrapper C).

Foco: Flutter mobile (Android e iOS).

## Metas de aprendizado

- Identificar quando uma biblioteca é "fácil" ou "difícil" para FFI.
- Usar `dart:ffi` em um projeto Flutter real.
- Entender o fluxo completo: código nativo → compilação (Android/iOS) → carregamento em Flutter → uso em widgets.

---

## PARTE 1 — Binding fácil (API em C "FFI-friendly")

Objetivo: criar uma lib C que use apenas tipos primitivos e POD structs, e integrá-la ao Flutter via FFI.

### 1.1 API em C (exemplo)

Arquivos esperados: `math_lib.h`, `math_lib.c`.

Exemplo de header:

```c
// math_lib.h
#ifndef MATH_LIB_H
#define MATH_LIB_H

typedef struct { double x; double y; } Point;

int add(int a, int b);
double hypotenuse(double a, double b);
int factorial(int n);
Point add_points(Point a, Point b);

#endif // MATH_LIB_H
```

Requisitos:

- Usar apenas `int`, `double` e structs POD.
- Expor uma interface limpa em `.h`.

### 1.2 Integração com Flutter (FFI)

No projeto Flutter:

- Colocar fontes nativos em `android/src/main/cpp` e/ou `ios/Classes` (ou `native/`).
- Em Dart, abrir a biblioteca com `DynamicLibrary.open` (Android) ou `DynamicLibrary.process`/`DynamicLibrary.open` conforme plataforma.
- Fazer `lookupFunction` para cada rotina C e declarar os tipos FFI (`Int32`, `Double`, `Struct`, `Pointer<T>`, etc.).

Implementação recomendada:

- Criar uma classe Dart `NativeMath` que encapsula as funções nativas (conversões, memórias, etc.).
- Tela Flutter de exemplo: campos de entrada, botões que chamam as funções nativas e exibem resultados.

### 1.3 Build nativo (resumo)

- Android (NDK + CMake): criar `CMakeLists.txt` em `android/src/main/cpp`, compilar `.so` para arquiteturas alvo.
- iOS: adicionar os arquivos `.c/.h` ao target do Xcode ou usar um Podspec para empacotar a lib.
- Empacotamento: o artefato (`.so` / `.a` / `.dylib`) deve estar disponível no runtime do app; o Flutter carrega via `DynamicLibrary.open`.

Exemplo mínimo de `CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.4.1)
add_library(math_lib SHARED math_lib.c)
target_include_directories(math_lib PRIVATE ${CMAKE_SOURCE_DIR})
```

---

## PARTE 2 — Binding não fácil (C++ com wrapper C)

Objetivo: exemplificar uma biblioteca C++ que usa `std::string` e `std::vector`, e mostrar como criar um wrapper C para uso via FFI.

### 2.1 Classe C++ (não FFI-friendly)

```cpp
// calculator.hpp
#include <string>
#include <vector>

class Calculator {
public:
  Calculator(std::string name);
  int sum(int a, int b);
  double average(const std::vector<double>& values);
  std::string description() const;
};
```

Por que não expor direto ao FFI:

- `std::string` e `std::vector` são tipos C++ cujo layout e semântica não são garantidos para ABI C estável. `dart:ffi` exige tipos C/ABI compatíveis.

### 2.2 Wrapper C (API C que esconde o C++)

Exponha apenas tipos simples e um ponteiro opaco:

```c
// calculator_c_api.h
#ifdef __cplusplus
extern "C" {
#endif

typedef void* CalculatorHandle;

CalculatorHandle calculator_new(const char* name);
void calculator_free(CalculatorHandle c);

int calculator_sum(CalculatorHandle c, int a, int b);
double calculator_average(CalculatorHandle c, const double* values, int length);
const char* calculator_description(CalculatorHandle c); // aloca C-string
void calculator_free_string(const char* s);

#ifdef __cplusplus
}
#endif
```

Boas práticas e responsabilidades:

- `CalculatorHandle` é um ponteiro opaco (internamente `new Calculator(...)`): no Dart, tratado como `Pointer<Void>`.
- `extern "C"` evita name mangling e garante ABI C.
- Para strings retornadas, definir claramente: a função que retorna (`calculator_description`) aloca, e o chamador deve liberar (`calculator_free_string`).

### 2.3 Binding em Flutter via FFI

No Dart:

- Declarar `typedef`s e `lookupFunction` das funções do wrapper C.
- Mapear `CalculatorHandle` para `Pointer<Void>`.
- Implementar uma classe Dart `Calculator` que contém o handle e expõe métodos `sum`, `average`, `description` e `dispose`.

Esqueleto Dart:

```dart
class Calculator {
  final Pointer<Void> _handle;
  Calculator._(this._handle);

  // factory para criar via calculator_new
  // sum(int a, int b)
  // average(List<double> values) -> converte para Pointer<Double>
  // description() -> chama calculator_description e depois calculator_free_string
  // dispose() -> chama calculator_free
}
```

### 2.4 Build nativo (C++)

- Android: NDK + CMake. Certifique-se de ativar C++11/17: `set(CMAKE_CXX_STANDARD 17)` no `CMakeLists.txt`.
- iOS: adicionar `.cpp`/`.mm` aos fontes do target no Xcode. Use `.mm` quando precisar de Objective-C++.

Exemplo mínimo (CMake) com C++:

```cmake
add_library(calculator SHARED calculator.cpp calculator_c_api.cpp)
set_target_properties(calculator PROPERTIES CXX_STANDARD 17)
```

---

## Comparação: binding fácil vs difícil

Binding fácil (Parte 1):

- API C com tipos primitivos e structs POD é diretamente compatível com `dart:ffi`.
- Vantagens: menos código de glue, menor risco de erros, desenvolvimento mais rápido.
- Limitações: menos expressivo que C++ (sem RAII, STL, sobrecarga, etc.).

Binding difícil (Parte 2 — C++):

- Problemas: `std::string`, `std::vector`, classes, templates, exceções, métodos virtuais e overloads complicam a exposição direta.
- Solução: escrever um wrapper C que exponha tipos planos, ponteiros opacos e funções com ABI C (`extern "C"`).
- Trade-offs: mais código de wrapper, responsabilidade explícita por alocação/liberação, mas permite expor a lógica C++ rica ao Dart.

## Pontos essenciais para documentar em cada exemplo

- Quem aloca e quem libera memória (strings, buffers, handles).
- Como os tipos são convertidos entre Dart e C/C++ (`List<double>` → `Pointer<Double>`, structs via `Struct` no Dart).
- Trechos de configuração para build (ex.: `CMakeLists.txt`, instruções rápidas para Xcode/Podspec).

## Estilo de entrega esperado

- Código completo (C, C++, wrappers, Dart) em blocos.
- Comentários didáticos explicando decisões (por que algo é FFI-friendly ou não).
- Trechos de configuração relevantes e comandos de build de exemplo.

---

## Contexto do usuário

- Você é dev Flutter com bom domínio de Dart e conhecimento básico em C/C++.
- Objetivo: estudo prático (não produção). Exemplos simples e reproduzíveis para copiar/rodar/estudar.

---

Se quiser, eu posso agora:

1. Gerar os arquivos C/C++ e o wrapper (código completo).
2. Gerar as bindings Dart e a UI de exemplo em Flutter.
3. Incluir `CMakeLists.txt` e instruções passo a passo para Android/iOS.

Diga qual opção prefere que eu implemente primeiro.
