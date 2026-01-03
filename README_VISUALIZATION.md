# Launch Screen Assets

You can customize the launch screen with your own desired assets by replacing the image files in this directory.

You can also do it by opening your Flutter project's Xcode project with `open ios/Runner.xcworkspace`, selecting `Runner/Assets.xcassets` in the Project Navigator and dropping in the desired images.

---

# Flutter FFI Implementation Architecture

Este projeto demonstra duas abordagens de FFI (Foreign Function Interface) no Flutter: uma simples (C direto) e uma complexa (C++ com wrapper C).

## 📐 Arquitetura Geral do Projeto

```mermaid
graph TB
    subgraph "Flutter/Dart Layer"
        A[lib/main.dart<br/>App Principal]
        B[lib/screens/part1_easy_binding.dart<br/>UI - FFI Simples]
        C[lib/screens/part2_cpp_wrapper.dart<br/>UI - FFI Complexo]
        D[lib/bindings/math_lib_bindings.dart<br/>Dart FFI Bindings - C]
        E[lib/bindings/calculator_bindings.dart<br/>Dart FFI Bindings - C++]
    end

    subgraph "Native Layer - Centralized"
        F[native/CMakeLists.txt<br/>Master Build Config]
        G[native/cpp/math_lib.c/h<br/>Biblioteca C]
        H[native/cpp/calculator.cpp/hpp<br/>Classe C++]
        I[native/cpp/calculator_c_api.cpp/h<br/>C Wrapper para C++]
    end

    subgraph "Platform - Android"
        J[android/app/src/main/cpp/CMakeLists.txt<br/>Android Config]
        K[libmath_lib.so<br/>Biblioteca Compilada]
        L[libcalculator.so<br/>Biblioteca Compilada]
    end

    subgraph "Platform - iOS"
        M[ios/Runner/Scripts/link_native_sources.sh<br/>iOS Build Script]
        N[libmath_lib.a<br/>Static Library]
        O[libcalculator.a<br/>Static Library]
    end

    A --> B
    A --> C
    B --> D
    C --> E
    D -.Carrega Runtime.-> K
    E -.Carrega Runtime.-> L
    D -.Carrega Runtime.-> N
    E -.Carrega Runtime.-> O

    J --> F
    M --> F
    F --> G
    F --> H
    F --> I
    J --> K
    J --> L
    M --> N
    M --> O

    style A fill:#4fc3f7,stroke:#01579b,stroke-width:3px,color:#000
    style B fill:#4fc3f7,stroke:#01579b,stroke-width:3px,color:#000
    style C fill:#4fc3f7,stroke:#01579b,stroke-width:3px,color:#000
    style D fill:#fff176,stroke:#f57f17,stroke-width:3px,color:#000
    style E fill:#fff176,stroke:#f57f17,stroke-width:3px,color:#000
    style F fill:#ff9800,stroke:#e65100,stroke-width:3px,color:#000
    style G fill:#66bb6a,stroke:#1b5e20,stroke-width:3px,color:#000
    style H fill:#ff8a65,stroke:#bf360c,stroke-width:3px,color:#000
    style I fill:#ff8a65,stroke:#bf360c,stroke-width:3px,color:#000
    style J fill:#81c784,stroke:#2e7d32,stroke-width:3px,color:#000
    style K fill:#4db6ac,stroke:#004d40,stroke-width:3px,color:#000
    style L fill:#4db6ac,stroke:#004d40,stroke-width:3px,color:#000
    style M fill:#9575cd,stroke:#4a148c,stroke-width:3px,color:#000
    style N fill:#ba68c8,stroke:#6a1b9a,stroke-width:3px,color:#000
    style O fill:#ba68c8,stroke:#6a1b9a,stroke-width:3px,color:#000
```

## 🎯 Part 1: FFI Simples (C Direto)

Biblioteca C com funções simples - FFI nativo sem conversões complexas.

```mermaid
sequenceDiagram
    participant D as Dart Code<br/>(part1_easy_binding.dart)
    participant B as FFI Bindings<br/>(math_lib_bindings.dart)
    participant S as Shared Library<br/>(libmath_lib.so/a)
    participant C as Native C Code<br/>(math_lib.c)

    Note over D: Usuario clica "Add 5 + 3"
    D->>B: MathLib.add(5, 3)
    B->>B: Converte Dart int → C int
    B->>S: Carrega função via DynamicLibrary
    S->>C: Chama add(5, 3)
    C->>C: Calcula: a + b = 8
    C-->>S: Retorna 8
    S-->>B: int result = 8
    B->>B: Converte C int → Dart int
    B-->>D: Retorna 8
    Note over D: Exibe "Result: 8" na UI

    Note over D: Usuario clica "Square Root of 16"
    D->>B: MathLib.squareRoot(16.0)
    B->>B: Converte Dart double → C double
    B->>S: Carrega função via DynamicLibrary
    S->>C: Chama square_root(16.0)
    C->>C: Calcula: sqrt(16) = 4.0
    C-->>S: Retorna 4.0
    S-->>B: double result = 4.0
    B->>B: Converte C double → Dart double
    B-->>D: Retorna 4.0
    Note over D: Exibe "Result: 4.0" na UI
```

