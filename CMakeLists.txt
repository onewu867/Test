# 设置所需的CMake最低版本为3.5
cmake_minimum_required(VERSION 3.5...4.2)

# 定义名为TestApp的项目，版本0.1，使用C++语言
project(TestApp VERSION 0.1 LANGUAGES CXX)

# 自动包含当前目录到包含路径中
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# 包含输出助手（解决跨平台编码问题）
include(${CMAKE_CURRENT_LIST_DIR}/cmake/output_helper.cmake)

# 包含Qt通用配置文件
include(${CMAKE_CURRENT_LIST_DIR}/cmake/qtcommon.cmake)

# ============================================================================
# 测试功能1: Qt 应用编译 (cpp_execute + setup_qt) - 主要功能
# ============================================================================
message(STATUS "")
message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}========== 测试功能1: Qt 应用编译与自动打包 ==========${_COLOR_RESET}")

# 手动指定源文件（排除示例文件）
set(SRC_FILES
    main.cpp
    mainwindow.cpp
    mylib.cpp
)
set(H_FILES
    mainwindow.h
    mylib.h
)
set(UI_FILES
    mainwindow.ui
)

# 创建可执行文件
add_executable(${PROJECT_NAME} ${SRC_FILES} ${H_FILES} ${UI_FILES})

# 应用 C++ 配置
set_cpp(${PROJECT_NAME})

# 启用自动打包（标准模式）
# 选项说明：
#   - 无选项：仅复制 platforms 插件（开发模式）
#   - DEPLOY：自动运行 windeployqt，复制所有依赖（推荐）
#   - DEPLOY_FULL：完整打包，包含翻译和所有插件（发布模式）
#   - NO_WIN32：显示控制台窗口（调试用）
setup_qt(${PROJECT_NAME} DEPLOY)

# ============================================================================
# 安装配置（用于 CPack 打包）
# ============================================================================
# 安装可执行文件
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
)

# 安装 bin 目录下的所有 DLL 和插件（windeployqt 生成的）
install(DIRECTORY ${CMAKE_SOURCE_DIR}/bin/
    DESTINATION bin
    USE_SOURCE_PERMISSIONS
    FILES_MATCHING
    PATTERN "*.dll"
    PATTERN "*.exe" EXCLUDE  # 不重复安装可执行文件
)

# 安装插件目录
install(DIRECTORY ${CMAKE_SOURCE_DIR}/bin/platforms
    DESTINATION bin
    USE_SOURCE_PERMISSIONS
    OPTIONAL
)

install(FILES ${CMAKE_SOURCE_DIR}/bin/qt.conf
    DESTINATION bin
    OPTIONAL
)

# ============================================================================
# 测试功能2: 库编译 (cpp_library)
# ============================================================================
message(STATUS "")
message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}========== 测试功能2: 库编译 ==========${_COLOR_RESET}")
# 创建库：mylib
# 注意：由于 get_src_include() 会收集所有文件，我们需要在子目录中测试
# 或者我们可以注释掉这个测试，专注于主要功能
# 为了演示，我们创建一个简单的测试
# cpp_library(mylib)  # 需要 mylib.cpp 和 mylib.h 在当前目录
message(STATUS "${_COLOR_YELLOW}库编译测试: 已创建 mylib.h 和 mylib.cpp，可以取消注释下面的行来测试${_COLOR_RESET}")
message(STATUS "${_COLOR_YELLOW}注意: 由于文件收集机制，建议在子目录中测试库编译功能${_COLOR_RESET}")
# 取消注释下面这行来测试库编译：
# cpp_library(mylib)

# ============================================================================
# 测试功能3: 外部库导入 (find_and_link_library)
# ============================================================================
print_header("外部库检测")
print_info("测试外部库查找功能（可选）...")

# ----------------------------------------------------------------------------
# 测试1: OpenCV（可选，如果出错可以注释掉）
# ----------------------------------------------------------------------------
# print_subheader("检测 OpenCV")
# find_package(OpenCV QUIET)
# if(OpenCV_FOUND)
#     print_library_found("OpenCV" "${OpenCV_VERSION}")
#     print_path("包含目录" "${OpenCV_INCLUDE_DIRS}")
#     print_path("库文件" "${OpenCV_LIBS}")
#     # 可选：链接到主程序
#     # target_include_directories(${PROJECT_NAME} PRIVATE ${OpenCV_INCLUDE_DIRS})
#     # target_link_libraries(${PROJECT_NAME} PRIVATE ${OpenCV_LIBS})
# else()
#     print_library_not_found("OpenCV")
#     print_info("安装方式: vcpkg install opencv:x64-windows")
#     print_info("或设置环境变量 OpenCV_DIR")
# endif()

