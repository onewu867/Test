# Qt 项目打包完全指南

本文档详细介绍 `qtcommon.cmake` 中的打包功能，包括单项目和多项目场景的编译与打包方法。

---

## 目录

- [概述](#概述)
- [单项目打包](#单项目打包)
  - [基础用法](#基础用法)
  - [完整打包](#完整打包)
  - [自定义插件](#自定义插件)
- [多项目打包](#多项目打包)
  - [统一打包目录](#统一打包目录)
  - [批量打包](#批量打包)
  - [依赖管理](#依赖管理)
- [CPack 集成](#cpack-集成)
  - [生成安装包](#生成安装包)
  - [平台特定配置](#平台特定配置)
- [打包辅助函数](#打包辅助函数)
- [最佳实践](#最佳实践)
- [故障排除](#故障排除)

---

## 概述

`qtcommon.cmake` 提供了完整的 Qt 项目打包解决方案，支持：

- ✅ 单个项目自动打包（开发和发布模式）
- ✅ 多个项目统一打包管理
- ✅ 跨平台支持（Windows、macOS、Linux）
- ✅ 自动依赖检测和复制
- ✅ CPack 集成生成安装包
- ✅ 灵活的配置选项

---

## 单项目打包

### 基础用法

最简单的方式是使用 `setup_qt()` 函数的 `DEPLOY` 选项：

```cmake
cmake_minimum_required(VERSION 3.5)
project(MyApp VERSION 1.0.0)

# 包含 qtcommon.cmake
include(cmake/qtcommon.cmake)

# 创建可执行文件
get_src_include()
cpp_execute(${PROJECT_NAME})

# 自动打包（标准模式）
setup_qt(${PROJECT_NAME} DEPLOY)
```

**效果**：
- Windows: 自动运行 `windeployqt`，复制所有必要的 Qt DLL 和插件
- macOS: 自动运行 `macdeployqt`，创建独立的 .app Bundle
- Linux: 自动运行 `linuxdeployqt`（如果安装）

**构建命令**：
```powershell
cmake -S . -B build -G Ninja
cmake --build build
```

### 完整打包

对于需要发布的最终版本，使用 `DEPLOY_FULL` 选项：

```cmake
# 完整打包模式（包含所有插件和翻译文件）
setup_qt(${PROJECT_NAME} DEPLOY_FULL)
```

**与标准模式的区别**：

| 模式 | 标准 DEPLOY | 完整 DEPLOY_FULL |
|------|------------|------------------|
| 翻译文件 | ❌ 不包含 | ✅ 包含所有语言 |
| D3D 编译器 | ❌ 排除 | ✅ 包含 |
| OpenGL 软件渲染 | ❌ 排除 | ✅ 包含 |
| 所有插件 | 部分 | ✅ 全部 |
| 适用场景 | 开发/测试 | 最终发布 |

### 自定义插件

如果需要特定的 Qt 插件（如图片格式、图标引擎等）：

```cmake
# 使用内部函数复制额外的插件
setup_qt(${PROJECT_NAME} DEPLOY)

# 复制额外的插件类别
_copy_qt_plugins(${PROJECT_NAME} "imageformats;iconengines;styles")
```

**支持的插件类别**：
- `platforms` - 平台插件（自动包含）
- `imageformats` - 图片格式（JPEG、PNG、SVG 等）
- `iconengines` - 图标引擎
- `styles` - 样式插件
- `sqldrivers` - 数据库驱动
- `networkinformation` - 网络信息
- `tls` - TLS/SSL 后端

---

## 多项目打包

### 统一打包目录

对于包含多个子项目的工作区，使用 `setup_multi_project_package()` 创建统一的打包目录：

```cmake
# 顶层 CMakeLists.txt
cmake_minimum_required(VERSION 3.5)
project(MyWorkspace VERSION 1.0.0)

include(cmake/qtcommon.cmake)

# 配置多项目统一打包
setup_multi_project_package(
    PROJECTS App1 App2 LibraryA
    OUTPUT_DIR ${CMAKE_BINARY_DIR}/package
)

# 添加子项目
add_subdirectory(app1)
add_subdirectory(app2)
add_subdirectory(library_a)
```

**目录结构**：
```
build/package/
├── bin/           # 所有可执行文件
│   ├── App1.exe
│   └── App2.exe
├── lib/           # 所有库文件
│   └── LibraryA.dll
├── plugins/       # Qt 插件
│   └── platforms/
└── docs/          # 文档
```

### 批量打包

使用自动生成的 `package_all` 目标一键打包所有项目：

```powershell
# 构建并打包所有项目
cmake --build build --target package_all
```

这会：
1. 构建所有指定的项目
2. 复制可执行文件到 `package/bin/`
3. 复制库文件到 `package/lib/`
4. 自动处理依赖关系

### 依赖管理

在多项目场景中，`setup_qt()` 会自动检测并处理依赖：

```cmake
# 子项目 CMakeLists.txt
project(App1)

get_src_include()
cpp_execute(${PROJECT_NAME})

# 自动打包，并复制到统一目录
setup_qt(${PROJECT_NAME} DEPLOY)

# 链接其他项目的库
target_link_libraries(${PROJECT_NAME} PRIVATE LibraryA)
```

**自动处理**：
- ✅ 检测是否为多项目模式
- ✅ 自动复制到统一打包目录
- ✅ 避免重复复制 Qt 依赖

---

## CPack 集成

### 生成安装包

使用 `setup_cpack()` 配置 CPack，生成专业的安装包：

```cmake
# 在顶层 CMakeLists.txt 中
project(MyApp VERSION 1.0.0)

include(cmake/qtcommon.cmake)

# 配置项目...
get_src_include()
cpp_execute(${PROJECT_NAME})
setup_qt(${PROJECT_NAME} DEPLOY_FULL)

# 配置 CPack
setup_cpack(
    VENDOR "MyCompany"
    DESCRIPTION "MyApp - 一个强大的 Qt 应用程序"
    LICENSE_FILE "${CMAKE_SOURCE_DIR}/LICENSE"
    README_FILE "${CMAKE_SOURCE_DIR}/README.md"
    ICON "${CMAKE_SOURCE_DIR}/resources/app.ico"
    CONTACT "support@mycompany.com"
)
```

**生成安装包**：
```powershell
# 构建项目
cmake --build build --config Release

# 生成安装包
cmake --build build --target package
```

### 平台特定配置

#### Windows (NSIS)

生成 `.exe` 安装程序和 `.zip` 压缩包：

```cmake
setup_cpack(
    VENDOR "MyCompany"
    ICON "${CMAKE_SOURCE_DIR}/installer.ico"
    # NSIS 特定配置会自动应用
)
```

**特性**：
- 开始菜单快捷方式
- 卸载程序
- 安装前卸载旧版本
- 自定义安装路径
- 系统 PATH 修改（可选）

#### macOS (DMG)

生成 `.dmg` 磁盘镜像：

```cmake
setup_cpack(
    VENDOR "MyCompany"
    ICON "${CMAKE_SOURCE_DIR}/app.icns"
)
```

**特性**：
- 拖放式安装界面
- 应用程序 Bundle
- 压缩格式 (UDBZ)

#### Linux (DEB/RPM)

生成 `.deb`、`.rpm` 和 `.tar.gz` 包：

```cmake
setup_cpack(
    VENDOR "MyCompany"
    CONTACT "support@mycompany.com"
)
```

**特性**：
- 系统包管理器集成
- 依赖自动处理
- 符合 FHS 标准

---

## 打包辅助函数

### _copy_qt_plugins()

复制指定的 Qt 插件到目标目录：

```cmake
_copy_qt_plugins(MyApp "imageformats;iconengines")
```

### _generate_qt_conf()

生成 `qt.conf` 配置文件，指定插件和库的相对路径：

```cmake
_generate_qt_conf(MyApp)
```

生成的 `qt.conf` 内容：
```ini
[Paths]
Plugins = .
Libraries = .
```

### setup_package_directory()

为单个项目创建打包目录结构：

```cmake
setup_package_directory(NAME MyApp)
```

---

## 最佳实践

### 1. 开发与发布分离

**开发阶段**：
```cmake
# 使用标准打包，快速迭代
setup_qt(${PROJECT_NAME} DEPLOY)
```

**发布阶段**：
```cmake
# 使用完整打包，包含所有依赖
setup_qt(${PROJECT_NAME} DEPLOY_FULL)

# 配置 CPack 生成安装包
setup_cpack(...)
```

### 2. 控制台应用处理

对于需要控制台输出的应用（如命令行工具）：

```cmake
# 显示控制台窗口
setup_qt(${PROJECT_NAME} NO_WIN32 DEPLOY)
```

### 3. 多项目组织结构

推荐的目录结构：

```
MyWorkspace/
├── CMakeLists.txt          # 顶层配置
├── cmake/
│   ├── qtcommon.cmake      # Qt 公共配置
│   └── PACKAGING.md        # 本文档
├── app1/
│   ├── CMakeLists.txt
│   └── src/
├── app2/
│   ├── CMakeLists.txt
│   └── src/
└── shared_lib/
    ├── CMakeLists.txt
    └── src/
```

**顶层 CMakeLists.txt**：
```cmake
cmake_minimum_required(VERSION 3.5)
project(MyWorkspace VERSION 1.0.0)

include(cmake/qtcommon.cmake)

# 配置统一打包
setup_multi_project_package(
    PROJECTS app1 app2
    OUTPUT_DIR ${CMAKE_BINARY_DIR}/package
)

add_subdirectory(shared_lib)
add_subdirectory(app1)
add_subdirectory(app2)

# 配置 CPack（可选）
setup_cpack(VENDOR "MyCompany")
```

### 4. 版本管理

在项目根目录使用版本号：

```cmake
project(MyApp VERSION 1.2.3)

# 版本号会自动传递给 CPack
setup_cpack(...)
```

### 5. 资源文件组织

```
resources/
├── app.ico          # Windows 图标
├── app.icns         # macOS 图标
├── LICENSE          # 许可证
└── README.md        # 说明文档
```

---

## 故障排除

### 问题 1: 找不到 windeployqt

**症状**：
```
Windows: 未找到 windeployqt 工具，无法自动打包
```

**解决方法**：
```powershell
# 方法 1: 设置环境变量
$env:QT_PREFIX_PATH = "C:\Qt\6.5.0\msvc2019_64"

# 方法 2: 在 CMake 配置时指定
cmake -S . -B build -DCMAKE_PREFIX_PATH="C:/Qt/6.5.0/msvc2019_64"
```

### 问题 2: 多项目重复复制依赖

**症状**：每个子项目都复制了一份完整的 Qt 依赖

**解决方法**：
使用统一打包模式：

```cmake
# 顶层 CMakeLists.txt
setup_multi_project_package(PROJECTS app1 app2)

# 子项目只需标准配置
setup_qt(${PROJECT_NAME} DEPLOY)
```

### 问题 3: CPack 生成的包无法运行

**可能原因**：缺少运行时依赖

**解决方法**：
```cmake
# 确保使用 DEPLOY_FULL 进行完整打包
setup_qt(${PROJECT_NAME} DEPLOY_FULL)

# 检查依赖（Windows）
# 构建后运行：
dumpbin /dependents build/bin/MyApp.exe
```

### 问题 4: Linux 缺少 linuxdeployqt

**解决方法**：
```bash
# 下载 linuxdeployqt
wget https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage
chmod +x linuxdeployqt-continuous-x86_64.AppImage

# 添加到 PATH
sudo mv linuxdeployqt-continuous-x86_64.AppImage /usr/local/bin/linuxdeployqt
```

### 问题 5: macOS 签名问题

**症状**：打包的应用无法在其他 Mac 上运行

**解决方法**：
```bash
# 对 Bundle 进行签名
codesign --deep --force --verify --verbose --sign "Developer ID" MyApp.app

# 创建公证的 DMG
xcrun notarytool submit MyApp.dmg --wait
```

---

## 完整示例

### 单项目完整示例

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.5)
project(ImageViewer VERSION 1.0.0 LANGUAGES CXX)

# 包含 qtcommon.cmake
include(${CMAKE_CURRENT_LIST_DIR}/cmake/qtcommon.cmake)

# 收集源文件
get_src_include()

# 创建可执行文件
cpp_execute(${PROJECT_NAME})

# 配置 Qt（完整打包模式）
setup_qt(${PROJECT_NAME} 
    DEPLOY_FULL 
    COMPONENTS Widgets Gui Core
)

# 复制额外的图片格式插件
_copy_qt_plugins(${PROJECT_NAME} "imageformats")

# 配置 CPack
setup_cpack(
    VENDOR "MyCompany"
    DESCRIPTION "ImageViewer - 专业的图片查看器"
    LICENSE_FILE "${CMAKE_SOURCE_DIR}/LICENSE"
    README_FILE "${CMAKE_SOURCE_DIR}/README.md"
    ICON "${CMAKE_SOURCE_DIR}/resources/viewer.ico"
    CONTACT "support@mycompany.com"
)
```

### 多项目完整示例

**顶层 CMakeLists.txt**：
```cmake
cmake_minimum_required(VERSION 3.5)
project(MyProductSuite VERSION 2.0.0)

include(cmake/qtcommon.cmake)

# 配置多项目打包
setup_multi_project_package(
    PROJECTS EditorApp ViewerApp ConverterApp
    OUTPUT_DIR ${CMAKE_BINARY_DIR}/release
)

# 添加子项目
add_subdirectory(editor)
add_subdirectory(viewer)
add_subdirectory(converter)
add_subdirectory(common_lib)

# 配置 CPack
setup_cpack(
    VENDOR "MyCompany"
    DESCRIPTION "MyProduct Suite - 完整的编辑工具集"
    LICENSE_FILE "${CMAKE_SOURCE_DIR}/LICENSE"
    CONTACT "support@mycompany.com"
)
```

**子项目 CMakeLists.txt**（editor/CMakeLists.txt）：
```cmake
project(EditorApp)

get_src_include()
cpp_execute(${PROJECT_NAME})

# 链接公共库
target_link_libraries(${PROJECT_NAME} PRIVATE common_lib)

# 配置 Qt（标准打包，会自动复制到统一目录）
setup_qt(${PROJECT_NAME} DEPLOY)
```

**构建和打包**：
```powershell
# 配置
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release

# 构建所有项目
cmake --build build

# 统一打包所有项目
cmake --build build --target package_all

# 生成安装包
cmake --build build --target package
```

---

## 总结

`qtcommon.cmake` 的打包功能提供了：

1. **简单易用**：只需一行 `setup_qt(target DEPLOY)` 即可实现自动打包
2. **灵活配置**：支持标准和完整打包模式，适应不同场景
3. **跨平台**：Windows、macOS、Linux 统一接口
4. **多项目支持**：统一管理多个子项目的打包
5. **专业安装包**：集成 CPack 生成各平台的标准安装包

根据项目规模和需求选择合适的打包方案，即可轻松实现 Qt 应用的分发部署。

---

**更多信息**：
- [Qt 官方文档 - 部署](https://doc.qt.io/qt-6/deployment.html)
- [CMake CPack 文档](https://cmake.org/cmake/help/latest/module/CPack.html)
- [qtcommon.cmake README](./README.md)
