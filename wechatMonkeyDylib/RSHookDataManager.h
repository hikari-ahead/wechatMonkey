//
//  RSHookDataManager.h
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 25/12/2017.
//  Copyright © 2017 kuangjeon. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *RSParamKey = @"RSParamKey";

@interface RSHookDataManager : NSObject
/** Hook Sport Switch */
@property (nonatomic, assign) BOOL sportsHookOn;
/** Hook Red packet Switch */
@property (nonatomic, assign) BOOL redPacketHookOn;
/** Hook Recall Switch */
@property (nonatomic, assign) BOOL recallHookOn;

@property (nonatomic, assign) unsigned int footCount;

@property (nonatomic, strong, readonly) NSUserDefaults *userDefault;

+ (instancetype)shareInstance;
- (void)setFlagsToPersistence;
- (void)getFlagsFromPersistence;
@end



@interface NSMutableDictionary (RSSafety)
- (void)SafetySetObject:(id)anObject forKey:(id <NSCopying>)aKey;
@end
