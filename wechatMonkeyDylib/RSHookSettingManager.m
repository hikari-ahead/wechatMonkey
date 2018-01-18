//
//  RSHookSettingManager.m
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 13/01/2018.
//  Copyright © 2018 kuangjeon. All rights reserved.
//

#import "RSHookSettingManager.h"
#import "RSHookDataManager.h"
#import "RSHookSettingTableViewCell.h"
#import "RSHookHeader.h"
#import "RSHookFloatingView.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation RSHookSettingManager
singleton_implementation(RSHookSettingManager)

- (void)showHookSettingController:(id)sender {
    NSLog(@"Tappppppppped!!");
    if (![RSHookFloatingView shareInstance].mainHookVC) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        [RSHookFloatingView shareInstance].mainHookVC = [storyBoard instantiateViewControllerWithIdentifier:@"RSHookMainViewController"];
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:[RSHookFloatingView shareInstance].mainHookVC animated:YES completion:NULL];
}

- (id)singleCellSectionWithImageName:(NSString *)imageName title:(NSString *)title target:(id)target selector:(SEL)selector {
    Class class = objc_getClass("MMTableViewSectionInfo");
    MMTableViewSectionInfo *hookSectionInfo = ((id(*)(id, SEL))objc_msgSend)(class, @selector(sectionInfoDefaut));
    SEL makeCellInfoSEL = @selector(normalCellForSel:target:title:rightValue:imageName:accessoryType:isFitIpadClassic:);
    id(*objc_msgSendTyped)(id self, SEL _cmd, SEL normalCellForSel, id target, id title, id rightValue, id imageName, long long accessoryType, _Bool isFitIpadClassic) = (void*)objc_msgSend;
    MMTableViewCellInfo *cellInfo = objc_msgSendTyped(objc_getClass("MMTableViewCellInfo"), makeCellInfoSEL, selector,  target, title, 0, imageName, 1, 1);
    [hookSectionInfo addCell:cellInfo];
    return hookSectionInfo;
}

- (id)singleSwitchCellSectionWithTitle:(NSString *)title target:(id)target selector:(SEL)selector on:(BOOL)on {
    Class class = objc_getClass("MMTableViewSectionInfo");
    MMTableViewSectionInfo *hookSectionInfo = ((id(*)(id, SEL))objc_msgSend)(class, @selector(sectionInfoDefaut));
    SEL makeCellInfoSEL = @selector(switchCellForSel:target:title:on:isFitIpadClassic:);
    id(*objc_msgSendTyped)(id self, SEL _cmd, SEL normalCellForSel, id target, id title, _Bool on, _Bool isFitIpadClassic) = (void*)objc_msgSend;
    MMTableViewCellInfo *cellInfo = objc_msgSendTyped(objc_getClass("MMTableViewCellInfo"), makeCellInfoSEL, selector, target, title, on, 1);
//    [cellInfo makeSwitchCell:cellInfo];
    [hookSectionInfo addCell:cellInfo];
    return hookSectionInfo;
}

- (id)hookSectionForMoreViewController {
    return [self singleCellSectionWithImageName:@"icon_hook_hammer_small" title:@"Hook" target:self selector:@selector(showHookSettingController:)];
}

- (id)redPackSwitchCellForChatRoomSettingViewController:(id)viewController cellTitle:(NSString *)title {
    // 默认是开启抢红包的
    BOOL on = YES;
    NSMutableDictionary *mDic = [[RSHookDataManager shareInstance].userDefault objectForKey:rsHookRedPackOnDicKey];
    NSString *key = [self redPackKeyForCurrentTopViewController];
    if (!key) {
        NSLog(@"发生了错误");
        return nil;
    }
    if (mDic && [mDic.allKeys containsObject:key]) {
        on = [mDic[key] boolValue];
    }
    id sectionInfo = [self singleSwitchCellSectionWithTitle:title target:self selector:@selector(redPackSwitchChanged:) on:on];
    return sectionInfo;
}

- (void)redPackSwitchChanged:(UISwitch *)sender {
    NSString *key = [self redPackKeyForCurrentTopViewController];
    if (!key) {
        return;
    }
    id mDic = [[RSHookDataManager shareInstance].userDefault objectForKey:rsHookRedPackOnDicKey];
    if (!mDic) {
        mDic = [NSMutableDictionary new];
    }else {
        mDic = [[NSMutableDictionary alloc] initWithDictionary:mDic];
    }
    mDic[key] = [NSNumber numberWithBool:sender.isOn];
    [[RSHookDataManager shareInstance].userDefault setObject:mDic forKey:rsHookRedPackOnDicKey];
    [[RSHookDataManager shareInstance].userDefault synchronize];
}


- (NSString *)redPackKeyForCurrentTopViewController {
    id chatRoomVC = topViewControllerInWeChat;
    BOOL topVCIsChatRoomVC = [NSStringFromClass([chatRoomVC class]) isEqualToString:@"ChatRoomInfoViewController"];
    BOOL topVCIsAddContactVC = [NSStringFromClass([chatRoomVC class]) isEqualToString:@"AddContactToChatRoomViewController"];
    if (!topVCIsChatRoomVC && !topVCIsAddContactVC) {
        return nil;
    }
    
    id m_contact;
    NSString *m_nsUsrName;
    if (topVCIsChatRoomVC) {
        m_contact = [chatRoomVC performSelector:@selector(m_chatRoomContact)];
        m_nsUsrName = [m_contact performSelector:@selector(m_nsUsrName)];
        
    }
    
    if (topVCIsAddContactVC) {
        m_contact = [chatRoomVC performSelector:@selector(m_contact)];
        m_nsUsrName = [m_contact performSelector:@selector(m_nsUsrName)];
    }
    NSString *key = [NSString stringWithFormat:@"%@_%@", rsHookRedPackOnPrefix, m_nsUsrName];
    return key;
}

@end
