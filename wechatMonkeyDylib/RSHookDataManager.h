//
//  RSHookDataManager.h
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 25/12/2017.
//  Copyright © 2017 kuangjeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WechatPrivateClass.h"

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

- (void)avoidRevokingMessage:(CMessageWrap *)msg withSelf:(id)arg2;
/**
 *  In normal condition, users tap the redpacket cell on the chat vc ,
 *  there will pop a view up, this function is used to fetch neccessary info.
 */
- (void)QueryOpenRedPacktetInfo:(id)msg msgWrap:(CMessageWrap *)wrap;

- (void)OnWCToHongbaoCommonResponse:(id)arg1 request:(id)arg2;

@end



