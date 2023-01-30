#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ApplyWithdrawRequestModel : NSObject

@property(nonatomic, strong)NSNumber *amount;
@property(nonatomic, strong)NSNumber *channel;
@property(nonatomic, strong)NSString *currency;
@property(nonatomic, strong)NSNumber *paymentMethodId;
@property(nonatomic, strong)NSString *tradePwd;

- (NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END
