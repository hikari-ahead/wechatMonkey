//
//  NSMutableDictionary+RSSafety.m
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 28/12/2017.
//  Copyright © 2017 kuangjeon. All rights reserved.
//

#import "NSMutableDictionary+RSSafety.h"

@implementation NSMutableDictionary (RSSafety)
- (void)SafetySetObject:(id)anObject forKey:(id <NSCopying>)aKey {
    if (anObject) {
        [self setObject:anObject forKey:aKey];
    }
}
@end
