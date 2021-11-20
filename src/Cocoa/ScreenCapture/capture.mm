#include "capture.h"
#import <CoreGraphics/CGWindow.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Cocoa/Cocoa.h>
#import <Accelerate/Accelerate.h>

#include <QWidget>
#include <QDebug>

#define GET_IMAGE_BUFFER 3

Capture::Capture()
{

}

int Capture::GetWindowNumber(QWidget* widget) {
    NSView* view = (NSView*)widget->winId();
    NSWindow* win = view.window;

    qDebug() << "GetWindowNumber::" << win.windowNumber;
    return win.windowNumber;
}

bool Capture::CaptureFrame(uint64_t window, const std::function<void (int width, int height, uint8_t* data)>& onFrame) {
    qDebug() << "window:" << window;

#if 0
    // CGWindowListCopyWindowInfo返回的是windowinfo dict（里面包含CGWindowID）
    // CGWindowListCreate返回的是CGWindowID
    CFArrayRef windowList = CGWindowListCreate(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    CFMutableArrayRef windows = CFArrayCreateMutableCopy(nullptr, 0, windowList);
    CFRelease(windowList);

    for (int i = CFArrayGetCount(windows) - 1; i>=0; i--) {
        auto id = (CGWindowID)(uintptr_t)CFArrayGetValueAtIndex(windows, i);
        qDebug() << "window list:" << id;
    }
#else
    CFMutableArrayRef windows = CFArrayCreateMutable(nullptr, 0, nullptr);
    CFArrayAppendValue(windows, reinterpret_cast<const void*>(window));
#endif

    // capture
    // CGRectNull 自动匹配最小区域
    // kCGWindowImageBoundsIgnoreFraming 当第一个参数为CGRectNull时，指定只采集窗口区域，不包括特效区域，例如shadow
    // kCGWindowImageNominalResolution 采集逻辑分辨率而不是物理分辨率
    CGImageRef image = CGWindowListCreateImageFromArray(CGRectNull, windows, kCGWindowImageBoundsIgnoreFraming | kCGWindowImageNominalResolution);

    // image中的数据是有stride的，使用CGImageGetBytesPerRow(image)/4来计算真实宽高
    //int width = CGImageGetWidth(image);
    int width = CGImageGetBytesPerRow(image) / 4;
    int height = CGImageGetHeight(image);

    // get rgba buffer
#if GET_IMAGE_BUFFER == 1
    // by CGContextDrawImage
    uint8_t* buffer = new uint8_t[width * height * 4];
    CGContextRef bitmap = CGBitmapContextCreate(buffer, width, height, 8, 4 * width,
                            CGImageGetColorSpace(image), CGImageGetBitmapInfo(image));

    CGRect bufferRect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(bitmap, bufferRect, image);
#endif

#if GET_IMAGE_BUFFER == 2
    // by CGDataProviderCopyData
    // 这一步可能是lazy copy，耗时和cpu占用都不高，后面使用这个buffer的时候才会真正copy
    CFDataRef dataFromCGImageProvider = CGDataProviderCopyData(CGImageGetDataProvider(image));
    uint8_t* buffer = (uint8_t*)CFDataGetBytePtr(dataFromCGImageProvider);

    // mac下可以创建cpu/gpu都允许访问的内存，后期应该可以类似下面操作直接读取内存，待调研
    //uint8_t* buffer = (uint8_t*)CFDataGetBytePtr(CGImageGetDataProvider(image));
#endif

#if GET_IMAGE_BUFFER == 3
    // by vImageBuffer_InitWithCGImage
    CGColorSpaceRef colorSpace = CGColorSpaceRetain(CGImageGetColorSpace(image));
    vImage_CGImageFormat inputImageFormat = {
      .bitsPerComponent = (uint32_t)CGImageGetBitsPerComponent(image),
      .bitsPerPixel = (uint32_t)CGImageGetBitsPerComponent(image) *
                      (uint32_t)(CGColorSpaceGetNumberOfComponents(colorSpace) +
                                 (kCGImageAlphaNone != CGImageGetAlphaInfo(image))),
      .colorSpace = colorSpace,
      .bitmapInfo = CGImageGetBitmapInfo(image),
      .version = 0,
      .decode = nullptr,
      .renderingIntent = kCGRenderingIntentDefault};

    vImage_Buffer imageBuffer;
    imageBuffer.data = malloc(width*height*4);
    imageBuffer.width = width;
    imageBuffer.height = height;
    imageBuffer.rowBytes = width * 4;
    // 这一步可能是lazy init，cpu占用不高，后面使用这个buffer的时候才会真正copy
    vImageBuffer_InitWithCGImage(&imageBuffer, &inputImageFormat, nullptr, image, kvImageNoAllocate);
    uint8_t* buffer = (uint8_t*)imageBuffer.data;
#endif

    // callback
    onFrame(width, height, buffer);

    // clear
#if GET_IMAGE_BUFFER == 1
    CGContextRelease(bitmap);
    delete[] buffer;
#endif
#if GET_IMAGE_BUFFER == 2
    CFRelease(dataFromCGImageProvider);
#endif
#if GET_IMAGE_BUFFER == 3
    delete[] buffer;
#endif

    CGImageRelease(image);
    CFRelease(windows);

    return true;
}
