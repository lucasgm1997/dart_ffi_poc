# 🚀 Quick Start - Código Nativo Centralizado

Guia rápido para trabalhar com a estrutura centralizada de código nativo.

## Estrutura Agora

```
native/cpp/              ← EDITE AQUI
├── math_lib.h
├── math_lib.c
├── calculator.hpp
├── calculator.cpp
├── calculator_c_api.h
└── calculator_c_api.cpp

android/src/main/cpp/CMakeLists.txt    ← Referencia native/
ios/Runner/Native/                      ← Symlinks para native/cpp/
```

## Primeira Vez (Setup)

```bash
# 1. Clone o projeto
git clone <repo>

# 2. Crie os symlinks iOS (IMPORTANTE)
bash ios/Runner/Scripts/link_native_sources.sh

# 3. Get dependencies
flutter pub get

# 4. Pronto!
flutter run
```

## Dia a Dia

### Editar Código Nativo

```bash
# SEMPRE edite em: native/cpp/
nano native/cpp/math_lib.c
nano native/cpp/calculator.cpp

# Mudanças refletem automaticamente em:
# - Android (CMake referencia)
# - iOS (symlinks apontam)
```

### Rebuild

```bash
# Android
flutter run --release

# iOS
flutter run -d <device>

# Ambos pegam código de: native/cpp/
```

## Se Symlinks Forem Removidos (iOS)

```bash
# Re-criar symlinks
bash ios/Runner/Scripts/link_native_sources.sh

# Pronto! iOS encontra os arquivos novamente
```

## Verificar Status

```bash
# Ver estrutura
tree native/
# Mostra: native/CMakeLists.txt + native/cpp/*

# Ver symlinks iOS
ls -la ios/Runner/Native/
# Mostra: lrwxr-xr-x ... math_lib.h -> ../../native/cpp/math_lib.h

# Ver referência Android
cat android/src/main/cpp/CMakeLists.txt
# Mostra: include() pointing to native/CMakeLists.txt
```

## Arquitetura

```
┌─────────────────────────────────────────┐
│     native/cpp/ (Única Fonte)           │
│  ✏️ Edite aqui                          │
│  - math_lib.h/c                        │
│  - calculator.hpp/cpp                  │
│  - calculator_c_api.h/cpp              │
└──────────────┬──────────────────────────┘
               │
        ┌──────┴──────┐
        │             │
    ┌───▼──┐    ┌───▼──┐
    │Android   │ iOS  │
    │(CMake   │(symlinks)
    │include) │
    └────────┘ └──────┘
```

## Resumo de Arquivos

| Local | Função | Editar? |
|-------|--------|---------|
| `native/cpp/*` | Código nativo | ✅ SIM |
| `native/CMakeLists.txt` | Config build | ⚠️ Raramente |
| `android/src/main/cpp/CMakeLists.txt` | Inclui master | ❌ Não |
| `ios/Runner/Native/*` | Symlinks | ❌ Não (auto) |
| `ios/Runner/Scripts/link_native_sources.sh` | Cria symlinks | ❌ Só run |

## Troubleshooting

### iOS não compila
```bash
# Verificar symlinks
ls -la ios/Runner/Native/

# Se vazio, executar:
bash ios/Runner/Scripts/link_native_sources.sh

# Se ainda não funcionar, adicionar à Xcode:
# 1. Right-click "Runner"
# 2. "Add Files to Runner..."
# 3. Navigate: ios/Runner/Native/
# 4. Select all files
# 5. ✓ "Create folder references"
```

### Android não encontra arquivo
```bash
# Verificar CMakeLists.txt
cat android/src/main/cpp/CMakeLists.txt

# Deve mostrar caminho para native/CMakeLists.txt
# Se não funcionar, limpar:
flutter clean
flutter pub get
flutter run
```

---

**Resumo**: Edite em `native/cpp/`, tudo mais é automático! 🎉
