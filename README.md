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

Each platform directory is intended to hold its respective build artifacts, in per-build-type subdirectories (`Debug/`, `Release/`).

---

## Build Instructions

### Linux
```bash
mkdir -p Linux/x86_64/Debug
cd Linux/x86_64/Debug
cmake ../.. -G Ninja -DCMAKE_BUILD_TYPE=Debug
ninja
```

### Android
```bash
mkdir -p Android/armeabi-v7a/Debug
cd Android/armeabi-v7a/Debug
cmake ../../ -G Ninja -DANDROID_ABI="armeabi-v7a" \
    -DCMAKE_ANDROID_NDK=$ANDROID_NDK \
    -DANDROID_TOOLCHAIN=clang \
    -DCMAKE_BUILD_TYPE=Debug
ninja
```
or
```bash
mkdir -p Android/arm64-v8a/Debug
cd Android/arm64-v8a/Debug
cmake ../../ -G Ninja -DANDROID_ABI="arm64-v8a" \
    -DCMAKE_ANDROID_NDK=$ANDROID_NDK \
    -DANDROID_TOOLCHAIN=clang \
    -DCMAKE_BUILD_TYPE=Debug
ninja
```

### macOS (OSX)
```bash
mkdir -p OSX/Debug
cd OSX/Debug
cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Debug
ninja
```

### iOS
```bash
mkdir -p iOS/Debug
cd iOS/Debug
cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Debug
ninja
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
- Standard build (**Ninja**, as used above):
```bash
cmake -G Ninja ..
ninja
```

- Without Ninja (Makefiles fallback):
```bash
cmake ..
make -j<threads>
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
