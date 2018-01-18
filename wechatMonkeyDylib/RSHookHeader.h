//
//  RSHookHeader.h
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 13/01/2018.
//  Copyright © 2018 kuangjeon. All rights reserved.
//

#ifndef RSHookHeader_h
#define RSHookHeader_h

/** 单例宏 */
#define singleton_interface(class) + (instancetype)shared##class;

#define singleton_implementation(class) \
static class *_instance; \
+ (instancetype)shared##class \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[class alloc] init]; \
}); \
return _instance; \
}

/** 顶级控制器 */
#define topViewControllerInWeChat [[((UITabBarController *)[[[UIApplication sharedApplication].delegate window] rootViewController]) selectedViewController] topViewController]

/** 强弱引用 */
#ifndef weakify
#if DEBUG
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#endif
#endif

#ifndef strongify
#if DEBUG
#define strongify(object) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"")\
autoreleasepool{} __typeof__(object) object = weak##_##object;\
_Pragma("clang diagnostic pop")
#else
#define strongify(object) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"")\
try{} @finally{} \
__typeof__(object) object = weak##_##object;\
_Pragma("clang diagnostic pop")
#endif
#endif

#endif /* RSHookHeader_h */

