#import <Foundation/Foundation.h>

#import "MJExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface WalletInfoModel : NSObject

@property(nonatomic, strong)NSString *balance;
@property(nonatomic, assign)NSInteger canRecharge;
@property(nonatomic, assign)NSInteger canWithdraw;
@property(nonatomic, strong)NSString *currency;
@property(nonatomic, strong)NSString *freeze;

@end

NS_ASSUME_NONNULL_END
