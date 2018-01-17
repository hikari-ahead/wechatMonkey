//
//  RSHookSettingManager.m
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 13/01/2018.
//  Copyright © 2018 kuangjeon. All rights reserved.
//

#import "RSHookSettingManager.h"
#import <objc/runtime.h>
#import "RSHookSettingTableViewCell.h"
#import "RSHookHeader.h"
#import "RSHookFloatingView.h"

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
@end
