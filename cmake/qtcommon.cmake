
# ============================================================================
# CMake 公共配置和工具函数库
# ============================================================================
# 此文件包含了项目中所有子项目共享的 CMake 配置和工具函数
# 提供了统一的编译配置、库构建、测试程序构建等功能
# 注意：文件名应该是 common.cmake（不是 commmon.txt）

# ----------------------------------------------------------------------------
# 配置信息输出
# ----------------------------------------------------------------------------
# 检测使用模式：单个项目使用 vs 多个子项目使用
if(NOT DEFINED _QTCOMMON_LOADED)
  set(_QTCOMMON_LOADED TRUE)
  message(STATUS "")
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}============================================================================${_COLOR_RESET}")
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}Qt 公共配置模块 (qtcommon.cmake)${_COLOR_RESET}")
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}============================================================================${_COLOR_RESET}")
  message(STATUS "${_COLOR_GREEN}模块路径:${_COLOR_RESET} ${CMAKE_CURRENT_LIST_DIR}/qtcommon.cmake")
  message(STATUS "${_COLOR_GREEN}项目根目录:${_COLOR_RESET} ${CMAKE_SOURCE_DIR}")
  message(STATUS "${_COLOR_GREEN}当前目录:${_COLOR_RESET} ${CMAKE_CURRENT_SOURCE_DIR}")
  
  # 判断使用模式
  if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    message(STATUS "${_COLOR_YELLOW}使用模式:${_COLOR_RESET} ${_COLOR_BOLD}单个项目${_COLOR_RESET}（顶层 CMakeLists.txt）")
  else()
    message(STATUS "${_COLOR_YELLOW}使用模式:${_COLOR_RESET} ${_COLOR_BOLD}多个子项目${_COLOR_RESET}（子目录 CMakeLists.txt）")
    message(STATUS "${_COLOR_WHITE}  - 项目根:${_COLOR_RESET} ${CMAKE_SOURCE_DIR}")
    message(STATUS "${_COLOR_WHITE}  - 当前子项目:${_COLOR_RESET} ${CMAKE_CURRENT_SOURCE_DIR}")
  endif()
  
  # 显示项目信息
  if(DEFINED PROJECT_NAME)
    message(STATUS "${_COLOR_MAGENTA}项目名称:${_COLOR_RESET} ${_COLOR_BOLD}${PROJECT_NAME}${_COLOR_RESET}")
    if(DEFINED PROJECT_VERSION)
      message(STATUS "${_COLOR_MAGENTA}项目版本:${_COLOR_RESET} ${_COLOR_BOLD}${PROJECT_VERSION}${_COLOR_RESET}")
    endif()
  endif()
  
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}============================================================================${_COLOR_RESET}")
  message(STATUS "")
endif()

# ============================================================================
# 全局配置变量
# ============================================================================

# ----------------------------------------------------------------------------
# ANSI 颜色代码定义（用于美化输出）
# ----------------------------------------------------------------------------
# 检测是否支持颜色输出（终端环境）
if(NOT WIN32 OR DEFINED ENV{TERM} OR DEFINED ENV{ANSICON} OR DEFINED ENV{ConEmuANSI})
  set(_COLOR_RESET "\033[0m")
  set(_COLOR_BOLD "\033[1m")
  set(_COLOR_RED "\033[31m")
  set(_COLOR_GREEN "\033[32m")
  set(_COLOR_YELLOW "\033[33m")
  set(_COLOR_BLUE "\033[34m")
  set(_COLOR_MAGENTA "\033[35m")
  set(_COLOR_CYAN "\033[36m")
  set(_COLOR_WHITE "\033[37m")
else()
  # Windows 非终端环境，不使用颜色
  set(_COLOR_RESET "")
  set(_COLOR_BOLD "")
  set(_COLOR_RED "")
  set(_COLOR_GREEN "")
  set(_COLOR_YELLOW "")
  set(_COLOR_BLUE "")
  set(_COLOR_MAGENTA "")
  set(_COLOR_CYAN "")
  set(_COLOR_WHITE "")
endif()

# ----------------------------------------------------------------------------
# 命名空间配置
# ----------------------------------------------------------------------------
# 设置统一的 C++ 命名空间
# 这个变量可以在生成头文件时使用（通过 configure_file）
# 注释掉的那行是模板文件的用法示例
# set(_XCPP_NAMESPACE_ "namespace xcpp {")

# 自动包含当前目录到包含路径中
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# 启用Qt的自动UI处理功能
set(CMAKE_AUTOUIC ON)
# 启用Qt的元对象代码(MOC)自动处理
set(CMAKE_AUTOMOC ON)
# 启用Qt的资源文件(RCC)自动处理
set(CMAKE_AUTORCC ON)

# ----------------------------------------------------------------------------
# Qt 前缀路径与提示
# ----------------------------------------------------------------------------
# 支持通过环境变量 QT_PREFIX_PATH 注入 Qt 安装前缀，避免写死路径。
# 若未找到 Qt，将给出清晰错误提示。
if(DEFINED ENV{QT_PREFIX_PATH})
  list(APPEND CMAKE_PREFIX_PATH "$ENV{QT_PREFIX_PATH}")
  message(STATUS "已从环境变量 QT_PREFIX_PATH 追加 Qt 前缀: $ENV{QT_PREFIX_PATH}")
endif()

# ----------------------------------------------------------------------------
# 导出 compile_commands.json（便于 clangd 等工具）
# ----------------------------------------------------------------------------
# 注意：Visual Studio 生成器不支持 compile_commands.json，仅 Ninja/Unix Makefiles 等支持
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
if(CMAKE_EXPORT_COMPILE_COMMANDS AND NOT TARGET copy_compile_commands)
  # 检查生成器是否支持 compile_commands.json（排除 Visual Studio 系列）
  if(NOT CMAKE_GENERATOR MATCHES "Visual Studio" AND NOT CMAKE_GENERATOR MATCHES "NMake")
    # 提取复制命令为变量，避免重复
    set(_COPY_COMPILE_COMMANDS_CMD
      ${CMAKE_COMMAND} -E copy_if_different
      "${CMAKE_BINARY_DIR}/compile_commands.json"
      "${CMAKE_SOURCE_DIR}/compile_commands.json"
    )
    # 自动同步目标（构建时自动运行）
    add_custom_target(copy_compile_commands ALL
      COMMAND ${_COPY_COMPILE_COMMANDS_CMD}
      BYPRODUCTS "${CMAKE_SOURCE_DIR}/compile_commands.json"
      COMMENT "同步 compile_commands.json 到源码根目录，方便 IDE/clangd 使用"
    )
    # 独立目标（可手动运行：cmake --build build --target gen_compile_commands）
    add_custom_target(gen_compile_commands
      COMMAND ${_COPY_COMPILE_COMMANDS_CMD}
      COMMENT "手动生成 compile_commands.json 到源码根目录"
    )
    message(STATUS "已启用 compile_commands.json 自动同步（生成器: ${CMAKE_GENERATOR}）")
    message(STATUS "手动生成命令: cmake --build build --target gen_compile_commands")
  else()
    message(STATUS "当前生成器 ${CMAKE_GENERATOR} 不支持 compile_commands.json，建议使用 Ninja 生成器")
  endif()
endif()

# ----------------------------------------------------------------------------
# 使用说明
# ----------------------------------------------------------------------------
# 详细使用文档请参考：cmake/README.md
#
# 快速参考：
#   - setup_qt(target [WIN32] [NO_WIN32] [DEPLOY] [DEPLOY_FULL] [COMPONENTS ...])
#   - 默认：隐藏控制台、仅复制 platforms 插件、自动查找 Qt6/Qt5
#   - DEPLOY：自动打包所有依赖（windeployqt/macdeployqt/linuxdeployqt）
#   - DEPLOY_FULL：完整打包模式，包含所有插件和翻译（适合发布）
#   - compile_commands.json：使用 Ninja 生成器自动生成并同步
#   - setup_package_directory：为多项目创建统一打包目录
#   - setup_cpack：配置 CPack 自动生成安装包
#
# 更多信息请查看：cmake/README.md

# ============================================================================
# 打包辅助函数
# ============================================================================

# ----------------------------------------------------------------------------
# 函数：复制 platforms 插件到目标目录（内部辅助函数）
# ----------------------------------------------------------------------------
# 功能：将 Qt platforms 插件复制到目标运行目录
# 参数：target - 目标名称，plugin_path - 插件源路径
function(_copy_platforms_plugin target plugin_path)
  if(plugin_path AND EXISTS "${plugin_path}")
    add_custom_command(TARGET ${target} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E make_directory \"$<TARGET_FILE_DIR:${target}>/platforms\"
      COMMAND ${CMAKE_COMMAND} -E copy_directory
        \"${plugin_path}\"
        \"$<TARGET_FILE_DIR:${target}>/platforms\"
    )
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 函数：复制 Qt 插件到目标目录（增强版）
# ----------------------------------------------------------------------------
# 功能：复制指定的 Qt 插件到目标运行目录
# 参数：
#   target - 目标名称
#   plugin_categories - 插件类别列表（如 platforms imageformats iconengines styles）
function(_copy_qt_plugins target plugin_categories)
  # 获取 Qt 安装前缀
  _get_qt_prefix_dir()
  
  if(NOT QT_PREFIX_DIR)
    message(WARNING "未找到 Qt 安装路径，无法复制插件")
    return()
  endif()
  
  set(PLUGIN_BASE_PATH "${QT_PREFIX_DIR}/plugins")
  
  foreach(category IN LISTS plugin_categories)
    set(PLUGIN_SOURCE "${PLUGIN_BASE_PATH}/${category}")
    if(EXISTS "${PLUGIN_SOURCE}")
      add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory \"$<TARGET_FILE_DIR:${target}>/${category}\"
        COMMAND ${CMAKE_COMMAND} -E copy_directory
          \"${PLUGIN_SOURCE}\"
          \"$<TARGET_FILE_DIR:${target}>/${category}\"
        COMMENT "复制 Qt ${category} 插件"
      )
      message(STATUS "已配置复制 Qt ${category} 插件")
    else()
      message(WARNING "未找到 Qt ${category} 插件: ${PLUGIN_SOURCE}")
    endif()
  endforeach()
endfunction()

# ----------------------------------------------------------------------------
# 函数：复制 Qt 依赖库（手动方式）
# ----------------------------------------------------------------------------
# 功能：手动复制必要的 Qt DLL 到目标运行目录（Windows 备用方案）
# 参数：
#   target - 目标名称
#   qt_components - Qt 组件列表
function(_copy_qt_dependencies target qt_components)
  if(NOT WIN32)
    return()
  endif()
  
  # 获取 Qt 安装前缀
  _get_qt_prefix_dir()
  
  if(NOT QT_PREFIX_DIR)
    message(WARNING "未找到 Qt 安装路径，无法复制依赖库")
    return()
  endif()
  
  set(QT_BIN_DIR "${QT_PREFIX_DIR}/bin")
  
  # 基础依赖 DLL
  set(CORE_DLLS
    Qt${QT_VERSION_MAJOR}Core$<$<CONFIG:Debug>:d>.dll
  )
  
  # 根据组件添加相应的 DLL
  foreach(comp IN LISTS qt_components)
    list(APPEND CORE_DLLS Qt${QT_VERSION_MAJOR}${comp}$<$<CONFIG:Debug>:d>.dll)
  endforeach()
  
  # 复制 DLL
  foreach(dll IN LISTS CORE_DLLS)
    add_custom_command(TARGET ${target} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different
        \"${QT_BIN_DIR}/${dll}\"
        \"$<TARGET_FILE_DIR:${target}>\"
      COMMENT "复制 ${dll}"
    )
  endforeach()
  
  message(STATUS "已配置手动复制 Qt 依赖库（${qt_components}）")
endfunction()

