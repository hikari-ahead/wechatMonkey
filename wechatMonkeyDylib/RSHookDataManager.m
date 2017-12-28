//
//  RSHookDataManager.m
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 25/12/2017.
//  Copyright © 2017 kuangjeon. All rights reserved.
//

#import "RSHookDataManager.h"
#import <objc/runtime.h>

static RSHookDataManager *manager;
@interface RSHookDataManager()
@property (nonatomic, strong) NSUserDefaults *userDefault;
@end
@implementation RSHookDataManager
+ (instancetype)shareInstance {
    if (!manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [RSHookDataManager new];
        });
    }
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup {
    _userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"com.tencent.wechat.rshook"];
    [self getFlagsFromPersistence];
}

#pragma mark - Persistence
- (void)getFlagsFromPersistence {
    self.sportsHookOn = [_userDefault boolForKey:@"sportsHookOn"];
    self.redPacketHookOn = [_userDefault boolForKey:@"redPacketHookOn"];
    self.recallHookOn = [_userDefault boolForKey:@"recallHookOn"];
    self.footCount = (unsigned int)[_userDefault integerForKey:@"footCount"];
}

- (void)setFlagsToPersistence {
    [_userDefault setBool:self.sportsHookOn forKey:@"sportsHookOn"];
    [_userDefault setBool:self.redPacketHookOn forKey:@"redPacketHookOn"];
    [_userDefault setBool:self.recallHookOn forKey:@"recallHookOn"];
    [_userDefault setInteger:self.footCount forKey:@"footCount"];
}
@end


@implementation NSMutableDictionary (RSSafety)
- (void)SafetySetObject:(id)anObject forKey:(id <NSCopying>)aKey {
    if (anObject) {
        [self setObject:anObject forKey:aKey];
    }
}
@end
