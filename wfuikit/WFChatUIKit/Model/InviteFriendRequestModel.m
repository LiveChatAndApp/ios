#import "InviteFriendRequestModel.h"

@implementation InviteFriendRequestModel

- (NSDictionary *)parameters {
    return @{@"helloText": self.helloText,
             @"uid": self.uid,
             @"verify": self.verify,
             @"verifyText": self.verifyText};
}

@end

