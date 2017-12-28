//
//  NSMutableDictionary+RSSafety.h
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 28/12/2017.
//  Copyright © 2017 kuangjeon. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface NSMutableDictionary (RSSafety)
- (void)SafetySetObject:(id)anObject forKey:(id <NSCopying>)aKey;
@end
