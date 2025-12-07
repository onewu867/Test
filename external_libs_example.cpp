// 外部库使用示例
// 此文件展示如何在项目中使用 OpenCV、Boost 和 HALCON

#include <iostream>

// ============================================================================
// 示例1: OpenCV - 图像处理
// ============================================================================
#ifdef USE_OPENCV
#include <opencv2/opencv.hpp>

void opencvExample() {
    std::cout << "OpenCV Example\n";
    std::cout << "OpenCV Version: " << CV_VERSION << "\n";
    
    // 创建一个空白图像
    cv::Mat image(480, 640, CV_8UC3, cv::Scalar(255, 255, 255));
    
    // 绘制矩形
    cv::rectangle(image, cv::Point(100, 100), cv::Point(300, 300), 
                  cv::Scalar(0, 0, 255), 2);
    
    // 添加文字
    cv::putText(image, "Hello OpenCV!", cv::Point(150, 200),
                cv::FONT_HERSHEY_SIMPLEX, 1.0, cv::Scalar(0, 0, 0), 2);
    
    // 保存图像
    cv::imwrite("opencv_example.jpg", image);
    std::cout << "Image saved to opencv_example.jpg\n";
    
    // 图像处理示例
    cv::Mat gray;
    cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
    
    cv::Mat blurred;
    cv::GaussianBlur(gray, blurred, cv::Size(5, 5), 0);
    
    cv::Mat edges;
    cv::Canny(blurred, edges, 50, 150);
    
    cv::imwrite("opencv_edges.jpg", edges);
    std::cout << "Edge detection result saved to opencv_edges.jpg\n";
}
#endif

// ============================================================================
// 示例2: Boost - 文件系统操作
// ============================================================================
#ifdef USE_BOOST
#include <boost/filesystem.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <iostream>

namespace fs = boost::filesystem;

void boostFilesystemExample() {
    std::cout << "\nBoost Filesystem Example\n";
    
    // 获取当前路径
    fs::path currentPath = fs::current_path();
    std::cout << "Current path: " << currentPath << "\n";
    
    // 遍历当前目录
    std::cout << "Files in current directory:\n";
    int count = 0;
    for (const auto& entry : fs::directory_iterator(currentPath)) {
        if (count++ < 10) {  // 只显示前10个
            std::cout << "  " << entry.path().filename() << "\n";
        }
    }
    
    // 创建目录
    fs::path testDir = currentPath / "test_output";
    if (!fs::exists(testDir)) {
        fs::create_directory(testDir);
        std::cout << "Created directory: " << testDir << "\n";
    }
    
    // 文件大小和时间
    if (fs::exists("CMakeLists.txt")) {
        std::cout << "CMakeLists.txt size: " 
                  << fs::file_size("CMakeLists.txt") << " bytes\n";
        std::time_t modTime = fs::last_write_time("CMakeLists.txt");
        std::cout << "Last modified: " << std::ctime(&modTime);
    }
}

void boostDateTimeExample() {
    std::cout << "\nBoost DateTime Example\n";
    
    using namespace boost::posix_time;
    using namespace boost::gregorian;
    
    // 当前时间
    ptime now = second_clock::local_time();
    std::cout << "Current time: " << now << "\n";
    
    // 时间运算
    ptime futureTime = now + hours(24);
    std::cout << "24 hours later: " << futureTime << "\n";
    
    // 日期运算
    date today = day_clock::local_day();
    date nextWeek = today + days(7);
    std::cout << "Today: " << today << "\n";
    std::cout << "Next week: " << nextWeek << "\n";
    
    // 计算时间差
    time_duration duration = hours(2) + minutes(30) + seconds(15);
    std::cout << "Duration: " << duration << "\n";
}
#endif

// ============================================================================
// 示例3: HALCON - 机器视觉
// ============================================================================
#ifdef USE_HALCON
#include "HalconCpp.h"
#include <iostream>

using namespace HalconCpp;

void halconExample() {
    std::cout << "\nHALCON Example\n";
    
    try {
        // 创建一个测试图像
        HImage image;
        image.GenImageConst("byte", 640, 480);
        
        // 绘制矩形
        HRegion rectangle;
        rectangle.GenRectangle1(100, 100, 300, 300);
        
        // 图像处理
        HImage filtered = image.MedianImage("circle", 5, "mirrored");
        
        // 边缘检测
        HRegion edges = filtered.EdgesSubPix("canny", 1.0, 20, 40);
        
        std::cout << "HALCON operations completed successfully\n";
        
        // 如果有真实图像
        if (0) {  // 设置为 1 来执行
            HImage realImage;
            realImage.ReadImage("test_image.jpg");
            
            // 转换为灰度图
            HImage grayImage = realImage.Rgb1ToGray();
            
            // 阈值分割
            HRegion region = grayImage.Threshold(128.0, 255.0);
            
            // 形态学操作
            HRegion opened = region.OpeningCircle(3.5);
            HRegion closed = opened.ClosingCircle(3.5);
            
            // 连通域分析
            HRegion connected = closed.Connection();
            HTuple area, row, column;
            connected.AreaCenter(&area, &row, &column);
            
            std::cout << "Found " << area.Length() << " objects\n";
            
            // 保存结果
            grayImage.WriteImage("png", 0, "halcon_result.png");
        }
        
    } catch (HException& exception) {
        std::cout << "HALCON Error: " << exception.ErrorMessage().Text() << "\n";
    }
}
#endif

// ============================================================================
// 主函数 - 根据定义的宏运行相应示例
// ============================================================================
#ifndef USE_AS_LIBRARY

int main() {
    std::cout << "===========================================\n";
    std::cout << "External Libraries Usage Examples\n";
    std::cout << "===========================================\n";
    
#ifdef USE_OPENCV
    opencvExample();
#else
    std::cout << "\nOpenCV: Not enabled (define USE_OPENCV to enable)\n";
#endif
    
#ifdef USE_BOOST
    boostFilesystemExample();
    boostDateTimeExample();
#else
    std::cout << "\nBoost: Not enabled (define USE_BOOST to enable)\n";
#endif
    
#ifdef USE_HALCON
    halconExample();
#else
    std::cout << "\nHALCON: Not enabled (define USE_HALCON to enable)\n";
#endif
    
    std::cout << "\n===========================================\n";
    std::cout << "All examples completed\n";
    std::cout << "===========================================\n";
    
    return 0;
}

#endif // USE_AS_LIBRARY
