#import <UIKit/UIKit.h>

#import "WalletOrderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WithdrawDetailTableViewCell : UITableViewCell

@property(nonatomic, strong)WalletOrderModel *order;
@property(nonatomic, strong)UIButton *confirmButton;

@end

NS_ASSUME_NONNULL_END