# ----------------------------------------------------------------------------
# 函数：生成 qt.conf 配置文件
# ----------------------------------------------------------------------------
# 功能：在可执行文件目录生成 qt.conf，指定插件和库的相对路径
# 参数：target - 目标名称
function(_generate_qt_conf target)
  set(QT_CONF_CONTENT "[Paths]\nPlugins = .\nLibraries = .\n")
  
  add_custom_command(TARGET ${target} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "[Paths]" > \"$<TARGET_FILE_DIR:${target}>/qt.conf\"
    COMMAND ${CMAKE_COMMAND} -E echo "Plugins = ." >> \"$<TARGET_FILE_DIR:${target}>/qt.conf\"
    COMMAND ${CMAKE_COMMAND} -E echo "Libraries = ." >> \"$<TARGET_FILE_DIR:${target}>/qt.conf\"
    COMMENT "生成 qt.conf 配置文件"
  )
  
  message(STATUS "已配置生成 qt.conf")
endfunction()

# ----------------------------------------------------------------------------
# 函数：创建打包目录结构
# ----------------------------------------------------------------------------
# 功能：为多项目场景创建统一的打包目录结构
# 参数：package_name - 打包名称（默认使用 PROJECT_NAME）
function(setup_package_directory)
  set(options)
  set(oneValueArgs NAME)
  set(multiValueArgs)
  cmake_parse_arguments(PKG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  if(NOT PKG_NAME)
    set(PKG_NAME ${PROJECT_NAME})
  endif()
  
  # 设置打包根目录
  set(PACKAGE_ROOT_DIR "${CMAKE_BINARY_DIR}/package/${PKG_NAME}" CACHE PATH "打包根目录")
  set(PACKAGE_BIN_DIR "${PACKAGE_ROOT_DIR}/bin" CACHE PATH "打包可执行文件目录")
  set(PACKAGE_LIB_DIR "${PACKAGE_ROOT_DIR}/lib" CACHE PATH "打包库文件目录")
  set(PACKAGE_PLUGIN_DIR "${PACKAGE_ROOT_DIR}/plugins" CACHE PATH "打包插件目录")
  set(PACKAGE_DOC_DIR "${PACKAGE_ROOT_DIR}/docs" CACHE PATH "打包文档目录")
  
  # 创建目录
  file(MAKE_DIRECTORY ${PACKAGE_ROOT_DIR})
  file(MAKE_DIRECTORY ${PACKAGE_BIN_DIR})
  file(MAKE_DIRECTORY ${PACKAGE_LIB_DIR})
  file(MAKE_DIRECTORY ${PACKAGE_PLUGIN_DIR})
  file(MAKE_DIRECTORY ${PACKAGE_DOC_DIR})
  
  message(STATUS "${_COLOR_GREEN}打包目录已创建:${_COLOR_RESET} ${PACKAGE_ROOT_DIR}")
endfunction()

# ----------------------------------------------------------------------------
# 函数：获取 Qt 安装前缀路径（内部辅助函数）
# ----------------------------------------------------------------------------
# 功能：从环境变量或 CMake 变量中推导 Qt 安装前缀路径
# 输出：QT_PREFIX_DIR 变量（如果找到）
function(_get_qt_prefix_dir)
  set(QT_PREFIX_DIR "" PARENT_SCOPE)
  if(DEFINED ENV{QT_PREFIX_PATH})
    set(QT_PREFIX_DIR "$ENV{QT_PREFIX_PATH}" PARENT_SCOPE)
    message(STATUS "从环境变量 QT_PREFIX_PATH 获取 Qt 路径")
    return()
  endif()
  
  # 尝试从已找到的 Qt 包中获取安装路径
  # 方法1：从 Qt5Core_DIR 或 Qt6Core_DIR 推导（最可靠）
  if(QT_VERSION_MAJOR EQUAL 5 AND DEFINED Qt5Core_DIR)
    get_filename_component(_QT_PREFIX "${Qt5Core_DIR}/../../.." ABSOLUTE)
    set(QT_PREFIX_DIR "${_QT_PREFIX}" PARENT_SCOPE)
    message(STATUS "从 Qt5Core_DIR 自动推导 Qt 路径")
  elseif(QT_VERSION_MAJOR EQUAL 6 AND DEFINED Qt6Core_DIR)
    get_filename_component(_QT_PREFIX "${Qt6Core_DIR}/../../.." ABSOLUTE)
    set(QT_PREFIX_DIR "${_QT_PREFIX}" PARENT_SCOPE)
    message(STATUS "从 Qt6Core_DIR 自动推导 Qt 路径")
  # 方法1.5：备用方案，从 Qt5_DIR 或 Qt6_DIR 推导
  elseif(QT_VERSION_MAJOR EQUAL 5 AND DEFINED Qt5_DIR)
    get_filename_component(_QT_PREFIX "${Qt5_DIR}/../.." ABSOLUTE)
    set(QT_PREFIX_DIR "${_QT_PREFIX}" PARENT_SCOPE)
    message(STATUS "从 Qt5_DIR 自动推导 Qt 路径")
  elseif(QT_VERSION_MAJOR EQUAL 6 AND DEFINED Qt6_DIR)
    get_filename_component(_QT_PREFIX "${Qt6_DIR}/../.." ABSOLUTE)
    set(QT_PREFIX_DIR "${_QT_PREFIX}" PARENT_SCOPE)
    message(STATUS "从 Qt6_DIR 自动推导 Qt 路径")
  # 方法2：从 QtCore 目标位置推导（备用方案）
  elseif(TARGET Qt${QT_VERSION_MAJOR}::Core)
    get_target_property(QT_CORE_LOCATION Qt${QT_VERSION_MAJOR}::Core IMPORTED_LOCATION)
    if(NOT QT_CORE_LOCATION)
      get_target_property(QT_CORE_LOCATION Qt${QT_VERSION_MAJOR}::Core LOCATION)
    endif()
    if(QT_CORE_LOCATION)
      get_filename_component(QT_LIB_DIR ${QT_CORE_LOCATION} DIRECTORY)
      get_filename_component(_QT_PREFIX ${QT_LIB_DIR} DIRECTORY)
      set(QT_PREFIX_DIR "${_QT_PREFIX}" PARENT_SCOPE)
      message(STATUS "从 Qt${QT_VERSION_MAJOR}::Core 自动推导 Qt 路径")
    endif()
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 函数：统一查找并链接 Qt（支持 Qt6/Qt5，默认 Widgets）
# ----------------------------------------------------------------------------
# 用法：
#   setup_qt(<target> [WIN32] [NO_WIN32] [DEPLOY] [DEPLOY_FULL] [COMPONENTS Widgets Gui Core ...])
#
# 参数：
#   WIN32: 在 Windows 上隐藏控制台窗口（Windows 子系统，默认启用）
#   NO_WIN32: 在 Windows 上显示控制台窗口（控制台应用）
#   DEPLOY: 在 Windows 上自动运行 windeployqt 打包所有依赖（构建后）
#   DEPLOY_FULL: 完整打包模式，包含所有插件和依赖（适合发布）
#   COMPONENTS: Qt 组件列表，默认仅 Widgets
#
# 说明：
# - 自动优先查找 Qt6，不存在则回落 Qt5
# - 必须先创建目标（add_executable/add_library）再调用
# - 默认仅链接 Widgets，如需额外组件使用 COMPONENTS 传入
# - Windows 上默认隐藏控制台（WIN32），如需显示控制台使用 NO_WIN32
# - 使用 DEPLOY 选项可自动打包所有 Qt 依赖，无需手动配置 PATH
# - 使用 DEPLOY_FULL 选项可进行完整打包，适合最终发布
function(setup_qt target)
  if(NOT TARGET ${target})
    message(FATAL_ERROR "setup_qt: 目标 ${target} 未创建，请先 add_executable/add_library。")
  endif()

  set(options WIN32 NO_WIN32 DEPLOY DEPLOY_FULL)
  set(oneValueArgs)
  set(multiValueArgs COMPONENTS)
  cmake_parse_arguments(QT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT QT_COMPONENTS)
    set(QT_COMPONENTS Widgets)
  endif()

  # 显示配置信息
  message(STATUS "")
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}--- 配置 Qt 目标: ${target} ---${_COLOR_RESET}")
  
  # 检测文件使用模式
  if(DEFINED SRC)
    list(LENGTH SRC SRC_COUNT)
    message(STATUS "${_COLOR_GREEN}源文件数量:${_COLOR_RESET} ${_COLOR_BOLD}${SRC_COUNT}${_COLOR_RESET}")
  endif()
  if(DEFINED H_FILE)
    list(LENGTH H_FILE H_FILE_COUNT)
    if(H_FILE_COUNT GREATER 0)
      message(STATUS "${_COLOR_GREEN}头文件数量:${_COLOR_RESET} ${_COLOR_BOLD}${H_FILE_COUNT}${_COLOR_RESET}")
    endif()
  endif()
  if(DEFINED UI_FILE)
    list(LENGTH UI_FILE UI_FILE_COUNT)
    if(UI_FILE_COUNT GREATER 0)
      message(STATUS "${_COLOR_GREEN}UI 文件数量:${_COLOR_RESET} ${_COLOR_BOLD}${UI_FILE_COUNT}${_COLOR_RESET}")
    endif()
  endif()
  
  # 显示使用模式
  if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    message(STATUS "${_COLOR_YELLOW}使用模式:${_COLOR_RESET} ${_COLOR_BOLD}单个项目${_COLOR_RESET}")
    set(IS_SINGLE_PROJECT TRUE)
  else()
    message(STATUS "${_COLOR_YELLOW}使用模式:${_COLOR_RESET} ${_COLOR_BOLD}子项目${_COLOR_RESET}（${CMAKE_CURRENT_SOURCE_DIR}）")
    set(IS_SINGLE_PROJECT FALSE)
  endif()

  find_package(QT NAMES Qt6 Qt5 COMPONENTS ${QT_COMPONENTS} REQUIRED)
  if(NOT QT_FOUND)
    message(FATAL_ERROR "未找到 Qt6/Qt5，请检查 CMAKE_PREFIX_PATH 或设置环境变量 QT_PREFIX_PATH。")
  endif()

  find_package(Qt${QT_VERSION_MAJOR} COMPONENTS ${QT_COMPONENTS} REQUIRED)
  if(NOT Qt${QT_VERSION_MAJOR}_FOUND)
    message(FATAL_ERROR "未找到 Qt${QT_VERSION_MAJOR} 组件: ${QT_COMPONENTS}，请检查安装。")
  endif()

  message(STATUS "${_COLOR_MAGENTA}Qt 版本:${_COLOR_RESET} ${_COLOR_BOLD}Qt${QT_VERSION_MAJOR}${_COLOR_RESET}，${_COLOR_MAGENTA}组件:${_COLOR_RESET} ${_COLOR_BOLD}${QT_COMPONENTS}${_COLOR_RESET}")

  foreach(comp IN LISTS QT_COMPONENTS)
    target_link_libraries(${target} PRIVATE Qt${QT_VERSION_MAJOR}::${comp})
  endforeach()

  # 获取 Qt 安装前缀路径（所有平台通用，用于打包工具）
  _get_qt_prefix_dir()

  # 确定打包模式
  set(ENABLE_DEPLOY FALSE)
  set(FULL_DEPLOY FALSE)
  
  if(QT_DEPLOY OR QT_DEPLOY_FULL)
    set(ENABLE_DEPLOY TRUE)
  endif()
  
  if(QT_DEPLOY_FULL)
    set(FULL_DEPLOY TRUE)
    message(STATUS "${_COLOR_MAGENTA}打包模式:${_COLOR_RESET} ${_COLOR_BOLD}完整打包（DEPLOY_FULL）${_COLOR_RESET}")
  elseif(QT_DEPLOY)
    message(STATUS "${_COLOR_MAGENTA}打包模式:${_COLOR_RESET} ${_COLOR_BOLD}标准打包（DEPLOY）${_COLOR_RESET}")
  else()
    message(STATUS "${_COLOR_MAGENTA}打包模式:${_COLOR_RESET} ${_COLOR_BOLD}开发模式（仅复制 platforms）${_COLOR_RESET}")
  endif()

  # 平台运行时提示与可选配置
  if(WIN32)
    # 控制台窗口控制：默认隐藏（WIN32），可通过 NO_WIN32 显式显示
    if(QT_NO_WIN32)
      # 用户显式要求显示控制台窗口
      set_target_properties(${target} PROPERTIES WIN32_EXECUTABLE FALSE)
      message(STATUS "Windows: 已设置为控制台应用（显示控制台窗口）")
    else()
      # 默认或显式指定 WIN32：隐藏控制台窗口（Windows 子系统）
      set_target_properties(${target} PROPERTIES WIN32_EXECUTABLE TRUE)
      if(QT_WIN32)
        message(STATUS "Windows: 已设置为 Windows 子系统应用（隐藏控制台窗口）")
      else()
        message(STATUS "Windows: 已设置为 Windows 子系统应用（隐藏控制台窗口，默认行为）")
      endif()
    endif()
    
    # 设置插件路径（Windows 专用）
    set(QT_PLUGIN_SOURCE_PATH "")
    if(QT_PREFIX_DIR)
      set(QT_PLUGIN_SOURCE_PATH "${QT_PREFIX_DIR}/plugins/platforms")
    endif()
    
    # 自动打包或复制插件
    if(ENABLE_DEPLOY)
      # 使用 windeployqt 自动打包所有依赖（推荐方式）
      # 构建搜索路径列表
      set(WINDEPLOYQT_SEARCH_PATHS "")
      if(QT_PREFIX_DIR)
        list(APPEND WINDEPLOYQT_SEARCH_PATHS "${QT_PREFIX_DIR}/bin")
      endif()
      if(DEFINED ENV{QT_PREFIX_PATH})
        list(APPEND WINDEPLOYQT_SEARCH_PATHS "$ENV{QT_PREFIX_PATH}/bin")
      endif()
      # 备用路径：直接从 Qt_DIR 推导
      if(QT_VERSION_MAJOR EQUAL 5 AND DEFINED Qt5_DIR)
        get_filename_component(_QT5_PREFIX "${Qt5_DIR}/../.." ABSOLUTE)
        list(APPEND WINDEPLOYQT_SEARCH_PATHS "${_QT5_PREFIX}/bin")
      elseif(QT_VERSION_MAJOR EQUAL 6 AND DEFINED Qt6_DIR)
        get_filename_component(_QT6_PREFIX "${Qt6_DIR}/../.." ABSOLUTE)
        list(APPEND WINDEPLOYQT_SEARCH_PATHS "${_QT6_PREFIX}/bin")
      endif()
      
      find_program(WINDEPLOYQT_EXECUTABLE
        NAMES windeployqt
        PATHS ${WINDEPLOYQT_SEARCH_PATHS}
        NO_DEFAULT_PATH
      )
      
      if(WINDEPLOYQT_EXECUTABLE)
        # 构建 windeployqt 参数
        set(DEPLOY_ARGS "")
        if(FULL_DEPLOY)
          # 完整打包：包含所有插件和翻译
          list(APPEND DEPLOY_ARGS --verbose 1)
        else()
          # 标准打包：排除不必要的插件
          list(APPEND DEPLOY_ARGS --no-translations)
          list(APPEND DEPLOY_ARGS --no-system-d3d-compiler)
          list(APPEND DEPLOY_ARGS --no-opengl-sw)
        endif()
        
        # 构建后自动运行 windeployqt 打包
        add_custom_command(TARGET ${target} POST_BUILD
          COMMAND ${WINDEPLOYQT_EXECUTABLE}
            ${DEPLOY_ARGS}
            \"$<TARGET_FILE:${target}>\"
          COMMENT "自动打包 Qt 依赖（windeployqt ${FULL_DEPLOY}）"
        )
        message(STATUS "Windows: 已启用自动打包（windeployqt），构建后自动复制所有 Qt 依赖")
        message(STATUS "Windows: windeployqt 路径: ${WINDEPLOYQT_EXECUTABLE}")
        
        # 生成 qt.conf
        _generate_qt_conf(${target})
      else()
        message(WARNING "Windows: 未找到 windeployqt 工具，无法自动打包。请手动运行 windeployqt 或使用 DEPLOY 选项")
        # 回退到手动复制 platforms 插件
        _copy_platforms_plugin(${target} "${QT_PLUGIN_SOURCE_PATH}")
        if(QT_PLUGIN_SOURCE_PATH AND EXISTS "${QT_PLUGIN_SOURCE_PATH}")
          message(STATUS "Windows: 已启用自动复制 platforms 插件（windeployqt 未找到，使用备用方案）")
        endif()
      endif()
    else()
      # 手动复制 platforms 插件（轻量级方案）
      _copy_platforms_plugin(${target} "${QT_PLUGIN_SOURCE_PATH}")
      if(QT_PLUGIN_SOURCE_PATH AND EXISTS "${QT_PLUGIN_SOURCE_PATH}")
        message(STATUS "Windows: 已启用自动复制 platforms 插件到运行目录（构建后自动完成）")
        message(STATUS "Windows: 运行时依赖：请确保 Qt 的 bin 目录在 PATH 中，或使用 setup_qt(${target} DEPLOY) 自动打包")
      else()
        message(STATUS "Windows: 未找到 platforms 插件路径，跳过自动复制")
        message(STATUS "Windows: 运行时依赖：请将 Qt 的 bin 和 plugins 目录加入 PATH，或使用 setup_qt(${target} DEPLOY) 自动打包")
      endif()
    endif()
  elseif(APPLE)
    set(CMAKE_MACOSX_RPATH ON)
    set_target_properties(${target} PROPERTIES
      MACOSX_BUNDLE TRUE
      MACOSX_RPATH TRUE
    )
    message(STATUS "macOS: 已开启 CMAKE_MACOSX_RPATH，并设置 MACOSX_BUNDLE")
    
    # macOS 自动打包
    if(ENABLE_DEPLOY)
      # 查找 macdeployqt 工具
      set(MACDEPLOYQT_SEARCH_PATHS "")
      if(QT_PREFIX_DIR)
        list(APPEND MACDEPLOYQT_SEARCH_PATHS "${QT_PREFIX_DIR}/bin")
      endif()
      if(DEFINED ENV{QT_PREFIX_PATH})
        list(APPEND MACDEPLOYQT_SEARCH_PATHS "$ENV{QT_PREFIX_PATH}/bin")
      endif()
      
      find_program(MACDEPLOYQT_EXECUTABLE
        NAMES macdeployqt
        PATHS ${MACDEPLOYQT_SEARCH_PATHS}
        NO_DEFAULT_PATH
      )
      
      if(MACDEPLOYQT_EXECUTABLE)
        # 构建 macdeployqt 参数
        set(DEPLOY_ARGS "")
        if(FULL_DEPLOY)
          list(APPEND DEPLOY_ARGS -verbose=2)
        else()
          list(APPEND DEPLOY_ARGS -verbose=1)
        endif()
        
        # 构建后自动运行 macdeployqt 打包
        add_custom_command(TARGET ${target} POST_BUILD
          COMMAND ${MACDEPLOYQT_EXECUTABLE}
            \"$<TARGET_BUNDLE_DIR:${target}>\"
            ${DEPLOY_ARGS}
          COMMENT "自动打包 Qt 依赖（macdeployqt）"
        )
        message(STATUS "Windows: 已启用自动打包（windeployqt），构建后自动复制所有 Qt 依赖")
        message(STATUS "Windows: windeployqt 路径: ${WINDEPLOYQT_EXECUTABLE}")
      else()
        message(WARNING "Windows: 未找到 windeployqt 工具，无法自动打包。请手动运行 windeployqt 或使用 DEPLOY 选项")
        # 回退到手动复制 platforms 插件
        _copy_platforms_plugin(${target} "${QT_PLUGIN_SOURCE_PATH}")
        if(QT_PLUGIN_SOURCE_PATH AND EXISTS "${QT_PLUGIN_SOURCE_PATH}")
          message(STATUS "Windows: 已启用自动复制 platforms 插件（windeployqt 未找到，使用备用方案）")
        endif()
      endif()
    else()
      # 手动复制 platforms 插件（轻量级方案）
      _copy_platforms_plugin(${target} "${QT_PLUGIN_SOURCE_PATH}")
      if(QT_PLUGIN_SOURCE_PATH AND EXISTS "${QT_PLUGIN_SOURCE_PATH}")
        message(STATUS "Windows: 已启用自动复制 platforms 插件到运行目录（构建后自动完成）")
        message(STATUS "Windows: 运行时依赖：请确保 Qt 的 bin 目录在 PATH 中，或使用 setup_qt(${target} DEPLOY) 自动打包")
      else()
        message(STATUS "Windows: 未找到 platforms 插件路径，跳过自动复制")
        message(STATUS "Windows: 运行时依赖：请将 Qt 的 bin 和 plugins 目录加入 PATH，或使用 setup_qt(${target} DEPLOY) 自动打包")
      endif()
    endif()
  elseif(APPLE)
    set(CMAKE_MACOSX_RPATH ON)
    set_target_properties(${target} PROPERTIES
      MACOSX_BUNDLE TRUE
      MACOSX_RPATH TRUE
    )
    message(STATUS "macOS: 已开启 CMAKE_MACOSX_RPATH，并设置 MACOSX_BUNDLE")
    
    # macOS 自动打包
    if(QT_DEPLOY)
      # 查找 macdeployqt 工具
      set(MACDEPLOYQT_SEARCH_PATHS "")
      if(QT_PREFIX_DIR)
        list(APPEND MACDEPLOYQT_SEARCH_PATHS "${QT_PREFIX_DIR}/bin")
      endif()
      if(DEFINED ENV{QT_PREFIX_PATH})
        list(APPEND MACDEPLOYQT_SEARCH_PATHS "$ENV{QT_PREFIX_PATH}/bin")
      endif()
      
      find_program(MACDEPLOYQT_EXECUTABLE
        NAMES macdeployqt
        PATHS ${MACDEPLOYQT_SEARCH_PATHS}
        NO_DEFAULT_PATH
      )
      
      if(MACDEPLOYQT_EXECUTABLE)
        # 构建后自动运行 macdeployqt 打包
        add_custom_command(TARGET ${target} POST_BUILD
          COMMAND ${MACDEPLOYQT_EXECUTABLE}
            \"$<TARGET_BUNDLE_DIR:${target}>\"
          COMMENT "自动打包 Qt 依赖（macdeployqt）"
        )
        # 构建后自动运行 macdeployqt 打包
        add_custom_command(TARGET ${target} POST_BUILD
          COMMAND ${MACDEPLOYQT_EXECUTABLE}
            \"$<TARGET_BUNDLE_DIR:${target}>\"
            ${DEPLOY_ARGS}
          COMMENT "自动打包 Qt 依赖（macdeployqt）"
        )
        message(STATUS "macOS: 已启用自动打包（macdeployqt），构建后自动复制所有 Qt 依赖")
        message(STATUS "macOS: macdeployqt 路径: ${MACDEPLOYQT_EXECUTABLE}")
      else()
        message(WARNING "macOS: 未找到 macdeployqt 工具，无法自动打包。请手动运行 macdeployqt")
        message(STATUS "macOS: 手动打包命令: macdeployqt $<TARGET_BUNDLE_DIR:${target}>")
      endif()
    else()
      message(STATUS "macOS: 如需自动打包，请使用 setup_qt(${target} DEPLOY)")
    endif()
  else()
    # Linux 平台
    message(STATUS "Linux: 如需 X11/Wayland 等额外模块，请在 COMPONENTS 中显式添加。")
    
    # Linux 自动打包
    if(ENABLE_DEPLOY)
      # 查找 linuxdeployqt 工具（如果安装了）
      find_program(LINUXDEPLOYQT_EXECUTABLE
        NAMES linuxdeployqt
        PATHS
          /usr/local/bin
          /usr/bin
          "$ENV{HOME}/.local/bin"
        NO_DEFAULT_PATH
      )
      
      if(LINUXDEPLOYQT_EXECUTABLE)
        # 构建 linuxdeployqt 参数
        set(DEPLOY_ARGS -bundle-non-qt-libs)
        if(FULL_DEPLOY)
          list(APPEND DEPLOY_ARGS -appimage)
        endif()
        
        # 构建后自动运行 linuxdeployqt 打包
        add_custom_command(TARGET ${target} POST_BUILD
          COMMAND ${LINUXDEPLOYQT_EXECUTABLE}
            \"$<TARGET_FILE:${target}>\"
            ${DEPLOY_ARGS}
          COMMENT "自动打包 Qt 依赖（linuxdeployqt）"
        )
        message(STATUS "Linux: 已启用自动打包（linuxdeployqt），构建后自动复制所有 Qt 依赖")
        message(STATUS "Linux: linuxdeployqt 路径: ${LINUXDEPLOYQT_EXECUTABLE}")
      else()
        message(STATUS "Linux: 未找到 linuxdeployqt 工具")
        message(STATUS "Linux: 建议安装 linuxdeployqt 或手动复制 Qt 依赖到运行目录")
        message(STATUS "Linux: 安装: https://github.com/probonopd/linuxdeployqt")
        # 可选：手动复制 Qt 库（需要用户配置）
        if(QT_PREFIX_DIR)
          message(STATUS "Linux: Qt 路径: ${QT_PREFIX_DIR}，可手动复制 lib 和 plugins 目录")
        endif()
      endif()
    else()
      message(STATUS "Linux: 如需自动打包，请使用 setup_qt(${target} DEPLOY) 或手动配置依赖")
    endif()
  endif()
  
  # 多项目打包支持
  if(NOT IS_SINGLE_PROJECT AND ENABLE_DEPLOY)
    # 在多项目模式下，复制到统一的打包目录
    if(DEFINED PACKAGE_BIN_DIR)
      add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
          \"$<TARGET_FILE:${target}>\"
          \"${PACKAGE_BIN_DIR}\"
        COMMENT "复制 ${target} 到统一打包目录"
      )
      message(STATUS "多项目: 已配置复制到统一打包目录: ${PACKAGE_BIN_DIR}")
    endif()
  endif()
  
  # 添加 Qt 相关的构建完成命令提示
  if(ENABLE_DEPLOY)
    # 如果启用了自动打包，在构建完成后显示打包相关命令
    if(WIN32)
      add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E echo "Qt 打包相关命令:"
        COMMAND ${CMAKE_COMMAND} -E echo "  手动打包:     windeployqt $<TARGET_FILE:${target}>"
        COMMAND ${CMAKE_COMMAND} -E echo "  检查依赖:     dumpbin /dependents $<TARGET_FILE:${target}>"
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMENT "显示 Qt 打包相关命令"
      )
    elseif(APPLE)
      add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E echo "Qt 打包相关命令:"
        COMMAND ${CMAKE_COMMAND} -E echo "  手动打包:     macdeployqt ${target}.app"
        COMMAND ${CMAKE_COMMAND} -E echo "  检查依赖:     otool -L $<TARGET_FILE:${target}>"
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMENT "显示 Qt 打包相关命令"
      )
    else()
      add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E echo "Qt 打包相关命令:"
        COMMAND ${CMAKE_COMMAND} -E echo "  手动打包:     linuxdeployqt $<TARGET_FILE:${target}> -bundle-non-qt-libs -appimage"
        COMMAND ${CMAKE_COMMAND} -E echo "  检查依赖:     ldd $<TARGET_FILE:${target}>"
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMENT "显示 Qt 打包相关命令"
      )
    endif()
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 输出目录配置
# ----------------------------------------------------------------------------
# 输出到项目根目录的 bin/ 和 lib/ 目录（而非 cmake/ 子目录）
# CMAKE_SOURCE_DIR 是顶层 CMakeLists.txt 所在目录（项目根目录）
#
# RUNTIME_DIR: 可执行文件（.exe, .dll）的输出目录
# LIBRARY_DIR: 库文件（.lib, .a, .so）的输出目录
set(RUNTIME_DIR ${CMAKE_SOURCE_DIR}/bin)
set(LIBRARY_DIR ${CMAKE_SOURCE_DIR}/lib)

