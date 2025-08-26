# CMake Template Repository

This repository provides a cross-platform CMake template structured to support builds on **Android**, **Linux**, **macOS (OSX)**, **Windows**, and **iOS**.

---

## Directory Structure

- **Android/**
  - Expected subdirectories: `arm64-v8a/`, `armeabi-v7a/`
- **Linux/**
  - Expected subdirectories: `x86_64/`, `arm64/`
- **OSX/**
- **Windows/**
- **iOS/**

Each platform directory is intended to hold its respective build artifacts.

---

## Build Instructions

### Linux
```bash
mkdir -p Linux/x86_64
cd Linux/x86_64
cmake ../.. -DCMAKE_BUILD_TYPE=Release
make -j<threads>
```

### Android
```bash
mkdir -p Android/armeabi-v7a
cd Android/armeabi-v7a
cmake ../../ -DANDROID_ABI="armeabi-v7a" \
    -DCMAKE_ANDROID_NDK=$ANDROID_NDK \
    -DANDROID_TOOLCHAIN=clang \
    -DCMAKE_BUILD_TYPE=Release
make -j<threads>
```
or
```bash
mkdir -p Android/arm64-v8a
cd Android/arm64-v8a
cmake ../../ -DANDROID_ABI="arm64-v8a" \
    -DCMAKE_ANDROID_NDK=$ANDROID_NDK \
    -DANDROID_TOOLCHAIN=clang \
    -DCMAKE_BUILD_TYPE=Release
make -j<threads>
```

### macOS (OSX)
```bash
cd OSX
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j<threads>
```

### iOS
```bash
cd iOS
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j<threads>
```

### Windows
```powershell
cd Windows
cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release
cmake --build . --parallel <threads> --config Release
```

---

## Dependency Management

By default, the CMake configuration will download dependencies (`thirdparty` and `zkllvm`) from the **develop** branch.

- To specify a custom branch:
```bash
cmake .. -DGENIUS_DEPENDENCY_BRANCH=<BranchName>
```

- To specify a tagged release:
```bash
cmake .. -DBRANCH_IS_TAG=ON -DGENIUS_DEPENDENCY_BRANCH=<TagName>
```
Example:
```bash
cmake .. -DBRANCH_IS_TAG=ON -DGENIUS_DEPENDENCY_BRANCH=TestNet-Phase-3.2
```

This will fetch artifacts from GitHub releases for `zkllvm` and `thirdparty`.

---

## Build Tools

### POSIX Platforms (Linux, Android, macOS, iOS)
- Standard build:
```bash
make -j<threads>
```

- With **Ninja** (if installed):
```bash
cmake -G Ninja ..
ninja -j<threads>
```

### Windows
```powershell
cmake --build . --parallel <threads> --config Release
```

---

## Summary

This template provides a consistent cross-platform setup for building with CMake:
- Organized directories for each platform and architecture.
- Flexible dependency fetching from branches or tagged releases.
- Support for both `make` and `ninja` on POSIX platforms.
- Windows builds with Visual Studio generator.
