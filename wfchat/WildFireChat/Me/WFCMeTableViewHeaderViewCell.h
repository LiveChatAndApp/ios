//
//  MeTableViewCell.h
//  WildFireChat
//
//  Created by WF Chat on 2018/10/2.
//  Copyright © 2018 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFCMeTableViewHeaderViewCell : UITableViewCell

- (void)setUserInfo:(UserInfoModel *)userInfo;

@end

NS_ASSUME_NONNULL_END
