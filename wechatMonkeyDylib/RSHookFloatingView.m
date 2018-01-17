//
//  RSHookSportsView.m
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 25/12/2017.
//  Copyright © 2017 kuangjeon. All rights reserved.
//

#import "RSHookFloatingView.h"

static RSHookFloatingView *instance;

@interface RSHookFloatingView()
@property (nonatomic, strong) UIButton *btnIcon;
@end

@implementation RSHookFloatingView
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[RSHookFloatingView alloc] initWithFrame:CGRectZero];
        }
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup {
    self.frame = CGRectMake(0, 0, 60, 60);
    self.backgroundColor = [UIColor clearColor];
    
    
    _btnIcon = [UIButton new];
    [_btnIcon.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_btnIcon setImage:[UIImage imageNamed:@"icon_hook_pocket"] forState:UIControlStateNormal];
    [self addSubview:_btnIcon];
    [_btnIcon addTarget:self action:@selector(btnIconClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _btnIcon.frame = self.bounds;
}

#pragma mark - Action
- (void)btnIconClicked {
    if (!self.mainHookVC) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        _mainHookVC = [storyBoard instantiateViewControllerWithIdentifier:@"RSHookMainViewController"];
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.mainHookVC animated:YES completion:NULL];
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    if (!CGRectContainsPoint(self.bounds, point) && gesture.state == UIGestureRecognizerStateBegan) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        // 移动操作
        CGPoint translation = [gesture translationInView:self.superview];
        CGPoint newCenter  = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        // 确保中心不越界
        newCenter.x = (newCenter.x >= 0) ? newCenter.x : 0;
        newCenter.y = (newCenter.y >= 0) ? newCenter.y : 0;
        
        CGFloat maxX = (self.superview.bounds.size.width);
        CGFloat maxY = (self.superview.bounds.size.height);
        newCenter.x = (newCenter.x <= maxX) ? newCenter.x : maxX;
        newCenter.y = (newCenter.y <= maxY) ? newCenter.y : maxY;
        
        self.center = newCenter;
        [gesture setTranslation:CGPointZero inView:self.superview];
    }
}


@end