# 替代 /utf-8
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-finput-charset=UTF-8 -fexec-charset=UTF-8)
else()
  add_compile_options(/utf-8)
endif()

# ----------------------------------------------------------------------------
# 环境变量访问示例
# ----------------------------------------------------------------------------
# CMake 提供了多种方式访问环境变量
# 1. 使用 $ENV{变量名} 直接读取环境变量
# 2. 使用 command(ENVIRONMENT) 设置环境变量
# 3. 使用 CMAKE_SYSTEM_PROCESSOR 等特定变量获取系统信息

# 示例：读取 PATH 环境变量
message(STATUS "当前 PATH 环境变量: $ENV{PATH}")

# 示例：检查特定环境变量是否存在
if(DEFINED ENV{MY_CUSTOM_VAR})
  message(STATUS "检测到环境变量 MY_CUSTOM_VAR: $ENV{MY_CUSTOM_VAR}")
else()
  message(STATUS "未检测到环境变量 MY_CUSTOM_VAR")
endif()

# 示例：获取系统信息
message(STATUS "系统处理器: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "操作系统: ${CMAKE_SYSTEM_NAME}")
message(STATUS "架构: ${CMAKE_SIZEOF_VOID_P}")

# 示例：设置临时环境变量
# command(ENVIRONMENT MY_TEMP_VAR "临时变量值")
message(STATUS "临时环境变量: $ENV{MY_TEMP_VAR}")

# ----------------------------------------------------------------------------
# 包含 GTest 配置
# ----------------------------------------------------------------------------
# 引入 gtest.cmake 文件，提供 GTest 自动安装功能
# include(${CMAKE_CURRENT_LIST_DIR}/gtest.cmake)

# ============================================================================
# 工具宏和函数定义
# ============================================================================

# ----------------------------------------------------------------------------
# 宏：获取环境变量并设置默认值
# ----------------------------------------------------------------------------
# 功能：获取指定的环境变量，如果不存在则使用默认值
#
# 参数：
#   var_name: 环境变量名称
#   default_value: 环境变量不存在时的默认值
#   output_var: 存储结果的变量名
#
# 示例：
#   get_env_with_default("MY_COMPILER" "g++" COMPILER)
#   message("编译器: ${COMPILER}")
macro(get_env_with_default var_name default_value output_var)
  if(DEFINED ENV{${var_name}})
    set(${output_var} $ENV{${var_name}})
    message(STATUS "使用环境变量 ${var_name} 的值: ${${output_var}}")
  else()
    set(${output_var} ${default_value})
    message(STATUS "环境变量 ${var_name} 未设置，使用默认值: ${${output_var}}")
  endif()
endmacro()

# ----------------------------------------------------------------------------
# 宏：检查必需的环境变量
# ----------------------------------------------------------------------------
# 功能：检查指定的环境变量是否存在，如果不存在则报错并退出
#
# 参数：
#   var_name: 必需的环境变量名称
macro(check_required_env var_name)
  if(NOT DEFINED ENV{${var_name}})
    message(FATAL_ERROR "必需的环境变量 ${var_name} 未设置")
  endif()
endmacro()

# ----------------------------------------------------------------------------
# 宏：获取源码和头文件
# ----------------------------------------------------------------------------
# 功能：自动收集当前目录下的所有源码文件和头文件
# 详细说明：cmake/README.md
#
# 输出变量：
#   - SRC: 所有 .cpp/.cc/.cxx 等源文件
#   - H_FILE: 当前目录下的所有 .h 头文件
#   - UI_FILE: 当前目录下的所有 .ui 文件
#   - H_FILE_I: include/ 目录下的所有头文件（对外接口）
macro(get_src_include)
  # 收集源文件（.cpp, .cxx, .cc, .c 等）
  aux_source_directory(${CMAKE_CURRENT_LIST_DIR} SRC)

  # 收集头文件（当前目录，内部头文件）
  FILE(GLOB H_FILE ${CMAKE_CURRENT_LIST_DIR}/*.h)

  # 收集 UI 文件（当前目录，Qt UI 文件）
  FILE(GLOB UI_FILE ${CMAKE_CURRENT_LIST_DIR}/*.ui)

  # 收集公开头文件（include/ 目录，对外接口）
  FILE(GLOB H_FILE_I ${CMAKE_CURRENT_LIST_DIR}/include/*.h)
  
  # 显示收集到的文件信息
  list(LENGTH SRC SRC_COUNT)
  list(LENGTH H_FILE H_FILE_COUNT)
  list(LENGTH UI_FILE UI_FILE_COUNT)
  list(LENGTH H_FILE_I H_FILE_I_COUNT)
  
  if(SRC_COUNT GREATER 0 OR H_FILE_COUNT GREATER 0 OR UI_FILE_COUNT GREATER 0 OR H_FILE_I_COUNT GREATER 0)
    message(STATUS "${_COLOR_BLUE}收集文件:${_COLOR_RESET} ${_COLOR_BOLD}源文件=${SRC_COUNT}${_COLOR_RESET}, ${_COLOR_BOLD}头文件=${H_FILE_COUNT}${_COLOR_RESET}, ${_COLOR_BOLD}UI文件=${UI_FILE_COUNT}${_COLOR_RESET}, ${_COLOR_BOLD}公开头文件=${H_FILE_I_COUNT}${_COLOR_RESET}")
  endif()
endmacro()

# ----------------------------------------------------------------------------
# 函数：查找并链接外部库
# ----------------------------------------------------------------------------
# 功能：统一查找和链接外部库，支持多种查找方式
# 详细说明：cmake/README.md
#
# 用法：
#   find_and_link_library(<target> <lib_name> [METHOD <method>] [COMPONENTS <comp1> <comp2> ...] [REQUIRED])
#
# 参数：
#   target: 目标名称（必需）
#   lib_name: 库名称（必需）
#   METHOD: 查找方法（可选）
#     - AUTO: 自动选择（默认，优先 find_package，然后 pkg-config，最后手动）
#     - CMAKE: 使用 find_package（CMake 包）
#     - PKG: 使用 pkg-config（Linux/macOS）
#     - MANUAL: 手动指定路径（需要 LIB_PATH 和 INCLUDE_PATH）
#   COMPONENTS: 库组件列表（可选，用于 find_package）
#   REQUIRED: 如果未找到则报错（可选）
#
# 环境变量支持：
#   ${LIB_NAME}_PATH: 库的安装路径（用于 MANUAL 方法）
#   ${LIB_NAME}_INCLUDE_PATH: 头文件路径（用于 MANUAL 方法）
#
# 示例：
#   find_and_link_library(myapp Boost REQUIRED COMPONENTS system filesystem)
#   find_and_link_library(myapp OpenCV REQUIRED)
#   find_and_link_library(myapp mylib METHOD MANUAL)
function(find_and_link_library target lib_name)
  if(NOT TARGET ${target})
    message(FATAL_ERROR "find_and_link_library: 目标 ${target} 未创建，请先 add_executable/add_library。")
  endif()

  set(options REQUIRED)
  set(oneValueArgs METHOD)
  set(multiValueArgs COMPONENTS)
  cmake_parse_arguments(LIB "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT LIB_METHOD)
    set(LIB_METHOD AUTO)
  endif()

  message(STATUS "${_COLOR_YELLOW}查找库:${_COLOR_RESET} ${_COLOR_BOLD}${lib_name}${_COLOR_RESET} (方法: ${LIB_METHOD})")

  set(LIB_FOUND FALSE)
  string(TOUPPER ${lib_name} LIB_NAME_UPPER)

  # 方法1: find_package (CMake 包)
  if(LIB_METHOD STREQUAL "CMAKE" OR LIB_METHOD STREQUAL "AUTO")
    if(LIB_COMPONENTS)
      find_package(${lib_name} COMPONENTS ${LIB_COMPONENTS} QUIET)
    else()
      find_package(${lib_name} QUIET)
    endif()

    if(${lib_name}_FOUND OR ${LIB_NAME_UPPER}_FOUND)
      set(LIB_FOUND TRUE)
      message(STATUS "${_COLOR_GREEN}  ✓ 使用 find_package 找到 ${lib_name}${_COLOR_RESET}")
      
      # 链接库（优先使用导入目标）
      if(TARGET ${lib_name}::${lib_name})
        target_link_libraries(${target} PRIVATE ${lib_name}::${lib_name})
      elseif(TARGET ${lib_name}::lib${lib_name})
        target_link_libraries(${target} PRIVATE ${lib_name}::lib${lib_name})
      elseif(TARGET ${lib_name})
        target_link_libraries(${target} PRIVATE ${lib_name})
      else()
        # 使用变量方式链接
        if(${lib_name}_LIBRARIES)
          target_link_libraries(${target} PRIVATE ${${lib_name}_LIBRARIES})
          if(${lib_name}_INCLUDE_DIRS)
            target_include_directories(${target} PRIVATE ${${lib_name}_INCLUDE_DIRS})
          endif()
        endif()
      endif()
    endif()
  endif()

  # 方法2: pkg-config (Linux/macOS)
  if((LIB_METHOD STREQUAL "PKG" OR (LIB_METHOD STREQUAL "AUTO" AND NOT LIB_FOUND)) AND NOT WIN32)
    find_package(PkgConfig QUIET)
    if(PKG_CONFIG_FOUND)
      pkg_check_modules(PC_${LIB_NAME_UPPER} QUIET ${lib_name})
      if(PC_${LIB_NAME_UPPER}_FOUND)
        set(LIB_FOUND TRUE)
        message(STATUS "${_COLOR_GREEN}  ✓ 使用 pkg-config 找到 ${lib_name}${_COLOR_RESET}")
        
        target_link_libraries(${target} PRIVATE ${PC_${LIB_NAME_UPPER}_LIBRARIES})
        target_include_directories(${target} PRIVATE ${PC_${LIB_NAME_UPPER}_INCLUDE_DIRS})
        if(PC_${LIB_NAME_UPPER}_LDFLAGS_OTHER)
          target_link_options(${target} PRIVATE ${PC_${LIB_NAME_UPPER}_LDFLAGS_OTHER})
        endif()
        if(PC_${LIB_NAME_UPPER}_CFLAGS_OTHER)
          target_compile_options(${target} PRIVATE ${PC_${LIB_NAME_UPPER}_CFLAGS_OTHER})
        endif()
      endif()
    endif()
  endif()

  # 方法3: 手动指定路径
  if(LIB_METHOD STREQUAL "MANUAL" OR (LIB_METHOD STREQUAL "AUTO" AND NOT LIB_FOUND))
    set(LIB_PATH "")
    set(INCLUDE_PATH "")
    
    # 从环境变量获取路径
    if(DEFINED ENV{${LIB_NAME_UPPER}_PATH})
      set(LIB_PATH "$ENV{${LIB_NAME_UPPER}_PATH}")
      message(STATUS "${_COLOR_GREEN}  ✓ 从环境变量 ${LIB_NAME_UPPER}_PATH 获取路径${_COLOR_RESET}")
    endif()
    
    if(DEFINED ENV{${LIB_NAME_UPPER}_INCLUDE_PATH})
      set(INCLUDE_PATH "$ENV{${LIB_NAME_UPPER}_INCLUDE_PATH}")
    endif()

    # 如果提供了路径，使用 find_library 和 find_path
    if(LIB_PATH)
      # 查找库文件
      if(WIN32)
        find_library(${LIB_NAME_UPPER}_LIB
          NAMES ${lib_name} lib${lib_name}
          PATHS ${LIB_PATH}/lib ${LIB_PATH}/lib64 ${LIB_PATH}
          NO_DEFAULT_PATH
        )
      else()
        find_library(${LIB_NAME_UPPER}_LIB
          NAMES ${lib_name} lib${lib_name}
          PATHS ${LIB_PATH}/lib ${LIB_PATH}/lib64 ${LIB_PATH}
          NO_DEFAULT_PATH
        )
      endif()

      # 查找头文件
      if(INCLUDE_PATH)
        find_path(${LIB_NAME_UPPER}_INCLUDE_DIR
          NAMES ${lib_name}.h ${lib_name}/${lib_name}.h
          PATHS ${INCLUDE_PATH} ${LIB_PATH}/include
          NO_DEFAULT_PATH
        )
      else()
        find_path(${LIB_NAME_UPPER}_INCLUDE_DIR
          NAMES ${lib_name}.h ${lib_name}/${lib_name}.h
          PATHS ${LIB_PATH}/include ${LIB_PATH}
          NO_DEFAULT_PATH
        )
      endif()

      if(${LIB_NAME_UPPER}_LIB)
        set(LIB_FOUND TRUE)
        message(STATUS "${_COLOR_GREEN}  ✓ 手动找到 ${lib_name} 库${_COLOR_RESET}")
        message(STATUS "${_COLOR_WHITE}    库文件: ${${LIB_NAME_UPPER}_LIB}${_COLOR_RESET}")
        
        target_link_libraries(${target} PRIVATE ${${LIB_NAME_UPPER}_LIB})
        
        if(${LIB_NAME_UPPER}_INCLUDE_DIR)
          message(STATUS "${_COLOR_WHITE}    头文件: ${${LIB_NAME_UPPER}_INCLUDE_DIR}${_COLOR_RESET}")
          target_include_directories(${target} PRIVATE ${${LIB_NAME_UPPER}_INCLUDE_DIR})
        endif()
      endif()
    endif()
  endif()

  # 如果未找到且标记为 REQUIRED，报错
  if(NOT LIB_FOUND)
    if(LIB_REQUIRED)
      message(FATAL_ERROR "${_COLOR_RED}未找到必需的库: ${lib_name}${_COLOR_RESET}\n"
        "请检查:\n"
        "  1. 库是否已安装\n"
        "  2. CMAKE_PREFIX_PATH 是否正确设置\n"
        "  3. 环境变量 ${LIB_NAME_UPPER}_PATH 是否设置（用于 MANUAL 方法）\n"
        "  4. pkg-config 是否可用（Linux/macOS）")
    else()
      message(WARNING "${_COLOR_YELLOW}未找到库: ${lib_name}（非必需，继续构建）${_COLOR_RESET}")
    endif()
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 宏：配置 C++ 编译参数
# ----------------------------------------------------------------------------
# 功能：为指定的目标配置统一的编译设置
# 详细说明：cmake/README.md
#
# 配置内容：头文件路径、C++标准(C++17)、编译选项、输出路径等
# 参数：name - 目标名称（通过 add_executable 或 add_library 创建的目标）
macro(set_cpp name)
  # 设置头文件搜索路径（当前目录、include/、上级目录等）
  target_include_directories(${name} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/include/
        ${CMAKE_CURRENT_LIST_DIR}
        ${CMAKE_CURRENT_LIST_DIR}/../include
        ${CMAKE_CURRENT_LIST_DIR}../
    )

  # 配置 C++ 标准版本（C++17）
  target_compile_features(${name} PRIVATE cxx_std_17)

  # Windows MSVC 编译器特殊配置（-bigobj 选项）
  if(MSVC)
    set_target_properties(${name} PROPERTIES COMPILE_FLAGS "-bigobj")
  endif()

  # Linux/Unix 系统链接 pthread 库
  if(NOT WIN32)
    target_link_libraries(${name} pthread)
  endif()

  # 构建类型默认值设置（单配置生成器需要）
  if(CMAKE_BUILD_TYPE STREQUAL "")
    set(CMAKE_BUILD_TYPE Debug)
  endif()

  # 配置输出路径（所有构建类型统一路径：bin/ 和 lib/）
  set(CONF_TYPES Debug Release RelWithDebInfo MinSizeRel "")
  foreach(type IN LISTS CONF_TYPES)
    set(conf "")
    if(type)
      string(TOUPPER _${type} conf)
      message(STATUS "配置 ${type} 构建类型的输出路径: ${conf}")
    endif()
    set_target_properties(${name} PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY${conf} ${RUNTIME_DIR}
            LIBRARY_OUTPUT_DIRECTORY${conf} ${LIBRARY_DIR}
            ARCHIVE_OUTPUT_DIRECTORY${conf} ${LIBRARY_DIR}
            PDB_OUTPUT_DIRECTORY${conf} ${RUNTIME_DIR}
        )
  endforeach()

  # 设置 Debug 版本文件名后缀（'d'）
  set_target_properties(${name} PROPERTIES DEBUG_POSTFIX "d")

  # 配置库文件搜索路径
  target_link_directories(${name} PRIVATE ${LIBRARY_DIR})

  # 获取 Debug 后缀（Windows 用于链接时自动添加后缀）
  set(debug_postfix "")
  if(WIN32)
    get_target_property(debug_postfix ${name} DEBUG_POSTFIX)
  endif()

  # Linux/Unix 系统再次链接 pthread（确保链接）
  if(NOT WIN32)
    target_link_libraries(${name} pthread)
  endif()
endmacro()

# ----------------------------------------------------------------------------
# 宏：配置 GTest（内部辅助宏）
# ----------------------------------------------------------------------------
# 功能：查找和配置 GTest，支持多种查找方式
function(setup_gtest)
  # 如果已经找到，直接返回
  if(GTest_FOUND OR TARGET GTest::gtest OR TARGET GTest::gtest_main)
    return()
  endif()

  message(STATUS "${_COLOR_YELLOW}查找 GTest...${_COLOR_RESET}")

  # 方法1: 使用 find_package（推荐，支持 vcpkg）
  # vcpkg 会自动设置 CMAKE_PREFIX_PATH，所以直接查找即可
  find_package(GTest QUIET)
  
  if(GTest_FOUND)
    message(STATUS "${_COLOR_GREEN}  ✓ 使用 find_package 找到 GTest${_COLOR_RESET}")
    if(TARGET GTest::gtest_main)
      message(STATUS "${_COLOR_WHITE}    使用目标: GTest::gtest_main${_COLOR_RESET}")
    elseif(TARGET GTest::gtest)
      message(STATUS "${_COLOR_WHITE}    使用目标: GTest::gtest${_COLOR_RESET}")
    endif()
    return()
  endif()

  # 方法1.5: 如果设置了 GTEST_PATH 环境变量，添加到搜索路径
  if(DEFINED ENV{GTEST_PATH})
    list(APPEND CMAKE_PREFIX_PATH "$ENV{GTEST_PATH}/lib/cmake")
    message(STATUS "${_COLOR_GREEN}  从环境变量 GTEST_PATH 获取路径: $ENV{GTEST_PATH}${_COLOR_RESET}")
    find_package(GTest QUIET)
    if(GTest_FOUND)
      message(STATUS "${_COLOR_GREEN}  ✓ 使用 find_package 找到 GTest（通过 GTEST_PATH）${_COLOR_RESET}")
      return()
    endif()
  endif()

  # 方法2: 使用 find_and_link_library（如果可用）
  # 注意：这里只是查找，不实际链接
  if(DEFINED ENV{GTEST_PATH})
    set(GTEST_LIB_PATH "$ENV{GTEST_PATH}/lib")
    set(GTEST_INCLUDE_PATH "$ENV{GTEST_PATH}/include")
    
    find_library(GTEST_LIBRARY
      NAMES gtest gtestd
      PATHS ${GTEST_LIB_PATH}
      NO_DEFAULT_PATH
    )
    
    find_path(GTEST_INCLUDE_DIR
      NAMES gtest/gtest.h
      PATHS ${GTEST_INCLUDE_PATH}
      NO_DEFAULT_PATH
    )
    
    if(GTEST_LIBRARY AND GTEST_INCLUDE_DIR)
      message(STATUS "${_COLOR_GREEN}  ✓ 从环境变量找到 GTest${_COLOR_RESET}")
      message(STATUS "${_COLOR_WHITE}    库文件: ${GTEST_LIBRARY}${_COLOR_RESET}")
      message(STATUS "${_COLOR_WHITE}    头文件: ${GTEST_INCLUDE_DIR}${_COLOR_RESET}")
      set(GTEST_FOUND TRUE)
      return()
    endif()
  endif()

  # 如果都找不到，给出提示
  message(WARNING "${_COLOR_YELLOW}未找到 GTest，请：${_COLOR_RESET}")
  message(WARNING "${_COLOR_YELLOW}  1. 安装 GTest 并设置环境变量 GTEST_PATH${_COLOR_RESET}")
  message(WARNING "${_COLOR_YELLOW}  2. 或使用 vcpkg: vcpkg install gtest${_COLOR_RESET}")
  message(WARNING "${_COLOR_YELLOW}  3. 或使用 find_and_link_library 手动查找${_COLOR_RESET}")
endfunction()

# ----------------------------------------------------------------------------
# 函数：构建单元测试程序
# ----------------------------------------------------------------------------
# 功能：创建一个使用 Google Test 框架的单元测试可执行文件
# 详细说明：cmake/README.md
#
# 用法：
#   cpp_test(<name> [LIB_SRC_DIR <dir>])
#
# 参数：
#   name - 测试程序的目标名称（必需）
#   LIB_SRC_DIR - 被测试库的源码目录（可选，默认: ../）
#
# 功能：自动查找配置 GTest、收集测试源码、链接 GTest、集成 CTest
function(cpp_test name)
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}================ 开始配置单元测试: ${name} =================${_COLOR_RESET}")

  # 解析参数
  set(options)
  set(oneValueArgs LIB_SRC_DIR)
  set(multiValueArgs)
  cmake_parse_arguments(TEST "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT TEST_LIB_SRC_DIR)
    set(TEST_LIB_SRC_DIR "${CMAKE_CURRENT_LIST_DIR}/../")
  endif()

  # ------------------------------------------------------------------------
  # 步骤 1: 查找和配置 GTest
  # ------------------------------------------------------------------------
  setup_gtest()
  
  if(NOT GTest_FOUND AND NOT TARGET GTest::gtest AND NOT TARGET GTest::gtest_main)
    message(FATAL_ERROR "${_COLOR_RED}未找到 GTest，无法配置单元测试${_COLOR_RESET}")
  endif()

  # ------------------------------------------------------------------------
  # 步骤 2：收集测试源码和头文件
  # ------------------------------------------------------------------------
  # 获取当前测试目录下的所有源码和头文件
  get_src_include()

  # ------------------------------------------------------------------------
  # 步骤 3：收集被测试库的源码（可选）
  # ------------------------------------------------------------------------
  # 单元测试可能需要访问库的内部实现，所以需要包含库的源码
  # 如果提供了 LIB_SRC_DIR，则收集该目录的源码
  if(TEST_LIB_SRC_DIR AND EXISTS "${TEST_LIB_SRC_DIR}")
    aux_source_directory(${TEST_LIB_SRC_DIR} TEST_SRC)
    if(TEST_SRC)
      list(APPEND SRC ${TEST_SRC})
      message(STATUS "${_COLOR_GREEN}已收集库源码目录: ${TEST_LIB_SRC_DIR}${_COLOR_RESET}")
    endif()
  endif()

  # ------------------------------------------------------------------------
  # 步骤 4：创建测试可执行文件
  # ------------------------------------------------------------------------
  # add_executable 创建一个可执行文件目标
  add_executable(${name} ${SRC})

  # 应用统一的 C++ 编译配置
  set_cpp(${name})

  # ------------------------------------------------------------------------
  # 步骤 5：配置 MSVC 运行时库
  # ------------------------------------------------------------------------
  # MSVC_RUNTIME_LIBRARY 指定使用哪个 C++ 运行时库
  # MultiThreadedDebug 表示使用多线程调试版本的静态运行时库
  # 这样可以避免需要分发 Visual C++ 运行时 DLL
  set_target_properties(${name} PROPERTIES
        MSVC_RUNTIME_LIBRARY MultiThreadedDebug
    )

  # ------------------------------------------------------------------------
  # 步骤 6：链接 GTest 库
  # ------------------------------------------------------------------------
  # 优先使用 CMake 导入的目标（如果 find_package 成功）

  # 优先使用 CMake 导入的目标（如果 find_package 成功）
  if(TARGET GTest::gtest_main)
    # 使用 CMake 导入的目标（推荐方式）
    # GTest::gtest_main 包含了 main 函数，自动运行所有测试
    target_link_libraries(${name} PRIVATE GTest::gtest_main)
    message(STATUS "${_COLOR_GREEN}使用 GTest::gtest_main（CMake 目标）${_COLOR_RESET}")
  elseif(TARGET GTest::gtest)
    # 如果没有 gtest_main，使用 gtest 并手动提供 main
    target_link_libraries(${name} PRIVATE GTest::gtest)
    message(STATUS "${_COLOR_GREEN}使用 GTest::gtest（CMake 目标）${_COLOR_RESET}")
  elseif(GTEST_LIBRARY)
    # 使用手动找到的库
    target_link_libraries(${name} PRIVATE ${GTEST_LIBRARY})
    target_include_directories(${name} PRIVATE ${GTEST_INCLUDE_DIR})
    message(STATUS "${_COLOR_GREEN}使用手动找到的 GTest 库${_COLOR_RESET}")
  else()
    # 尝试使用 find_and_link_library（如果可用）
    find_and_link_library(${name} GTest)
  endif()
  
  # Linux/Unix 需要链接 pthread
  if(NOT WIN32)
    target_link_libraries(${name} PRIVATE pthread)
  endif()

  # ------------------------------------------------------------------------
  # 步骤 9：集成 CTest 和 GTest
  # ------------------------------------------------------------------------
  # include(GoogleTest) 引入 CMake 的 GoogleTest 模块
  # 这个模块提供了 gtest_discover_tests 函数
  include(GoogleTest)

  # gtest_discover_tests 自动扫描可执行文件中的测试用例
  # 并为每个测试用例创建一个 CTest 测试
  # 这样就可以使用 ctest 命令运行所有测试
  gtest_discover_tests(${name})

  # ------------------------------------------------------------------------
  # 步骤 10：启用测试
  # ------------------------------------------------------------------------
  # enable_testing 启用 CTest 测试框架
  # 这是运行 ctest 命令的前提条件
  enable_testing()

  message(STATUS "${_COLOR_GREEN}${_COLOR_BOLD}================ 单元测试配置完成: ${name} =================${_COLOR_RESET}")
endfunction()

# ----------------------------------------------------------------------------
# 函数：构建可执行程序
# ----------------------------------------------------------------------------
# 功能：创建一个可执行文件，并链接指定的库
# 详细说明：cmake/README.md
#
# 参数：name - 可执行文件的目标名称（必需）
#       lib1, lib2, ... - 要链接的库名称（可选，可多个）
# 示例：cpp_execute(my_app xlog xthread_pool)
function(cpp_execute name)
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}================ 开始配置可执行程序: ${name} =================${_COLOR_RESET}")

  # ------------------------------------------------------------------------
  # 步骤 1：收集源码和头文件
  # ------------------------------------------------------------------------
  # 获取当前目录下的所有源码和头文件
  get_src_include()

  # ------------------------------------------------------------------------
  # 步骤 2：创建可执行文件目标
  # ------------------------------------------------------------------------
  # add_executable 创建可执行文件
  # 包含所有源文件和头文件（头文件用于 IDE 显示，不参与编译）
  add_executable(${name} ${SRC} ${H_FILE} ${H_FILE_I} ${UI_FILE})

  # ------------------------------------------------------------------------
  # 步骤 3：应用统一的 C++ 配置
  # ------------------------------------------------------------------------
  set_cpp(${name})

  # ------------------------------------------------------------------------
  # 步骤 4：链接依赖库
  # ------------------------------------------------------------------------
  # ${ARGC} 是函数参数的个数
  # ${ARGV0}, ${ARGV1}, ... 是各个参数的值
  # ${ARGV0} 总是函数名本身（在这个例子中是 name）
  message(STATUS "函数参数个数: ${ARGC}, 第一个参数: ${ARGV0}, 第二个参数: ${ARGV1}")

  # 计算需要链接的库的数量（总参数数 - 1，因为第一个是 name）
  math(EXPR size "${ARGC}-1")

  # 如果有需要链接的库（size > 0）
  if(size GREATER 0)
    # 遍历所有库参数（从第二个参数开始，索引从 1 开始）
    foreach(i RANGE 1 ${size})
      # ${ARGV${i}} 获取第 i 个参数（库名）
      message(STATUS "链接库: ${ARGV${i}}")
      set(lib_name ${ARGV${i}})

      # 链接库，如果是 Windows Debug 版本，自动添加 'd' 后缀
      # 例如：xlog -> xlogd (Debug), xlog (Release)
      target_link_libraries(${name} ${lib_name}${debug_postfix})
    endforeach()
  endif()

  message(STATUS "${_COLOR_GREEN}${_COLOR_BOLD}================ 可执行程序配置完成: ${name} =================${_COLOR_RESET}")
  
  # 添加构建完成后的命令提示（根据平台输出不同命令）
  if(WIN32)
    # Windows 平台命令（使用 chcp 65001 设置 UTF-8 编码避免乱码）
    add_custom_command(TARGET ${name} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "============================================================================"
      COMMAND ${CMAKE_COMMAND} -E echo "Build completed: ${name}"
      COMMAND ${CMAKE_COMMAND} -E echo "============================================================================"
      COMMAND ${CMAKE_COMMAND} -E echo "Executable: $<TARGET_FILE:${name}>"
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "Common commands:"
      COMMAND ${CMAKE_COMMAND} -E echo "  Run:          $<TARGET_FILE:${name}>"
      COMMAND ${CMAKE_COMMAND} -E echo "  Or:           .\\bin\\${name}.exe"
      COMMAND ${CMAKE_COMMAND} -E echo "  Rebuild:      cmake --build ${CMAKE_BINARY_DIR} --target ${name}"
      COMMAND ${CMAKE_COMMAND} -E echo "  Clean:        cmake --build ${CMAKE_BINARY_DIR} --target clean"
      COMMAND ${CMAKE_COMMAND} -E echo "  Install:      cmake --install ${CMAKE_BINARY_DIR}"
      COMMAND ${CMAKE_COMMAND} -E echo "  Package:      cmake --build ${CMAKE_BINARY_DIR} --target package"
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "Generate compile_commands.json (for clangd/IDE):"
      COMMAND ${CMAKE_COMMAND} -E echo "  Note: Visual Studio generator does not support, use Ninja instead"
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMENT "Display build completion info"
    )
  elseif(APPLE)
    # macOS 平台命令
    add_custom_command(TARGET ${name} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "============================================================================"
      COMMAND ${CMAKE_COMMAND} -E echo "构建完成: ${name}"
      COMMAND ${CMAKE_COMMAND} -E echo "============================================================================"
      COMMAND ${CMAKE_COMMAND} -E echo "可执行文件: $<TARGET_FILE:${name}>"
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "常用命令:"
      COMMAND ${CMAKE_COMMAND} -E echo "  运行程序:     $<TARGET_FILE:${name}>"
      COMMAND ${CMAKE_COMMAND} -E echo "  或:           ./bin/${name}"
      COMMAND ${CMAKE_COMMAND} -E echo "  重新构建:     cmake --build ${CMAKE_BINARY_DIR} --target ${name}"
      COMMAND ${CMAKE_COMMAND} -E echo "  清理构建:     cmake --build ${CMAKE_BINARY_DIR} --target clean"
      COMMAND ${CMAKE_COMMAND} -E echo "  安装程序:     cmake --install ${CMAKE_BINARY_DIR}"
      COMMAND ${CMAKE_COMMAND} -E echo "  打包程序:     macdeployqt $<TARGET_BUNDLE_DIR:${name}>"
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "生成 compile_commands.json (用于 clangd/IDE):"
      COMMAND ${CMAKE_COMMAND} -E echo "  方法1 (推荐): cmake --build ${CMAKE_BINARY_DIR} --target gen_compile_commands"
      COMMAND ${CMAKE_COMMAND} -E echo "  方法2:        cmake --build ${CMAKE_BINARY_DIR} --target copy_compile_commands"
      COMMAND ${CMAKE_COMMAND} -E echo "  方法3:        cp ${CMAKE_BINARY_DIR}/compile_commands.json ."
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMENT "显示构建完成信息和常用命令"
    )
  else()
    # Linux 平台命令
    add_custom_command(TARGET ${name} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "============================================================================"
      COMMAND ${CMAKE_COMMAND} -E echo "构建完成: ${name}"
      COMMAND ${CMAKE_COMMAND} -E echo "============================================================================"
      COMMAND ${CMAKE_COMMAND} -E echo "可执行文件: $<TARGET_FILE:${name}>"
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "常用命令:"
      COMMAND ${CMAKE_COMMAND} -E echo "  运行程序:     $<TARGET_FILE:${name}>"
      COMMAND ${CMAKE_COMMAND} -E echo "  或:           ./bin/${name}"
      COMMAND ${CMAKE_COMMAND} -E echo "  重新构建:     cmake --build ${CMAKE_BINARY_DIR} --target ${name}"
      COMMAND ${CMAKE_COMMAND} -E echo "  清理构建:     cmake --build ${CMAKE_BINARY_DIR} --target clean"
      COMMAND ${CMAKE_COMMAND} -E echo "  安装程序:     cmake --install ${CMAKE_BINARY_DIR}"
      COMMAND ${CMAKE_COMMAND} -E echo "  打包程序:     cmake --build ${CMAKE_BINARY_DIR} --target package"
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "生成 compile_commands.json (用于 clangd/IDE):"
      COMMAND ${CMAKE_COMMAND} -E echo "  方法1 (推荐): cmake --build ${CMAKE_BINARY_DIR} --target gen_compile_commands"
      COMMAND ${CMAKE_COMMAND} -E echo "  方法2:        cmake --build ${CMAKE_BINARY_DIR} --target copy_compile_commands"
      COMMAND ${CMAKE_COMMAND} -E echo "  方法3:        cp ${CMAKE_BINARY_DIR}/compile_commands.json ."
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMENT "显示构建完成信息和常用命令"
    )
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 函数：构建库（静态库或动态库）
# ----------------------------------------------------------------------------
# 功能：创建一个静态库或动态库，并配置安装规则
# 详细说明：cmake/README.md
#
# 参数：name - 库的目标名称（必需）
# 选项：${NAME}_SHARED (ON=动态库, OFF=静态库)，可通过 cmake -DXLOG_SHARED=OFF 控制
function(cpp_library name)
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}================ 开始配置库: ${name} =================${_COLOR_RESET}")

  # ------------------------------------------------------------------------
  # 步骤 1：确定库的类型（静态库或动态库）
  # ------------------------------------------------------------------------
  # 将库名转换为大写，用于构建选项变量名
  # 例如：xlog -> XLOG
  string(TOUPPER ${name} NAME)

  # 创建选项变量，允许用户选择库的类型
  # 选项名格式：${NAME}_SHARED（例如：XLOG_SHARED）
  # 默认值为 ON（构建动态库）
  option(${NAME}_SHARED "构建动态库（ON）还是静态库（OFF）" ON)
  message(STATUS "${NAME}_SHARED = ${${NAME}_SHARED}")

  # 根据选项设置库类型
  set(TYPE STATIC)  # 默认为静态库
  if(${NAME}_SHARED)
    set(TYPE SHARED)  # 如果选项为 ON，则使用动态库
  endif()

  # ------------------------------------------------------------------------
  # 步骤 2：收集源码和头文件
  # ------------------------------------------------------------------------
  get_src_include()

  # ------------------------------------------------------------------------
  # 步骤 3：创建库目标
  # ------------------------------------------------------------------------
  # add_library 创建库文件
  # ${TYPE} 可以是 STATIC（静态库）或 SHARED（动态库）
  add_library(${name} ${TYPE} ${SRC} ${H_FILE} ${H_FILE_I})

  # 应用统一的 C++ 配置
  set_cpp(${name})

  # ------------------------------------------------------------------------
  # 步骤 4：配置编译定义（宏定义）
  # ------------------------------------------------------------------------
  # target_compile_definitions 添加预处理器宏定义
  # PUBLIC 表示这些宏定义会传递给使用此库的目标
  #
  # 动态库：定义 ${NAME}_EXPORTS 宏
  #   用于标记哪些符号需要从 DLL 中导出（Windows）
  #   例如：__declspec(dllexport)
  #
  # 静态库：定义 ${NAME}_STATIC 宏
  #   用于在头文件中区分是静态链接还是动态链接
  #   例如：可以改变函数声明方式
  if(${NAME}_SHARED)
    target_compile_definitions(${name} PUBLIC ${NAME}_EXPORTS)
  else()
    target_compile_definitions(${name} PUBLIC ${NAME}_STATIC)
  endif()

  # ------------------------------------------------------------------------
  # 步骤 5：配置安装规则
  # ------------------------------------------------------------------------
  # 安装是将编译好的库和头文件复制到系统目录或指定目录的过程
  # 用户可以通过以下命令安装：
  #   cmake -S . -B build -D CMAKE_INSTALL_PREFIX=./out
  #   cmake --install build --prefix=out

  set(version 1.0)  # 库的版本号

  # 设置公开头文件属性
  # PUBLIC_HEADER 标记哪些头文件是公开的接口
  # 这些头文件会在安装时被复制
  set_target_properties(${name} PROPERTIES
        PUBLIC_HEADER "${H_FILE_I}"
    )

  # install(TARGETS ...) 安装目标（库或可执行文件）
  # EXPORT: 导出目标，用于生成配置文件（支持 find_package）
  # RUNTIME DESTINATION: 可执行文件和 DLL 的安装目录
  # LIBRARY DESTINATION: 共享库的安装目录（.so, .dylib）
  # PUBLIC_HEADER DESTINATION: 公开头文件的安装目录
  install(TARGETS ${name}
        EXPORT ${name}
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        PUBLIC_HEADER DESTINATION include
    )

  # ------------------------------------------------------------------------
  # 步骤 6：生成 CMake 配置文件（支持 find_package）
  # ------------------------------------------------------------------------
  # 为了支持 find_package(${name})，需要生成配置文件
  # 配置文件名称格式：${name}Config.cmake
  # 例如：xlogConfig.cmake
  #
  # 注意：原代码中有拼写错误 instaLl，应该是 install
  install(EXPORT ${name}
        FILE ${name}Config.cmake
        DESTINATION lib/config/${name}-${version}
    )

  # ------------------------------------------------------------------------
  # 步骤 7：生成版本配置文件
  # ------------------------------------------------------------------------
  # 版本配置文件用于 find_package 时检查版本兼容性
  # 文件名格式：${name}ConfigVersion.cmake
  #
  # 设置版本文件的路径（源码目录）
  set(CONF_VER_FILE
        ${CMAKE_CURRENT_LIST_DIR}/../lib/conf/${name}-${version}/${name}ConfigVersion.cmake
    )

  message(STATUS "版本配置文件路径: ${CONF_VER_FILE}")

  # 引入 CMakePackageConfigHelpers 模块
  # 这个模块提供了 write_basic_package_version_file 函数
  include(CMakePackageConfigHelpers)

  # 生成版本配置文件
  # VERSION: 库的版本号
  # COMPATIBILITY: 版本兼容策略
  #   SameMajorVersion: 只有主版本号相同才兼容（例如：1.x 兼容，2.x 不兼容）
  write_basic_package_version_file(
        ${CONF_VER_FILE}
        VERSION ${version}
        COMPATIBILITY SameMajorVersion
    )

  # 安装版本配置文件
  install(FILES ${CONF_VER_FILE}
        DESTINATION lib/config/${name}-${version}
    )

  message(STATUS "${_COLOR_GREEN}${_COLOR_BOLD}================ 库配置完成: ${name} =================${_COLOR_RESET}")
  
  # 添加构建完成后的命令提示（根据平台输出不同命令）
  if(WIN32)
    # Windows 平台命令（使用 chcp 65001 设置 UTF-8 编码避免乱码）
    add_custom_command(TARGET ${name} POST_BUILD
      COMMAND cmd /c "chcp 65001 >nul && echo."
      COMMAND cmd /c "chcp 65001 >nul && echo ============================================================================"
      COMMAND cmd /c "chcp 65001 >nul && echo 构建完成: ${name} (${TYPE})"
      COMMAND cmd /c "chcp 65001 >nul && echo ============================================================================"
      COMMAND cmd /c "chcp 65001 >nul && echo 库文件位置: $<TARGET_FILE:${name}>"
      COMMAND cmd /c "if \"${${NAME}_SHARED}\"==\"ON\" (chcp 65001 >nul && echo 库类型: 动态库 (.dll)) else (chcp 65001 >nul && echo 库类型: 静态库 (.lib))"
      COMMAND cmd /c "chcp 65001 >nul && echo."
      COMMAND cmd /c "chcp 65001 >nul && echo 常用命令:"
      COMMAND cmd /c "chcp 65001 >nul && echo   重新构建:     cmake --build ${CMAKE_BINARY_DIR} --target ${name}"
      COMMAND cmd /c "chcp 65001 >nul && echo   清理构建:     cmake --build ${CMAKE_BINARY_DIR} --target clean"
      COMMAND cmd /c "chcp 65001 >nul && echo   安装库:       cmake --install ${CMAKE_BINARY_DIR}"
      COMMAND cmd /c "chcp 65001 >nul && echo   切换类型:     cmake -S . -B ${CMAKE_BINARY_DIR} -D${NAME}_SHARED=OFF"
      COMMAND cmd /c "chcp 65001 >nul && echo   生成文档:     cmake --build ${CMAKE_BINARY_DIR} --target docs"
      COMMAND cmd /c "chcp 65001 >nul && echo."
      COMMAND cmd /c "chcp 65001 >nul && echo 生成 compile_commands.json (用于 clangd/IDE):"
      COMMAND cmd /c "chcp 65001 >nul && echo   方法1 (推荐): cmake --build ${CMAKE_BINARY_DIR} --target gen_compile_commands"
      COMMAND cmd /c "chcp 65001 >nul && echo   方法2:        cmake --build ${CMAKE_BINARY_DIR} --target copy_compile_commands"
      COMMAND cmd /c "chcp 65001 >nul && echo   方法3:        copy ${CMAKE_BINARY_DIR}\\compile_commands.json ."
      COMMAND cmd /c "chcp 65001 >nul && echo   注意:         Visual Studio 生成器不支持，需使用 Ninja 生成器"
      COMMAND cmd /c "chcp 65001 >nul && echo."
      COMMENT "显示库构建完成信息和常用命令"
    )
  elseif(APPLE)
    # macOS 平台命令
    add_custom_command(TARGET ${name} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "============================================================================"
      COMMAND ${CMAKE_COMMAND} -E echo "构建完成: ${name} (${TYPE})"
      COMMAND ${CMAKE_COMMAND} -E echo "============================================================================"
      COMMAND ${CMAKE_COMMAND} -E echo "库文件位置: $<TARGET_FILE:${name}>"
      if(${NAME}_SHARED)
        COMMAND ${CMAKE_COMMAND} -E echo "库类型: 动态库 (.dylib)"
      else()
        COMMAND ${CMAKE_COMMAND} -E echo "库类型: 静态库 (.a)"
      endif()
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "常用命令:"
      COMMAND ${CMAKE_COMMAND} -E echo "  重新构建:     cmake --build ${CMAKE_BINARY_DIR} --target ${name}"
      COMMAND ${CMAKE_COMMAND} -E echo "  清理构建:     cmake --build ${CMAKE_BINARY_DIR} --target clean"
      COMMAND ${CMAKE_COMMAND} -E echo "  安装库:       cmake --install ${CMAKE_BINARY_DIR}"
      COMMAND ${CMAKE_COMMAND} -E echo "  切换类型:     cmake -S . -B ${CMAKE_BINARY_DIR} -D${NAME}_SHARED=OFF"
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "生成 compile_commands.json (用于 clangd/IDE):"
      COMMAND ${CMAKE_COMMAND} -E echo "  方法1 (推荐): cmake --build ${CMAKE_BINARY_DIR} --target gen_compile_commands"
      COMMAND ${CMAKE_COMMAND} -E echo "  方法2:        cmake --build ${CMAKE_BINARY_DIR} --target copy_compile_commands"
      COMMAND ${CMAKE_COMMAND} -E echo "  方法3:        cp ${CMAKE_BINARY_DIR}/compile_commands.json ."
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMENT "显示库构建完成信息和常用命令"
    )
  else()
    # Linux 平台命令
    add_custom_command(TARGET ${name} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "============================================================================"
      COMMAND ${CMAKE_COMMAND} -E echo "构建完成: ${name} (${TYPE})"
      COMMAND ${CMAKE_COMMAND} -E echo "============================================================================"
      COMMAND ${CMAKE_COMMAND} -E echo "库文件位置: $<TARGET_FILE:${name}>"
      if(${NAME}_SHARED)
        COMMAND ${CMAKE_COMMAND} -E echo "库类型: 动态库 (.so)"
      else()
        COMMAND ${CMAKE_COMMAND} -E echo "库类型: 静态库 (.a)"
      endif()
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "常用命令:"
      COMMAND ${CMAKE_COMMAND} -E echo "  重新构建:     cmake --build ${CMAKE_BINARY_DIR} --target ${name}"
      COMMAND ${CMAKE_COMMAND} -E echo "  清理构建:     cmake --build ${CMAKE_BINARY_DIR} --target clean"
      COMMAND ${CMAKE_COMMAND} -E echo "  安装库:       cmake --install ${CMAKE_BINARY_DIR}"
      COMMAND ${CMAKE_COMMAND} -E echo "  切换类型:     cmake -S . -B ${CMAKE_BINARY_DIR} -D${NAME}_SHARED=OFF"
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMAND ${CMAKE_COMMAND} -E echo "生成 compile_commands.json (用于 clangd/IDE):"
      COMMAND ${CMAKE_COMMAND} -E echo "  方法1 (推荐): cmake --build ${CMAKE_BINARY_DIR} --target gen_compile_commands"
      COMMAND ${CMAKE_COMMAND} -E echo "  方法2:        cmake --build ${CMAKE_BINARY_DIR} --target copy_compile_commands"
      COMMAND ${CMAKE_COMMAND} -E echo "  方法3:        cp ${CMAKE_BINARY_DIR}/compile_commands.json ."
      COMMAND ${CMAKE_COMMAND} -E echo ""
      COMMENT "显示库构建完成信息和常用命令"
    )
  endif()
endfunction()

# ============================================================================
# CPack 打包配置函数
# ============================================================================

# ----------------------------------------------------------------------------
# 函数：配置 CPack 打包
# ----------------------------------------------------------------------------
# 功能：为项目配置 CPack，支持生成各平台的安装包
# 详细说明：cmake/README.md
#
# 用法：
#   setup_cpack(
#     [VENDOR <vendor_name>]
#     [DESCRIPTION <description>]
#     [LICENSE_FILE <license_file_path>]
#     [README_FILE <readme_file_path>]
#     [ICON <icon_file_path>]
#     [CONTACT <contact_info>]
#   )
#
# 参数：
#   VENDOR: 供应商名称（默认: ${PROJECT_NAME}）
#   DESCRIPTION: 项目描述（默认: ${PROJECT_NAME} Application）
#   LICENSE_FILE: 许可证文件路径
#   README_FILE: README 文件路径
#   ICON: 应用图标文件路径（Windows: .ico, macOS: .icns）
#   CONTACT: 联系信息（邮箱等）
#
# 生成的安装包类型：
#   Windows: NSIS (安装程序) 或 ZIP (压缩包)
#   macOS: DragNDrop (.dmg) 或 Bundle
#   Linux: DEB, RPM, TGZ
#
# 使用方法：
#   cmake --build build --target package
function(setup_cpack)
  set(options)
  set(oneValueArgs VENDOR DESCRIPTION LICENSE_FILE README_FILE ICON CONTACT)
  set(multiValueArgs)
  cmake_parse_arguments(CPACK_ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  message(STATUS "")
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}============================================================================${_COLOR_RESET}")
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}配置 CPack 打包${_COLOR_RESET}")
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}============================================================================${_COLOR_RESET}")
  
  # 设置基本信息
  set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
  set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
  set(CPACK_PACKAGE_VENDOR ${CPACK_ARG_VENDOR})
  if(NOT CPACK_PACKAGE_VENDOR)
    set(CPACK_PACKAGE_VENDOR ${PROJECT_NAME})
  endif()
  
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${CPACK_ARG_DESCRIPTION})
  if(NOT CPACK_PACKAGE_DESCRIPTION_SUMMARY)
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_NAME} Application")
  endif()
  
  set(CPACK_PACKAGE_CONTACT ${CPACK_ARG_CONTACT})
  if(NOT CPACK_PACKAGE_CONTACT)
    set(CPACK_PACKAGE_CONTACT "support@${PROJECT_NAME}.com")
  endif()
  
  # 安装目录
  set(CPACK_PACKAGE_INSTALL_DIRECTORY ${PROJECT_NAME})
  
  # 资源文件
  if(CPACK_ARG_LICENSE_FILE AND EXISTS ${CPACK_ARG_LICENSE_FILE})
    set(CPACK_RESOURCE_FILE_LICENSE ${CPACK_ARG_LICENSE_FILE})
    message(STATUS "${_COLOR_GREEN}许可证文件:${_COLOR_RESET} ${CPACK_ARG_LICENSE_FILE}")
  endif()
  
  if(CPACK_ARG_README_FILE AND EXISTS ${CPACK_ARG_README_FILE})
    set(CPACK_RESOURCE_FILE_README ${CPACK_ARG_README_FILE})
    message(STATUS "${_COLOR_GREEN}README 文件:${_COLOR_RESET} ${CPACK_ARG_README_FILE}")
  endif()
  
  # 平台特定配置
  if(WIN32)
    # Windows 平台：NSIS 安装程序或 ZIP 压缩包
    set(CPACK_GENERATOR "NSIS;ZIP")
    
    # NSIS 配置
    set(CPACK_NSIS_DISPLAY_NAME ${PROJECT_NAME})
    set(CPACK_NSIS_PACKAGE_NAME ${PROJECT_NAME})
    set(CPACK_NSIS_HELP_LINK "https://www.${PROJECT_NAME}.com")
    set(CPACK_NSIS_URL_INFO_ABOUT "https://www.${PROJECT_NAME}.com")
    set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT})
    set(CPACK_NSIS_MODIFY_PATH ON)
    set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
    
    # 图标设置
    if(CPACK_ARG_ICON AND EXISTS ${CPACK_ARG_ICON})
      set(CPACK_NSIS_MUI_ICON ${CPACK_ARG_ICON})
      set(CPACK_NSIS_MUI_UNIICON ${CPACK_ARG_ICON})
      message(STATUS "${_COLOR_GREEN}安装图标:${_COLOR_RESET} ${CPACK_ARG_ICON}")
    endif()
    
    # 开始菜单快捷方式
    set(CPACK_NSIS_MENU_LINKS
      "bin/${PROJECT_NAME}.exe" "${PROJECT_NAME}"
    )
    
    message(STATUS "${_COLOR_MAGENTA}Windows 打包类型:${_COLOR_RESET} NSIS 安装程序, ZIP 压缩包")
    
  elseif(APPLE)
    # macOS 平台：DMG 或 Bundle
    set(CPACK_GENERATOR "DragNDrop;TGZ")
    
    # DMG 配置
    set(CPACK_DMG_VOLUME_NAME ${PROJECT_NAME})
    set(CPACK_DMG_FORMAT "UDBZ")
    
    if(CPACK_ARG_ICON AND EXISTS ${CPACK_ARG_ICON})
      set(CPACK_DMG_DS_STORE_SETUP_SCRIPT ${CPACK_ARG_ICON})
      message(STATUS "${_COLOR_GREEN}DMG 图标:${_COLOR_RESET} ${CPACK_ARG_ICON}")
    endif()
    
    message(STATUS "${_COLOR_MAGENTA}macOS 打包类型:${_COLOR_RESET} DMG, TGZ")
    
  else()
    # Linux 平台：DEB, RPM, TGZ
    set(CPACK_GENERATOR "DEB;RPM;TGZ")
    
    # DEB 配置
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER ${CPACK_PACKAGE_CONTACT})
    set(CPACK_DEBIAN_PACKAGE_SECTION "utils")
    set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6, libstdc++6")
    
    # RPM 配置
    set(CPACK_RPM_PACKAGE_LICENSE "Proprietary")
    set(CPACK_RPM_PACKAGE_GROUP "Applications/System")
    set(CPACK_RPM_PACKAGE_REQUIRES "glibc, libstdc++")
    
    message(STATUS "${_COLOR_MAGENTA}Linux 打包类型:${_COLOR_RESET} DEB, RPM, TGZ")
  endif()
  
  # 包含 CPack 模块
  include(CPack)
  
  message(STATUS "${_COLOR_GREEN}CPack 配置完成${_COLOR_RESET}")
  message(STATUS "${_COLOR_CYAN}打包命令:${_COLOR_RESET} cmake --build ${CMAKE_BINARY_DIR} --target package")
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}============================================================================${_COLOR_RESET}")
  message(STATUS "")
endfunction()

# ----------------------------------------------------------------------------
# 函数：配置多项目统一打包
# ----------------------------------------------------------------------------
# 功能：为多项目场景配置统一的打包目标
# 详细说明：cmake/README.md
#
# 用法：
#   setup_multi_project_package(
#     [PROJECTS <project1> <project2> ...]
#     [OUTPUT_DIR <output_directory>]
#   )
#
# 参数：
#   PROJECTS: 需要打包的项目列表
#   OUTPUT_DIR: 输出目录（默认: ${CMAKE_BINARY_DIR}/package）
#
# 功能：
#   - 创建统一的打包目录结构
#   - 复制所有项目的可执行文件和库到统一目录
#   - 生成统一的依赖配置
#   - 支持一键打包所有项目
function(setup_multi_project_package)
  set(options)
  set(oneValueArgs OUTPUT_DIR)
  set(multiValueArgs PROJECTS)
  cmake_parse_arguments(MPP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  if(NOT MPP_OUTPUT_DIR)
    set(MPP_OUTPUT_DIR "${CMAKE_BINARY_DIR}/package")
  endif()
  
  message(STATUS "")
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}============================================================================${_COLOR_RESET}")
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}配置多项目统一打包${_COLOR_RESET}")
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}============================================================================${_COLOR_RESET}")
  
  # 创建打包目录结构
  set(PACKAGE_ROOT_DIR "${MPP_OUTPUT_DIR}" CACHE PATH "多项目打包根目录" FORCE)
  set(PACKAGE_BIN_DIR "${PACKAGE_ROOT_DIR}/bin" CACHE PATH "多项目打包可执行文件目录" FORCE)
  set(PACKAGE_LIB_DIR "${PACKAGE_ROOT_DIR}/lib" CACHE PATH "多项目打包库文件目录" FORCE)
  set(PACKAGE_PLUGIN_DIR "${PACKAGE_ROOT_DIR}/plugins" CACHE PATH "多项目打包插件目录" FORCE)
  set(PACKAGE_DOC_DIR "${PACKAGE_ROOT_DIR}/docs" CACHE PATH "多项目打包文档目录" FORCE)
  
  message(STATUS "${_COLOR_GREEN}打包根目录:${_COLOR_RESET} ${PACKAGE_ROOT_DIR}")
  message(STATUS "${_COLOR_GREEN}可执行文件目录:${_COLOR_RESET} ${PACKAGE_BIN_DIR}")
  message(STATUS "${_COLOR_GREEN}库文件目录:${_COLOR_RESET} ${PACKAGE_LIB_DIR}")
  
  # 如果指定了项目列表，创建统一打包目标
  if(MPP_PROJECTS)
    message(STATUS "${_COLOR_MAGENTA}包含项目:${_COLOR_RESET} ${MPP_PROJECTS}")
    
    # 创建统一打包目标
    add_custom_target(package_all
      COMMAND ${CMAKE_COMMAND} -E echo "正在打包所有项目..."
      COMMENT "统一打包所有项目"
    )
    
    # 为每个项目添加依赖
    foreach(proj IN LISTS MPP_PROJECTS)
      if(TARGET ${proj})
        add_dependencies(package_all ${proj})
        
        # 添加复制命令
        add_custom_command(TARGET package_all POST_BUILD
          COMMAND ${CMAKE_COMMAND} -E copy_if_different
            \"$<TARGET_FILE:${proj}>\"
            \"${PACKAGE_BIN_DIR}\"
          COMMENT "复制 ${proj} 到打包目录"
        )
      else()
        message(WARNING "${_COLOR_YELLOW}项目 ${proj} 不存在，跳过${_COLOR_RESET}")
      endif()
    endforeach()
    
    message(STATUS "${_COLOR_GREEN}已创建统一打包目标:${_COLOR_RESET} package_all")
    message(STATUS "${_COLOR_CYAN}打包命令:${_COLOR_RESET} cmake --build ${CMAKE_BINARY_DIR} --target package_all")
  endif()
  
  message(STATUS "${_COLOR_CYAN}${_COLOR_BOLD}============================================================================${_COLOR_RESET}")
  message(STATUS "")
endfunction()