# ----------------------------------------------------------------------------
# 测试2: Boost
# ----------------------------------------------------------------------------
print_subheader("检测 Boost")
# 查找 Boost 的常用组件
find_package(Boost QUIET COMPONENTS system filesystem thread date_time)
if(Boost_FOUND)
    print_library_found("Boost" "${Boost_VERSION_STRING}")
    print_path("包含目录" "${Boost_INCLUDE_DIRS}")
    print_path("库目录" "${Boost_LIBRARY_DIRS}")
    print_path("库文件" "${Boost_LIBRARIES}")
    # 可选：链接到主程序
    # target_include_directories(${PROJECT_NAME} PRIVATE ${Boost_INCLUDE_DIRS})
    # target_link_libraries(${PROJECT_NAME} PRIVATE ${Boost_LIBRARIES})
else()
    print_library_not_found("Boost")
    print_info("安装方式: vcpkg install boost:x64-windows")
    print_info("或设置环境变量 BOOST_ROOT")
endif()

# ----------------------------------------------------------------------------
# 测试3: HALCON
# ----------------------------------------------------------------------------
print_subheader("检测 HALCON")

# 尝试从环境变量或常见路径查找 HALCON
set(HALCON_POSSIBLE_PATHS
    "$ENV{HALCONROOT}"
    "$ENV{HALCON_ROOT}"
    "C:/Program Files/MVTec/HALCON-20.11-Steady"
    "C:/Program Files/MVTec/HALCON-21.11-Progress"
    "C:/Program Files/MVTec/HALCON-22.11-Progress"
    "C:/Program Files/MVTec/HALCON-23.05-Progress"
)

set(HALCON_FOUND FALSE)
foreach(HALCON_PATH IN LISTS HALCON_POSSIBLE_PATHS)
    if(EXISTS "${HALCON_PATH}")
        set(HALCON_ROOT "${HALCON_PATH}")
        set(HALCON_INCLUDE_DIR "${HALCON_ROOT}/include")
        set(HALCON_LIB_DIR "${HALCON_ROOT}/lib/x64-win64")
        
        # 查找 HALCON 库文件
        find_library(HALCON_LIBRARY
            NAMES halcon halconcpp
            PATHS ${HALCON_LIB_DIR}
            NO_DEFAULT_PATH
        )
        
        if(HALCON_LIBRARY AND EXISTS "${HALCON_INCLUDE_DIR}")
            set(HALCON_FOUND TRUE)
            print_library_found("HALCON" "")
            print_path("根目录" "${HALCON_ROOT}")
            print_path("包含目录" "${HALCON_INCLUDE_DIR}")
            print_path("库目录" "${HALCON_LIB_DIR}")
            print_path("库文件" "${HALCON_LIBRARY}")
            # 可选：链接到主程序
            # target_include_directories(${PROJECT_NAME} PRIVATE ${HALCON_INCLUDE_DIR})
            # target_link_libraries(${PROJECT_NAME} PRIVATE ${HALCON_LIBRARY})
            break()
        endif()
    endif()
endforeach()

if(NOT HALCON_FOUND)
    print_library_not_found("HALCON")
    print_info("安装方式: 从 MVTec 官网下载")
    print_info("或设置环境变量 HALCONROOT")
endif()

# ----------------------------------------------------------------------------
# 总结
# ----------------------------------------------------------------------------
print_separator()
print_success("外部库检测完成")
print_info("取消上面代码中的注释可将库链接到主程序")

# ============================================================================
# 测试功能4: CTest 和 GTest 集成
# ============================================================================
message(STATUS "")
message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}========== 测试功能4: CTest 和 GTest 集成 ==========${_COLOR_RESET}")
message(STATUS "${_COLOR_YELLOW}CTest 和 GTest 测试:${_COLOR_RESET}")
message(STATUS "${_COLOR_YELLOW}  1. 已创建测试文件: tests/test_mylib.cpp${_COLOR_RESET}")
message(STATUS "${_COLOR_YELLOW}  2. 已创建测试配置: tests/CMakeLists.txt${_COLOR_RESET}")
message(STATUS "${_COLOR_YELLOW}  3. 使用方式:${_COLOR_RESET}")
message(STATUS "${_COLOR_WHITE}     a) 设置环境变量: export GTEST_PATH=/path/to/gtest${_COLOR_RESET}")
message(STATUS "${_COLOR_WHITE}     b) 在 tests/ 目录中: add_subdirectory(tests)${_COLOR_RESET}")
message(STATUS "${_COLOR_WHITE}     c) 运行测试: ctest 或 cmake --build build --target test${_COLOR_RESET}")
message(STATUS "${_COLOR_YELLOW}  4. 或使用 vcpkg: vcpkg install gtest${_COLOR_RESET}")

