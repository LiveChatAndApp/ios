//
//  GroupTableViewCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/13.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUGroupTableViewCell.h"

#import <SDWebImage/SDWebImage.h>
#import <WFChatUIKit/WFCUUtilities.h>

#import "UIFont+YH.h"
#import "UIColor+YH.h"
#import "WFCUImage.h"

@interface WFCUGroupTableViewCell()
@property (strong, nonatomic) UIImageView *portrait;
@property (strong, nonatomic) UILabel *name;

@end

@implementation WFCUGroupTableViewCell
- (void)layoutSubviews {
    [super layoutSubviews];
    _portrait.frame = CGRectMake(20, (self.frame.size.height - 40) / 2.0, 40, 40);
    _name.frame = CGRectMake(20 + 40 + 10, (self.frame.size.height - 17) / 2.0, [UIScreen mainScreen].bounds.size.width - (20 + 40 + 10 + 10), 17);
}

- (UIImageView *)portrait {
    if (!_portrait) {
        _portrait = [UIImageView new];
        _portrait.layer.cornerRadius = 20.0f;
        _portrait.layer.masksToBounds = YES;
        [self.contentView addSubview:_portrait];
    }
    return _portrait;
}

- (UILabel *)name {
    if (!_name) {
        _name = [UILabel new];
        _name.textColor = [UIColor colorWithHexString:@"0x1d1d1d"];
        _name.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:17];
        [self.contentView addSubview:_name];
    }
    return _name;
}

- (void)setGroupInfo:(WFCCGroupInfo *)groupInfo {
    _groupInfo = groupInfo;
    if (groupInfo.displayName.length == 0) {
        self.name.text = WFCString(@"GroupChat");
    } else {
        self.name.text = groupInfo.displayName;
        [self layoutIfNeeded];
        [WFCUUtilities addAndTruncateStringWithLabel:self.name resevedString:[NSString stringWithFormat:@"(%ld)", groupInfo.memberCount]];
    }
    [self.portrait sd_setImageWithURL:[NSURL URLWithString:[groupInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[WFCUImage imageNamed:@"group_default_portrait"]];
    
    if (groupInfo.portrait.length) {
        [self.portrait sd_setImageWithURL:[NSURL URLWithString:[groupInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[WFCUImage imageNamed:@"group_default_portrait"]];
    } else {
        __weak typeof(self)ws = self;
        NSString *groupId = groupInfo.target;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"GroupPortraitChanged" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            NSString *path = [note.userInfo objectForKey:@"path"];
            if ([ws.groupInfo.target isEqualToString:groupId] && [groupId isEqualToString:note.object]) {
                [ws.portrait sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[WFCUImage imageNamed:@"group_default_portrait"]];
            }
        }];
        [self.portrait setImage:[WFCUImage imageNamed:@"group_default_portrait"]];
        
        
        NSString *path = [WFCCUtilities getGroupGridPortrait:groupInfo.target width:80 generateIfNotExist:YES defaultUserPortrait:^UIImage *(NSString *userId) {
            return [WFCUImage imageNamed:@"PersonalChat"];
        }];
        
        if (path) {
            [self.portrait sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[WFCUImage imageNamed:@"group_default_portrait"]];
            [self.portrait setImage:[UIImage imageWithContentsOfFile:path]];
        }
    }
}

@end
