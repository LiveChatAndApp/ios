#import "RechargeChannelModel.h"

#import <WFChatClient/WFCCUtilities.h>

@implementation RechargeChannelModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"channelId": @"id"};
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"info": BankInfo.class};
}

@end

@implementation BankInfo

- (NSString *)qrCodeImage {
    return [WFCCUtilities replaceDomainWithString:_qrCodeImage];
}

@end

