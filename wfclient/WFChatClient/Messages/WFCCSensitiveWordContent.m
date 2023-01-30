#import "WFCCSensitiveWordContent.h"

#import "Common.h"
#import "WFCCIMService.h"

@implementation WFCCSensitiveWordContent
- (WFCCMessagePayload *)encode {
    return [super encode];
}

- (void)decode:(WFCCMessagePayload *)payload {
    [super decode:payload];
    self.text = payload.searchableContent;
    self.mentionedType = payload.mentionedType;
    self.mentionedTargets = payload.mentionedTargets;
    if (payload.binaryContent.length) {
        NSError *__error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:payload.binaryContent
                                                                   options:kNilOptions
                                                                     error:&__error];
        if (!__error) {
            NSDictionary *quoteDict = dictionary[@"quote"];
            if (quoteDict) {
                self.quoteInfo = [[WFCCQuoteInfo alloc] init];
                [self.quoteInfo decode:quoteDict];
            }
        }
    }
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_SENSITIVE_WORD;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST;
}

+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest:(WFCCMessage *)message {
    return [self formatNotification:message];
}

- (NSString *)formatNotification:(WFCCMessage *)message {
    if (message.direction == MessageDirection_Receive) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:message.fromUser refresh:NO];
        return [NSString stringWithFormat:@"%@发送包含敏感词的内容。", userInfo.displayName];
    } else {
        return @"您发送包含敏感词的内容。";
    }
}
@end
