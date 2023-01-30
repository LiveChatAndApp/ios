#import "ChatRoomListModel.h"

#import <WFChatClient/WFCCUtilities.h>

@implementation ChatRoomListModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"roomId": @"id"};
}

- (WFCCChatroomInfo *)WFCCChatroomInfo {
    WFCCChatroomInfo *info = [[WFCCChatroomInfo alloc] init];
    info.chatroomId = self.cid;
    info.title = self.name ? self.name : @"";;
    info.desc = self.desc ? self.desc : @"";
    info.portrait = self.image ? self.image : @"";
    
    info.extra = self.extra ? self.extra : @"";
    info.state = self.status ? self.status.intValue : 0;
    info.memberCount = 0;
    info.createDt = self.createTime ? self.createTime.longLongValue : 0;
    info.updateDt = self.updateTime ? self.updateTime.longLongValue : 0;
    
    return info;
}

- (NSString *)image {
    return [WFCCUtilities replaceDomainWithString:_image];
}

@end
