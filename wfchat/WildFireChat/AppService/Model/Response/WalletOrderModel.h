#import <Foundation/Foundation.h>

#import "MJExtension.h"
#import "RechargeChannelModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WalletOrderModel : NSObject

@property(nonatomic, strong)NSString *amount;
// 訂單時間
@property(nonatomic, strong)NSString *createTime;
@property(nonatomic, strong)NSNumber *orderId;
@property(nonatomic, strong)NSString *orderCode;
@property(nonatomic, strong)RechargeChannelModel *rechargeChannel;
// 0 訂單成立 1 待審核 2 已完成 3 已拒絕 4 用戶已取消 5 订单超时
@property(nonatomic, strong)NSNumber *status;
// 1 充值 2 提現
@property(nonatomic, strong)NSNumber *type;

- (NSString *)statusString;
- (UIColor *)statusStringColor;
- (NSString *)typeString;

@end

NS_ASSUME_NONNULL_END