### Estrutura Part 1

```mermaid
classDiagram
    class MathLibBindings {
        +DynamicLibrary _lib
        +int Function(int, int) add
        +double Function(double) squareRoot
        +loadLibrary() void
    }

    class MathLibC {
        +add(int a, int b) int
        +square_root(double x) double
    }

    class Part1UI {
        +build() Widget
        +_testAdd() void
        +_testSquareRoot() void
    }

    Part1UI --> MathLibBindings : usa
    MathLibBindings --> MathLibC : FFI direto

    note for MathLibC "Biblioteca C pura\nSem conversões complexas\nTipos primitivos apenas"
```

## 🎯 Part 2: FFI Complexo (C++ com Wrapper C)

Classe C++ moderna exposta via wrapper C para compatibilidade FFI.

```mermaid
sequenceDiagram
    participant D as Dart Code<br/>(part2_cpp_wrapper.dart)
    participant B as FFI Bindings<br/>(calculator_bindings.dart)
    participant S as Shared Library<br/>(libcalculator.so/a)
    participant W as C Wrapper<br/>(calculator_c_api.cpp)
    participant CPP as C++ Class<br/>(Calculator)

    Note over D: Usuario clica "Create Calculator"
    D->>B: CalculatorBindings.createCalculator()
    B->>S: Chama calculator_create()
    S->>W: calculator_create()
    W->>CPP: new Calculator()
    CPP-->>W: this pointer
    W-->>S: void* handle
    S-->>B: Pointer<Void> handle
    B-->>D: CalculatorHandle
    Note over D: Handle armazenado

    Note over D: Usuario insere "2 + 3 * 4"
    D->>B: calculator.pushNumber(2.0)
    B->>S: calculator_push_number(handle, 2.0)
    S->>W: calculator_push_number(handle, 2.0)
    W->>CPP: static_cast<Calculator*>(handle)->pushNumber(2.0)
    CPP->>CPP: operandStack.push(2.0)

    D->>B: calculator.pushOperator('+')
    B->>S: calculator_push_operator(handle, '+')
    S->>W: calculator_push_operator(handle, '+')
    W->>CPP: Calculator->pushOperator('+')
    CPP->>CPP: operatorStack.push('+')

    D->>B: calculator.pushNumber(3.0)
    D->>B: calculator.pushOperator('*')
    D->>B: calculator.pushNumber(4.0)

    Note over D: Usuario clica "Calculate"
    D->>B: calculator.calculate()
    B->>S: calculator_calculate(handle)
    S->>W: calculator_calculate(handle)
    W->>CPP: Calculator->calculate()
    CPP->>CPP: Processa operadores<br/>* tem precedência sobre +<br/>3 * 4 = 12<br/>2 + 12 = 14
    CPP-->>W: 14.0
    W-->>S: 14.0
    S-->>B: 14.0
    B-->>D: 14.0
    Note over D: Exibe "Result: 14.0"

    Note over D: Usuario fecha tela
    D->>B: calculator.destroy()
    B->>S: calculator_destroy(handle)
    S->>W: calculator_destroy(handle)
    W->>CPP: delete Calculator
    CPP-->>W: destruído
```

### Estrutura Part 2

```mermaid
classDiagram
    class CalculatorBindings {
        +DynamicLibrary _lib
        +Pointer~Void~ Function() createCalculator
        +void Function(Pointer, double) pushNumber
        +void Function(Pointer, String) pushOperator
        +double Function(Pointer) calculate
        +void Function(Pointer) destroy
    }

    class CalculatorCAPI {
        +calculator_create() void*
        +calculator_push_number(void*, double)
        +calculator_push_operator(void*, char)
        +calculator_calculate(void*) double
        +calculator_destroy(void*)
    }

    class Calculator_CPP {
        -std::stack~double~ operandStack
        -std::stack~char~ operatorStack
        +pushNumber(double)
        +pushOperator(char)
        +calculate() double
        -applyOperator()
        -precedence(char) int
    }

    class Part2UI {
        +Pointer~Void~ _calculatorHandle
        +build() Widget
        +_createCalculator() void
        +_pushNumber(double) void
        +_pushOperator(String) void
        +_calculate() void
    }

    Part2UI --> CalculatorBindings : usa
    CalculatorBindings --> CalculatorCAPI : FFI via C wrapper
    CalculatorCAPI --> Calculator_CPP : converte e delega

    note for CalculatorCAPI "Wrapper C expõe C++\npara FFI-friendly API\nGerencia ponteiros opacos"
    note for Calculator_CPP "Classe C++ moderna\nSTL (stack, vector)\nLógica complexa"
```

