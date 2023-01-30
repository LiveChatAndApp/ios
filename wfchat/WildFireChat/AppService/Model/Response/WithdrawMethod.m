#import "WithdrawMethod.h"

#import <WFChatClient/WFCCUtilities.h>

@implementation WithdrawMethod

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"methodId":@"id"};
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"info": WithdrawMethodInfoModel.class};
}

- (NSString *)image {
    return [WFCCUtilities replaceDomainWithString:_image];
}

@end
