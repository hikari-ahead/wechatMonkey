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
- (id)cellForHookSetting:(id)tableView indexPath:(NSIndexPath *)indexPath;
@end
