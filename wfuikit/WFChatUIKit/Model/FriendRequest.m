#import "FriendRequest.h"

#import <WFChatClient/WFCCUtilities.h>

@implementation FriendRequest

- (NSString *)avatar {
    return [WFCCUtilities replaceDomainWithString:_avatar];
}

@end