## 🏗️ Build System - Multiplataforma

```mermaid
flowchart TB
    subgraph "Source Code"
        A[native/CMakeLists.txt<br/>Master Config]
        B[native/cpp/*.c]
        C[native/cpp/*.cpp]
        D[native/cpp/*.h]
    end

    subgraph "Android Build"
        E[android/app/src/main/cpp/CMakeLists.txt<br/>include master]
        F[Gradle + NDK + CMake]
        G[libmath_lib.so<br/>arm64-v8a]
        H[libcalculator.so<br/>arm64-v8a]
        I[libmath_lib.so<br/>armeabi-v7a]
        J[libcalculator.so<br/>armeabi-v7a]
        K[app-release.apk<br/>contém todas .so]
    end

    subgraph "iOS Build"
        L[ios/Runner/Scripts/link_native_sources.sh<br/>symlink para native/]
        M[Xcode + CMake]
        N[libmath_lib.a<br/>arm64]
        O[libcalculator.a<br/>arm64]
        P[Runner.app<br/>embedded frameworks]
    end

    A --> E
    A --> L
    B --> A
    C --> A
    D --> A

    E --> F
    F --> G
    F --> H
    F --> I
    F --> J
    G --> K
    H --> K
    I --> K
    J --> K

    L --> M
    M --> N
    M --> O
    N --> P
    O --> P

    style A fill:#ff9800,stroke:#e65100,stroke-width:3px,color:#000
    style B fill:#66bb6a,stroke:#1b5e20,stroke-width:2px,color:#000
    style C fill:#ff8a65,stroke:#bf360c,stroke-width:2px,color:#000
    style D fill:#ffd54f,stroke:#f57f17,stroke-width:2px,color:#000
    style E fill:#81c784,stroke:#2e7d32,stroke-width:3px,color:#000
    style F fill:#4dd0e1,stroke:#006064,stroke-width:2px,color:#000
    style G fill:#4db6ac,stroke:#004d40,stroke-width:2px,color:#000
    style H fill:#4db6ac,stroke:#004d40,stroke-width:2px,color:#000
    style I fill:#4db6ac,stroke:#004d40,stroke-width:2px,color:#000
    style J fill:#4db6ac,stroke:#004d40,stroke-width:2px,color:#000
    style K fill:#26a69a,stroke:#004d40,stroke-width:4px,color:#000
    style L fill:#9575cd,stroke:#4a148c,stroke-width:3px,color:#000
    style M fill:#ce93d8,stroke:#6a1b9a,stroke-width:2px,color:#000
    style N fill:#ba68c8,stroke:#6a1b9a,stroke-width:2px,color:#000
    style O fill:#ba68c8,stroke:#6a1b9a,stroke-width:2px,color:#000
    style P fill:#ab47bc,stroke:#6a1b9a,stroke-width:4px,color:#000
```

## 🔧 CMake Configuration Flow

```mermaid
graph LR
    A[Platform CMakeLists<br/>android/ ou ios/] -->|include| B[native/CMakeLists.txt]
    B --> C{CMAKE_CURRENT_LIST_DIR<br/>resolve correto}
    C --> D[native/cpp/math_lib.c]
    C --> E[native/cpp/calculator.cpp]
    C --> F[native/cpp/calculator_c_api.cpp]

    D --> G[add_library math_lib SHARED]
    E --> H[add_library calculator SHARED]
    F --> H

    G --> I[target_link_libraries math_lib m]
    H --> J[target_link_libraries calculator m]

    I --> K[Build Output]
    J --> K

    K -->|Android| L[libmath_lib.so<br/>libcalculator.so]
    K -->|iOS| M[libmath_lib.a<br/>libcalculator.a]

    style A fill:#9575cd,stroke:#4a148c,stroke-width:3px,color:#000
    style B fill:#ff9800,stroke:#e65100,stroke-width:4px,color:#000
    style C fill:#f06292,stroke:#c2185b,stroke-width:3px,color:#fff
    style D fill:#66bb6a,stroke:#1b5e20,stroke-width:2px,color:#000
    style E fill:#ff8a65,stroke:#bf360c,stroke-width:2px,color:#000
    style F fill:#ff8a65,stroke:#bf360c,stroke-width:2px,color:#000
    style G fill:#81c784,stroke:#2e7d32,stroke-width:2px,color:#000
    style H fill:#ffab91,stroke:#bf360c,stroke-width:2px,color:#000
    style I fill:#81c784,stroke:#2e7d32,stroke-width:2px,color:#000
    style J fill:#ffab91,stroke:#bf360c,stroke-width:2px,color:#000
    style K fill:#ffd54f,stroke:#f57f17,stroke-width:3px,color:#000
    style L fill:#4db6ac,stroke:#004d40,stroke-width:3px,color:#000
    style M fill:#ba68c8,stroke:#6a1b9a,stroke-width:3px,color:#000
```

