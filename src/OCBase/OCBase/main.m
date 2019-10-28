//
//  main.m
//  OCBase
//
//  Created by barry on 2019/10/27.
//  Copyright © 2019 barry. All rights reserved.
//

// 引入头文件，import自动防止重复引用
#import <Foundation/Foundation.h>

// 定义MyObject类，继承NSObject
@interface MyObject : NSObject {
@public int member0; // 共有成员变量
    // 默认protect属性
    int member1; // 成员变量
}
// 返回值 方法名add:and:，参数为a，b，和c++不同的是，参数可以夹杂在方法名之间，用:标示参数，与阅读习惯更加符合,例如：
//       加       a 和        b
// 其实严格来说，add是方法名，and是标签，oc使用方法名+标签的方式确定一个方法
-(int) add:(int) a and:(int) b; // - 普通类方法
+(void) staticFunc:(NSString*) param; // + 静态类方法

@end

// 类实现
@implementation MyObject {
    // 在这里声明的是private属性
    int member2; // 私有成员变量
}

// 构造方法
- (MyObject*) init {
    NSLog(@"init");
    member0 = 0;
    member1 = 0;
    
    self = [super init];
    
    return self;
}

// 析构方法
- (void) dealloc {
    NSLog(@"dealloc");
}

-(int) add:(int) a and:(int) b {
     NSLog(@"add");
    return a + b;
}

+(void) staticFunc:(NSString*) param {
    NSLog(@"staticFunc %@", param);
}
@end

int main(int argc, const char * argv[]) {
    
    // 局部自动释放池，{构造池，}释放池，释放时自动释放自动池内变量，避免内存峰值
    @autoreleasepool {
        // 向静态方法发送消息（类似调用函数，但是原理完全不一样）
        [MyObject staticFunc:@"barry"];
        // 组合发送消息，先向MyObject发送alloc，再向返回值发送init
        MyObject* obj = [[MyObject alloc] init];
        obj->member0 = 1;
        NSLog(@"member0 %d", obj->member0);
        // :标示参数，参数夹杂在方法名之间，顺序和方法名声明顺序一样
        NSLog(@"a+b=%d", [obj add:1 and:2]);
    }
    // 局部自动释放池应用场景
    int largeNumber = 100;
    for (int i = 0; i < largeNumber; i++) {
        // 如果没有@autoreleasepool，str局部变量会在全局池上构建，全局池清理之前，会造成短暂内存持续增长，
        // 使用局部自动释放池避免内存峰值
        @autoreleasepool {
            NSString *str = [NSString stringWithFormat:@"hello -%04d", i];
            str = [str stringByAppendingString:@" - world"];
            //NSLog(@"%@", str);
        }
    }
    
    NSLog(@"Hello World");
    return 0;
}
