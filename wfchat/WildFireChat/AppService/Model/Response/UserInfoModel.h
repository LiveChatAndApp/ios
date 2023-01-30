#import <Foundation/Foundation.h>

#import <WFChatClient/WFCCUserInfo.h>

#import "MJExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserInfoModel : NSObject

@property(nonatomic, strong)NSString *avatar;
@property(nonatomic, strong)NSString *balance;
@property(nonatomic, assign)NSInteger gender;
@property(nonatomic, assign)NSInteger hasTradePwd;
@property(nonatomic, strong)NSString *memberName;
@property(nonatomic, strong)NSString *mobile;
@property(nonatomic, strong)NSString *nickName;
@property(nonatomic, strong)NSString *uid;
// 0不可創建群聊。1可創建群聊
@property(nonatomic, strong)NSNumber *createGroupEnable;

- (NSString *)genderString;
- (WFCCUserInfo *)WFCCUserInfo;

@end

NS_ASSUME_NONNULL_END
