//
//  ConversationSettingMemberCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/11/3.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUConversationSettingMemberCell.h"
#import <SDWebImage/SDWebImage.h>
#import <WFChatClient/WFCChatClient.h>
#import "WFCUConfigManager.h"
#import "UIFont+YH.h"
#import "UIColor+YH.h"
#import "WFCUImage.h"
#import "masonry.h"

@interface WFCUConversationSettingMemberCell ()
@property(nonatomic, strong)NSObject *model;
@property(nonatomic, strong)UIView *cellView;
@end

@implementation WFCUConversationSettingMemberCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.whiteColor;
        [self setupUI];
        self.isfunctionCell = NO;
    }
    return self;
}

- (void)setupUI {
    UIView *view = [[UIView alloc] init];
    self.cellView = view;
    [self.contentView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.equalTo(self.contentView);
    }];
    
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.headerImageView.autoresizingMask =
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImageView.clipsToBounds = YES;
    self.headerImageView.layer.cornerRadius = 8;
    self.headerImageView.backgroundColor = [UIColor clearColor];
    self.headerImageView.layer.edgeAntialiasingMask =
    kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge |
    kCALayerTopEdge;
    [view addSubview:self.headerImageView];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:13];
    [view addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerImageView.mas_bottom).offset(4);
        make.left.bottom.right.equalTo(view);
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.isfunctionCell = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.headerImageView layoutIfNeeded];
    self.headerImageView.layer.cornerRadius = self.headerImageView.frame.size.width / 2;
    
}

//- (UILabel *)nameLabel {
//    if (!_nameLabel) {
//        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        _nameLabel.textAlignment = NSTextAlignmentCenter;
//        _nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:13];
//        _nameLabel.textAlignment = NSTextAlignmentCenter;
//        [[self contentView] addSubview:_nameLabel];
//    }
//    return _nameLabel;
//}
//
//- (UIImageView *)headerImageView {
//    if (!_headerImageView) {
//        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        _headerImageView.autoresizingMask =
//        UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
//        _headerImageView.clipsToBounds = YES;
//
//        _headerImageView.layer.borderWidth = 1;
//        _headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
//        _headerImageView.layer.cornerRadius = 8;
//        _headerImageView.layer.masksToBounds = YES;
//        _headerImageView.backgroundColor = [UIColor clearColor];
//        _headerImageView.layer.edgeAntialiasingMask =
//        kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge |
//        kCALayerTopEdge;
//        [[self contentView] addSubview:_headerImageView];
//    }
//    return _headerImageView;
//}

- (void)setIsfunctionCell:(BOOL)functionCell {
    _isfunctionCell = functionCell;
    
    [self.headerImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.equalTo(self.cellView);
        make.height.equalTo(self.headerImageView.mas_width);
        if (self.isfunctionCell) {
            make.width.equalTo(self.cellView).multipliedBy(0.61);
        } else {
            make.width.equalTo(self.cellView).multipliedBy(0.81);
        }
    }];
}

- (void)setModel:(NSObject *)model withType:(WFCCConversationType)type {
//    self.nameLabel.textColor = [WFCUConfigManager globalManager].textColor;
    
    self.model = model;
    
    WFCCUserInfo *userInfo;
    WFCCGroupMember *groupMember;
    WFCCChannelInfo *channelInfo;
    if (type == Group_Type) {
        groupMember = (WFCCGroupMember *)model;
        userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:groupMember.memberId inGroup:groupMember.groupId refresh:NO];
    } else if(type == Single_Type) {
        userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:(NSString *)model refresh:NO];
    } else if(type == Channel_Type) {
        channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:(NSString *)model refresh:NO];
    } else if(type == SecretChat_Type) {
        NSString *userId = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:(NSString *)model].userId;
        userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userId refresh:NO];
    } else {
        return;
    }
    
    if (type == Channel_Type) {
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[channelInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[WFCUImage imageNamed:@"PersonalChat"]];
        self.nameLabel.text = channelInfo.name;
    } else {
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[WFCUImage imageNamed:@"PersonalChat"]];
        
        if (userInfo.friendAlias.length) {
            self.nameLabel.text = userInfo.friendAlias;
        } else if(userInfo.groupAlias.length) {
            self.nameLabel.text = userInfo.groupAlias;
        } else if(userInfo.displayName.length) {
            self.nameLabel.text = userInfo.displayName;
        } else {
            self.nameLabel.text = nil;
        }
    }
    self.nameLabel.hidden = NO;
}

- (void)resetLayout:(CGFloat)nameLabelHeight
       insideMargin:(CGFloat)insideMargin {
}
@end
