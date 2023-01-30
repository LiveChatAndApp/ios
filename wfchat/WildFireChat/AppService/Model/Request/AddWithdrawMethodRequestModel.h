#import <Foundation/Foundation.h>

#import "WithdrawMethodInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddWithdrawMethodRequestModel : NSObject

// 收款方式 1=銀行卡
@property(nonatomic, strong)NSNumber *channel;
// 自定義名稱
@property(nonatomic, strong)NSString *customName;
@property(nonatomic, strong)WithdrawMethodInfoModel *info;
// qrcode 圖片
@property(nonatomic, strong)UIImage *image;

- (NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END
