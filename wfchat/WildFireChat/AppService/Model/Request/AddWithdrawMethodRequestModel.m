#import "AddWithdrawMethodRequestModel.h"

@implementation AddWithdrawMethodRequestModel

- (instancetype)init {
    self = [super init];
    
    self.info = [[WithdrawMethodInfoModel alloc] init];
    
    return self;
}

- (NSDictionary *)parameters {
    NSString *infoString = [self.info mj_JSONString];
    
    return @{@"channel": self.channel,
             @"info": infoString,
             @"name": self.customName,
             @"paymentMethodId": self.channel};
}

@end
