//
//  SelectedUserCollectionViewCell.m
//  WFChatUIKit
//
//  Created by Zack Zhang on 2020/4/4.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCUSelectedUserCollectionViewCell.h"
#import <SDWebImage/SDWebImage.h>
#import "WFCUImage.h"

@implementation WFCUSelectedUserCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imgV];
    }
    return self;
}

- (void)setUser:(WFCUSelectedUserInfo *)user {
    [self.imgV sd_setImageWithURL:[NSURL URLWithString:[user.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage: [WFCUImage imageNamed:@"PersonalChat"]];
}

- (void)setIsSmall:(BOOL)isSmall {
    if (isSmall) {
        self.imgV.layer.cornerRadius = 4;
    }
}



- (void)layoutSubviews {
    [super layoutSubviews];
    self.imgV.frame = self.bounds;
}

- (UIImageView *)imgV {
    if (!_imgV) {
        _imgV = [UIImageView new];
        _imgV.layer.cornerRadius = 8;
        _imgV.layer.masksToBounds = YES;
    }
    return _imgV;
}
@end
