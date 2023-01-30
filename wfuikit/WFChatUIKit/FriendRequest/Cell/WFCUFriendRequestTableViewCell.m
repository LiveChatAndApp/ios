//
//  FriendRequestTableViewCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/23.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUFriendRequestTableViewCell.h"

#import <SDWebImage/SDWebImage.h>
#import "UIColor+YH.h"
#import "WFCUImage.h"
#import "masonry.h"

@interface WFCUFriendRequestTableViewCell()
@property (nonatomic, strong)UIImageView *portraitView;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UILabel *helloTextLabel;
@end

@implementation WFCUFriendRequestTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.portraitView = [[UIImageView alloc] init];
    self.portraitView.layer.cornerRadius = 20;
    self.portraitView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.portraitView];
    [self.portraitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(40);
        make.left.equalTo(self.contentView).offset(20);
        make.centerY.equalTo(self.contentView);
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portraitView.mas_right).offset(10);
        make.top.equalTo(self.contentView).offset(10);
    }];
    
    self.helloTextLabel = [[UILabel alloc] init];
    self.helloTextLabel.font = [UIFont systemFontOfSize:15];
    self.helloTextLabel.textColor = [UIColor colorWithHexString:@"0xadadad"];
    [self.contentView addSubview:self.helloTextLabel];
    [self.helloTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portraitView.mas_right).offset(10);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
    
    UIButton *acceptBtn = [[UIButton alloc] init];
    acceptBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [acceptBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [acceptBtn setTitle:WFCString(@"Accept") forState:UIControlStateNormal];
    [acceptBtn setTitleColor:[UIColor colorWithHexString:@"0x4970ba"] forState:UIControlStateNormal];
    [acceptBtn addTarget:self action:@selector(onAddBtn:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:acceptBtn];
    [acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.centerY.equalTo(self.contentView);
    }];
    
    UIButton *rejectBtn = [[UIButton alloc] init];
    rejectBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [rejectBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [rejectBtn setTitle:@"拒绝" forState:UIControlStateNormal];
    [rejectBtn setTitleColor:[UIColor colorWithHexString:@"0xadadad"] forState:UIControlStateNormal];
    [rejectBtn addTarget:self action:@selector(onRejectBtn:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:rejectBtn];
    [rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.nameLabel.mas_right).offset(2);
        make.left.greaterThanOrEqualTo(self.helloTextLabel.mas_right).offset(2);
        make.right.equalTo(acceptBtn.mas_left).offset(-15);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)onAddBtn:(id)sender {
    [self.delegate onAcceptBtn:self.friendRequest];
}

- (void)onRejectBtn:(id)sender {
    [self.delegate onRejectBtn:self.friendRequest];
}

- (void)setFriendRequest:(FriendRequest *)friendRequest {
    _friendRequest = friendRequest;
    if (friendRequest.avatar != nil) {
        [self.portraitView sd_setImageWithURL:[NSURL URLWithString:friendRequest.avatar] placeholderImage:[WFCUImage imageNamed:@"PersonalChat"]];
    } else {
        self.portraitView.image = [WFCUImage imageNamed:@"PersonalChat"];
    }
    
    self.nameLabel.text = friendRequest.nickName;
    self.helloTextLabel.text = friendRequest.helloText;
}

@end
