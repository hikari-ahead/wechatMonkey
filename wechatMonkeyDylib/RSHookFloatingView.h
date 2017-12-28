//
//  RSHookSportsView.h
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 25/12/2017.
//  Copyright © 2017 kuangjeon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSHookFloatingView : UIView
+ (instancetype)shareInstance;
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)gesture;
@end
