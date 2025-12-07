# CMake 配置脚本 - 支持中文输出
# 使用方法: .\configure.ps1 [生成器] [构建类型]
# 示例: .\configure.ps1 Ninja Release
#      .\configure.ps1 "Visual Studio 15 2017" Debug

param(
    [string]$Generator = "Ninja",
    [string]$BuildType = "Release",
    [string]$BuildDir = "build"
)

# 设置 UTF-8 编码以正确显示中文
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"
chcp 65001 > $null

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CMake 配置脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "生成器: $Generator" -ForegroundColor Yellow
Write-Host "构建类型: $BuildType" -ForegroundColor Yellow
Write-Host "构建目录: $BuildDir" -ForegroundColor Yellow
Write-Host ""

# 检查 vcpkg 工具链
$VcpkgToolchain = ""
if ($env:VCPKG_ROOT) {
    $VcpkgToolchain = "$env:VCPKG_ROOT\scripts\buildsystems\vcpkg.cmake"
    if (Test-Path $VcpkgToolchain) {
        Write-Host "[成功] 找到 vcpkg 工具链" -ForegroundColor Green
        Write-Host "  路径: $VcpkgToolchain" -ForegroundColor Gray
    }
} elseif (Test-Path "C:\Users\jinxi\vcpkg\scripts\buildsystems\vcpkg.cmake") {
    $VcpkgToolchain = "C:\Users\jinxi\vcpkg\scripts\buildsystems\vcpkg.cmake"
    Write-Host "[成功] 找到 vcpkg 工具链（默认路径）" -ForegroundColor Green
    Write-Host "  路径: $VcpkgToolchain" -ForegroundColor Gray
} else {
    Write-Host "[警告] 未找到 vcpkg 工具链" -ForegroundColor Yellow
    Write-Host "  某些外部库可能无法自动找到" -ForegroundColor Gray
}

Write-Host ""
Write-Host "开始配置..." -ForegroundColor Cyan
Write-Host ""

# 删除旧的构建目录
if (Test-Path $BuildDir) {
    Write-Host "[信息] 删除旧的构建目录..." -ForegroundColor Gray
    Remove-Item -Recurse -Force $BuildDir -ErrorAction SilentlyContinue
}

# 创建构建目录
New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null

# 构建 CMake 命令
$CmakeArgs = @(
    "-S", ".",
    "-B", $BuildDir,
    "-G", $Generator
)

if ($BuildType) {
    $CmakeArgs += "-DCMAKE_BUILD_TYPE=$BuildType"
}

if ($VcpkgToolchain) {
    $CmakeArgs += "-DCMAKE_TOOLCHAIN_FILE=$VcpkgToolchain"
}

# 执行 CMake
Write-Host "执行命令: cmake $($CmakeArgs -join ' ')" -ForegroundColor Gray
Write-Host ""

& cmake @CmakeArgs

# 检查结果
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "配置成功！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步操作:" -ForegroundColor Cyan
    Write-Host "  1. 构建项目:  cmake --build $BuildDir --config $BuildType" -ForegroundColor White
    Write-Host "  2. 运行程序:  .\bin\TestApp.exe" -ForegroundColor White
    Write-Host "  3. 运行测试:  cd $BuildDir; ctest -C $BuildType" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "配置失败！" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "请检查上面的错误信息" -ForegroundColor Yellow
    exit 1
}
