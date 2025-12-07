# ============================================================================
# 自动测试脚本
# ============================================================================
# 功能：自动运行各种测试，验证 CMake 配置和构建功能
# 用法：cmake -P cmake/run_tests.cmake
#       或：cmake --build build --target run_tests

# 设置测试模式
set(TEST_MODE "all" CACHE STRING "测试模式: all, config, build, quick")
if(NOT TEST_MODE)
  set(TEST_MODE "all")
endif()

message(STATUS "")
message(STATUS "============================================================================")
message(STATUS "开始自动测试")
message(STATUS "============================================================================")
message(STATUS "测试模式: ${TEST_MODE}")
message(STATUS "项目目录: ${CMAKE_SOURCE_DIR}")
message(STATUS "")

# 获取构建目录
if(NOT DEFINED BUILD_DIR)
  set(BUILD_DIR "${CMAKE_SOURCE_DIR}/build-test")
endif()

# 测试结果统计
set(TEST_PASSED 0)
set(TEST_FAILED 0)
set(TEST_TOTAL 0)

# ----------------------------------------------------------------------------
# 辅助函数：运行测试
# ----------------------------------------------------------------------------
function(run_test test_name test_command)
  math(EXPR TEST_TOTAL "${TEST_TOTAL} + 1")
  message(STATUS "")
  message(STATUS "测试 ${TEST_TOTAL}: ${test_name}")
  message(STATUS "命令: ${test_command}")
  
  execute_process(
    COMMAND ${test_command}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    RESULT_VARIABLE TEST_RESULT
    OUTPUT_VARIABLE TEST_OUTPUT
    ERROR_VARIABLE TEST_ERROR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE
  )
  
  if(TEST_RESULT EQUAL 0)
    math(EXPR TEST_PASSED "${TEST_PASSED} + 1")
    message(STATUS "  ✓ 通过")
  else()
    math(EXPR TEST_FAILED "${TEST_FAILED} + 1")
    message(STATUS "  ✗ 失败 (退出码: ${TEST_RESULT})")
    if(TEST_ERROR)
      message(STATUS "  错误: ${TEST_ERROR}")
    endif()
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 测试1: CMake 配置测试
# ----------------------------------------------------------------------------
if(TEST_MODE STREQUAL "all" OR TEST_MODE STREQUAL "config" OR TEST_MODE STREQUAL "quick")
  message(STATUS "")
  message(STATUS "============================================================================")
  message(STATUS "测试组 1: CMake 配置测试")
  message(STATUS "============================================================================")
  
  # 清理旧的构建目录
  file(REMOVE_RECURSE "${BUILD_DIR}")
  
  # 测试配置（Visual Studio）
  if(WIN32)
    run_test("CMake 配置 (Visual Studio x64)"
      "${CMAKE_COMMAND} -S . -B ${BUILD_DIR} -A x64"
    )
  else()
    run_test("CMake 配置 (Unix Makefiles)"
      "${CMAKE_COMMAND} -S . -B ${BUILD_DIR} -G \"Unix Makefiles\" -DCMAKE_BUILD_TYPE=Release"
    )
  endif()
endif()

# ----------------------------------------------------------------------------
# 测试2: 构建测试
# ----------------------------------------------------------------------------
if(TEST_MODE STREQUAL "all" OR TEST_MODE STREQUAL "build" OR TEST_MODE STREQUAL "quick")
  message(STATUS "")
  message(STATUS "============================================================================")
  message(STATUS "测试组 2: 构建测试")
  message(STATUS "============================================================================")
  
  if(WIN32)
    run_test("构建项目 (Release)"
      "${CMAKE_COMMAND} --build ${BUILD_DIR} --config Release"
    )
  else()
    run_test("构建项目 (Release)"
      "${CMAKE_COMMAND} --build ${BUILD_DIR} --target all"
    )
  endif()
  
  # 检查可执行文件是否存在
  if(EXISTS "${CMAKE_SOURCE_DIR}/bin/TestApp.exe")
    math(EXPR TEST_PASSED "${TEST_PASSED} + 1")
    math(EXPR TEST_TOTAL "${TEST_TOTAL} + 1")
    message(STATUS "  ✓ 可执行文件存在: bin/TestApp.exe")
  elseif(EXISTS "${CMAKE_SOURCE_DIR}/bin/TestApp")
    math(EXPR TEST_PASSED "${TEST_PASSED} + 1")
    math(EXPR TEST_TOTAL "${TEST_TOTAL} + 1")
    message(STATUS "  ✓ 可执行文件存在: bin/TestApp")
  else()
    math(EXPR TEST_FAILED "${TEST_FAILED} + 1")
    math(EXPR TEST_TOTAL "${TEST_TOTAL} + 1")
    message(STATUS "  ✗ 可执行文件不存在")
  endif()
endif()

# ----------------------------------------------------------------------------
# 测试3: 功能验证测试
# ----------------------------------------------------------------------------
if(TEST_MODE STREQUAL "all" OR TEST_MODE STREQUAL "build")
  message(STATUS "")
  message(STATUS "============================================================================")
  message(STATUS "测试组 3: 功能验证测试")
  message(STATUS "============================================================================")
  
  # 测试 compile_commands.json 生成（如果使用 Ninja）
  if(EXISTS "${BUILD_DIR}/compile_commands.json")
    math(EXPR TEST_PASSED "${TEST_PASSED} + 1")
    math(EXPR TEST_TOTAL "${TEST_TOTAL} + 1")
    message(STATUS "  ✓ compile_commands.json 已生成")
  else()
    math(EXPR TEST_TOTAL "${TEST_TOTAL} + 1")
    message(STATUS "  - compile_commands.json 未生成（Visual Studio 生成器不支持，这是正常的）")
  endif()
  
  # 测试 platforms 插件是否复制
  if(WIN32)
    if(EXISTS "${CMAKE_SOURCE_DIR}/bin/platforms/qwindows.dll")
      math(EXPR TEST_PASSED "${TEST_PASSED} + 1")
      math(EXPR TEST_TOTAL "${TEST_TOTAL} + 1")
      message(STATUS "  ✓ platforms 插件已复制")
    else()
      math(EXPR TEST_FAILED "${TEST_FAILED} + 1")
      math(EXPR TEST_TOTAL "${TEST_TOTAL} + 1")
      message(STATUS "  ✗ platforms 插件未复制")
    endif()
  endif()
endif()

# ----------------------------------------------------------------------------
# 测试4: 清理测试
# ----------------------------------------------------------------------------
if(TEST_MODE STREQUAL "all")
  message(STATUS "")
  message(STATUS "============================================================================")
  message(STATUS "测试组 4: 清理测试")
  message(STATUS "============================================================================")
  
  run_test("清理构建"
    "${CMAKE_COMMAND} --build ${BUILD_DIR} --target clean"
  )
endif()

# ----------------------------------------------------------------------------
# 输出测试结果
# ----------------------------------------------------------------------------
message(STATUS "")
message(STATUS "============================================================================")
message(STATUS "测试结果汇总")
message(STATUS "============================================================================")
message(STATUS "总测试数: ${TEST_TOTAL}")
message(STATUS "通过: ${TEST_PASSED}")
message(STATUS "失败: ${TEST_FAILED}")

if(TEST_FAILED EQUAL 0)
  message(STATUS "")
  message(STATUS "✓ 所有测试通过！")
  message(STATUS "")
else()
  message(STATUS "")
  message(STATUS "✗ 有 ${TEST_FAILED} 个测试失败")
  message(STATUS "")
endif()

