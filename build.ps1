# 构建脚本 - 支持中文输出
# 使用方法: .\build.ps1 [构建类型] [目标]
# 示例: .\build.ps1 Release
#      .\build.ps1 Debug TestApp
#      .\build.ps1 Release mylib_test

param(
    [string]$BuildType = "Release",
    [string]$Target = "",
    [string]$BuildDir = "build"
)

# 设置 UTF-8 编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"
chcp 65001 > $null

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CMake 构建脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查构建目录
if (-not (Test-Path $BuildDir)) {
    Write-Host "[错误] 构建目录不存在: $BuildDir" -ForegroundColor Red
    Write-Host "  请先运行: .\configure.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "构建类型: $BuildType" -ForegroundColor Yellow
if ($Target) {
    Write-Host "构建目标: $Target" -ForegroundColor Yellow
} else {
    Write-Host "构建目标: 所有" -ForegroundColor Yellow
}
Write-Host ""

# 构建 CMake 命令
$CmakeArgs = @(
    "--build", $BuildDir,
    "--config", $BuildType
)

if ($Target) {
    $CmakeArgs += "--target", $Target
}

# 显示命令
Write-Host "执行命令: cmake $($CmakeArgs -join ' ')" -ForegroundColor Gray
Write-Host ""

# 执行构建
& cmake @CmakeArgs

# 检查结果
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "构建成功！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    # 查找可执行文件
    $ExeFiles = Get-ChildItem -Path "bin","$BuildDir" -Filter "*.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 5
    if ($ExeFiles) {
        Write-Host "生成的可执行文件:" -ForegroundColor Cyan
        foreach ($exe in $ExeFiles) {
            Write-Host "  $($exe.FullName)" -ForegroundColor White
        }
        Write-Host ""
    }
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "构建失败！" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    exit 1
}
