#include "widget.h"
#include "./ui_widget.h"
#include "capture.h"

#include <QWindow>
#include <QDebug>

Widget::Widget(QWidget *parent)
    : QWidget(parent)
    , ui(new Ui::Widget)
{
    ui->setupUi(this);
}

Widget::~Widget()
{
    delete ui;
}


void Widget::on_startBtn_clicked()
{
    static Capture* capture = new Capture();

    // 1. 权限
    // 2. qimage显示
    // 3. 定时器

    capture->Start(windowHandle()->winId(), [this](int width, int height, uint8_t* data) {
        qDebug() << "width:" << width << " height:" << height;
    });
}

