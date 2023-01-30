#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ApplyRechargeRequestModel : NSObject

@property(nonatomic, strong)NSNumber *amount;
@property(nonatomic, assign)NSInteger channelId;
@property(nonatomic, strong)NSString *currency;
@property(nonatomic, assign)NSInteger method;

- (NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END
