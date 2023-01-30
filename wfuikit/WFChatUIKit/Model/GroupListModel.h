#import <Foundation/Foundation.h>
#import <WFChatClient/WFCCConversationInfo.h>

#import "MJExtension.h"

@class GroupListData;

NS_ASSUME_NONNULL_BEGIN

@interface GroupListModel : NSObject

@property(nonatomic, strong)NSArray<GroupListData *> *data;
@property(nonatomic, strong)NSNumber *page;
@property(nonatomic, strong)NSNumber *pageSize;
@property(nonatomic, strong)NSNumber *totalElement;
@property(nonatomic, strong)NSNumber *totalPage;

- (NSArray<WFCCConversationInfo *> *)createNoRepeatInfoWithConversationInfos:(NSArray<WFCCConversationInfo *> *)infos;

@end

@interface GroupListData : NSObject

@property(nonatomic, strong)NSString *gid;
@property(nonatomic, strong)NSString *groupName;
@property(nonatomic, strong)NSString *portrait;

- (WFCCConversation *)WFCCConversation;

@end
 
NS_ASSUME_NONNULL_END
