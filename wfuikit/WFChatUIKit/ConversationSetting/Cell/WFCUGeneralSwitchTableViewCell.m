//
//  SwitchTableViewCell.m
//  WildFireChat
//
//  Created by heavyrain lee on 27/12/2017.
//  Copyright © 2017 WildFireChat. All rights reserved.
//

#import "WFCUGeneralSwitchTableViewCell.h"

#import "masonry.h"
#import "MBProgressHUD.h"
#import "UIColor+YH.h"

@interface WFCUGeneralSwitchTableViewCell()
@end

@implementation WFCUGeneralSwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.valueSwitch = [[UISwitch alloc] init];
        [self.contentView addSubview:self.valueSwitch];
        [self.valueSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-20);
            make.centerY.equalTo(self.contentView);
        }];
        self.valueSwitch.backgroundColor = [UIColor colorWithHexString:@"0x000000" alpha:0.38];
        self.valueSwitch.onTintColor = [UIColor colorWithHexString:@"0x4970ba"];
        self.valueSwitch.layer.cornerRadius = self.valueSwitch.frame.size.height / 2.0f;
        [self.valueSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)onSwitch:(id)sender {
    BOOL value = _valueSwitch.on;
    __weak typeof(self)ws = self;
    if (self.onSwitch) {
        self.onSwitch(value, self.type, ^(BOOL success) {
            if (success) {
                [ws.valueSwitch setOn:value];
            } else {
                [ws.valueSwitch setOn:!value];
            }
        });
    }
}

- (void)setOn:(BOOL)on {
    _on = on;
    [self.valueSwitch setOn:on];
}
@end
