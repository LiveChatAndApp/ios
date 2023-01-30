#import "NSString+hash.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (hash)

- (NSString *)sha256String {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
 
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
 
    CC_SHA256(data.bytes, (uint32_t)data.length, digest);
 
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
 
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
 
    return output;
}

@end