# 如果 tests 目录存在且包含 CMakeLists.txt，则添加测试子目录
if(EXISTS "${CMAKE_SOURCE_DIR}/tests/CMakeLists.txt")
    message(STATUS "${_COLOR_GREEN}发现 tests/CMakeLists.txt，尝试查找 GTest...${_COLOR_RESET}")
    
    # 先尝试查找 GTest（支持 vcpkg）
    find_package(GTest QUIET)
    
    # 如果未找到，尝试从 vcpkg 路径查找
    if(NOT GTest_FOUND)
        # 检查常见的 vcpkg 路径
        set(VCPKG_POSSIBLE_PATHS
            "$ENV{VCPKG_ROOT}/installed/x64-windows"
            "$ENV{VCPKG_ROOT}/installed/x86-windows"
            "C:/Users/jinxi/vcpkg/installed/x64-windows"
            "C:/vcpkg/installed/x64-windows"
        )
        
        foreach(VCPKG_PATH IN LISTS VCPKG_POSSIBLE_PATHS)
            if(EXISTS "${VCPKG_PATH}/share/gtest")
                list(APPEND CMAKE_PREFIX_PATH "${VCPKG_PATH}")
                message(STATUS "${_COLOR_GREEN}  从 vcpkg 路径添加: ${VCPKG_PATH}${_COLOR_RESET}")
                find_package(GTest QUIET)
                if(GTest_FOUND)
                    break()
                endif()
            endif()
        endforeach()
    endif()
    
    # 如果找到 GTest，添加测试子目录
    if(GTest_FOUND OR TARGET GTest::gtest OR TARGET GTest::gtest_main)
        add_subdirectory(tests)
        message(STATUS "${_COLOR_GREEN}  ✓ 已添加测试子目录（GTest 已找到）${_COLOR_RESET}")
    else()
        message(STATUS "${_COLOR_YELLOW}  - 未找到 GTest，跳过测试配置${_COLOR_RESET}")
        message(STATUS "${_COLOR_YELLOW}    提示: 使用 vcpkg 安装: vcpkg install gtest:x64-windows${_COLOR_RESET}")
        message(STATUS "${_COLOR_YELLOW}    或设置环境变量: \$env:GTEST_PATH='C:\\path\\to\\gtest'${_COLOR_RESET}")
    endif()
endif()

# ============================================================================
# 自动测试目标
# ============================================================================
# 注意：由于 Visual Studio 生成器的限制，建议直接使用脚本：
#   Windows: .\test.ps1 [模式]
#   Linux/macOS: ./test.sh [模式]
#   或: cmake -P cmake/run_tests.cmake

# 添加自定义测试目标（使用 add_custom_command 避免 Visual Studio 问题）
if(NOT TARGET run_tests)
  add_custom_target(run_tests
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_SOURCE_DIR}/cmake/run_tests.cmake
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "运行自动测试套件（使用: .\\test.ps1 或 ./test.sh）"
    VERBATIM
  )
endif()

if(NOT TARGET test_quick)
  add_custom_target(test_quick
    COMMAND ${CMAKE_COMMAND} -DTEST_MODE=quick -P ${CMAKE_SOURCE_DIR}/cmake/run_tests.cmake
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "运行快速测试（使用: .\\test.ps1 quick 或 ./test.sh quick）"
    VERBATIM
  )
endif()

# ============================================================================
# 测试功能：CPack 安装包生成
# ============================================================================
# CPack 是 CMake 的打包工具，可以生成各种格式的安装包和压缩包
#
# 支持的打包格式：
#   Windows: ZIP (压缩包), NSIS (安装程序), WIX (MSI 安装包)
#   macOS:   DragNDrop (DMG 磁盘镜像), TGZ (tar.gz)
#   Linux:   DEB (Debian/Ubuntu), RPM (RedHat/CentOS), TGZ
#
# 生成命令：
#   生成所有格式:  cmake --build build --target package
#   仅生成 ZIP:    cd build && cpack -G ZIP
#   仅生成 NSIS:   cd build && cpack -G NSIS  (需要安装 NSIS)
#   仅生成 DEB:    cd build && cpack -G DEB
#
# 输出位置：
#   build/TestApp-<版本>-<平台>.<格式>
#   例如: build/TestApp-0.1-win64.zip
#
# 注意事项：
#   - Windows NSIS 需要先安装: https://nsis.sourceforge.io/
#   - 压缩包包含所有依赖，可直接分发
#   - 会自动包含 windeployqt 打包的所有 Qt 依赖

