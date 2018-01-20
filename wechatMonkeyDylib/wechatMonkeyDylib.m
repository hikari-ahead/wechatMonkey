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
#import <objc/runtime.h>

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

CHDeclareClass(MoreViewController);
CHDeclareClass(ChatRoomInfoViewController);
CHDeclareClass(AddContactToChatRoomViewController);

CHDeclareClass(EmoticonBoardView);
CHDeclareClass(EmoticonBoardBottomTabBar);

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
//    if (RSHookFloatingView.shareInstance.superview) {
//        [RSHookFloatingView.shareInstance removeFromSuperview];
//    }
//    [self.view addSubview:RSHookFloatingView.shareInstance];
//    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:RSHookFloatingView.shareInstance action:@selector(panGestureRecognizer:)]];
}

#pragma mark - MMTableViewInfo
CHMethod2(NSInteger, MMTableViewInfo, tableView, id, arg1, numberOfRowsInSection, NSInteger, arg2) {
    NSInteger result = CHSuper2(MMTableViewInfo, tableView, arg1, numberOfRowsInSection, arg2);
    return result;
}

CHMethod1(NSInteger, MMTableViewInfo, numberOfSectionsInTableView, id, arg1) {
    NSInteger result = CHSuper1(MMTableViewInfo, numberOfSectionsInTableView, arg1);
    return result;
}

CHMethod2(id, MMTableViewInfo, tableView, id, arg1, cellForRowAtIndexPath, id, arg2) {
    id cell = CHSuper2(MMTableViewInfo, tableView, arg1, cellForRowAtIndexPath, arg2);
    return cell;
}


CHMethod2(NSInteger, MMTableViewInfo, tableView, id, arg1, heightForRowAtIndexPath, id, arg2) {
    NSInteger result = CHSuper2(MMTableViewInfo, tableView, arg1, heightForRowAtIndexPath, arg2);
    return result;
}

#pragma mark - MMTableViewCellInfo
CHMethod1(void, MMTableViewCellInfo, makeSwitchCell, id, arg1) {
    CHSuper1(MMTableViewCellInfo, makeSwitchCell, arg1);
}


#pragma mark - NewSettingViewController
CHMethod0(void, MoreViewController, viewDidLoad) {
    CHSuper0(MoreViewController, viewDidLoad);
    NSLog(@"MoreViewController viewDidLoad -- Hooked");
}

CHMethod0(void, MoreViewController, addSettingSection) {
    CHSuper0(MoreViewController, addSettingSection);
    NSLog(@"MoreViewController addSettingSection -- Hooked");
    id hookSectionInfo = [[RSHookSettingManager sharedRSHookSettingManager] hookSectionForMoreViewController];
    Ivar ivar = class_getInstanceVariable(objc_getClass("MoreViewController"), "m_tableViewInfo");
    MMTableViewInfo *moreVCTableInfo = object_getIvar(self, ivar);
    [moreVCTableInfo addSection:hookSectionInfo];
}


CHMethod0(void, MoreViewController, reloadMoreView) {
    CHSuper0(MoreViewController, reloadMoreView);
    NSLog(@"MoreViewController reloadMoreView -- Hooked");
}

#pragma mark - ChatRoomInfoViewController
CHMethod0(void, ChatRoomInfoViewController, reloadTableData) {
    CHSuper0(ChatRoomInfoViewController, reloadTableData);
    id hookSectionInfo = [[RSHookSettingManager sharedRSHookSettingManager] redPackSwitchCellForChatRoomSettingViewController:self cellTitle:@"自动抢红包"];
    if (!hookSectionInfo) {
        return;
    }
    Ivar ivar = class_getInstanceVariable(objc_getClass("ChatRoomInfoViewController"), "m_tableViewInfo");
    MMTableViewInfo *moreVCTableInfo = object_getIvar(self, ivar);
    [moreVCTableInfo addSection:hookSectionInfo];
    // 因为微信在调用reloadTableData时会先调用clearAllSection 所有在这里注入section之后调用tableView再次刷新
    Ivar tableViewIvar = class_getInstanceVariable(objc_getClass("MMTableViewInfo"), "_tableView");
    UITableView *tableView = object_getIvar(moreVCTableInfo, tableViewIvar);
    [tableView reloadData];
}

CHMethod0(void, ChatRoomInfoViewController, initView) {
    CHSuper0(ChatRoomInfoViewController, initView);
}

#pragma mark - EmoticonBoardView
CHMethod0(void, EmoticonBoardView, initData) {
    CHSuper0(EmoticonBoardView, initData);
    
}

CHMethod0(void, EmoticonBoardView, initView) {
    CHSuper0(EmoticonBoardView, initView);
    
}

CHMethod1(void, EmoticonBoardView, onEmoticonBoardBottomTabBarClickItem, id, arg1) {
    CHSuper1(EmoticonBoardView, onEmoticonBoardBottomTabBarClickItem, arg1);
}

#pragma mark - EmoticonBoardView
CHMethod0(void, EmoticonBoardBottomTabBar, reloadData) {
    CHSuper0(EmoticonBoardBottomTabBar, reloadData);
}


#pragma mark - AddContactToChatRoomViewController
CHMethod0(void, AddContactToChatRoomViewController, reloadTableData) {
    CHSuper0(AddContactToChatRoomViewController, reloadTableData);
    id hookSectionInfo = [[RSHookSettingManager sharedRSHookSettingManager] redPackSwitchCellForChatRoomSettingViewController:self cellTitle:@"自动抢红包"];
    if (!hookSectionInfo) {
        return;
    }
    Ivar ivar = class_getInstanceVariable(objc_getClass("AddContactToChatRoomViewController"), "m_tableViewInfo");
    MMTableViewInfo *moreVCTableInfo = object_getIvar(self, ivar);
    [moreVCTableInfo addSection:hookSectionInfo];
    // 因为微信在调用reloadTableData时会先调用clearAllSection 所有在这里注入section之后调用tableView再次刷新
    Ivar tableViewIvar = class_getInstanceVariable(objc_getClass("MMTableViewInfo"), "_tableView");
    UITableView *tableView = object_getIvar(moreVCTableInfo, tableViewIvar);
    [tableView reloadData];
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
    CHHook1(MMTableViewCellInfo, makeSwitchCell);
    
    CHLoadLateClass(MMTableViewCell);
    
    CHLoadLateClass(MMTableViewUserInfo);
    
    CHLoadLateClass(MoreViewController);
    CHClassHook0(MoreViewController, viewDidLoad);
    CHClassHook0(MoreViewController, addSettingSection);
    CHClassHook0(MoreViewController, reloadMoreView);
    
    CHLoadLateClass(ChatRoomInfoViewController);
    CHClassHook0(ChatRoomInfoViewController, reloadTableData);
    CHClassHook0(ChatRoomInfoViewController, initView);
    
    CHLoadLateClass(AddContactToChatRoomViewController);
    CHClassHook0(AddContactToChatRoomViewController, reloadTableData);

    CHLoadLateClass(EmoticonBoardView);
    CHClassHook0(EmoticonBoardView, initData);
    CHClassHook0(EmoticonBoardView, initView);
    CHClassHook1(EmoticonBoardView, onEmoticonBoardBottomTabBarClickItem);

    CHLoadLateClass(EmoticonBoardBottomTabBar);
    CHClassHook0(EmoticonBoardBottomTabBar, reloadData);
}

