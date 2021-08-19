介绍参考这里 https://www.cocoawithlove.com/2008/12/drawing-custom-window-on-mac-os-x.html

跨平台的自定义形状窗口 https://texus.me/2015/06/20/cross-platform-custom-shaped-windows/

RoundTransparentWindow
======================
This sample code shows how to use Cocoa to create custom-shaped windows and/or transparent window content. It also shows how to change the shape of the window on the fly, and instructs the system to recalculate the drop shadow around the custom window shape. 

Build Requirements
==================
OS X 10.7 SDK or later

Runtime Requirements
====================
OS X 10.7 or later

Packaging List
==============
main.m
Template main method.

Controller.{h/m}
The Controller class implements the -changeTransparency: action, called when the slider on the window is moved.

CustomWindow.{h/m}
Subclass of NSWindow with a custom shape and transparency. Since the window will not have a title bar, -mouseDown: and -mouseDragged: are overriden so the window can be moved by dragging its content area.

CustomView.{h/m}
Subclass of NSView which handles the drawing of the window content. Circle and pentagon graphics are used, switching between the two depending upon the window's level of transparency.

Changes from Previous Versions
==============================
1.5 - Replaced use of deprecated API "[NSImage compositeToPoint:fromRect:operation:]"
1.4 - Updated for Xcode 4.
1.3 - Updated for Mac OS X 10.6, now builds 3-way Universal (ppc, i386, x86_64)
1.2 - Updated for Xcode Tools version 3.1 and Objective C 2.0.
1.1 - Added override of -canBecomeKeyWindow so that controls in the window are enabled.
1.0 - Initial version published.

Copyright (C) 2003-2013 Apple Inc. All rights reserved.
