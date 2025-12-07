# 外部库集成指南

本项目展示了如何在 CMake 中查找和链接常用的外部库。

## 支持的库

- **OpenCV** - 计算机视觉库
- **Boost** - C++ 通用库集合
- **HALCON** - 机器视觉库

## 查看库检测结果

配置项目时会自动检测已安装的库：

```powershell
cmake -S . -B build -G "Ninja"
```

输出示例：
```
-- 测试查找 OpenCV...
--   ✓ 找到 OpenCV 4.11.0
--     包含目录: C:/Users/jinxi/vcpkg/installed/x64-windows/include/opencv4
--     库文件: opencv_calib3d;opencv_core;opencv_dnn;...

-- 测试查找 Boost...
--   ✓ 找到 Boost 1.89.0
--     包含目录: C:/Users/jinxi/vcpkg/installed/x64-windows/include
--     库文件: Boost::system;Boost::filesystem;...

-- 测试查找 HALCON...
--   ✓ 找到 HALCON
--     根目录: C:\Program Files\MVTec\HALCON-20.11-Steady
--     包含目录: C:\Program Files\MVTec\HALCON-20.11-Steady/include
```

## 安装外部库

### OpenCV

#### 方法1: 使用 vcpkg（推荐）

```powershell
vcpkg install opencv:x64-windows
```

#### 方法2: 手动安装

1. 下载: https://opencv.org/releases/
2. 解压到本地目录
3. 设置环境变量:
   ```powershell
   $env:OpenCV_DIR = "C:\path\to\opencv\build"
   ```

### Boost

#### 方法1: 使用 vcpkg（推荐）

```powershell
# 完整安装（大约需要较长时间）
vcpkg install boost:x64-windows

# 或只安装需要的组件
vcpkg install boost-system:x64-windows
vcpkg install boost-filesystem:x64-windows
vcpkg install boost-thread:x64-windows
```

#### 方法2: 手动安装

1. 下载: https://www.boost.org/users/download/
2. 解压到本地目录
3. 设置环境变量:
   ```powershell
   $env:BOOST_ROOT = "C:\local\boost_1_89_0"
   ```

### HALCON

1. 下载并安装 MVTec HALCON: https://www.mvtec.com/products/halcon
2. 默认安装到: `C:\Program Files\MVTec\HALCON-XX.XX-Steady`
3. 或设置环境变量:
   ```powershell
   $env:HALCONROOT = "C:\Program Files\MVTec\HALCON-20.11-Steady"
   ```

## 链接库到项目

默认情况下，库只是被检测但不会链接到项目。要链接库，需要在 `CMakeLists.txt` 中取消相应的注释。

### 链接 OpenCV

在 `CMakeLists.txt` 中找到 OpenCV 部分，取消注释：

```cmake
if(OpenCV_FOUND)
    # 取消下面两行的注释
    target_include_directories(${PROJECT_NAME} PRIVATE ${OpenCV_INCLUDE_DIRS})
    target_link_libraries(${PROJECT_NAME} PRIVATE ${OpenCV_LIBS})
endif()
```

### 链接 Boost

```cmake
if(Boost_FOUND)
    # 取消下面两行的注释
    target_include_directories(${PROJECT_NAME} PRIVATE ${Boost_INCLUDE_DIRS})
    target_link_libraries(${PROJECT_NAME} PRIVATE ${Boost_LIBRARIES})
endif()
```

### 链接 HALCON

```cmake
if(HALCON_FOUND)
    # 取消下面两行的注释
    target_include_directories(${PROJECT_NAME} PRIVATE ${HALCON_INCLUDE_DIR})
    target_link_libraries(${PROJECT_NAME} PRIVATE ${HALCON_LIBRARY})
endif()
```

## 使用示例

### OpenCV 示例

```cpp
#include <opencv2/opencv.hpp>

int main() {
    cv::Mat image = cv::imread("image.jpg");
    if (image.empty()) {
        return -1;
    }
    
    cv::Mat gray;
    cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
    cv::imwrite("gray.jpg", gray);
    
    return 0;
}
```

### Boost 示例

