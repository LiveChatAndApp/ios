#import <UIKit/UIKit.h>

#import "WalletInfoModel.h"

@interface WithdrawViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property(nonatomic, strong)WalletInfoModel *walletModel;

@end
