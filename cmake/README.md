# Qt 公共配置模块 (qtcommon.cmake) 使用文档

## 📖 概述

`qtcommon.cmake` 是一个 CMake 公共配置和工具函数库，提供了统一的编译配置、库构建、测试程序构建、以及完善的打包功能。此模块支持 Qt6 和 Qt5，并提供了跨平台的自动打包功能。

## 📚 文档索引

- [快速开始](#-快速开始) - 基本使用方法
- [核心功能](#-核心功能) - 主要功能列表
- [打包完全指南](./PACKAGING.md) - **详细的单项目和多项目打包文档**
- [函数参考](#-函数参考) - 所有可用函数的详细说明
- [最佳实践](#-最佳实践) - 使用建议和技巧

## 🚀 快速开始

### 基本使用（可执行程序）

在 `CMakeLists.txt` 中包含此模块：

```cmake
include(${CMAKE_CURRENT_LIST_DIR}/cmake/qtcommon.cmake)

get_src_include()
cpp_execute(${PROJECT_NAME})
setup_qt(${PROJECT_NAME})
```

### 自动打包（推荐）

添加 `DEPLOY` 选项实现一键打包：

```cmake
include(${CMAKE_CURRENT_LIST_DIR}/cmake/qtcommon.cmake)

get_src_include()
cpp_execute(${PROJECT_NAME})
setup_qt(${PROJECT_NAME} DEPLOY)  # 自动打包所有依赖
```

**详细打包说明请查看 [PACKAGING.md](./PACKAGING.md)**

### 库编译示例

**编译静态库**：
```cmake
include(${CMAKE_CURRENT_LIST_DIR}/cmake/qtcommon.cmake)

get_src_include()
cpp_library(mylib)

# 构建静态库
# cmake -S . -B build -DMYLIB_SHARED=OFF
# cmake --build build
```

**编译动态库**：
```cmake
include(${CMAKE_CURRENT_LIST_DIR}/cmake/qtcommon.cmake)

get_src_include()
cpp_library(mylib)

# 构建动态库（默认）
# cmake -S . -B build
# cmake --build build
```

**同时编译库和可执行程序**：
```cmake
include(${CMAKE_CURRENT_LIST_DIR}/cmake/qtcommon.cmake)

# 编译库
get_src_include()
cpp_library(mylib)

# 编译可执行程序（链接库）
get_src_include()
cpp_execute(myapp mylib)
```

**使用外部库**：
```cmake
include(${CMAKE_CURRENT_LIST_DIR}/cmake/qtcommon.cmake)

get_src_include()
cpp_execute(myapp)

# 查找并链接外部库
find_and_link_library(myapp OpenCV REQUIRED)
find_and_link_library(myapp Boost REQUIRED COMPONENTS system filesystem)
```

## 📚 主要功能

### 1. Qt 查找与链接

#### setup_qt 函数

**功能**：统一查找并链接 Qt（支持 Qt6/Qt5，默认 Widgets）

**用法**：
```cmake
setup_qt(<target> [WIN32] [NO_WIN32] [DEPLOY] [COMPONENTS Widgets Gui Core ...])
```

**参数说明**：
- `target`: 目标名称（必需）
- `WIN32`: 在 Windows 上隐藏控制台窗口（Windows 子系统，默认启用）
- `NO_WIN32`: 在 Windows 上显示控制台窗口（控制台应用）
- `DEPLOY`: 自动打包所有 Qt 依赖（构建后）
- `COMPONENTS`: Qt 组件列表，默认仅 Widgets

**特性**：
- 自动优先查找 Qt6，不存在则回落 Qt5
- 必须先创建目标（add_executable/add_library）再调用
- 默认仅链接 Widgets，如需额外组件使用 COMPONENTS 传入
- Windows 上默认隐藏控制台（WIN32），如需显示控制台使用 NO_WIN32
- 使用 DEPLOY 选项可自动打包所有 Qt 依赖，无需手动配置 PATH

**示例**：
```cmake
# 基本使用（默认 Widgets，隐藏控制台）
setup_qt(my_app)

# 指定多个组件
setup_qt(my_app COMPONENTS Widgets Gui Core Network)

# 显示控制台窗口（命令行工具）
setup_qt(my_app NO_WIN32)

# 自动打包所有依赖（推荐用于发布）
setup_qt(my_app DEPLOY)
```

### 2. Windows 控制台窗口控制

**默认行为**：隐藏控制台窗口（Windows 子系统，适合 GUI 应用）

```cmake
setup_qt(my_app)        # 默认隐藏控制台
setup_qt(my_app WIN32)  # 显式指定隐藏控制台
```

**显示控制台窗口**（适合命令行工具）：
```cmake
setup_qt(my_app NO_WIN32)  # 显示控制台窗口
```

### 3. Windows 运行与打包

**默认行为**：自动复制 platforms 插件到运行目录（轻量级）
```cmake
setup_qt(my_app)  # 仅复制 platforms 插件
```

**自动打包所有依赖**（推荐，无需配置 PATH）：
```cmake
setup_qt(my_app DEPLOY)  # 使用 windeployqt 自动打包所有 Qt 依赖
```

**说明**：
- 默认方式仍需确保 Qt 的 bin 目录在 PATH 中
- DEPLOY 方式无需配置 PATH，所有依赖自动复制

### 4. macOS 运行/打包

**默认配置**：
- 已启用 `CMAKE_MACOSX_RPATH` 和 `MACOSX_BUNDLE`
- 需要手动运行 `macdeployqt` 打包

**自动打包**：
```cmake
setup_qt(my_app DEPLOY)  # 使用 macdeployqt 自动打包所有 Qt 依赖
```

**手动打包命令**：
```bash
macdeployqt path/to/App.app
```

### 5. Linux 运行/打包

**默认**：需要手动配置 Qt 依赖或使用系统包管理器

**自动打包**：
```cmake
setup_qt(my_app DEPLOY)  # 使用 linuxdeployqt 自动打包（需安装）
```

**注意事项**：
- 如需 X11/Wayland 等模块，请在 COMPONENTS 中显式添加相应 Qt 组件
- linuxdeployqt 需要单独安装：https://github.com/probonopd/linuxdeployqt

### 6. compile_commands.json 生成方法

**功能**：生成 `compile_commands.json` 文件，用于 clangd、IDE 代码补全和跳转

**自动生成（推荐）**：
- 使用 Ninja 生成器时，会在配置阶段自动生成 `compile_commands.json`
- 构建时会自动同步到源码根目录（通过 `copy_compile_commands` 目标）
- 命令：`cmake -S . -B build -G "Ninja" && cmake --build build`

**手动生成（如果需要）**：

方法1：运行独立目标（推荐，Ninja/Unix Makefiles）
```bash
cmake --build build --target gen_compile_commands
```

方法2：运行自动同步目标（构建时已自动运行）
```bash
cmake --build build --target copy_compile_commands
```

方法3：手动复制（如果自动同步失败）
```bash
# Windows
copy build\compile_commands.json .

# Linux/macOS
cp build/compile_commands.json .
```

方法4：Visual Studio 生成器不支持，需改用 Ninja 生成器
```bash
cmake -S . -B build-ninja -G "Ninja" -DCMAKE_BUILD_TYPE=Release
```

**验证生成**：
```bash
# Linux/macOS
ls compile_commands.json

# Windows
dir compile_commands.json
```

**文件位置**：项目根目录（与 CMakeLists.txt 同级）

**注意事项**：
- 仅 Ninja/Unix Makefiles 等生成器支持
- Visual Studio 生成器不支持，建议使用 Ninja 生成器

### 7. 生成器选择

**推荐使用 Ninja**（更快，支持 compile_commands.json）：
- **安装**：通过 vcpkg、scoop 或 CMake 自带（CMake 3.10+ 内置）
- **使用**：`cmake -S . -B build -G "Ninja" -DCMAKE_BUILD_TYPE=Release`

**Visual Studio 生成器**（适合 IDE 集成）：
```bash
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
```

## 📝 平台生成示例

### Windows 生成示例

**Ninja 生成器（推荐，支持 compile_commands.json）**：
```powershell
$env:QT_PREFIX_PATH="C:\Qt\5.12.12\msvc2017_64"  # 或 Qt6 路径
cmake -S . -B build -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$env:QT_PREFIX_PATH"
cmake --build build
# compile_commands.json 会自动同步到源码根目录
```

**Visual Studio 生成器（不支持 compile_commands.json）**：
```powershell
cmake -S . -B build -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="$env:QT_PREFIX_PATH"
cmake -S . -B build -G "Visual Studio 15 2017" -A x64 -DCMAKE_PREFIX_PATH="$env:QT_PREFIX_PATH"
cmake --build build --config Release
```

### macOS 生成示例（推荐 Ninja + clang）

```bash
export QT_PREFIX_PATH="/path/to/Qt/6.6.0/macos"  # 或 Qt5 路径
cmake -S . -B build -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$QT_PREFIX_PATH"
cmake --build build
# compile_commands.json 会自动同步到源码根目录
# 打包：macdeployqt path/to/App.app
```

### Linux 生成示例（推荐 Ninja）

```bash
export QT_PREFIX_PATH="/path/to/Qt/6.6.0/gcc_64"  # 或 Qt5 路径
cmake -S . -B build -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$QT_PREFIX_PATH"
cmake --build build
# compile_commands.json 会自动同步到源码根目录
# 如需 Wayland/X11 组件，使用 COMPONENTS 显式添加相应模块
```

## 🔧 其他工具函数

### get_src_include 宏

**功能**：自动收集当前目录下的所有源码文件和头文件

**用法**：
```cmake
get_src_include()
```

**输出变量**：
- `SRC`: 所有 .cpp/.cc/.cxx 等源文件（通过 `aux_source_directory` 收集）
- `H_FILE`: 当前目录下的所有 .h 头文件（内部头文件）
- `UI_FILE`: 当前目录下的所有 .ui 文件（Qt UI 文件）
- `H_FILE_I`: include/ 目录下的所有头文件（对外接口）

**说明**：
- 自动扫描当前目录和 include/ 子目录
- 收集结果会显示在配置输出中（带颜色）
- 通常与 `cpp_execute` 或 `cpp_library` 配合使用

### cpp_execute 函数

**功能**：创建一个可执行文件，并链接指定的库

**用法**：
```cmake
cpp_execute(<name> [lib1] [lib2] ...)
```

**参数**：
- `name`: 可执行文件的目标名称（必需）
- `lib1, lib2, ...`: 要链接的库名称（可选，可多个）

**功能特性**：
- 自动收集源码和头文件（调用 `get_src_include()`）
- 应用统一的 C++ 配置（调用 `set_cpp()`）
- 自动处理 Debug 版本库名后缀（Windows：添加 'd' 后缀）
- 自动链接 pthread（Linux/Unix）
- 配置输出路径到 `bin/` 目录
- 构建完成后显示命令提示

**示例**：
```cmake
cpp_execute(my_app xlog xthread_pool)
# 这会创建一个名为 my_app 的可执行文件，并链接 xlog 和 xthread_pool 库
```

### set_cpp 宏

**功能**：为指定的目标配置统一的 C++ 编译设置

**用法**：
```cmake
set_cpp(<name>)
```

**配置内容**：
- 头文件搜索路径（当前目录、include/、上级目录等）
- C++ 标准版本（C++17）
- MSVC 特殊选项（-bigobj）
- pthread 链接（Linux/Unix）
- 输出目录配置（bin/、lib/）
- Debug 版本后缀（'d'）

**说明**：
- 通常由 `cpp_execute` 或 `cpp_library` 内部调用
- 也可手动调用以统一配置

### cpp_library 函数

**功能**：创建一个静态库或动态库，并配置安装规则

**用法**：
```cmake
cpp_library(<name>)
```

**控制选项**：
- `${NAME}_SHARED`: 控制库的类型
  - `ON`: 构建动态库（.dll, .so, .dylib）
  - `OFF`: 构建静态库（.lib, .a）
- 可通过 `cmake -DXLOG_SHARED=OFF` 来控制

**功能特性**：
- 自动收集源码和头文件
- 应用统一的 C++ 配置
- 配置安装规则（库文件和头文件）
- 支持静态库和动态库切换
- 自动生成 CMake 配置文件（支持 `find_package`）
- 生成版本配置文件
- 构建完成后显示库文件位置和常用命令

**示例**：
```cmake
# 在 CMakeLists.txt 中使用
get_src_include()
cpp_library(mylib)

# 构建动态库（默认）
cmake -S . -B build
cmake --build build

# 构建静态库
cmake -S . -B build -DMYLIB_SHARED=OFF
cmake --build build
```

**输出位置**：
- Windows: `bin/mylib.dll` (动态库) 或 `lib/mylib.lib` (静态库)
- Linux: `lib/libmylib.so` (动态库) 或 `lib/libmylib.a` (静态库)
- macOS: `lib/libmylib.dylib` (动态库) 或 `lib/libmylib.a` (静态库)

**安装库**：
```bash
# 安装到默认位置
cmake --install build

# 安装到指定位置
cmake --install build --prefix ./install
```

**在其他项目中使用**：
```cmake
# 在其他项目的 CMakeLists.txt 中
find_package(mylib REQUIRED)
target_link_libraries(myapp PRIVATE mylib)
```

### cpp_test 函数

**功能**：创建一个使用 Google Test 框架的单元测试可执行文件，并集成 CTest

**用法**：
```cmake
cpp_test(<name> [LIB_SRC_DIR <dir>])
```

**参数**：
- `name`: 测试程序的目标名称（必需）
- `LIB_SRC_DIR`: 被测试库的源码目录（可选，默认: `../`）

**功能特性**：
- 自动查找和配置 GTest（支持多种查找方式）
- 自动收集测试源码和头文件
- 可选收集被测试库的源码
- 自动链接 GTest 库
- 自动集成 CTest（使用 `gtest_discover_tests`）
- 自动启用测试框架（`enable_testing()`）

**GTest 查找方式**：
1. **环境变量**：设置 `GTEST_PATH` 指向 GTest 安装目录
2. **find_package**：自动查找 CMake 包
3. **vcpkg**：使用 `vcpkg install gtest`
4. **手动查找**：从 `GTEST_PATH` 环境变量指定的路径查找

**示例**：

**基本使用**：
```cmake
# 在 tests/CMakeLists.txt 中
include(${CMAKE_SOURCE_DIR}/cmake/qtcommon.cmake)

# 创建测试（自动收集当前目录的测试文件）
cpp_test(mylib_test)
```

**指定库源码目录**：
```cmake
# 测试项目根目录的库
cpp_test(mylib_test LIB_SRC_DIR ${CMAKE_SOURCE_DIR})
```

**完整示例**：
```cmake
# 主 CMakeLists.txt
project(MyApp LANGUAGES CXX)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/qtcommon.cmake)

# 添加测试子目录
add_subdirectory(tests)

# tests/CMakeLists.txt
include(${CMAKE_SOURCE_DIR}/cmake/qtcommon.cmake)
cpp_test(mylib_test LIB_SRC_DIR ${CMAKE_SOURCE_DIR})
```

**运行测试**：

**使用 CTest**（推荐）：
```bash
# 配置项目
cmake -S . -B build

# 构建测试
cmake --build build

# 运行所有测试
ctest --test-dir build

# 运行测试（详细输出）
ctest --test-dir build --output-on-failure -V

# 运行特定测试
ctest --test-dir build -R MyLibTest
```

**使用 CMake**：
```bash
# 运行测试目标
cmake --build build --target test

# 或
cmake --build build -t test
```

**使用可执行文件**：
```bash
# 直接运行测试可执行文件
./build/tests/mylib_test

# 或 Windows
.\build\tests\Release\mylib_test.exe
```

**测试输出示例**：
```
Test project D:/Document/Qt/Test/TestApp/build
    Start 1: MyLibTest.AddTest
1/4 Test #1: MyLibTest.AddTest ................   Passed    0.01 sec
    Start 2: MyLibTest.MultiplyTest
2/4 Test #2: MyLibTest.MultiplyTest ..........   Passed    0.01 sec
    Start 3: MyLibTest.GetVersionTest
3/4 Test #3: MyLibTest.GetVersionTest ........   Passed    0.01 sec
    Start 4: MyLibTestSuite.FixtureTest
4/4 Test #4: MyLibTestSuite.FixtureTest ......   Passed    0.01 sec

100% tests passed, 0 tests failed out of 4
```

**设置 GTest 路径**：

**Windows**：
```powershell
# 设置环境变量
$env:GTEST_PATH="C:\path\to\gtest"

# 或使用 vcpkg
vcpkg install gtest:x64-windows
```

**Linux/macOS**：
```bash
# 设置环境变量
export GTEST_PATH=/usr/local

# 或安装系统包
sudo apt-get install libgtest-dev  # Ubuntu/Debian
brew install googletest            # macOS
```

**vcpkg**（推荐）：
```bash
# 安装 GTest
vcpkg install gtest

# 配置 CMake
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

**注意事项**：
- 测试文件应放在 `tests/` 目录或测试子目录中
- 测试文件应包含 `gtest/gtest.h` 头文件
- 使用 `TEST` 或 `TEST_F` 宏定义测试用例
- 测试会自动被 CTest 发现，无需手动注册
- 如果未找到 GTest，配置会失败并给出提示

### get_env_with_default 宏

**功能**：获取指定的环境变量，如果不存在则使用默认值

**用法**：
```cmake
get_env_with_default(<var_name> <default_value> <output_var>)
```

**参数**：
- `var_name`: 环境变量名称
- `default_value`: 环境变量不存在时的默认值
- `output_var`: 存储结果的变量名

**示例**：
```cmake
get_env_with_default("MY_COMPILER" "g++" COMPILER)
message("编译器: ${COMPILER}")
```

### check_required_env 宏

**功能**：检查指定的环境变量是否存在，如果不存在则报错并退出

**用法**：
```cmake
check_required_env(<var_name>)
```

**参数**：
- `var_name`: 必需的环境变量名称

**说明**：
- 如果环境变量未设置，会立即终止 CMake 配置
- 用于确保必需的配置已设置

### find_and_link_library 函数

**功能**：统一查找和链接外部库，支持多种查找方式

**用法**：
```cmake
find_and_link_library(<target> <lib_name> [METHOD <method>] [COMPONENTS <comp1> <comp2> ...] [REQUIRED])
```

**参数**：
- `target`: 目标名称（必需，必须先创建目标）
- `lib_name`: 库名称（必需）
- `METHOD`: 查找方法（可选）
  - `AUTO`: 自动选择（默认，优先 find_package，然后 pkg-config，最后手动）
  - `CMAKE`: 使用 `find_package`（CMake 包）
  - `PKG`: 使用 `pkg-config`（Linux/macOS）
  - `MANUAL`: 手动指定路径（需要环境变量）
- `COMPONENTS`: 库组件列表（可选，用于 find_package）
- `REQUIRED`: 如果未找到则报错（可选）

**环境变量支持**（用于 MANUAL 方法）：
- `${LIB_NAME}_PATH`: 库的安装路径（例如：`OPENCV_PATH=/path/to/opencv`）
- `${LIB_NAME}_INCLUDE_PATH`: 头文件路径（可选，默认从 `${LIB_NAME}_PATH/include` 查找）

**功能特性**：
- 自动选择最佳查找方式
- 支持 CMake 包（find_package）
- 支持 pkg-config（Linux/macOS）
- 支持手动指定路径（通过环境变量）
- 自动链接库和头文件
- 支持组件库（如 Boost）
- 彩色输出，显示查找状态

**示例**：

**使用 find_package（推荐）**：
```cmake
# 基本使用
find_and_link_library(myapp OpenCV REQUIRED)

# 带组件的库（如 Boost）
find_and_link_library(myapp Boost REQUIRED COMPONENTS system filesystem thread)

# 指定方法
find_and_link_library(myapp OpenCV METHOD CMAKE REQUIRED)
```

**使用 pkg-config（Linux/macOS）**：
```cmake
# 自动使用 pkg-config（如果 find_package 失败）
find_and_link_library(myapp opencv REQUIRED)

# 显式指定使用 pkg-config
find_and_link_library(myapp opencv METHOD PKG REQUIRED)
```

**手动指定路径**：
```bash
# 设置环境变量
export OPENCV_PATH=/usr/local/opencv
export OPENCV_INCLUDE_PATH=/usr/local/opencv/include

# 或 Windows PowerShell
$env:OPENCV_PATH="C:\opencv"
$env:OPENCV_INCLUDE_PATH="C:\opencv\include"
```

```cmake
# 在 CMakeLists.txt 中使用
find_and_link_library(myapp OpenCV METHOD MANUAL REQUIRED)
```

**完整示例**：
```cmake
# CMakeLists.txt
include(${CMAKE_CURRENT_LIST_DIR}/cmake/qtcommon.cmake)

get_src_include()
cpp_execute(myapp)

# 查找并链接 OpenCV
find_and_link_library(myapp OpenCV REQUIRED)

# 查找并链接 Boost（带组件）
find_and_link_library(myapp Boost REQUIRED COMPONENTS system filesystem)

# 查找并链接自定义库（手动路径）
find_and_link_library(myapp mylib METHOD MANUAL)
```

**查找顺序**（AUTO 方法）：
1. 尝试 `find_package`（CMake 包）
2. 如果失败且非 Windows，尝试 `pkg-config`
3. 如果失败，尝试从环境变量手动查找

**注意事项**：
- 必须先创建目标（`add_executable` 或 `add_library`）再调用
- `REQUIRED` 选项确保库存在，否则构建失败
- 手动方法需要设置相应的环境变量
- 库名称区分大小写

## 🎨 颜色输出支持

模块支持 ANSI 颜色输出，使配置信息更清晰易读：

- **青色（Cyan）**：标题、分隔线、配置目标
- **绿色（Green）**：路径、文件数量、完成提示
- **黄色（Yellow）**：使用模式、提示信息
- **洋红色（Magenta）**：项目名称、版本、Qt 版本
- **蓝色（Blue）**：文件收集信息
- **粗体（Bold）**：重要数值和关键信息

**兼容性**：
- 自动检测终端环境，不支持颜色时自动禁用
- Windows PowerShell 7+ 和现代终端支持 ANSI 颜色
- 在非终端环境（如 IDE）中自动降级为普通文本

## 🔍 Qt 路径查找机制

模块会自动从以下位置查找 Qt 安装路径（按优先级）：

1. **环境变量** `QT_PREFIX_PATH`（最高优先级）
2. **Qt5Core_DIR** 或 **Qt6Core_DIR**（最可靠）
3. **Qt5_DIR** 或 **Qt6_DIR**（备用方案）
4. **QtCore 目标位置**（最后备用）

如果找到路径，会自动用于：
- 插件复制（Windows）
- 打包工具查找（windeployqt/macdeployqt/linuxdeployqt）

## 📦 输出目录结构

- **可执行文件**：`${CMAKE_SOURCE_DIR}/bin/`
- **库文件**：`${CMAKE_SOURCE_DIR}/lib/`
- **compile_commands.json**：`${CMAKE_SOURCE_DIR}/`（项目根目录）

## 🐛 常见问题

### Q: Visual Studio 生成器不支持 compile_commands.json？

**A**: 是的，Visual Studio 生成器不支持。请使用 Ninja 生成器：
```bash
cmake -S . -B build -G "Ninja" -DCMAKE_BUILD_TYPE=Release
```

### Q: 如何设置 Qt 路径？

**A**: 推荐使用环境变量：
```bash
# Windows PowerShell
$env:QT_PREFIX_PATH="C:\Qt\6.6.0\msvc2019_64"

# Linux/macOS
export QT_PREFIX_PATH="/path/to/Qt/6.6.0/gcc_64"
```

### Q: 如何打包 Qt 应用？

**A**: 使用 `DEPLOY` 选项：
```cmake
setup_qt(my_app DEPLOY)
```

构建后会自动运行对应的打包工具（windeployqt/macdeployqt/linuxdeployqt）。

### Q: 如何显示控制台窗口？

**A**: 使用 `NO_WIN32` 选项：
```cmake
setup_qt(my_app NO_WIN32)
```

## 📄 许可证

此模块为项目内部使用，请遵循项目许可证。

## 🧪 自动测试

### 测试脚本

项目提供了自动测试脚本，可以验证 CMake 配置和构建功能。

**PowerShell 脚本（Windows）**：
```powershell
# 快速测试（配置和构建）
.\test.ps1 quick

# 完整测试（包括功能验证）
.\test.ps1 all

# 仅配置测试
.\test.ps1 config

# 仅构建测试
.\test.ps1 build
```

**Bash 脚本（Linux/macOS）**：
```bash
# 快速测试（配置和构建）
./test.sh quick

# 完整测试（包括功能验证）
./test.sh all

# 仅配置测试
./test.sh config

# 仅构建测试
./test.sh build
```

**CMake 测试目标**：
```bash
# 运行所有测试
cmake --build build --target run_tests

# 快速测试
cmake --build build --target test_quick

# 配置测试
cmake --build build --target test_config

# 构建测试
cmake --build build --target test_build
```

**CMake 脚本方式**：
```bash
# 运行所有测试
cmake -P cmake/run_tests.cmake

# 快速测试
cmake -DTEST_MODE=quick -P cmake/run_tests.cmake

# 配置测试
cmake -DTEST_MODE=config -P cmake/run_tests.cmake

# 构建测试
cmake -DTEST_MODE=build -P cmake/run_tests.cmake
```

### 测试内容

**快速测试（quick）**：
- CMake 配置测试
- 构建测试
- 可执行文件检查

**完整测试（all）**：
- CMake 配置测试
- 构建测试
- 功能验证测试
- 清理测试

**功能验证测试包括**：
- `compile_commands.json` 生成检查
- `platforms` 插件复制检查（Windows）
- 其他功能验证

### 测试输出示例

```
============================================================================
自动测试脚本
============================================================================
测试模式: quick
构建目录: build-test

============================================================================
测试组 1: CMake 配置测试
============================================================================
测试 1 : CMake 配置 (Visual Studio x64)
  ✓ 通过

============================================================================
测试组 2: 构建测试
============================================================================
测试 2 : 构建项目 (Release)
  ✓ 通过
  ✓ 可执行文件存在: bin\TestApp.exe

============================================================================
测试结果汇总
============================================================================
总测试数: 3
通过: 3
失败: 0

✓ 所有测试通过！
```

## 📞 支持

如有问题或建议，请联系项目维护者。