## 📊 Memory Management & Type Conversion

```mermaid
flowchart TD
    subgraph "Dart Side"
        A[Dart int/double/String]
        B[FFI Type Conversion]
        C[Pointer~Void~ handles]
    end

    subgraph "C Wrapper Side"
        D[void* opaque pointers]
        E[C primitive types<br/>int, double, char*]
        F[static_cast~Calculator*~]
    end

    subgraph "C++ Side"
        G[Calculator class instance]
        H[std::stack<br/>std::vector]
        I[C++ types & methods]
    end

    A -->|ffi.Pointer| B
    B --> C
    C -->|FFI call| D
    D --> E
    E --> F
    F --> G
    G --> H
    H --> I

    I -->|return value| F
    F -->|cast result| E
    E -->|return to Dart| B
    B -->|convert to Dart type| A

    style A fill:#4fc3f7,stroke:#01579b,stroke-width:3px,color:#000
    style B fill:#81d4fa,stroke:#0277bd,stroke-width:3px,color:#000
    style C fill:#4dd0e1,stroke:#006064,stroke-width:3px,color:#000
    style D fill:#66bb6a,stroke:#1b5e20,stroke-width:3px,color:#000
    style E fill:#81c784,stroke:#2e7d32,stroke-width:3px,color:#000
    style F fill:#aed581,stroke:#33691e,stroke-width:3px,color:#000
    style G fill:#ff8a65,stroke:#bf360c,stroke-width:3px,color:#000
    style H fill:#ffab91,stroke:#bf360c,stroke-width:3px,color:#000
    style I fill:#ffccbc,stroke:#d84315,stroke-width:3px,color:#000
```

## 📁 Estrutura de Arquivos

```
dart_ffi_poc/
├── lib/
│   ├── main.dart                           # App principal
│   ├── screens/
│   │   ├── part1_easy_binding.dart         # UI FFI simples
│   │   └── part2_cpp_wrapper.dart          # UI FFI complexo
│   └── bindings/
│       ├── math_lib_bindings.dart          # FFI C direto
│       └── calculator_bindings.dart        # FFI C++ via wrapper
├── native/
│   ├── CMakeLists.txt                      # Master build config
│   └── cpp/
│       ├── math_lib.c/h                    # Biblioteca C
│       ├── calculator.cpp/hpp              # Classe C++
│       └── calculator_c_api.cpp/h          # C wrapper
├── android/
│   └── app/src/main/cpp/
│       └── CMakeLists.txt                  # include(native/CMakeLists.txt)
└── ios/
    └── Runner/Scripts/
        └── link_native_sources.sh          # Symlink para native/
```

## 🎓 Conceitos Demonstrados

### Part 1 (Easy) - FFI Direto
- ✅ Tipos primitivos C (int, double)
- ✅ Funções puras sem estado
- ✅ Conversão automática Dart ↔ C
- ✅ `DynamicLibrary.open()`
- ✅ `lookupFunction<NativeType, DartType>()`

### Part 2 (Complex) - C++ via Wrapper
- ✅ Classes C++ com estado
- ✅ Gerenciamento de ponteiros opacos (`void*`)
- ✅ Lifecycle (create/destroy)
- ✅ STL (std::stack)
- ✅ Lógica complexa (precedência de operadores)
- ✅ String marshalling (char* ↔ String)
- ✅ Wrapper C como ponte FFI-friendly

## 🔑 Pontos-Chave

1. **Centralização**: Todo código nativo em `native/`, compartilhado entre plataformas
2. **CMAKE_CURRENT_LIST_DIR**: Essencial para paths corretos em includes
3. **C Wrapper**: Necessário para expor C++ ao FFI (Dart FFI não suporta C++ direto)
4. **Opaque Pointers**: Gerenciamento de instâncias C++ via `void*` handle
5. **Memory Safety**: Dart não gerencia memória nativa - precisa de destroy() manual
6. **Type Marshalling**: Conversão cuidadosa entre tipos Dart ↔ C

---

📖 Veja `NATIVE_BUILD_FIX.md` para troubleshooting do build nativo.
