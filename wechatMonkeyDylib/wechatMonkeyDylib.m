//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  wechatMonkeyDylib.m
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 23/12/2017.
//  Copyright (c) 2017 kuangjeon. All rights reserved.
//

#import "wechatMonkeyDylib.h"
#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit.h>
#import <Cycript/Cycript.h>
#import "RSHookFloatingView.h"
#import "RSHookDataManager.h"

#pragma mark - Declare
CHDeclareClass(BraceletRankStepsView);
CHDeclareClass(WCDeviceStepObject);
CHDeclareClass(MMTabBarController);
CHDeclareClass(CMessageMgr);
CHDeclareClass(WCRedEnvelopesLogicMgr);

static __attribute__((constructor)) void entry(){
    NSLog(@"\n               🎉!!！congratulations!!！🎉\n👍----------------insert dylib success----------------👍");
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        CYListenServer(6666);
    }];
}

//SystemMessageCellView initWithViewModel
#pragma mark - BraceletRankStepsView
CHMethod1(void, BraceletRankStepsView, setStepDatas, id, data) {
    CHSuper1(BraceletRankStepsView, setStepDatas, data);
    NSLog(@"data is %@",data);
}

#pragma mark - WCDeviceStepObject
CHMethod0(unsigned int, WCDeviceStepObject, m7StepCount) {
    if (RSHookDataManager.shareInstance.sportsHookOn) {
        return RSHookDataManager.shareInstance.footCount;
    }else {
        return CHSuper0(WCDeviceStepObject, m7StepCount);
    }
}

#pragma mark - MMTabBarController
CHMethod0(void, MMTabBarController, viewDidLoad) {
    CHSuper0(MMTabBarController, viewDidLoad);
    // 添加hook视图
    if (RSHookFloatingView.shareInstance.superview) {
        [RSHookFloatingView.shareInstance removeFromSuperview];
    }
    [self.view addSubview:RSHookFloatingView.shareInstance];
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:RSHookFloatingView.shareInstance action:@selector(panGestureRecognizer:)]];
}

#pragma mark - CMessageMgr
CHMethod1(void, CMessageMgr, onRevokeMsg, CMessageWrap*, msg) {
    if (!RSHookDataManager.shareInstance.recallHookOn || [objc_getClass("CMessageWrap") isSenderFromMsgWrap:msg]) {
        CHSuper1(CMessageMgr, onRevokeMsg, msg);
    }else {
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
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf AddLocalMsg:newMsgWrap.m_nsFromUsr MsgWrap:newMsgWrap];
        });
    }
}

CHMethod2(void, CMessageMgr, AsyncOnAddMsg, id, msg, MsgWrap, CMessageWrap*, wrap) {
    CHSuper2(CMessageMgr, AsyncOnAddMsg, msg, MsgWrap, wrap);
    if (RSHookDataManager.shareInstance.redPacketHookOn) {
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
}

CHOptimizedMethod1(self, void, WCRedEnvelopesLogicMgr, OpenRedEnvelopesRequest, id, arg1) {
    NSLog(@"%@", arg1);
    CHSuper1(WCRedEnvelopesLogicMgr, OpenRedEnvelopesRequest, arg1);
}

CHOptimizedMethod1(self, void, WCRedEnvelopesLogicMgr, ReceiverQueryRedEnvelopesRequest, id, arg1) {
    CHSuper1(WCRedEnvelopesLogicMgr, ReceiverQueryRedEnvelopesRequest, arg1);
}

CHOptimizedMethod2(self, void, WCRedEnvelopesLogicMgr, OnWCToHongbaoCommonResponse, id, arg1, Request, id, arg2) {
    NSLog(@"%@", arg1);
    NSLog(@"%@", arg2);
    /*
     <HongBaoRes: 0x1123400f0>
     <HongBaoReq: 0x1123805f0>
     */
    
    CHSuper2(WCRedEnvelopesLogicMgr, OnWCToHongbaoCommonResponse, arg1, Request, arg2);
    
    if ([RSHookDataManager.shareInstance redPacketHookOn]) {
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
}

#pragma mark - CHConstructor
CHConstructor{
    CHLoadLateClass(BraceletRankStepsView);
    CHClassHook1(BraceletRankStepsView, setStepDatas);
    
    CHLoadLateClass(WCDeviceStepObject);
    CHClassHook0(WCDeviceStepObject, m7StepCount);
    
    CHLoadLateClass(MMTabBarController);
    CHClassHook0(MMTabBarController, viewDidLoad);
    
    CHLoadLateClass(CMessageMgr);
    CHClassHook1(CMessageMgr, onRevokeMsg);
    CHClassHook2(CMessageMgr, AsyncOnAddMsg, MsgWrap);
    
    CHLoadLateClass(WCRedEnvelopesLogicMgr);
    CHClassHook(1, WCRedEnvelopesLogicMgr, OpenRedEnvelopesRequest);
    CHClassHook(1, WCRedEnvelopesLogicMgr, ReceiverQueryRedEnvelopesRequest);
    CHClassHook(2, WCRedEnvelopesLogicMgr, OnWCToHongbaoCommonResponse, Request);
}

