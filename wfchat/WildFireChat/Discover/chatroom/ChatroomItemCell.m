//
//  ChatroomItemCell.m
//  WildFireChat
//
//  Created by heavyrain lee on 2018/8/24.
//  Copyright © 2018 WildFireChat. All rights reserved.
//

#import "ChatroomItemCell.h"

#import <SDWebImage/SDWebImage.h>

#import "UIColor+YH.h"

@interface ChatroomItemCell ()

@property(nonatomic, strong)UIImageView *portrait;
@property(nonatomic, strong)UILabel *titleLable;

@end

@implementation ChatroomItemCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.portrait.layer.cornerRadius = self.portrait.frame.size.width / 2;
}

- (void)setupUI {
    self.backgroundColor = UIColor.whiteColor;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    self.portrait = [[UIImageView alloc] init];
    self.portrait.layer.masksToBounds = YES;
    [self.contentView addSubview:self.portrait];
    [self.portrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.top.equalTo(self.contentView).offset(12);
        make.bottom.equalTo(self.contentView).offset(-12);
        make.width.equalTo(self.portrait.mas_height);
    }];
    
    self.titleLable = [[UILabel alloc] init];
    self.titleLable.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:self.titleLable];
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portrait.mas_right).offset(10);
        make.top.equalTo(self.contentView).offset(19);
        make.bottom.equalTo(self.contentView).offset(-19);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.mas_equalTo(1);
    }];
}

- (void)setChatroomInfo:(ChatRoomListModel *)chatroomInfo {
    _chatroomInfo = chatroomInfo;
    
    self.titleLable.text = chatroomInfo.name;
    if (chatroomInfo.image) {
        [self.portrait sd_setImageWithURL:[NSURL URLWithString:_chatroomInfo.image] placeholderImage:[UIImage imageNamed:@"GroupChatRound"]];
    } else {
        [self.portrait setImage:[UIImage imageNamed:@"GroupChatRound"]];
    }
}

@end

