# 测试目录的 CMakeLists.txt
# 这个文件展示了如何使用 GTest 创建单元测试

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
    ${GTEST_INCLUDE_DIRS}
)

# 链接 GTest
target_link_libraries(mylib_test PRIVATE
    GTest::gtest_main
)

# 添加测试
include(GoogleTest)
gtest_discover_tests(mylib_test)

