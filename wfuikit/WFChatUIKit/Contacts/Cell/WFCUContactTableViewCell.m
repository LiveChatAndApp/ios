//
//  ContactTableViewCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUContactTableViewCell.h"
#import <WFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>
#import "UIColor+YH.h"
#import "UIFont+YH.h"
#import "WFCUConfigManager.h"
#import "WFCUImage.h"
#import "masonry.h"

@interface WFCUContactTableViewCell ()
@property (nonatomic, strong)WFCCUserInfo *userInfo;
@property (nonatomic, strong)NSString *userId;
@property (nonatomic, strong)NSString *groupId;
@end

@implementation WFCUContactTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isSquare = NO;
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI {
    self.portraitView = [[UIImageView alloc] init];
    self.portraitView.layer.masksToBounds = YES;
    self.portraitView.layer.cornerRadius = 20;
    [self.contentView addSubview:self.portraitView];
    [self.portraitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(21);
        make.centerY.equalTo(self.contentView);
        make.height.width.mas_equalTo(40);
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portraitView.mas_right).offset(10);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
    }];
}

- (void)onUserInfoUpdated:(NSNotification *)notification {
    WFCCUserInfo *userInfo = notification.userInfo[@"userInfo"];
    if ([self.userId isEqualToString:userInfo.userId]) {
        [self updateUserInfo:userInfo];
    }
}

- (void)setUserId:(NSString *)userId groupId:(NSString *)groupId {
    _userId = userId;
    _groupId = groupId;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOnlineState) name:kUserOnlineStateUpdated object:nil];
    
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userId inGroup:groupId refresh:NO];
    if(userInfo.userId.length == 0) {
        userInfo = [[WFCCUserInfo alloc] init];
        userInfo.userId = userId;
    }
    [self updateUserInfo:userInfo];
}

- (void)updateOnlineState {
    [self updateUserInfo:_userInfo];
}

- (void)updateUserInfo:(WFCCUserInfo *)userInfo {
    if(!userInfo) {
        return;
    }
    _userInfo = userInfo;
    
    [self.portraitView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage: [WFCUImage imageNamed:@"PersonalChat"]];
    
    if (userInfo.friendAlias.length) {
        self.nameLabel.text = userInfo.friendAlias;
    } else if (userInfo.groupAlias.length) {
        self.nameLabel.text = userInfo.groupAlias;
    } else if(userInfo.displayName.length > 0) {
        self.nameLabel.text = userInfo.displayName;
    } else {
        self.nameLabel.text = [NSString stringWithFormat:@"user<%@>", userInfo.userId];
    }
    
    if ([[WFCCIMService sharedWFCIMService] isEnableUserOnlineState]) {
        WFCCUserOnlineState *state = [[WFCCIMService sharedWFCIMService] getUserOnlineState:self.userId];
        BOOL online = NO;
        BOOL hasMobileSession = NO;
        long long mobileLastSeen = 0;
        if(state.clientStates.count) { //有设备在线
            if(state.customState.state != 4) { //没有设置为隐身
                for (WFCCClientState *cs in state.clientStates) {
                    if(cs.state == 0) {
                        online = YES;
                        break;
                    }
                    if(cs.state == 1 && (cs.platform == 1 || cs.platform == 2)) {
                        hasMobileSession = YES;
                        if(mobileLastSeen < cs.lastSeen) {
                            mobileLastSeen = cs.lastSeen;
                        }
                    }
                }
            }
        }

        if(!online && hasMobileSession && mobileLastSeen > 0) {
            NSString *strSeenTime = nil;
            long long duration = [[[NSDate alloc] init] timeIntervalSince1970] - (mobileLastSeen/1000);
            int days = (int)(duration / 86400);
            if(days) {
                strSeenTime = [NSString stringWithFormat:@"%d天前", days];
            } else {
                int hours = (int)(duration/3600);
                if(hours) {
                    strSeenTime = [NSString stringWithFormat:@"%d时前", hours];
                } else {
                    int mins = (int)(duration/60);
                    if(mins) {
                        strSeenTime = [NSString stringWithFormat:@"%d分前", mins];
                    } else {
                        strSeenTime = [NSString stringWithFormat:@"不久前"];
                    }
                }
            }
            self.nameLabel.text = [NSString stringWithFormat:@"%@(%@)", self.nameLabel.text, strSeenTime];
        }
    }
}

- (void)setIsSquare:(BOOL)isSquare {
    _isSquare = isSquare;
    
    if (isSquare) {
        self.portraitView.layer.cornerRadius = 4;
    } else {
        self.portraitView.layer.cornerRadius = 20;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
