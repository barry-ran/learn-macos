#ifndef CAPTURE_H
#define CAPTURE_H

#include <functional>

class QWidget;
class Capture
{
public:
    Capture();
    static int GetWindowNumber(QWidget* widget);
    bool CaptureFrame(uint64_t window, const std::function<void (int width, int height, uint8_t* data)>& onFrame);
};

#endif // CAPTURE_H
