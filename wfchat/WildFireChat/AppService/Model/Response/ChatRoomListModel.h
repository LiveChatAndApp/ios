#import <Foundation/Foundation.h>

#import <WFChatClient/WFCCChatroomInfo.h>

#import "MJExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatRoomListModel : NSObject

@property(nonatomic, strong)NSNumber *chatStatus;
@property(nonatomic, strong)NSString *cid;
@property(nonatomic, strong)NSString *createTime;
@property(nonatomic, strong)NSString *desc;
@property(nonatomic, strong)NSString *extra;
@property(nonatomic, strong)NSNumber *roomId;
@property(nonatomic, strong)NSString *image;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSNumber *sort;
@property(nonatomic, strong)NSNumber *status;
@property(nonatomic, strong)NSString *updateTime;

- (WFCCChatroomInfo *)WFCCChatroomInfo;

@end

NS_ASSUME_NONNULL_END
