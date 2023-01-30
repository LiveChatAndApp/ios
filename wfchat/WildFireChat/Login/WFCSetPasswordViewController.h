#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WFCSetPasswordViewController : UIViewController
@property(nonatomic, strong)NSString *resetCode;
@property(nonatomic, strong)void(^successBlock)(void);
@end

NS_ASSUME_NONNULL_END
