//
//  RSHookSettingTableViewCell.m
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 13/01/2018.
//  Copyright © 2018 kuangjeon. All rights reserved.
//

#import "RSHookSettingTableViewCell.h"

@interface RSHookSettingTableViewCell ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *clickButton;
@end

@implementation RSHookSettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.iconView = [UIImageView new];
    [self.contentView addSubview:self.iconView];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.label = [UILabel new];
    [self.contentView addSubview:self.label];
    self.label.textColor = [UIColor blackColor];
    self.label.backgroundColor = [UIColor clearColor];
    
    self.clickButton = [UIButton new];
    self.clickButton.exclusiveTouch = YES;
    [self.contentView addSubview:self.clickButton];
    [self.clickButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configCell {
    self.iconView.image = self.icon;
    self.label.text = self.name;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat margin = 20.f;
    self.iconView.frame = CGRectMake(margin, (self.bounds.size.height - 25) / 2  , 25, 25);
    self.label.frame = CGRectMake(margin + 25 + 15, (self.bounds.size.height - 25) / 2  , 100, 25);
    self.clickButton.frame = self.bounds;
}

- (void)btnClicked:(id)sender {
    if (self.clickBlock) {
        self.clickBlock();
    }
}

@end
