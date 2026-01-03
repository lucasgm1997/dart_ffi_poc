# Gerenciamento Centralizado de Código Nativo

Este documento explica como os arquivos nativos (C/C++) são gerenciados de forma centralizada para evitar duplicação entre Android e iOS.

## Estrutura

```
dart_ffi_poc/
├── native/                         # ✅ ÚNICA FONTE DE VERDADE
│   ├── CMakeLists.txt              # Master CMake config
│   └── cpp/
│       ├── math_lib.h/.c           # Part 1 sources
│       ├── calculator.hpp/.cpp     # Part 2 sources
│       └── calculator_c_api.h/.cpp
│
├── android/
│   └── src/main/cpp/
│       └── CMakeLists.txt          # Referencia native/CMakeLists.txt
│
└── ios/
    └── Runner/
        ├── Scripts/
        │   └── link_native_sources.sh  # Script que cria symlinks
        └── Native/                      # Symlinks → native/cpp/
```

## Por que essa abordagem é melhor?

| Aspecto | Cópia (❌) | Centralizado (✅) |
|---------|-----------|-------------------|
| **Duplicação** | 2x código | 1x código |
| **Manutenção** | Sincronizar 2 locais | 1 local |
| **Bugs** | Possível desincronização | Garantido sincronizado |
| **CI/CD** | Complexo | Simples |
| **Storage** | Duplicado no git | Limpo |

## Android: Como Funciona

### 1. Estrutura

```
android/src/main/cpp/CMakeLists.txt
├── Calcula caminho para: native/CMakeLists.txt
├── Inclui: include("${NATIVE_CMAKE}")
└── CMake compila: native/cpp/*.{c,cpp}
```

### 2. Build automático

```bash
flutter build apk
# CMake automaticamente encontra e compila native/cpp/*.{c,cpp}
```

### 3. Sem arquivos duplicados

- ✅ Arquivos nativos em: `native/cpp/`
- ✅ Android referencia via CMake
- ❌ Nenhuma cópia em `android/src/main/cpp/`

## iOS: Como Funciona

### Opção A: Symlinks (Recomendado)

Crie symlinks para os arquivos nativos:

```bash
# Execute uma vez (ou adicione ao CI/CD)
bash ios/Runner/Scripts/link_native_sources.sh

# Isso cria:
# ios/Runner/Native/math_lib.h → native/cpp/math_lib.h (symlink)
# ios/Runner/Native/math_lib.c → native/cpp/math_lib.c (symlink)
# etc.
```

**Vantagens**:
- Sem duplicação
- Mudanças em `native/cpp/` refletem imediatamente
- Git não duplica arquivos
- Symlinks funcionam em macOS/Linux/Windows

**Como adicionar em Xcode**:

1. Em Xcode, click direito "Runner"
2. "Add Files to Runner..."
3. Navigate para `ios/Runner/Native/`
4. Selecione os symlinks (aparecem com ícone de seta)
5. ✓ "Create folder references"
6. ✓ Add to target "Runner"

### Opção B: Build Phase Script (Alternativa)

Se symlinks não funcionarem em seu setup:

1. Em Xcode:
   - Select "Runner" target
   - Go to "Build Phases"
   - Click "+" → "New Run Script Phase"

2. Nome: "Link Native Sources"

3. Script:
   ```bash
   bash "${SRCROOT}/Scripts/link_native_sources.sh"
   ```

4. Drag acima de "Compile Sources"

### Opção C: CMake para iOS (Avançado)

Para um setup totalmente unificado, configure CMake também para iOS:

```cmake
# ios/Runner/Scripts/build_native_ios.cmake
# (exemplo - requer setup complexo)

if(APPLE)
    enable_language(C CXX)

    set(NATIVE_SRC "${PROJECT_SOURCE_DIR}/../../native/cpp")

    add_library(math_lib STATIC
        "${NATIVE_SRC}/math_lib.c"
    )

    add_library(calculator STATIC
        "${NATIVE_SRC}/calculator.cpp"
        "${NATIVE_SRC}/calculator_c_api.cpp"
    )
endif()
```

Não recomendado para iOS (Xcode é mais natural).

## Git: Configurar para Ignorar Duplicações

Adicione ao `.gitignore`:

```bash
# ios/Runner/Native/ - contém symlinks
ios/Runner/Native/

# ou, se usar cópias, adicione ao .gitattributes:
# native/** merge=union
```

## Workflow de Desenvolvimento

### Editando código nativo

```bash
# Edite SEMPRE em: native/cpp/
nano native/cpp/math_lib.c

# Android: recompila automaticamente
flutter run

# iOS: symlink reflete imediatamente
# (Se usar Build Phase, executa automaticamente)
```

### CI/CD Pipeline

```bash
# 1. Clone repo
git clone <repo>

# 2. Setup iOS symlinks
bash ios/Runner/Scripts/link_native_sources.sh

# 3. Build (Android + iOS)
flutter build apk
flutter build ios

# Arquivos nativos vêm de: native/cpp/
# Sem duplicação, sem sincronização!
```

### GitHub Actions Example

```yaml
name: Build

on: [push]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2

      # Setup iOS symlinks
      - run: bash ios/Runner/Scripts/link_native_sources.sh

      # Build
      - run: flutter build apk
      - run: flutter build ios
```

## Troubleshooting

### "Symlinks não funcionam"

```bash
# Verificar se são realmente symlinks
ls -la ios/Runner/Native/

# Deve mostrar: lrwxr-xr-x ... math_lib.h -> ../../native/cpp/math_lib.h
```

Solução: Use Build Phase Script em vez de symlinks.

### "Arquivo não encontrado durante compilação"

```bash
# Verificar se symlinks existem
file ios/Runner/Native/math_lib.h

# Deve mostrar: symbolic link
```

Se não existem: execute `bash ios/Runner/Scripts/link_native_sources.sh`

### "Git commita os symlinks com conteúdo"

```bash
# Remover symlinks do git
git rm ios/Runner/Native/

# Adicionar ao .gitignore
echo "ios/Runner/Native/" >> .gitignore

# Adicionar script ao git
git add ios/Runner/Scripts/link_native_sources.sh

# Re-criar symlinks
bash ios/Runner/Scripts/link_native_sources.sh
```

## Estrutura Final (Recomendada)

```
dart_ffi_poc/
├── native/                              # ✅ ÚNICA FONTE
│   ├── CMakeLists.txt                   # Master build config
│   └── cpp/
│       ├── *.h, *.c, *.hpp, *.cpp
│       └── (editados AQUI)
│
├── android/
│   ├── build.gradle (configurado para CMake)
│   └── src/main/cpp/
│       └── CMakeLists.txt (include master)
│
├── ios/
│   └── Runner/
│       ├── Native/                      # Symlinks (leia .gitignore)
│       └── Scripts/
│           └── link_native_sources.sh
│
├── .gitignore (adicionar: ios/Runner/Native/)
└── lib/
    ├── bindings/
    └── screens/
```

## Resumo

| Operação | Comando |
|----------|---------|
| **Novo projeto** | `git clone` → `bash ios/Runner/Scripts/link_native_sources.sh` |
| **Editar código nativo** | Edit em `native/cpp/` |
| **Rebuild Android** | `flutter run` (automático) |
| **Rebuild iOS** | `flutter run` (automático) |
| **Verificar symlinks** | `ls -la ios/Runner/Native/` |
| **Resetar links** | `bash ios/Runner/Scripts/link_native_sources.sh` |

---

Essa abordagem garante **uma única fonte de verdade** para todo código nativo!
