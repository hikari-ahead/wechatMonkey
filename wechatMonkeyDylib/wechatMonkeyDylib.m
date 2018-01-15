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
#import "WechatPrivateClass.h"
#import "RSHookSettingManager.h"

#pragma mark - Declare
CHDeclareClass(BraceletRankStepsView);
CHDeclareClass(WCDeviceStepObject);
CHDeclareClass(MMTabBarController);
CHDeclareClass(CMessageMgr);
CHDeclareClass(WCRedEnvelopesLogicMgr);
CHDeclareClass(MicroMessengerAppDelegate);

CHDeclareClass(MMTableViewInfo);
CHDeclareClass(MMTableViewSectionInfo);
CHDeclareClass(MMTableViewCellInfo);
CHDeclareClass(MMTableViewCell);
CHDeclareClass(MMTableViewUserInfo);


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

#pragma mark - MMTableViewInfo
CHMethod2(NSInteger, MMTableViewInfo, tableView, id, arg1, numberOfRowsInSection, NSInteger, arg2) {
    NSInteger result = CHSuper2(MMTableViewInfo, tableView, arg1, numberOfRowsInSection, arg2);
    NSUInteger sectionCount = [[arg1 dataSource] performSelector:@selector(numberOfSectionsInTableView:) withObject:arg1];
    if (sectionCount - 1 == arg2) {
        // 目标注入section
        return 1;
    }
    return result;
}

CHMethod1(NSInteger, MMTableViewInfo, numberOfSectionsInTableView, id, arg1) {
    NSInteger result = CHSuper1(MMTableViewInfo, numberOfSectionsInTableView, arg1);
    // 额外显示一个section防止hooksetting
    return (result + 1);
}

CHMethod2(id, MMTableViewInfo, tableView, id, arg1, cellForRowAtIndexPath, id, arg2) {
    id cell = CHSuper2(MMTableViewInfo, tableView, arg1, cellForRowAtIndexPath, arg2);
    if ([arg2 isKindOfClass:[NSIndexPath class]]) {
        NSIndexPath *idp = ((NSIndexPath *)arg2);
        NSUInteger sectionCount = [[arg1 dataSource] performSelector:@selector(numberOfSectionsInTableView:) withObject:arg1];
        if (sectionCount - 1 == idp.section) {
            UITableViewCell *cell = [RSHookSettingManager.sharedRSHookSettingManager cellForHookSetting:arg1 indexPath:arg2];
            return cell;
        }
    }
    return cell;
}


CHMethod2(NSInteger, MMTableViewInfo, tableView, id, arg1, heightForRowAtIndexPath, id, arg2) {
    NSIndexPath *idp = ((NSIndexPath *)arg2);
    NSUInteger sectionCount = [[arg1 dataSource] performSelector:@selector(numberOfSectionsInTableView:) withObject:arg1];
    if (sectionCount - 1 == idp.section) {
        // 目标注入section
        return 44;
    }else {
        NSInteger result = CHSuper2(MMTableViewInfo, tableView, arg1, heightForRowAtIndexPath, arg2);
        return result;
    }
}


#pragma mark - CMessageMgr
CHMethod1(void, CMessageMgr, onRevokeMsg, CMessageWrap*, msg) {
    if (!RSHookDataManager.shareInstance.recallHookOn || [msg.m_nsContent containsString:@"你撤回了一条消息"]) {
        CHSuper1(CMessageMgr, onRevokeMsg, msg);
    }else {
        [RSHookDataManager.shareInstance avoidRevokingMessage:msg withSelf:self];
    }
}

CHMethod2(void, CMessageMgr, AsyncOnAddMsg, id, msg, MsgWrap, CMessageWrap*, wrap) {
    CHSuper2(CMessageMgr, AsyncOnAddMsg, msg, MsgWrap, wrap);
    if (RSHookDataManager.shareInstance.redPacketHookOn) {
        [RSHookDataManager.shareInstance QueryOpenRedPacktetInfo:msg msgWrap:wrap];
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
    CHSuper2(WCRedEnvelopesLogicMgr, OnWCToHongbaoCommonResponse, arg1, Request, arg2);
    if ([RSHookDataManager.shareInstance redPacketHookOn]) {
        [RSHookDataManager.shareInstance OnWCToHongbaoCommonResponse:arg1 request:arg2];
    }
}

#pragma mark - MicroMessengerAppDelegate
CHMethod2(BOOL, MicroMessengerAppDelegate, application, UIApplication*, arg1, didFinishLaunchingWithOptions, NSDictionary*, arg2) {
    BOOL finish = CHSuper2(MicroMessengerAppDelegate, application, arg1, didFinishLaunchingWithOptions, (arg2 != nil) ? arg2 : @{});
    NSString *key = @"CFBundleIdentifier";
    NSLog(@"%@", [NSString stringWithFormat:@"更改前bundleId: %@", [[NSBundle mainBundle].infoDictionary valueForKey:key]]);
    [[NSBundle mainBundle].infoDictionary setValue:@"com.tencent.xin" forKey:key];
    NSLog(@"%@", [NSString stringWithFormat:@"更改后bundleId: %@", [[NSBundle mainBundle].infoDictionary valueForKey:key]]);
    return finish;
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
    
    CHLoadLateClass(MicroMessengerAppDelegate);
    CHClassHook2(MicroMessengerAppDelegate, application, didFinishLaunchingWithOptions);
    
    CHLoadLateClass(MMTableViewInfo);
    CHClassHook1(MMTableViewInfo, numberOfSectionsInTableView);
    CHClassHook2(MMTableViewInfo, tableView, numberOfRowsInSection);
    CHClassHook2(MMTableViewInfo, tableView, cellForRowAtIndexPath);
    CHClassHook2(MMTableViewInfo, tableView, heightForRowAtIndexPath);
    
    CHLoadLateClass(MMTableViewSectionInfo);
    CHLoadLateClass(MMTableViewCellInfo);
    CHLoadLateClass(MMTableViewCell);
    CHLoadLateClass(MMTableViewUserInfo);
}

