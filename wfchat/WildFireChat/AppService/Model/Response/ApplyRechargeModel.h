#import <Foundation/Foundation.h>

#import "MJExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface ApplyRechargeModel : NSObject

@property(nonatomic, strong)NSNumber *amount;
@property(nonatomic, assign)NSInteger channelId;
@property(nonatomic, strong)NSString *completeTime;
@property(nonatomic, strong)NSString *createTime;
@property(nonatomic, strong)NSString *currency;
@property(nonatomic, strong)NSNumber *orderId;
@property(nonatomic, assign)NSInteger method;
@property(nonatomic, strong)NSString *orderCode;
@property(nonatomic, strong)NSString *payImage;
@property(nonatomic, assign)NSInteger status;
@property(nonatomic, strong)NSString *updateTime;
@property(nonatomic, strong)NSString *updaterId;
@property(nonatomic, assign)NSInteger updaterRole;
@property(nonatomic, assign)NSInteger userId;

@end

NS_ASSUME_NONNULL_END
