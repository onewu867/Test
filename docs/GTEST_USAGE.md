# Google Test 使用文档

## 项目结构

```
TestApp/
├── mylib.h              # 被测试的库头文件
├── mylib.cpp            # 被测试的库实现
├── tests/
│   ├── CMakeLists.txt   # 测试配置文件
│   └── test_mylib.cpp   # 测试用例
└── build-ctest/         # 构建目录
    └── tests/
        └── Release/
            └── mylib_test.exe  # 测试可执行文件
```

## 快速开始

### 1. 配置项目

使用 vcpkg 工具链配置（推荐）：

```powershell
# 删除旧的构建目录（如果存在）
Remove-Item -Recurse -Force build-ctest -ErrorAction SilentlyContinue

# 创建构建目录
mkdir build-ctest
cd build-ctest

# 配置项目（使用 vcpkg）
cmake .. -G "Visual Studio 15 2017" -A x64 `
  -DCMAKE_TOOLCHAIN_FILE="C:\Users\jinxi\vcpkg\scripts\buildsystems\vcpkg.cmake"
```

或者使用 Ninja 生成器（更快）：

```powershell
cmake .. -G "Ninja" `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_TOOLCHAIN_FILE="C:\Users\jinxi\vcpkg\scripts\buildsystems\vcpkg.cmake"
```

### 2. 构建测试

```powershell
# 构建所有目标（包括测试）
cmake --build . --config Release

# 或只构建测试目标
cmake --build . --config Release --target mylib_test
```

### 3. 运行测试

#### 方法1：直接运行测试可执行文件

```powershell
cd tests\Release
.\mylib_test.exe
```

#### 方法2：使用 CTest（推荐）

```powershell
# 在构建目录下运行
cd build-ctest
ctest -C Release --output-on-failure
```

#### 方法3：使用 CTest 详细模式

```powershell
ctest -C Release --verbose
```

## 测试输出示例

```
Running main() from gtest_main.cc
[==========] Running 26 tests from 4 test suites.
[----------] Global test environment set-up.
[----------] 13 tests from MyLibTest
[ RUN      ] MyLibTest.AddPositiveNumbers
[       OK ] MyLibTest.AddPositiveNumbers (0 ms)
[ RUN      ] MyLibTest.AddNegativeNumbers
[       OK ] MyLibTest.AddNegativeNumbers (0 ms)
...
[==========] 26 tests from 4 test suites ran. (15 ms total)
[  PASSED  ] 26 tests.
```

## 编写新测试

### 基本测试

```cpp
#include <gtest/gtest.h>
#include "mylib.h"

TEST(MyLibTest, TestName) {
    EXPECT_EQ(MyLib::add(1, 2), 3);
    ASSERT_NE(MyLib::getVersion(), nullptr);
}
```

### 测试夹具（Test Fixture）

```cpp
class MyLibTestSuite : public ::testing::Test {
protected:
    void SetUp() override {
        // 每个测试前执行
        testData = 10;
    }

    void TearDown() override {
        // 每个测试后执行
    }

    int testData;
};

TEST_F(MyLibTestSuite, UseFixture) {
    EXPECT_EQ(MyLib::add(testData, 5), 15);
}
```

### 参数化测试

```cpp
class AddParameterizedTest : 
    public ::testing::TestWithParam<std::tuple<int, int, int>> {
};

TEST_P(AddParameterizedTest, AddTests) {
    auto params = GetParam();
    int a = std::get<0>(params);
    int b = std::get<1>(params);
    int expected = std::get<2>(params);
    EXPECT_EQ(MyLib::add(a, b), expected);
}

INSTANTIATE_TEST_SUITE_P(
    AddTestCases,
    AddParameterizedTest,
    ::testing::Values(
        std::make_tuple(1, 2, 3),
        std::make_tuple(5, 5, 10),
        std::make_tuple(-1, 1, 0)
    )
);
```

## 常用断言

### 基本断言

```cpp
EXPECT_EQ(val1, val2);   // 相等
EXPECT_NE(val1, val2);   // 不相等
EXPECT_LT(val1, val2);   // 小于
EXPECT_LE(val1, val2);   // 小于等于
EXPECT_GT(val1, val2);   // 大于
EXPECT_GE(val1, val2);   // 大于等于
```

### 布尔断言

```cpp
EXPECT_TRUE(condition);
EXPECT_FALSE(condition);
```

### 字符串断言

