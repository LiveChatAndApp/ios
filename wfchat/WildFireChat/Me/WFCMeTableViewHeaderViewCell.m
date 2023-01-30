//
//  MeTableViewCell.m
//  WildFireChat
//
//  Created by WF Chat on 2018/10/2.
//  Copyright © 2018 WildFireChat. All rights reserved.
//

#import "WFCMeTableViewHeaderViewCell.h"
#import <SDWebImage/SDWebImage.h>
#import "UIFont+YH.h"
#import "UIColor+YH.h"
#import <WFChatUIKit/WFChatUIKit.h>

@interface WFCMeTableViewHeaderViewCell () <SDPhotoBrowserDelegate>
@property (strong, nonatomic) UIImageView *portrait;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *genderLabel;
@property (strong, nonatomic) UILabel *userName;
@end

@implementation WFCMeTableViewHeaderViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    [self setupUI];
    self.contentView.layer.cornerRadius = 12;
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"0xF6F6F6"];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    self.portrait.layer.cornerRadius = self.portrait.frame.size.height / 2;
}

- (void)setupUI {
    self.portrait = [[UIImageView alloc] init];
    self.portrait.layer.masksToBounds = YES;
    self.portrait.userInteractionEnabled = YES;
    [self.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage)]];
    [self.contentView addSubview:self.portrait];
    [self.portrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(14);
        make.top.equalTo(self.contentView).offset(10);
        make.bottom.equalTo(self.contentView).offset(-10);
        make.height.equalTo(self.portrait.mas_width);
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_edit"]];
    [self.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.equalTo(imageView.mas_width);
        make.height.mas_equalTo(17);
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portrait.mas_right).offset(10);
        make.top.equalTo(self.contentView).offset(25);
        make.right.equalTo(imageView.mas_left).offset(-5);
    }];
    
    self.genderLabel = [[UILabel alloc] init];
    self.genderLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:self.genderLabel];
    [self.genderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portrait.mas_right).offset(10);
        make.bottom.equalTo(self.contentView).offset(-25);
    }];
}

- (void)setUserInfo:(UserInfoModel *)userInfo {
    [self.portrait sd_setImageWithURL:[NSURL URLWithString:userInfo.avatar] placeholderImage: [UIImage imageNamed:@"PersonalChat"]];
    self.nameLabel.text = [NSString stringWithFormat:@"账号：%@", userInfo.memberName];
    self.genderLabel.text = [NSString stringWithFormat:@"性别：%@", userInfo.genderString];
}

- (void)showImage {
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = self.portrait;
    browser.imageCount = 1;
    browser.currentImageIndex = 0;
    browser.delegate = self;
    [browser show];
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    return self.portrait.image;
}

@end
