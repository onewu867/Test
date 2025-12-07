# GTest 测试快速指南

## 运行测试

### 方法1：直接运行
```powershell
cd build-ctest\tests\Release
.\mylib_test.exe
```

### 方法2：使用 CTest
```powershell
cd build-ctest
ctest -C Release --output-on-failure
```

## 构建测试

```powershell
# 完整构建（包含配置）
cd build-ctest
cmake .. -G "Visual Studio 15 2017" -A x64 -DCMAKE_TOOLCHAIN_FILE="C:\Users\jinxi\vcpkg\scripts\buildsystems\vcpkg.cmake"
cmake --build . --config Release --target mylib_test

# 仅重新构建
cmake --build . --config Release --target mylib_test
```

## 过滤测试

```powershell
# 只运行包含 "Add" 的测试
.\mylib_test.exe --gtest_filter=*Add*

# 排除某些测试
.\mylib_test.exe --gtest_filter=-*Multiply*

# 运行特定测试套件
.\mylib_test.exe --gtest_filter=MyLibTest.*
```

## 测试选项

```powershell
# 详细输出
.\mylib_test.exe --gtest_verbose

# 重复运行10次
.\mylib_test.exe --gtest_repeat=10

# 随机顺序
.\mylib_test.exe --gtest_shuffle

# 遇到失败立即停止
.\mylib_test.exe --gtest_break_on_failure
```

## 编写测试

### 基本测试
```cpp
TEST(TestSuiteName, TestName) {
    EXPECT_EQ(actual, expected);
    ASSERT_NE(ptr, nullptr);
}
```

### 常用断言
```cpp
EXPECT_EQ(a, b);      // 相等
EXPECT_NE(a, b);      // 不相等
EXPECT_LT(a, b);      // 小于
EXPECT_GT(a, b);      // 大于
EXPECT_TRUE(cond);    // 为真
EXPECT_FALSE(cond);   // 为假
EXPECT_STREQ(s1, s2); // 字符串相等
```

## 项目文件

- **测试源码**: `tests/test_mylib.cpp`
- **测试配置**: `tests/CMakeLists.txt`
- **被测代码**: `mylib.cpp`, `mylib.h`
- **测试程序**: `build-ctest/tests/Release/mylib_test.exe`

## 修复编码问题

如果看到乱码，在PowerShell中执行：
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001
```

## 详细文档

查看完整文档: [GTEST_USAGE.md](GTEST_USAGE.md)

## 当前测试统计

- **总测试数**: 26 个
- **测试套件**: 4 个
  - MyLibTest: 13 个测试
  - MyLibTestSuite: 3 个测试  
  - AddParameterizedTest: 5 个测试
  - MultiplyParameterizedTest: 5 个测试
