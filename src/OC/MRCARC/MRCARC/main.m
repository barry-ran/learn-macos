//
//  main.m
//  MRCARC
//
//  Created by bytedance on 12/14/21.
//

#import <Foundation/Foundation.h>

@interface MyObject : NSObject
@end

@implementation MyObject

// 构造方法
- (MyObject*) init {
    NSLog(@"init");
    
    self = [super init];
    return self;
}

// 析构方法
- (void) dealloc {
    NSLog(@"dealloc");
    
    [super dealloc];
}
@end

int main(int argc, const char * argv[]) {
    // @autoreleasepool在mrc和arc下都可以用
    // arc的本质是帮我们省去了retain/release/autorelease这些操作
    @autoreleasepool {
        
        // mrc内存管理指南 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmRules.html
        // 使用zombies监控内存管理是否正确 https://help.apple.com/instruments/mac/current/#/dev612e6956
        // 或者直接点击菜单中Product->Analyze即可分析内存管理是否正确，如果有问题可以点击提示信息中的explore查看详细信息

        // 检测是否开启arc，在项目属性 Build Setting中搜索arc可以找到开关arc的地方
#if __has_feature(objc_arc)
        NSLog(@"arc mode");
#else
        NSLog(@"mrc mode");
        const char* test = "aaaa";
        NSLog(@"test addr:%p", test);
        
        // 我拥有使用名称以“alloc”、“new”、“copy”或“mutableCopy”开头的方法（例如alloc，newObject、 或mutableCopy）创建的对象，所以我需要release释放
        NSString* str1 = [[NSString alloc] initWithFormat:@"%@%d", @"hello", 1];
        NSLog(@"str1:%@, addr:%p, retainCount:%lu, NSUIntegerMax=%lu", str1, str1, [str1 retainCount], NSUIntegerMax);
        // 可以注释这里再使用Product->Analyze看看效果
        //[str1 release];
        
        // stringWithFormat不是以上面规定的开头，所以不需要release
        NSString* str2 = [NSString stringWithFormat:@"%@%d", @"world", 2];
        NSLog(@"str2:%@, addr:%p, retainCount:%lu, NSUIntegerMax=%lu", str2, str2, [str2 retainCount], NSUIntegerMax);
        // 可以解除这里的注释再使用Product->Analyze看看效果
        //[str2 release];
    
        // autorelease
        NSString* str3 = [[NSString alloc] initWithFormat:@"%@%d", @"hahaha", 3];
        NSLog(@"str3:%@, addr:%p, retainCount:%lu, NSUIntegerMax=%lu", str3, str3, [str3 retainCount], NSUIntegerMax);
        // 这里使用release和autorelease释放都可以，最终效果都是retainCount-1
        // 区别是时机不同：
        // release是立即执行retainCount-1
        // autorelease是将release操作交给最近的autoreleasepool去统一执行，即延迟release的执行
        // 对autoreleasepool介绍比较好的文章：https://draveness.me/autoreleasepool/
        //[str3 release];
        [str3 autorelease];
        
        // 需要注意autorelease的这种设计会引起短暂内存峰值，可以使用@autoreleasepool{}限制autorelease执行的时机不要太晚
        for (int i=0; i<100; i++) {
            // 如果这里没有@autoreleasepool，那么100个stri要等到上面那个@autoreleasepool结束时才会真正release释放
            // 严格来说内存没有泄露，但是在for循环中会早
            @autoreleasepool{
                NSString* stri = [[NSString alloc] initWithFormat:@"%@%d", @"str", i];
                [stri autorelease];
            }
        }
        
        // 上面的结论都是正确的，使用Product->Analyze分析也没有问题，但是有一点很奇怪，retainCount都是等于NSUIntegerMax
        // 即使调用很多次release/autorelease也没有运行内存错误
        // 这是跟NSString内部实现有关，苹果旧文档表示：NSUIntegerMax意味着返回的对象是不朽的。这曾经在文档中，但此后已被删除
        // 对于NSUIntegerMax对象，release和autorelease不会做任何操作
        // 苹果新文档说retaincount不可信，不要相信它https://developer.apple.com/documentation/objectivec/1418956-nsobject/1571952-retaincount
        
        // 下面我们构造一个自定义的对象，可以看到正确的retainCount
        // 推荐按照官方文档，不要相信retainCount，使用Product->Analyze分析或者zombies等工具分析
        MyObject* obj = [[MyObject alloc] init];
        NSLog(@"myobj, retainCount:%lu", [obj retainCount]);
        [obj release];
        // 不过Product->Analyze分析不出这个异常不知为什么
        //[obj release];
#endif
        
    }
    return 0;
}
