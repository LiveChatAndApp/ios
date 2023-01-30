#import <Foundation/Foundation.h>

#import "MJExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface InviteFriendRequestModel : NSObject

@property(nonatomic, strong)NSString *helloText;
@property(nonatomic, strong)NSString *uid;
@property(nonatomic, strong)NSNumber *verify;
@property(nonatomic, strong)NSString *verifyText;

- (NSDictionary *)parameters;

@end

 
NS_ASSUME_NONNULL_END
