#import "ApplyRechargeRequestModel.h"

@implementation ApplyRechargeRequestModel

- (NSDictionary *)parameters {
    return @{@"amount": self.amount,
             @"channelId": @(self.channelId),
             @"currency": self.currency,
             @"method": @(self.method)};
}

@end
