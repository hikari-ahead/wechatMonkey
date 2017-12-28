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
        [RSHookDataManager.shareInstance avoidRevokingMessage:msg];
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

