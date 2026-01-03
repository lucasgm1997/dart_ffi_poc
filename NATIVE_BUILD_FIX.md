# 🔴 ERRO: "libmath_lib.so not found" - SOLUÇÃO VERIFICADA

Você vê este erro:
```
ArgumentError (Invalid argument(s): Failed to load dynamic library 'libmath_lib.so': dlopen failed: library "libmath_lib.so" not found)
```

Significa que o CMake **não compilou** as bibliotecas nativas.

## ✅ Solução Passo-a-Passo (VERIFICADA)

### 1️⃣ Verificar e Corrigir build.gradle.kts

O arquivo `android/app/build.gradle.kts` deve ter esta estrutura:

```kotlin
android {
    namespace = "com.example.dart_ffi_poc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"  // Use a versão instalada

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlin {
        jvmToolchain(21)
    }

    defaultConfig {
        applicationId = "com.example.dart_ffi_poc"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            abiFilters.addAll(listOf("arm64-v8a", "armeabi-v7a"))
        }
    }

    // ⚠️ IMPORTANTE: externalNativeBuild deve estar FORA de defaultConfig
    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.31.5"  // Use sua versão: cmake --version
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
```

**Erros comuns neste arquivo:**
- `externalNativeBuild` dentro de `defaultConfig` (ERRADO)
- `abiFilters 'arm64-v8a'` sem `listOf()` (sintaxe Groovy no arquivo .kts)
- `path = "string"` ao invés de `path = file("string")`
- `jvmTarget` deprecated, usar `jvmToolchain(21)`

### 2️⃣ Verificar NDK Installation

```bash
# Verificar versões instaladas
ls ~/Library/Android/sdk/ndk/

# Exemplo de output:
# 27.0.12077973
# 28.2.13676358
```

Se não tiver, instale via Android Studio:
1. Android Studio → Preferences → SDK Manager
2. SDK Tools → NDK (Side by side) → Instale a versão recomendada

### 3️⃣ Configurar local.properties

**IMPORTANTE:** NÃO use `ndk.dir` (deprecated). Configure apenas:

```properties
sdk.dir=/Users/YOUR_USERNAME/Library/Android/sdk
flutter.sdk=/Users/YOUR_USERNAME/fvm/versions/3.38.5
flutter.buildMode=release
flutter.versionName=1.0.0
flutter.versionCode=1
```

E adicione `ndkVersion` no `build.gradle.kts` (veja passo 1).

### 4️⃣ Criar CMakeLists.txt no Local Correto

O arquivo **DEVE** estar em `android/app/src/main/cpp/CMakeLists.txt` (não `android/src/main/cpp/`):

```cmake
# android/app/src/main/cpp/CMakeLists.txt
cmake_minimum_required(VERSION 3.4.1)

project(dart_ffi_poc_android)

# Calculate path to central native directory
# From: android/app/src/main/cpp/CMakeLists.txt
# To:   native/CMakeLists.txt
get_filename_component(PROJECT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../../../../" ABSOLUTE)
set(NATIVE_CMAKE "${PROJECT_ROOT}/native/CMakeLists.txt")

# Include the master CMakeLists from the central location
include("${NATIVE_CMAKE}")

# Additional Android-specific configuration
message(STATUS "Building for Android NDK")
message(STATUS "Native sources: ${PROJECT_ROOT}/native/cpp")
```

**Note o caminho:** 6 níveis acima (`../../../../../`) porque estamos em `android/app/src/main/cpp/`.

### 5️⃣ Corrigir native/CMakeLists.txt

**CRÍTICO:** Use `CMAKE_CURRENT_LIST_DIR` ao invés de `CMAKE_CURRENT_SOURCE_DIR`:

```cmake
# native/CMakeLists.txt
cmake_minimum_required(VERSION 3.10)

project(ffi_libraries)

# Set C++ standard globally
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ⚠️ IMPORTANTE: Use CMAKE_CURRENT_LIST_DIR para evitar paths errados
set(NATIVE_DIR "${CMAKE_CURRENT_LIST_DIR}")

# Part 1: Math Library
add_library(math_lib SHARED
    "${NATIVE_DIR}/cpp/math_lib.c"
)

target_include_directories(math_lib PRIVATE "${NATIVE_DIR}/cpp")
target_link_libraries(math_lib m)

# Part 2: Calculator Library
add_library(calculator SHARED
    "${NATIVE_DIR}/cpp/calculator.cpp"
    "${NATIVE_DIR}/cpp/calculator_c_api.cpp"
)

target_include_directories(calculator PRIVATE "${NATIVE_DIR}/cpp")
set_target_properties(calculator PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
)
target_link_libraries(calculator m)

# Visibility control
if(APPLE)
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
    set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)
elseif(ANDROID)
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
    set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)
endif()
```

**Por que `CMAKE_CURRENT_LIST_DIR`?**
- `CMAKE_CURRENT_SOURCE_DIR` aponta para o diretório do CMakeLists.txt **que chamou o include** (android/app/src/main/cpp)
- `CMAKE_CURRENT_LIST_DIR` aponta para o diretório do arquivo **atual** (native/)

### 6️⃣ Limpar Build

```bash
# Use FVM se estiver usando
fvm flutter clean

# Remove build Android específico
rm -rf android/.gradle
rm -rf android/build

# Get dependencies
fvm flutter pub get
```

