#import "GroupListModel.h"

#import <WFChatClient/WFCCUtilities.h>

@implementation GroupListModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"data": GroupListData.class};
}

- (NSArray<GroupListData *> *)filterRepeatGroup:(NSArray *)conversations {
    NSMutableArray<GroupListData *> *array = [[NSMutableArray alloc] init];
    
    for (GroupListData *group in self.data) {
        BOOL exist = NO;
        for (WFCCConversationInfo *info in conversations) {
            if ([group.gid isEqualToString:info.conversation.target]) {
                exist = YES;
            }
        }
        
        if (!exist) {
            [array addObject:group];
        }
    }
    
    return array;
}

- (NSArray<WFCCConversationInfo *> *)createNoRepeatInfoWithConversationInfos:(NSArray<WFCCConversationInfo *> *)infos {
    NSArray<GroupListData *> *datas = [self filterRepeatGroup:infos];
    NSMutableArray<WFCCConversationInfo *> *noRepeatInfos = [[NSMutableArray alloc] init];
    
    for (GroupListData *data in datas) {
        WFCCConversationInfo *info = [[WFCCConversationInfo alloc] init];
        WFCCConversation *conversation = [WFCCConversation conversationWithType:Group_Type target:data.gid line:0];
        info.conversation = conversation;
        info.lastMessage = nil;
        info.draft = @"";
        info.timestamp = [[NSDate date] timeIntervalSinceNow];
        info.isTop = NO;
        info.isSilent = NO;
        [noRepeatInfos addObject:info];
    }
    
    return noRepeatInfos;
}

@end

@implementation GroupListData

- (NSString *)portrait {
    return [WFCCUtilities replaceDomainWithString:_portrait];
}

- (WFCCConversation *)WFCCConversation {
    return [WFCCConversation conversationWithType:Group_Type target:self.gid line:0];
}

@end
