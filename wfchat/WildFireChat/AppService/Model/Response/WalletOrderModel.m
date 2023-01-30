#import "WalletOrderModel.h"

#import "UIColor+YH.h"

@implementation WalletOrderModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"orderId":@"id"};
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"rechargeChannel": RechargeChannelModel.class};
}

- (NSString *)statusString {
    switch (self.status.intValue) {
        case 0:
            return @"订单成立";
        case 1:
            return @"待审核";
        case 2:
            return @"已完成";
        case 3:
            return @"已拒绝";
        case 4:
            return @"用户已取消";
        case 5:
            return @"订单超时";
        default:
            return @"未知";
            break;
    }
}

- (UIColor *)statusStringColor {
    switch (self.status.intValue) {
        case 0:
        case 1:
            return [UIColor colorWithHexString:@"0x4970BA"];
        case 2:
            return [UIColor colorWithHexString:@"0x02DAA8"];
        case 3:
        case 4:
            return [UIColor colorWithHexString:@"0xadadad"];
        case 5:
            return [UIColor colorWithHexString:@"0xF85151"];
        default:
            return [UIColor colorWithHexString:@"0xadadad"];
            break;
    }
}

- (NSString *)typeString {
    switch (self.type.intValue) {
        case 1:
            return @"充值";
        case 2:
            return @"提现";
        default:
            return @"未知";
            break;
    }
}

@end
