# Qt 项目打包快速参考卡

## 🎯 单个项目打包

### 开发模式（仅复制 platforms 插件）
```cmake
setup_qt(MyApp)
```

### 标准打包（自动复制所有依赖）
```cmake
setup_qt(MyApp DEPLOY)
```

### 完整打包（包含翻译、所有插件）
```cmake
setup_qt(MyApp DEPLOY_FULL)
```

### 控制台应用
```cmake
setup_qt(MyApp NO_WIN32 DEPLOY)
```

## 🏗️ 多项目打包

### 配置统一打包目录
```cmake
# 顶层 CMakeLists.txt
setup_multi_project_package(
    PROJECTS App1 App2 LibA
    OUTPUT_DIR ${CMAKE_BINARY_DIR}/package
)
```

### 一键打包所有项目
```powershell
cmake --build build --target package_all
```

## 📦 CPack 安装包生成

### 配置 CPack
```cmake
setup_cpack(
    VENDOR "MyCompany"
    DESCRIPTION "应用描述"
    LICENSE_FILE "LICENSE"
    ICON "app.ico"
    CONTACT "support@example.com"
)
```

### 生成安装包
```powershell
cmake --build build --target package
```

**生成结果**：
- Windows: `.exe` 安装程序 + `.zip` 压缩包
- macOS: `.dmg` 磁盘镜像 + `.tar.gz`
- Linux: `.deb` + `.rpm` + `.tar.gz`

## 🛠️ 辅助函数

### 复制额外插件
```cmake
_copy_qt_plugins(MyApp "imageformats;iconengines")
```

### 生成 qt.conf
```cmake
_generate_qt_conf(MyApp)
```

### 创建打包目录
```cmake
setup_package_directory(NAME MyApp)
```

## 📋 常用命令

### Windows (PowerShell)
```powershell
# 配置（Ninja 生成器）
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release

# 构建
cmake --build build

# 打包（单项目）
cmake --build build --target package

# 打包（多项目）
cmake --build build --target package_all

# 检查依赖
dumpbin /dependents build/bin/MyApp.exe
```

### macOS
```bash
# 配置
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release

# 构建
cmake --build build

# 打包
cmake --build build --target package

# 检查依赖
otool -L build/bin/MyApp.app/Contents/MacOS/MyApp
```

### Linux
```bash
# 配置
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release

# 构建
cmake --build build

# 打包
cmake --build build --target package

# 检查依赖
ldd build/bin/MyApp
```

## 🎨 完整示例

### 单项目（带 CPack）
```cmake
cmake_minimum_required(VERSION 3.5)
project(MyApp VERSION 1.0.0)

include(cmake/qtcommon.cmake)

get_src_include()
cpp_execute(${PROJECT_NAME})
setup_qt(${PROJECT_NAME} DEPLOY_FULL)

setup_cpack(
    VENDOR "MyCompany"
    DESCRIPTION "My Application"
    LICENSE_FILE "LICENSE"
    ICON "app.ico"
)
```

### 多项目（统一打包）
```cmake
# 顶层 CMakeLists.txt
cmake_minimum_required(VERSION 3.5)
project(MySuite VERSION 2.0.0)

include(cmake/qtcommon.cmake)

setup_multi_project_package(
    PROJECTS App1 App2
    OUTPUT_DIR ${CMAKE_BINARY_DIR}/release
)

add_subdirectory(app1)
add_subdirectory(app2)

setup_cpack(VENDOR "MyCompany")
```

```cmake
# app1/CMakeLists.txt
project(App1)
get_src_include()
cpp_execute(${PROJECT_NAME})
setup_qt(${PROJECT_NAME} DEPLOY)
```

## 🔍 故障排除

### 找不到 windeployqt
```powershell
$env:QT_PREFIX_PATH = "C:\Qt\6.5.0\msvc2019_64"
cmake -S . -B build
```

### Linux 安装 linuxdeployqt
```bash
wget https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage
chmod +x linuxdeployqt-continuous-x86_64.AppImage
sudo mv linuxdeployqt-continuous-x86_64.AppImage /usr/local/bin/linuxdeployqt
```

### 验证打包结果
```powershell
# Windows - 检查缺少的 DLL
dumpbin /dependents MyApp.exe

# 运行测试
.\build\bin\MyApp.exe
```

## 📚 详细文档

完整文档请查看：
- [PACKAGING.md](./PACKAGING.md) - 详细的打包指南
- [README.md](./README.md) - qtcommon.cmake 完整文档

## ✨ 主要特性

✅ 自动检测 Qt6/Qt5  
✅ 跨平台支持（Windows/macOS/Linux）  
✅ 一键自动打包依赖  
✅ 支持开发和发布模式  
✅ 多项目统一管理  
✅ CPack 集成生成安装包  
✅ 灵活的配置选项  
✅ 详细的日志输出  

---

**提示**：首次使用建议从单项目的 `setup_qt(MyApp DEPLOY)` 开始，逐步熟悉打包流程。
