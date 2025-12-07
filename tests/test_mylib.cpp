#include <gtest/gtest.h>
#include "mylib.h"

// ============================================================================
// 测试 MyLib::add 函数 - 加法运算测试
// ============================================================================
TEST(MyLibTest, AddPositiveNumbers) {
    EXPECT_EQ(MyLib::add(2, 3), 5);
    EXPECT_EQ(MyLib::add(100, 200), 300);
    EXPECT_EQ(MyLib::add(1, 1), 2);
}

TEST(MyLibTest, AddNegativeNumbers) {
    EXPECT_EQ(MyLib::add(-1, -1), -2);
    EXPECT_EQ(MyLib::add(-5, -10), -15);
    EXPECT_EQ(MyLib::add(-100, -200), -300);
}

TEST(MyLibTest, AddMixedNumbers) {
    EXPECT_EQ(MyLib::add(-1, 1), 0);
    EXPECT_EQ(MyLib::add(10, -5), 5);
    EXPECT_EQ(MyLib::add(-20, 30), 10);
}

TEST(MyLibTest, AddZero) {
    EXPECT_EQ(MyLib::add(0, 0), 0);
    EXPECT_EQ(MyLib::add(5, 0), 5);
    EXPECT_EQ(MyLib::add(0, -5), -5);
}

TEST(MyLibTest, AddLargeNumbers) {
    EXPECT_EQ(MyLib::add(999999, 1), 1000000);
    EXPECT_EQ(MyLib::add(2147483647, 0), 2147483647); // INT_MAX
}

// ============================================================================
// 测试 MyLib::multiply 函数 - 乘法运算测试
// ============================================================================
TEST(MyLibTest, MultiplyPositiveNumbers) {
    EXPECT_EQ(MyLib::multiply(2, 3), 6);
    EXPECT_EQ(MyLib::multiply(10, 10), 100);
    EXPECT_EQ(MyLib::multiply(7, 8), 56);
}

TEST(MyLibTest, MultiplyNegativeNumbers) {
    EXPECT_EQ(MyLib::multiply(-2, -3), 6);
    EXPECT_EQ(MyLib::multiply(-5, -5), 25);
    EXPECT_EQ(MyLib::multiply(-10, -1), 10);
}

TEST(MyLibTest, MultiplyMixedNumbers) {
    EXPECT_EQ(MyLib::multiply(-1, 5), -5);
    EXPECT_EQ(MyLib::multiply(10, -2), -20);
    EXPECT_EQ(MyLib::multiply(-7, 3), -21);
}

TEST(MyLibTest, MultiplyByZero) {
    EXPECT_EQ(MyLib::multiply(0, 100), 0);
    EXPECT_EQ(MyLib::multiply(999, 0), 0);
    EXPECT_EQ(MyLib::multiply(0, 0), 0);
}

TEST(MyLibTest, MultiplyByOne) {
    EXPECT_EQ(MyLib::multiply(5, 1), 5);
    EXPECT_EQ(MyLib::multiply(1, -10), -10);
    EXPECT_EQ(MyLib::multiply(1, 1), 1);
}

// ============================================================================
// 测试 MyLib::getVersion 函数 - 版本信息测试
// ============================================================================
TEST(MyLibTest, GetVersionNotNull) {
    const char* version = MyLib::getVersion();
    ASSERT_NE(version, nullptr) << "版本字符串不应该为 NULL";
}

TEST(MyLibTest, GetVersionCorrectFormat) {
    const char* version = MyLib::getVersion();
    EXPECT_STREQ(version, "1.0.0") << "版本应该是 1.0.0";
}

TEST(MyLibTest, GetVersionConsistent) {
    const char* version1 = MyLib::getVersion();
    const char* version2 = MyLib::getVersion();
    EXPECT_STREQ(version1, version2) << "多次调用应该返回相同的版本";
}

// ============================================================================
// 测试套件 - 使用测试夹具进行更复杂的测试
// ============================================================================
class MyLibTestSuite : public ::testing::Test {
protected:
    // 测试前的初始化
    void SetUp() override {
        // 可以在这里初始化测试数据
        testValue1 = 10;
        testValue2 = 20;
    }

    // 测试后的清理
    void TearDown() override {
        // 可以在这里清理资源
    }

    // 测试夹具的成员变量
    int testValue1;
    int testValue2;
};

TEST_F(MyLibTestSuite, AddWithFixture) {
    EXPECT_EQ(MyLib::add(testValue1, testValue2), 30);
    EXPECT_EQ(MyLib::add(testValue1, 0), testValue1);
}

TEST_F(MyLibTestSuite, MultiplyWithFixture) {
    EXPECT_EQ(MyLib::multiply(testValue1, testValue2), 200);
    EXPECT_EQ(MyLib::multiply(testValue1, 1), testValue1);
}

TEST_F(MyLibTestSuite, CombinedOperations) {
    int sum = MyLib::add(testValue1, testValue2);
    int product = MyLib::multiply(sum, 2);
    EXPECT_EQ(product, 60);
}

// ============================================================================
// 参数化测试 - 测试多组数据
// ============================================================================
class AddParameterizedTest : public ::testing::TestWithParam<std::tuple<int, int, int>> {
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
        std::make_tuple(-1, 1, 0),
        std::make_tuple(0, 0, 0),
        std::make_tuple(100, -50, 50)
    )
);

class MultiplyParameterizedTest : public ::testing::TestWithParam<std::tuple<int, int, int>> {
};

TEST_P(MultiplyParameterizedTest, MultiplyTests) {
    auto params = GetParam();
    int a = std::get<0>(params);
    int b = std::get<1>(params);
    int expected = std::get<2>(params);
    EXPECT_EQ(MyLib::multiply(a, b), expected);
}

INSTANTIATE_TEST_SUITE_P(
    MultiplyTestCases,
    MultiplyParameterizedTest,
    ::testing::Values(
        std::make_tuple(2, 3, 6),
        std::make_tuple(5, 5, 25),
        std::make_tuple(-2, 3, -6),
        std::make_tuple(0, 100, 0),
        std::make_tuple(10, -5, -50)
    )
);

