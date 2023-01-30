#import <Foundation/Foundation.h>

#import "MJExtension.h"
#import "WithdrawMethodInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WithdrawMethod : NSObject

@property(nonatomic, strong)NSString *createTime;
@property(nonatomic, strong)NSNumber *methodId;
@property(nonatomic, strong)NSString *image;
@property(nonatomic, strong)WithdrawMethodInfoModel *info;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSNumber *paymentMethod;
@property(nonatomic, strong)NSString *updateTime;
@property(nonatomic, strong)NSNumber *userId;

@end

NS_ASSUME_NONNULL_END
