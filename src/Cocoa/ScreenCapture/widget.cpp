#include "widget.h"
#include "ui_widget.h"
#include "capture.h"

#include <QWindow>

Widget::Widget(QWidget *parent)
    : QWidget(parent)
    , ui(new Ui::Widget)
{
    ui->setupUi(this);
    m_capture = new Capture();
}

Widget::~Widget()
{
    delete ui;
}

void Widget::timerEvent(QTimerEvent *event)
{
    if (event->timerId() == m_timer) {
        m_capture->CaptureFrame(Capture::GetWindowNumber(this), [this](int width, int height, uint8_t* data) {
            QImage img(data, width, height, QImage::Format_ARGB32);
            ui->videoLabel->setPixmap(QPixmap::fromImage(img.scaled(ui->videoLabel->width(), ui->videoLabel->height())));
        });
    }
}


void Widget::on_startBtn_clicked()
{
    if (0 != m_timer) {
        return;
    }
    m_timer = startTimer(100);
}


void Widget::on_stopBtn_clicked()
{
    if (0 == m_timer) {
        return;
    }
    killTimer(m_timer);
    m_timer = 0;
}

