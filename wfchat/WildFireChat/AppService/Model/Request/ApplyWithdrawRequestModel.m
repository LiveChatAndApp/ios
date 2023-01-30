#import "ApplyWithdrawRequestModel.h"

@implementation ApplyWithdrawRequestModel

- (NSDictionary *)parameters {
    return @{@"amount": self.amount,
             @"channel": self.channel,
             @"currency": self.currency,
             @"paymentMethodId": self.paymentMethodId,
             @"tradePwd": self.tradePwd};
}

@end
