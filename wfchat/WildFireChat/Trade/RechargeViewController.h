#import <UIKit/UIKit.h>

#import "WalletInfoModel.h"

@interface RechargeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property(nonatomic, strong)WalletInfoModel *walletModel;

@end
