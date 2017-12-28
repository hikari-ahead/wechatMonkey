//
//  RSHookMainViewController.m
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 25/12/2017.
//  Copyright © 2017 kuangjeon. All rights reserved.
//

#import "RSHookMainViewController.h"
#import "RSHookDataManager.h"

@interface RSHookMainViewController ()<UITextFieldDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *tvSportCount;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *swSport;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *swRecall;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *swRedPacket;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnDismiss;
@property (nonatomic, assign) UIStatusBarStyle oldStatusBarStyle;
@end

@implementation RSHookMainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // do something u wanna do..
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restoreUIFromPersistence];
    [self commonSetup];
    self.oldStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)commonSetup {
    [_btnDismiss addTarget:self action:@selector(btnDismissClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _tvSportCount.keyboardType = UIKeyboardTypeNumberPad;
    _tvSportCount.delegate = self;
    
    _swSport.tag = 1;
    [_swSport addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    _swRecall.tag = 2;
    [_swRecall addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    _swRedPacket.tag = 3;
    [_swRedPacket addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)restoreUIFromPersistence {
    [RSHookDataManager.shareInstance getFlagsFromPersistence];
    self.swSport.on = RSHookDataManager.shareInstance.sportsHookOn;
    self.swRecall.on = RSHookDataManager.shareInstance.recallHookOn;
    self.swRedPacket.on = RSHookDataManager.shareInstance.redPacketHookOn;
    self.tvSportCount.text = [NSString stringWithFormat:@"%u",RSHookDataManager.shareInstance.footCount];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    RSHookDataManager.shareInstance.footCount = self.tvSportCount.text.intValue;
}

#pragma mark - Action
- (void)switchValueChanged:(UISwitch *)sender {
    switch (sender.tag) {
        case 1:
            RSHookDataManager.shareInstance.sportsHookOn = sender.isOn;
            break;
        case 2:
            RSHookDataManager.shareInstance.recallHookOn = sender.isOn;
            break;
        case 3:
            RSHookDataManager.shareInstance.redPacketHookOn = sender.isOn;
            break;
    }
    
}

- (void)btnDismissClicked {
    __weak typeof(self) weakSelf = self;
    [self.view endEditing:YES];
    RSHookDataManager.shareInstance.footCount = self.tvSportCount.text.intValue;
    [RSHookDataManager.shareInstance setFlagsToPersistence];
    [self dismissViewControllerAnimated:YES completion:^{
        __strong typeof(self) strongSelf = weakSelf;
        UIApplication.sharedApplication.statusBarStyle = _oldStatusBarStyle;
        [strongSelf setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:NO];
}
@end
