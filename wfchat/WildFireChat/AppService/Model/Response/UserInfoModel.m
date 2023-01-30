#import "UserInfoModel.h"

#import <WFChatClient/WFCCUtilities.h>

@implementation UserInfoModel

- (WFCCUserInfo *)WFCCUserInfo {
    WFCCUserInfo *info = [[WFCCUserInfo alloc] init];
    
    info.portrait = self.avatar;
    info.gender = (int)self.gender;
    info.name = self.memberName;
    info.mobile = self.mobile;
    info.displayName = self.nickName;
    info.userId = self.uid;
    
    return info;
}

- (NSString *)genderString {
    if (self.gender == 1) {
        return @"保留";
    } else if (self.gender == 2) {
        return @"男";
    } else if (self.gender == 3) {
        return @"女";
    }
    
    return @"";
}

- (NSString *)avatar {
    return [WFCCUtilities replaceDomainWithString:_avatar];
}

@end
