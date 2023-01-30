#import "ApplyRechargeModel.h"

#import <WFChatClient/WFCCUtilities.h>

@implementation ApplyRechargeModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"orderId": @"id"};
}

- (NSString *)payImage {
    return [WFCCUtilities replaceDomainWithString:_payImage];
}

@end
