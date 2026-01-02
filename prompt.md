Prompt — Estudo de FFI em Flutter com C e C++ (binding fácil e difícil)

Objetivo geral

Quero estudar, na prática, como integrar bibliotecas nativas C e C++ em um app Flutter usando FFI.
Quero que você crie exemplos completos cobrindo:

Um caso de binding fácil (API em C “amigável” ao FFI)

Um caso de binding não tão fácil (API em C++ com classes, etc., que precisa de wrapper C)

O foco é Flutter (mobile): Android e iOS.

Metas de aprendizado

Entender quando uma lib C/C++ é:

“fácil de bindar” (API C, tipos simples)

“difícil” (C++ OO, templates, STL, etc.)

Usar dart:ffi dentro de um projeto Flutter.

Ver o fluxo completo:

código nativo → compilação (Android/iOS) → carregamento em Flutter → uso em widgets.

PARTE 1 — Binding fácil (biblioteca em C “FFI-friendly”)

Crie um exemplo completo de integração de uma biblioteca em C com Flutter usando FFI.

1.1. API em C

Implemente um arquivo .c e .h com funções simples:

int add(int a, int b);

double hypotenuse(double a, double b);

int factorial(int n);

Uma função usando struct simples, ex.:

```
typedef struct {
  double x;
  double y;
} Point;

Point add_points(Point a, Point b);
```

Requisitos da API C:

Usar apenas tipos primitivos (int, double) e struct simples (POD).

Interface clara em um .h público.

1.2. Integração com Flutter (FFI)

No projeto Flutter:

Criar uma pasta para os códigos nativos (ex.: native/ ou ios/Classes, android/src/main/cpp).

Adicionar o binding FFI em Dart:

uso de DynamicLibrary.open / DynamicLibrary.process (conforme plataforma).

lookupFunction para mapear cada função C para Dart.

definição dos tipos FFI (Int32, Double, Pointer<T>, Struct, etc.).

Implementar:

Uma classe Dart “wrapper” em cima das funções nativas, ex.: NativeMath.

Um exemplo de tela Flutter com:

TextField para entrada de parâmetros.

ElevatedButton chamando a função nativa.

Exibição do resultado (ex.: soma, fatorial, hipotenusa, soma de pontos).

1.3. Build nativo

Documentar:

Como compilar/ligar o código C para Android (NDK, CMakeLists.txt ou Android.mk).

Como compilar/ligar o código C para iOS (Xcode, podspec/swift/objc se necessário).

Mostrar como o .so/.a/.dylib é empacotado e acessado pelo Flutter.

PARTE 2 — Binding não fácil (biblioteca C++ com wrapper C)

Agora quero um exemplo de lib C++ que não é diretamente amigável ao FFI, e que precisa de um wrapper C.

2.1. Classe C++ “complicadinha”

Crie uma classe C++ com mais cara de C++ do que de C:

```
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

Observações:

Usar std::string e std::vector<double> para mostrar que isso não é FFI-friendly diretamente.

Explicar (nos comentários) por que não dá pra expor isso direto pro Dart FFI.

2.2. Criar wrapper em C

Criar um wrapper C com extern "C" que:

Esconde toda a parte C++.

Expõe apenas funções C com tipos simples.

Exemplo:

```
// calculator_c_api.h
#ifdef __cplusplus
extern "C" {
#endif

typedef void* CalculatorHandle;

CalculatorHandle calculator_new(const char* name);
void calculator_free(CalculatorHandle c);

int calculator_sum(CalculatorHandle c, int a, int b);
double calculator_average(CalculatorHandle c, const double* values, int length);
const char* calculator_description(CalculatorHandle c);
void calculator_free_string(const char* s);

#ifdef __cplusplus
}
#endif

```

Requisitos:

Explicar a ideia de CalculatorHandle (ponteiro opaco).

Explicar por que usamos extern "C" (evitar name mangling, ABI C, etc.).

Cuidar de:

    quem aloca e quem libera strings retornadas (calculator_free_string).

    como converter std::string / std::vector internamente.

2.3. Binding em Flutter via FFI

    No Flutter:

    Fazer bindings para essas funções C do wrapper:

        calculator_new, calculator_free

        calculator_sum

        calculator_average

        calculator_description / calculator_free_string

    Criar uma classe Dart, por ex.:

```dart
class Calculator {
  // guarda Pointer<Void> do handle
  // expõe métodos:
  //  - sum(int a, int b)
  //  - average(List<double> values)
  //  - description()
  // implementa dispose() para liberar o handle
}

```

Demonstrar uso em uma tela Flutter:

Campo para nome da calculadora.

Campos para valores.

Botões que:

Criam a instância nativa.

Chamam sum, average, description.

Mostram resultados na UI.


2.4. Build nativo (C++)

Documentar também:

Como compilar C++ junto ao app Flutter:

Android: NDK + CMake com suporte a C++ (set(CMAKE_CXX_STANDARD 17) etc.).

iOS: adicionar arquivos .mm/.cpp ao target, ajustar flags de compilação C++.

Diferenciar quando usar .cpp/.mm/.m

Comparação explícita: binding fácil vs difícil

Peço que você inclua, ao final, uma seção explicando claramente:

Binding fácil (Parte 1)

Por que a API C é mais simples para FFI.

Vantagens: menos código de cola, menos risco de bug.

Limitações: menos “expressivo” que C++.

Binding difícil (Parte 2)

Quais aspectos de C++ dificultam o FFI:

std::string, std::vector, classes, métodos virtuais, templates, exceções.

Como o wrapper C resolve:

extern "C", tipos planos, ponteiro opaco.

Trade-offs: mais código, mas API nativa mais rica.

Estilo de resposta esperado do agente

Mostrar código completo (C, C++, wrappers, Dart) em blocos.

Comentar o código de forma didática.

Incluir trechos de configuração relevantes (CMakeLists, Android.mk, Podspec/Xcode, se necessário).

Sempre deixar claro:

quem aloca e quem libera memória

como os tipos são convertidos

Explicar o mínimo necessário sobre build, mas com comandos exemplo ou trechos de config.

Contexto do usuário

    Sou dev Flutter e já programo bem em Dart.

    Sei o básico de C/C++, mas nunca fiz FFI “de verdade”.

    O objetivo é estudo prático, não produção.

    Use exemplos simples, mas realistas, que eu consiga copiar, adaptar e rodar num projeto Flutter.