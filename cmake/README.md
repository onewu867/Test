# Qt 公共配置模块 (qtcommon.cmake) 使用文档

## 📖 概述

`qtcommon.cmake` 是一个 CMake 公共配置和工具函数库，提供了统一的编译配置、库构建、测试程序构建等功能。此模块支持 Qt6 和 Qt5，并提供了跨平台的自动打包功能。

## 🚀 快速开始

### 基本使用

在 `CMakeLists.txt` 中包含此模块：

```cmake
include(${CMAKE_CURRENT_LIST_DIR}/cmake/qtcommon.cmake)

get_src_include()
cpp_execute(${PROJECT_NAME})
setup_qt(${PROJECT_NAME})
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
  - `ON`: 构建动态库（.dll, .so）
  - `OFF`: 构建静态库（.lib, .a）
- 可通过 `cmake -DXLOG_SHARED=OFF` 来控制

**功能特性**：
- 自动收集源码和头文件
- 应用统一的 C++ 配置
- 配置安装规则（库文件和头文件）
- 支持静态库和动态库切换

### cpp_test 函数

**功能**：创建一个使用 Google Test 框架的单元测试可执行文件

**用法**：
```cmake
cpp_test(<name>)
```

**功能特性**：
- 自动安装和配置 GTest
- 收集测试源码和库源码
- 链接 GTest 库
- 集成 CTest 测试发现
- 启用测试框架

**说明**：
- 需要先配置 `GTEST_PATH` 环境变量
- 测试用例会自动被 CTest 发现
- 可使用 `ctest` 命令运行所有测试

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

## 📞 支持

如有问题或建议，请联系项目维护者。

