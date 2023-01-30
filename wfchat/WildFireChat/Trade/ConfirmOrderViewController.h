#import <UIKit/UIKit.h>

#import "RechargeChannelModel.h"

@interface ConfirmOrderViewController : UIViewController

@property(nonatomic, assign)RechargeChannelType rechargeType;
@property(nonatomic, strong)NSString *payee;
@property(nonatomic, strong)NSString *bankName;
@property(nonatomic, strong)NSString *account;
@property(nonatomic, strong)NSString *qrCodeURL;
@property(nonatomic, strong)NSString *orderId;
@property(nonatomic, assign)BOOL backToWallet;

@end
