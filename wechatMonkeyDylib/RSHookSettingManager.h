//
//  RSHookSettingManager.h
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 13/01/2018.
//  Copyright © 2018 kuangjeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSHookHeader.h"
#import "WechatPrivateClass.h"
#import <UIKit/UIKit.h>


@interface RSHookSettingManager:NSObject
singleton_interface(RSHookSettingManager);
- (id)singleCellSectionWithImageName:(NSString *)imageName title:(NSString *)title target:(id)target selector:(SEL)selector;
- (id)redPackSwitchCellForChatRoomSettingViewController:(id)viewController cellTitle:(NSString *)title;
/** 进入设置页面 */
- (void)showHookSettingController:(id)sender;
/** 我的页面hook设置入口 */
- (id)hookSectionForMoreViewController;
@end