setup_cpack(
    VENDOR "TestCompany"
    DESCRIPTION "TestApp - Qt 应用程序测试项目"
    CONTACT "support@example.com"
)

# 如果有许可证文件和图标，可以添加：
# LICENSE_FILE "${CMAKE_SOURCE_DIR}/LICENSE"
# ICON "${CMAKE_SOURCE_DIR}/resources/app.ico"

message(STATUS "")
message(STATUS "${_COLOR_GREEN}${_COLOR_BOLD}========================================${_COLOR_RESET}")
message(STATUS "${_COLOR_GREEN}${_COLOR_BOLD}配置完成！打包功能已启用${_COLOR_RESET}")
message(STATUS "${_COLOR_GREEN}${_COLOR_BOLD}========================================${_COLOR_RESET}")
message(STATUS "")
message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}1. 构建命令:${_COLOR_RESET}")
message(STATUS "  cmake -S . -B build -G Ninja")
message(STATUS "  cmake --build build")
message(STATUS "")
message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}2. 打包命令:${_COLOR_RESET}")
message(STATUS "  ${_COLOR_BOLD}cmake --build build --target package${_COLOR_RESET}")
message(STATUS "  ${_COLOR_YELLOW}↑ 自动生成 ZIP 压缩包 (无需安装任何工具)${_COLOR_RESET}")
message(STATUS "")
message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}3. 手动打包 (可选):${_COLOR_RESET}")
message(STATUS "  cd build")
message(STATUS "  cpack -G ZIP              # 仅生成 ZIP 压缩包")
if(WIN32)
    # 检查 NSIS 是否安装
    find_program(NSIS_MAKENSIS NAMES makensis)
    if(NSIS_MAKENSIS)
        message(STATUS "  cpack -G NSIS             # 生成 NSIS 安装程序 ${_COLOR_GREEN}(已安装)${_COLOR_RESET}")
    else()
        message(STATUS "  cpack -G NSIS             # 生成 NSIS 安装程序 ${_COLOR_YELLOW}(需要安装 NSIS)${_COLOR_RESET}")
        message(STATUS "  ${_COLOR_WHITE}  安装 NSIS: https://nsis.sourceforge.io/${_COLOR_RESET}")
    endif()
endif()
message(STATUS "")
message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}4. 打包结果:${_COLOR_RESET}")
message(STATUS "  - 可执行文件: ${_COLOR_BOLD}build/bin/TestApp.exe${_COLOR_RESET}")
message(STATUS "  - 压缩包: ${_COLOR_BOLD}build/TestApp-0.1-win64.zip${_COLOR_RESET}")
if(WIN32 AND NSIS_MAKENSIS)
    message(STATUS "  - 安装程序: ${_COLOR_BOLD}build/TestApp-0.1-win64.exe${_COLOR_RESET}")
endif()
message(STATUS "")
message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}5. 打包说明:${_COLOR_RESET}")
message(STATUS "  - ${_COLOR_GREEN}✓${_COLOR_RESET} 已启用 ${_COLOR_BOLD}DEPLOY${_COLOR_RESET} 模式 - 自动打包所有 Qt 依赖")
message(STATUS "  - ${_COLOR_GREEN}✓${_COLOR_RESET} 已启用 ${_COLOR_BOLD}CPack${_COLOR_RESET} - 自动生成压缩包")
message(STATUS "  - ${_COLOR_GREEN}✓${_COLOR_RESET} 压缩包包含所有依赖，解压即可运行")
message(STATUS "  - ${_COLOR_GREEN}✓${_COLOR_RESET} 无需配置 PATH 环境变量")
message(STATUS "")
message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}6. 其他选项:${_COLOR_RESET}")
message(STATUS "  - ${_COLOR_YELLOW}setup_qt(TestApp DEPLOY_FULL)${_COLOR_RESET} - 完整打包（包含翻译）")
message(STATUS "  - ${_COLOR_YELLOW}压缩包大小约 25-30 MB${_COLOR_RESET} (包含 Qt 运行时)")
message(STATUS "")
message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}7. 详细文档:${_COLOR_RESET}")
message(STATUS "  - cmake/PACKAGING.md - 完整打包指南")
message(STATUS "  - cmake/PACKAGING_QUICKREF.md - 快速参考")
message(STATUS "")
