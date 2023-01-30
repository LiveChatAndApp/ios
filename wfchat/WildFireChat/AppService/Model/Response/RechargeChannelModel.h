#import <Foundation/Foundation.h>

#import "MJExtension.h"

@class BankInfo;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RechargeChannelType)
{
    RechargeChannelTypeCard = 1,
    RechargeChannelTypeWeixin = 2,
    RechargeChannelTypeAlipay = 3
};

@interface RechargeChannelModel : NSObject

@property(nonatomic, assign)NSInteger channelId;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, assign)NSInteger paymentMethod;
@property(nonatomic, strong)BankInfo *info;
@property(nonatomic, assign)NSInteger status;
@property(nonatomic, strong)NSString *memo;
@property(nonatomic, strong)NSString *createTime;
@property(nonatomic, strong)NSString *updateTime;

@end

@interface BankInfo : NSObject

@property(nonatomic, strong)NSString *realName;
@property(nonatomic, strong)NSString *bankName;
@property(nonatomic, strong)NSString *bankAccount;
@property(nonatomic, strong)NSString *qrCodeImage;

@end

NS_ASSUME_NONNULL_END
