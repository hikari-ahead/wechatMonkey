//
//  RSHookDataManager.m
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 25/12/2017.
//  Copyright © 2017 kuangjeon. All rights reserved.
//

#import "RSHookDataManager.h"
#import <objc/runtime.h>
#import "wechatMonkeyDylib.h"
#import <objc/message.h>
#import "NSMutableDictionary+RSSafety.h"

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

#pragma mark - Revoke
- (void)avoidRevokingMessage:(CMessageWrap *)msg withSelf:(id)arg2 {
    CMessageWrap *msgWrap = (CMessageWrap *)msg;
    NSString *content = msgWrap.m_nsContent;
    //获取撤回人
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<!\\[CDATA\\[(.*?)撤回了一条消息\\]\\]>" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)].firstObject;
    NSString *senderUsername = [content substringWithRange:[result rangeAtIndex:1]];
    
    CMessageWrap *newMsgWrap = [[objc_getClass("CMessageWrap") alloc] initWithMsgType:0x2710];
    newMsgWrap.m_nsContent = [NSString stringWithFormat:@"已阻止 %@ 撤回一条信息",senderUsername];
    newMsgWrap.m_nsFromUsr = msgWrap.m_nsFromUsr;
    newMsgWrap.m_uiStatus = 0x4;
    newMsgWrap.m_nsToUsr = msgWrap.m_nsToUsr;
    newMsgWrap.m_uiCreateTime = msgWrap.m_uiCreateTime;
    dispatch_async(dispatch_get_main_queue(), ^{
        [arg2 AddLocalMsg:newMsgWrap.m_nsFromUsr MsgWrap:newMsgWrap];
    });
}

