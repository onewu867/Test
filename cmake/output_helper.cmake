# ============================================================================
# CMake 跨平台输出助手
# ============================================================================
# 此模块提供跨平台的彩色输出功能，自动处理 Windows 编码问题
# 
# 使用方法：
#   include(${CMAKE_CURRENT_LIST_DIR}/output_helper.cmake)
#   print_info("这是一条信息")
#   print_success("操作成功")
#   print_warning("这是警告")
#   print_error("发生错误")
#   print_header("标题")
#   print_separator()

# ----------------------------------------------------------------------------
# 彩色代码定义（ANSI 转义序列）
# ----------------------------------------------------------------------------
if(NOT WIN32)
  string(ASCII 27 ESC)
  set(COLOR_RESET "${ESC}[0m")
  set(COLOR_BOLD "${ESC}[1m")
  set(COLOR_RED "${ESC}[31m")
  set(COLOR_GREEN "${ESC}[32m")
  set(COLOR_YELLOW "${ESC}[33m")
  set(COLOR_BLUE "${ESC}[34m")
  set(COLOR_MAGENTA "${ESC}[35m")
  set(COLOR_CYAN "${ESC}[36m")
  set(COLOR_WHITE "${ESC}[37m")
else()
  # Windows 下不使用 ANSI 颜色代码（避免乱码）
  set(COLOR_RESET "")
  set(COLOR_BOLD "")
  set(COLOR_RED "")
  set(COLOR_GREEN "")
  set(COLOR_YELLOW "")
  set(COLOR_BLUE "")
  set(COLOR_MAGENTA "")
  set(COLOR_CYAN "")
  set(COLOR_WHITE "")
endif()

# ----------------------------------------------------------------------------
# 核心函数：安全输出（自动处理编码）
# ----------------------------------------------------------------------------
function(_safe_message level text)
  if(WIN32)
    # Windows 平台：使用 execute_process 执行 chcp 65001 后输出
    # 这样可以确保 UTF-8 编码正确显示
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E echo "${text}"
      ENCODING UTF-8
    )
  else()
    # 非 Windows 平台：直接使用 message
    message(${level} "${text}")
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 公共函数：普通信息
# ----------------------------------------------------------------------------
function(print_info)
  set(msg "${ARGN}")
  if(WIN32)
    _safe_message(STATUS "[信息] ${msg}")
  else()
    _safe_message(STATUS "${COLOR_WHITE}${msg}${COLOR_RESET}")
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 公共函数：成功信息
# ----------------------------------------------------------------------------
function(print_success)
  set(msg "${ARGN}")
  if(WIN32)
    _safe_message(STATUS "[成功] ${msg}")
  else()
    _safe_message(STATUS "${COLOR_GREEN}✓ ${msg}${COLOR_RESET}")
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 公共函数：警告信息
# ----------------------------------------------------------------------------
function(print_warning)
  set(msg "${ARGN}")
  if(WIN32)
    _safe_message(STATUS "[警告] ${msg}")
  else()
    _safe_message(STATUS "${COLOR_YELLOW}⚠ ${msg}${COLOR_RESET}")
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 公共函数：错误信息
# ----------------------------------------------------------------------------
function(print_error)
  set(msg "${ARGN}")
  if(WIN32)
    _safe_message(STATUS "[错误] ${msg}")
  else()
    _safe_message(STATUS "${COLOR_RED}✗ ${msg}${COLOR_RESET}")
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 公共函数：标题/头部
# ----------------------------------------------------------------------------
function(print_header)
  set(msg "${ARGN}")
  if(WIN32)
    _safe_message(STATUS "")
    _safe_message(STATUS "========================================")
    _safe_message(STATUS "${msg}")
    _safe_message(STATUS "========================================")
  else()
    _safe_message(STATUS "")
    _safe_message(STATUS "${COLOR_CYAN}${COLOR_BOLD}========================================${COLOR_RESET}")
    _safe_message(STATUS "${COLOR_CYAN}${COLOR_BOLD}${msg}${COLOR_RESET}")
    _safe_message(STATUS "${COLOR_CYAN}${COLOR_BOLD}========================================${COLOR_RESET}")
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 公共函数：子标题
# ----------------------------------------------------------------------------
function(print_subheader)
  set(msg "${ARGN}")
  if(WIN32)
    _safe_message(STATUS "")
    _safe_message(STATUS "--- ${msg} ---")
  else()
    _safe_message(STATUS "")
    _safe_message(STATUS "${COLOR_CYAN}--- ${msg} ---${COLOR_RESET}")
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 公共函数：分隔线
# ----------------------------------------------------------------------------
function(print_separator)
  _safe_message(STATUS "----------------------------------------")
endfunction()

# ----------------------------------------------------------------------------
# 公共函数：键值对输出
# ----------------------------------------------------------------------------
function(print_key_value key value)
  if(WIN32)
    _safe_message(STATUS "  ${key}: ${value}")
  else()
    _safe_message(STATUS "  ${COLOR_YELLOW}${key}:${COLOR_RESET} ${value}")
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 公共函数：列表项
# ----------------------------------------------------------------------------
function(print_list_item)
  set(msg "${ARGN}")
  if(WIN32)
    _safe_message(STATUS "  * ${msg}")
  else()
    _safe_message(STATUS "  ${COLOR_WHITE}• ${msg}${COLOR_RESET}")
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 公共函数：库查找结果（统一格式）
# ----------------------------------------------------------------------------
function(print_library_found lib_name version)
  if(WIN32)
    _safe_message(STATUS "[成功] 找到 ${lib_name} ${version}")
  else()
    _safe_message(STATUS "${COLOR_GREEN}✓ 找到 ${lib_name} ${version}${COLOR_RESET}")
  endif()
endfunction()

function(print_library_not_found lib_name)
  if(WIN32)
    _safe_message(STATUS "[警告] 未找到: ${lib_name}")
  else()
    _safe_message(STATUS "${COLOR_YELLOW}- 未找到: ${lib_name}${COLOR_RESET}")
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 公共函数：路径信息（特殊处理，始终显示完整路径）
# ----------------------------------------------------------------------------
function(print_path key path)
  if(WIN32)
    _safe_message(STATUS "    ${key}: ${path}")
  else()
    _safe_message(STATUS "    ${COLOR_WHITE}${key}:${COLOR_RESET} ${path}")
  endif()
endfunction()

# ----------------------------------------------------------------------------
# 示例用法（可删除）
# ----------------------------------------------------------------------------
function(print_output_helper_demo)
  print_header("Output Helper Demo")
  print_info("This is an info message")
  print_success("Operation completed successfully")
  print_warning("This is a warning")
  print_error("This is an error")
  print_subheader("Key-Value Pairs")
  print_key_value("Version" "1.0.0")
  print_key_value("Platform" "${CMAKE_SYSTEM_NAME}")
  print_path("Install Path" "${CMAKE_INSTALL_PREFIX}")
  print_subheader("List Items")
  print_list_item("First item")
  print_list_item("Second item")
  print_separator()
  print_library_found("OpenCV" "4.11.0")
  print_library_not_found("SomeLib")
endfunction()

# 使用提示
message(STATUS "Output helper loaded. Use print_* functions for clean output.")
