//
//  RSHookSettingTableViewCell.h
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 13/01/2018.
//  Copyright © 2018 kuangjeon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WechatPrivateClass.h"

typedef void(^RSHookSettingTableViewCellClickBlock)();
@interface RSHookSettingTableViewCell : UITableViewCell
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy)  RSHookSettingTableViewCellClickBlock clickBlock;
- (void)configCell;
@end