### 7️⃣ Build e Verificação

```bash
# Build APK
fvm flutter build apk --release

# Deve ver:
# Running Gradle task 'assembleRelease'...        21.1s
# ✓ Built build/app/outputs/flutter-apk/app-release.apk (46.3MB)
```

### 8️⃣ Verificar se .so foram compilados

```bash
# Verificar arquivos compilados
find build -name "*.so" -type f | grep -E "(libmath_lib|libcalculator)"

# Deve mostrar:
# build/app/intermediates/cxx/release/.../arm64-v8a/libmath_lib.so
# build/app/intermediates/cxx/release/.../arm64-v8a/libcalculator.so
# (e outras arquiteturas)

# Verificar dentro do APK
cd build/app/outputs/flutter-apk
unzip -l app-release.apk | grep -E "(libmath_lib|libcalculator)"

# Deve mostrar:
# lib/arm64-v8a/libcalculator.so
# lib/arm64-v8a/libmath_lib.so
# lib/armeabi-v7a/libcalculator.so
# lib/armeabi-v7a/libmath_lib.so
# lib/x86_64/libcalculator.so
# lib/x86_64/libmath_lib.so
```

## 🆘 Problemas Comuns

### "CMake Error: Cannot find source file"

```
Cannot find source file:
  /Users/.../android/app/src/main/cpp/cpp/math_lib.c
```

**Causa:** `CMAKE_CURRENT_SOURCE_DIR` ao invés de `CMAKE_CURRENT_LIST_DIR` no `native/CMakeLists.txt`

**Solução:** Use `CMAKE_CURRENT_LIST_DIR` (veja passo 5)

### "Unexpected tokens" no build.gradle.kts

```
Line 32: abiFilters 'arm64-v8a', 'armeabi-v7a'
                   ^ Unexpected tokens
```

**Causa:** Sintaxe Groovy em arquivo Kotlin (.kts)

**Solução:** Use `abiFilters.addAll(listOf("arm64-v8a", "armeabi-v7a"))`

### "Type mismatch: inferred type is String but File? was expected"

```
Line 38: path = "src/main/cpp/CMakeLists.txt"
```

**Causa:** String ao invés de File no Kotlin DSL

**Solução:** Use `path = file("src/main/cpp/CMakeLists.txt")`

### "Cannot find a Java installation matching: {languageVersion=17}"

**Causa:** Gradle usa JDK 21 do Android Studio, mas build.gradle.kts especifica Java 17

**Solução:** Use `JavaVersion.VERSION_21` e `jvmToolchain(21)`

### "NDK was located by using ndk.dir property" (Warning)

**Causa:** `ndk.dir` está deprecated

**Solução:**
1. Remova `ndk.dir` do `local.properties`
2. Adicione `ndkVersion = "28.2.13676358"` no `build.gradle.kts`

## ✨ Confirmação de Sucesso

Você verá:

```bash
$ fvm flutter build apk --release
Running Gradle task 'assembleRelease'...        21.1s
✓ Built build/app/outputs/flutter-apk/app-release.apk (46.3MB)
```

E ao executar:

```bash
$ unzip -l build/app/outputs/flutter-apk/app-release.apk | grep lib
329880  lib/arm64-v8a/libcalculator.so
  4832  lib/arm64-v8a/libmath_lib.so
200012  lib/armeabi-v7a/libcalculator.so
  3244  lib/armeabi-v7a/libmath_lib.so
323208  lib/x86_64/libcalculator.so
  4944  lib/x86_64/libmath_lib.so
```

**Pronto!** 🎉 As bibliotecas foram compiladas e empacotadas com sucesso.

## 📋 Checklist Final

- [x] Android NDK 28.2.13676358 instalado
- [x] `local.properties` **SEM** `ndk.dir` (deprecated)
- [x] `ndkVersion` configurado no `build.gradle.kts`
- [x] `android/app/src/main/cpp/CMakeLists.txt` existe (caminho correto!)
- [x] `native/CMakeLists.txt` usa `CMAKE_CURRENT_LIST_DIR`
- [x] `build.gradle.kts` usa sintaxe Kotlin DSL correta
- [x] Java/Kotlin versão 21 configurados
- [x] `externalNativeBuild` fora de `defaultConfig`
- [x] `flutter clean` executado
- [x] Build APK bem-sucedido (21.1s)
- [x] APK contém `lib/arm64-v8a/libmath_lib.so` e `libcalculator.so`
- [x] Todas as arquiteturas presentes (arm64-v8a, armeabi-v7a, x86_64)

## 🎯 Resumo dos Problemas Resolvidos

1. **Sintaxe Kotlin DSL incorreta** - Corrigido `abiFilters`, `path`, `jvmToolchain`
2. **`externalNativeBuild` no local errado** - Movido para fora de `defaultConfig`
3. **CMakeLists.txt no caminho errado** - Criado em `android/app/src/main/cpp/`
4. **`CMAKE_CURRENT_SOURCE_DIR` incorreto** - Trocado por `CMAKE_CURRENT_LIST_DIR`
5. **`ndk.dir` deprecated** - Removido e substituído por `ndkVersion`
6. **Java 17 vs JDK 21 mismatch** - Atualizado para Java 21

Todas as bibliotecas nativas agora compilam corretamente e são empacotadas no APK!