```cpp
EXPECT_STREQ(str1, str2);    // C字符串相等
EXPECT_STRNE(str1, str2);    // C字符串不相等
EXPECT_STRCASEEQ(str1, str2); // 忽略大小写相等
```

### 浮点数断言

```cpp
EXPECT_FLOAT_EQ(val1, val2);  // float 相等
EXPECT_DOUBLE_EQ(val1, val2); // double 相等
EXPECT_NEAR(val1, val2, abs_error); // 在误差范围内
```

### ASSERT vs EXPECT

- `EXPECT_*`: 失败后继续执行测试
- `ASSERT_*`: 失败后立即终止当前测试

```cpp
ASSERT_NE(ptr, nullptr);  // 如果失败，立即返回
EXPECT_EQ(ptr->value, 10); // 如果失败，继续执行
```

## 过滤测试

### 运行特定测试

```powershell
# 运行包含 "Add" 的测试
.\mylib_test.exe --gtest_filter=*Add*

# 运行特定测试套件
.\mylib_test.exe --gtest_filter=MyLibTest.*

# 排除某些测试
.\mylib_test.exe --gtest_filter=-*Multiply*
```

### 重复运行测试

```powershell
# 重复运行10次
.\mylib_test.exe --gtest_repeat=10

# 遇到失败立即停止
.\mylib_test.exe --gtest_repeat=100 --gtest_break_on_failure
```

## CMake 配置说明

### 最小配置（tests/CMakeLists.txt）

```cmake
# 启用测试
enable_testing()

# 查找 GTest
find_package(GTest REQUIRED)

# 添加测试可执行文件
add_executable(mylib_test 
    test_mylib.cpp
    ${CMAKE_SOURCE_DIR}/mylib.cpp
)

# 添加包含目录
target_include_directories(mylib_test PRIVATE
    ${CMAKE_SOURCE_DIR}
)

# 链接 GTest
target_link_libraries(mylib_test PRIVATE
    GTest::gtest_main  # 包含main函数
)

# 自动发现测试
include(GoogleTest)
gtest_discover_tests(mylib_test)
```

## 疑难解答

### 问题1：找不到 GTest

**解决方案**：使用 vcpkg 安装

```powershell
# 安装 GTest
vcpkg install gtest:x64-windows

# 配置时指定工具链文件
cmake .. -DCMAKE_TOOLCHAIN_FILE="C:\path\to\vcpkg\scripts\buildsystems\vcpkg.cmake"
```

### 问题2：中文乱码

**原因**：Windows 终端编码问题

**解决方案**：
1. 使用英文注释和消息
2. 或在PowerShell中执行：`[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`

### 问题3：找不到头文件

**解决方案**：确保包含目录正确

```cmake
target_include_directories(mylib_test PRIVATE
    ${CMAKE_SOURCE_DIR}  # 添加项目根目录
)
```

### 问题4：链接错误

**原因**：DLL导入/导出不一致

**解决方案**：移除或修改 `MYLIB_API` 宏定义

```cpp
// 对于测试，可以定义为空
#define MYLIB_API
```

## 持续集成

### GitHub Actions 示例

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install vcpkg
        run: |
          git clone https://github.com/Microsoft/vcpkg.git
          .\vcpkg\bootstrap-vcpkg.bat
          .\vcpkg\vcpkg install gtest:x64-windows
      
      - name: Configure
        run: |
          mkdir build
          cd build
          cmake .. -DCMAKE_TOOLCHAIN_FILE=..\vcpkg\scripts\buildsystems\vcpkg.cmake
      
      - name: Build
        run: cmake --build build --config Release
      
      - name: Test
        run: |
          cd build
          ctest -C Release --output-on-failure
```

## 最佳实践

1. **一个测试只测试一个功能点**
   - 测试应该简单、清晰
   - 失败时容易定位问题

2. **使用描述性的测试名称**
   ```cpp
   TEST(MyLibTest, AddTwoPositiveNumbers)  // 好
   TEST(MyLibTest, Test1)                  // 差
   ```

3. **测试边界条件**
   - 零值、负值、最大值、最小值
   - 空指针、空字符串

4. **测试独立性**
   - 测试之间不应该有依赖
   - 使用 SetUp/TearDown 初始化

5. **适度使用参数化测试**
   - 减少重复代码
   - 提高测试覆盖率

## 参考资源

- [Google Test 官方文档](https://google.github.io/googletest/)
- [Google Test Primer](https://google.github.io/googletest/primer.html)
- [Google Test Advanced Guide](https://google.github.io/googletest/advanced.html)
- [vcpkg 官网](https://vcpkg.io/)
