#import <Foundation/Foundation.h>

#import "MJExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface WithdrawMethodInfoModel : NSObject

// 卡號
@property(nonatomic, strong)NSString *bankCardNumber;
// 收款人
@property(nonatomic, strong)NSString *name;
// 銀行名稱
@property(nonatomic, strong)NSString *bankName;

@end

NS_ASSUME_NONNULL_END
