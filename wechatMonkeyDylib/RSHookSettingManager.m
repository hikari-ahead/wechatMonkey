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

@implementation RSHookSettingManager
singleton_implementation(RSHookSettingManager)

- (id)cellForHookSetting:(id)tableView indexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = NSStringFromClass([RSHookSettingTableViewCell class]);
    [tableView registerClass:[RSHookSettingTableViewCell class] forCellReuseIdentifier:reuseId];
    RSHookSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    if (!cell) {
        // 需要创建一个自定义的cell
        cell = [[RSHookSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseId];
    }
    
    [cell setClickBlock:^{
        [self showHookSettingController];
    }];
    cell.icon = [UIImage imageNamed:@"icon_hook_pocket"];
    cell.name = @"hook";
    [cell configCell];
    cell.backgroundColor = [UIColor whiteColor];
    cell.frame = CGRectMake(CGRectGetMinX(cell.frame), CGRectGetMinY(cell.frame), CGRectGetWidth(cell.frame), 44.f);
    ((UITableView *)tableView).rowHeight = UITableViewAutomaticDimension;
    return cell;
}

- (void)showHookSettingController {
    NSLog(@"Tappppppppped!!");
}
@end
