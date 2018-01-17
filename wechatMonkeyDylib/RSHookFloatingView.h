//
//  RSHookSportsView.h
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 25/12/2017.
//  Copyright © 2017 kuangjeon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSHookMainViewController.h"

@interface RSHookFloatingView : UIView
@property (nonatomic, strong) RSHookMainViewController *mainHookVC;
+ (instancetype)shareInstance;
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)gesture;
@end