```cpp
#include <boost/filesystem.hpp>
#include <iostream>

namespace fs = boost::filesystem;

int main() {
    fs::path currentPath = fs::current_path();
    std::cout << "Current path: " << currentPath << std::endl;
    
    for (const auto& entry : fs::directory_iterator(currentPath)) {
        std::cout << entry.path().filename() << std::endl;
    }
    
    return 0;
}
```

### HALCON 示例

```cpp
#include "HalconCpp.h"

using namespace HalconCpp;

int main() {
    HImage image;
    image.ReadImage("image.jpg");
    
    HImage grayImage = image.Rgb1ToGray();
    grayImage.WriteImage("png", 0, "gray.png");
    
    return 0;
}
```

## 配置 vcpkg 工具链

使用 vcpkg 安装的库需要在配置时指定工具链文件：

```powershell
cmake -S . -B build `
  -G "Ninja" `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_TOOLCHAIN_FILE="C:\Users\jinxi\vcpkg\scripts\buildsystems\vcpkg.cmake"
```

或者设置环境变量：

```powershell
$env:CMAKE_TOOLCHAIN_FILE = "C:\Users\jinxi\vcpkg\scripts\buildsystems\vcpkg.cmake"
cmake -S . -B build -G "Ninja"
```

## 常见问题

### Q1: OpenCV 配置时出现错误

**问题**: `cmake_policy PUSH without matching POP`

**原因**: vcpkg 的 OpenCV 包存在一些配置问题

**解决**: 这通常不影响使用，可以忽略。如果确实有问题，可以尝试：
```powershell
vcpkg remove opencv:x64-windows
vcpkg install opencv4:x64-windows
```

### Q2: Boost 库文件找不到

**问题**: 链接时报告找不到 Boost 库

**解决**: 
1. 确保安装了正确的架构版本（x64-windows）
2. 检查环境变量 `BOOST_ROOT` 是否正确
3. 尝试指定 Boost 根目录：
   ```cmake
   set(BOOST_ROOT "C:/local/boost_1_89_0")
   find_package(Boost REQUIRED COMPONENTS system filesystem)
   ```

### Q3: HALCON 找不到

**问题**: 配置时显示"未找到 HALCON"

**解决**:
1. 确认 HALCON 已正确安装
2. 检查安装路径是否在 `CMakeLists.txt` 的 `HALCON_POSSIBLE_PATHS` 列表中
3. 设置环境变量：
   ```powershell
   $env:HALCONROOT = "C:\Program Files\MVTec\HALCON-20.11-Steady"
   ```

### Q4: 运行时找不到 DLL

**问题**: 程序运行时报告缺少 DLL 文件

**解决**:
1. 将库的 `bin` 目录添加到 PATH：
   ```powershell
   $env:PATH += ";C:\Users\jinxi\vcpkg\installed\x64-windows\bin"
   $env:PATH += ";C:\Program Files\MVTec\HALCON-20.11-Steady\bin\x64-win64"
   ```

2. 或将需要的 DLL 复制到可执行文件目录

3. 使用 CMake 的安装功能自动复制 DLL：
   ```cmake
   install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)
   install(FILES ${OPENCV_DLL_FILES} DESTINATION bin)
   ```

## 库版本兼容性

| 库 | 推荐版本 | 最低版本 | 备注 |
|---|---------|---------|------|
| OpenCV | 4.x | 3.0 | 4.x API 有较大变化 |
| Boost | 1.70+ | 1.60 | 使用 C++17 需要较新版本 |
| HALCON | 20.11+ | 18.11 | 不同版本 API 可能有差异 |

## 性能优化提示

### OpenCV
- 编译时启用 AVX2/SSE 优化
- 使用 `cv::parallel_for_` 进行并行处理
- 对于大图像，考虑使用 GPU 版本

### Boost
- 只链接需要的组件，避免全部链接
- 使用 Boost.Asio 时考虑线程池大小
- 文件系统操作可以使用 C++17 的 `std::filesystem` 替代

### HALCON
- 合理设置图像缓存大小
- 使用多线程操作符（`par_start`/`par_join`）
- 注意算子的线程安全性

## 更多资源

- **OpenCV**: https://docs.opencv.org/
- **Boost**: https://www.boost.org/doc/
- **HALCON**: https://www.mvtec.com/products/halcon/documentation
- **vcpkg**: https://vcpkg.io/en/getting-started.html
