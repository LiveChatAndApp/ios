#import <UIKit/UIKit.h>

#import "WithdrawMethod.h"

NS_ASSUME_NONNULL_BEGIN

@interface WithdrawMethodTableViewCell : UITableViewCell

@property(nonatomic, strong)WithdrawMethod *withdrawMethod;
@property(nonatomic, strong)UIButton *deleteButton;

@end

NS_ASSUME_NONNULL_END
