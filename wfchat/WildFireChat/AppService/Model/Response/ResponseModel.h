#import <Foundation/Foundation.h>

#import "MJExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface ResponseModel : NSObject

@property(nonatomic, strong)NSNumber *code;
@property(nonatomic, strong)id result;
@property(nonatomic, strong)NSString *message;

@end

NS_ASSUME_NONNULL_END
