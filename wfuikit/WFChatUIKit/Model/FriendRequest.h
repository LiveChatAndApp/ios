#import <Foundation/Foundation.h>

#import "MJExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequest : NSObject

@property(nonatomic, strong)NSString *avatar;
@property(nonatomic, strong)NSNumber *gender;
@property(nonatomic, strong)NSString *helloText;
@property(nonatomic, strong)NSString *memberName;
@property(nonatomic, strong)NSString *mobile;
@property(nonatomic, strong)NSString *nickName;
@property(nonatomic, strong)NSString *uid;
@property(nonatomic, strong)NSNumber *verify;

@end
 
NS_ASSUME_NONNULL_END