#pragma mark - Red Packet
- (void)QueryOpenRedPacktetInfo:(id)msg msgWrap:(CMessageWrap *)wrap {
    // 获取消息类型
    unsigned long type = wrap.m_uiMessageType;
    switch (type) {
        case 49:
        {
            // 49代表红包
            id m_nsFromUsr = [wrap m_nsFromUsr];
            id m_nsContent = [wrap m_nsContent];
            
            id logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("WCRedEnvelopesLogicMgr")];
            id contactManager =[[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CContactMgr")];
            id selfContact = [contactManager getSelfContact];
            id m_nsUsrName = [selfContact m_nsUsrName];
            
            if ([m_nsFromUsr isEqualToString:m_nsUsrName]) {
                // 这个地方代表别人收取了红包
                return;
            }
            
            if ([m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound) {
                
                NSString *nativeUrl = m_nsContent;
                NSRange rangeStart = [m_nsContent rangeOfString:@"wxpay://c2cbizmessagehandler/hongbao"];
                if (rangeStart.location != NSNotFound) {
                    NSUInteger locationStart = rangeStart.location;
                    nativeUrl = [nativeUrl substringFromIndex:locationStart];
                }
                
                NSRange rangeEnd = [nativeUrl rangeOfString:@"]]"];
                if (rangeEnd.location != NSNotFound) {
                    NSUInteger locationEnd = rangeEnd.location;
                    nativeUrl = [nativeUrl substringToIndex:locationEnd];
                }
                
                NSString *naUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
                
                NSArray *parameterPairs =[naUrl componentsSeparatedByString:@"&"];
                
                NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[parameterPairs count]];
                for (NSString *currentPair in parameterPairs) {
                    NSRange range = [currentPair rangeOfString:@"="];
                    if(range.location == NSNotFound)
                        continue;
                    NSString *key = [currentPair substringToIndex:range.location];
                    NSString *value =[currentPair substringFromIndex:range.location + 1];
                    [parameters SafetySetObject:value forKey:key];
                }
                
                //红包参数
                NSMutableDictionary *params = [@{} mutableCopy];
                
                [params SafetySetObject:parameters[@"msgtype"] forKey:@"msgType"];
                [params SafetySetObject:parameters[@"sendid"] forKey:@"sendId"];
                [params SafetySetObject:parameters[@"channelid"] forKey:@"channelId"];
                
                id getContactDisplayName = [selfContact getContactDisplayName];
                id m_nsHeadImgUrl = [selfContact m_nsHeadImgUrl];
                
                [params SafetySetObject:getContactDisplayName forKey:@"nickName"];
                [params SafetySetObject:m_nsHeadImgUrl forKey:@"headImg"];
                [params SafetySetObject:[NSString stringWithFormat:@"%@", nativeUrl] forKey:@"nativeUrl"];
                [params SafetySetObject:m_nsFromUsr forKey:@"sessionUserName"];
                
                [RSHookDataManager.shareInstance.userDefault setObject:params forKey:RSParamKey];
                
                NSMutableDictionary* dictParam = [NSMutableDictionary dictionary];
                /*
                 agreeDuty = 0;
                 channelId = 1;
                 inWay = 1;
                 msgType = 1;
                 nativeUrl = "wxpay://c2cbizmessagehandler/hongbao/receivehongbao?msgtype=1&channelid=1&sendid=1000039501201709047019673006344&sendusername=ljl4323108&ver=6&sign=99690d3a66ff93739b339d1e1fc71ec12f026f3e34a0806aec19f05f6ab09c9604e4a5a63eef95b25b87cff49fa5bd0d87e46e8a35eca8189fc1020479fc23ad04c00ab0ca78ede59440ed8c63da189b60df7e8f9c7795ca43d1a78410f4ab47";
                 wxpay://c2cbizmessagehandler/hongbao/receivehongbao?msgtype=1&channelid=1&sendid=1000039501201709047018482497054&sendusername=ljl4323108&ver=6&sign=4bee27fc5aeec1399701f05959a48100fbd01fb263d295dd29e13129b8d94c8939232ee668a1e68bf164ee9bead0f4ff14001333427f3a653519efa1578d6f74b7ee48ba20034727fb1c64105b91153c0891f0f29c979437c46f9e9b289a14a8
                 sendId = 1000039501201709047019673006344;
                 */
                [dictParam SafetySetObject:@"0" forKey:@"agreeDuty"];                                             //agreeDuty
                [dictParam SafetySetObject:parameters[@"channelid"] forKey:@"channelId"];        //channelId
                [dictParam SafetySetObject:@"1" forKey:@"inWay"];                                                 //inWay
                [dictParam SafetySetObject:parameters[@"msgtype"] forKey:@"msgType"];            //msgType
                [dictParam SafetySetObject:nativeUrl forKey:@"nativeUrl"];                                     //nativeUrl
                [dictParam SafetySetObject:parameters[@"sendid"] forKey:@"sendId"];              //sendId
                
                NSLog(@"dictParam=%@", dictParam);
                ((void (*)(id, SEL, NSMutableDictionary*))objc_msgSend)(logicMgr, @selector(ReceiverQueryRedEnvelopesRequest:), dictParam);
                return;
            }
        }
            break;
        default:
            break;
    }
}

- (void)OnWCToHongbaoCommonResponse:(id)arg1 request:(id)arg2 {
        if ([NSStringFromClass([arg1 class]) isEqualToString:@"HongBaoRes"]) {
            NSData *data = [[arg1 retText] buffer];
            
            if (nil != data && 0 < [data length]) {
                NSError* error = nil;
                id jsonObj = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
                if (nil != error) {
                    NSLog(@"error %@", [error localizedDescription]);
                }
                else if (nil != jsonObj)
                {
                    if ([NSJSONSerialization isValidJSONObject:jsonObj]) {
                        if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                            id idTemp = jsonObj[@"timingIdentifier"];
                            if (idTemp) {
                                NSMutableDictionary *params = [[RSHookDataManager.shareInstance.userDefault objectForKey:RSParamKey] mutableCopy];
                                [RSHookDataManager.shareInstance.userDefault setObject:[NSMutableDictionary dictionary] forKey:RSParamKey];
                                [params SafetySetObject:idTemp forKey:@"timingIdentifier"]; // "timingIdentifier"字段
                                
                                // 防止重复请求
                                if (params.allKeys.count < 2) {
                                    return;
                                }
                                
                                id logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("WCRedEnvelopesLogicMgr")];
                                
                                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
                                dispatch_after(delayTime, dispatch_get_main_queue(), ^(void) {
                                    ((void (*)(id, SEL, NSMutableDictionary*))objc_msgSend)(logicMgr, @selector(OpenRedEnvelopesRequest:), params);
                                });
                            }
                        }
                    }
                }
            }
        }
}

@end
