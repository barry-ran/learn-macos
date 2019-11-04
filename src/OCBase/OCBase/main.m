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
@public int publicMember_; // 公有成员变量
    // 默认protect属性
    int protectMember_; // 成员变量
}

// 声明属性来访问保护变量（读写）（其实是自动声明存取函数）
@property(readwrite) int protectMember_;

// 返回值 方法名add:and:，参数为a，b，和c++不同的是，参数可以夹杂在方法名之间，用:标示参数，与阅读习惯更加符合,例如：
//       加       a 和        b
// 其实严格来说，add是方法名，and是标签，oc使用方法名+标签的方式确定一个方法
-(int) add:(int) a and:(int) b; // - 普通类方法
+(void) staticFunc:(NSString*) param; // + 静态类方法

@end

// 类实现
@implementation MyObject {
    // 在这里声明的是private属性
    int privateMember_; // 私有成员变量
}

// 告诉编译器，protectMember_的存取属性自动帮我实现
@synthesize protectMember_;

// 构造方法
- (MyObject*) init {
    NSLog(@"init");
    publicMember_ = -1;
    protectMember_ = -2;
    privateMember_ = -3;
    
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

// 协议，类似虚基类
@protocol Locking
- (void)lock;
- (void)unlock;
@optional - (void)test; // 可选的，可以不用实现
@end

// 声明SomeClass实现Locking协议
@interface SomeClass : NSObject<Locking>
@end

@implementation SomeClass
- (void)lock {
    NSLog(@"lock");
}
- (void)unlock {
    NSLog(@"unlock");
}
@end

// 测试分类:扩展原有类的功能
// 声明MyObject类的分类ExtObject
@interface MyObject(ExtObject)
- (void) print;
@end

@implementation MyObject(ExtObject)

- (void) print
{
    // 扩展方法中访问原类的属性
    NSLog(@"ExtObject print privateMember_:%d", self->privateMember_);
}

@end

// 运行环境为自动垃圾收集ARC

int main(int argc, const char * argv[]) {
    // 字符串
    NSString* myString = @"My String\n";
    NSLog(@"myString:%@", myString);
    NSString* anotherString = [NSString stringWithFormat:@"%d %@", 1, @"String"];
    NSLog(@"anotherString:%@", anotherString);
    // 从一个C语言字符串创建Objective-C字符串
    NSString* fromCString = [NSString stringWithCString:"A C string" encoding:NSASCIIStringEncoding];
    NSLog(@"fromCString:%@", fromCString);
    
    // 测试访问property
    MyObject* testPro = [[MyObject alloc] init];
    testPro.protectMember_ = 111; // 注意：点表达式，等于[testPro setProtectMember_: 111;
    NSLog(@"Access protectMember_ by message (%d), dot notation(%d), property name(%@) and direct instance variable access (%d)",
          [testPro protectMember_], testPro.protectMember_, [testPro valueForKey:@"protectMember_"], testPro->protectMember_);
    // 动态读取属性
    /*
    int i;
    int propertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList([testPro class], &propertyCount);
    for ( i=0; i < propertyCount; i++ ) {
        objc_property_t *thisProperty = propertyList + i;
        const char* propertyName = property_getName(*thisProperty);
        NSLog(@"MyObject has a property: '%s'", propertyName);
    }
     */
    
    // 测试扩展类，直接向MyObject对象发送消息即可
    [testPro print];
    
    // 测试协议
    SomeClass* sc = [SomeClass new];
    [sc lock];
    [sc unlock];
    
    // 局部自动释放池，{构造池，}释放池，释放时自动释放自动池内变量，避免内存峰值
    @autoreleasepool {
        // 向静态方法发送消息（类似调用函数，但是原理完全不一样）
        [MyObject staticFunc:@"barry"];
        // 组合发送消息，先向MyObject发送alloc，再向返回值发送init
        MyObject* obj = [[MyObject alloc] init];
        obj->publicMember_ = 1;
        NSLog(@"member0 %d", obj->publicMember_);
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
