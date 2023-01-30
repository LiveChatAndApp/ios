#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "WFCCIMService.h"

NS_ASSUME_NONNULL_BEGIN

@interface UpdateProfileModel : NSObject

@property(nonatomic, readonly)NSString *flagString;
@property(nonatomic, strong)NSString *nickName;
@property(nonatomic, strong)UIImage *avatar;
@property(nonatomic, assign)NSInteger gender;
@property(nonatomic, readonly)NSDictionary *parameters;

- (void)setValue:(id)value type:(ModifyMyInfoType)type;
- (NSString *)genderString;

@end

NS_ASSUME_NONNULL_END
