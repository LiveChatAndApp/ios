#import "WalletViewController.h"

#import "AppService.h"
#import "UIColor+YH.h"
#import "RechargeViewController.h"
#import "MBProgressHUD.h"
#import "NewTradePasswordViewController.h"
#import "WithdrawViewController.h"
#import "WalletDetailViewController.h"

@interface WalletViewController ()

@property(nonatomic, strong)WalletInfoModel *walletModel;
@property(nonatomic, strong)UILabel *balanceLabel;
@end

@implementation WalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getWalletInfo];
}

- (void)setup {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"我的钱包";
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    }
    
    UIButton *detailButton = [[UIButton alloc] init];
    [detailButton setTitle:@"明细" forState:UIControlStateNormal];
    [detailButton setTitleColor:[UIColor colorWithHexString:@"0x4970BA"] forState:UIControlStateNormal];
    detailButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [detailButton addTarget:self action:@selector(goToDetailVC) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:detailButton];
    
    UIView *backgroudView = [[UIView alloc] init];
    backgroudView.backgroundColor = UIColor.whiteColor;
    backgroudView.layer.cornerRadius = 12;
    [self.view addSubview:backgroudView];
    [backgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(16);
    }];
    
    UILabel *walletLabel = [[UILabel alloc] init];
    walletLabel.text = @"钱包总额";
    walletLabel.font = [UIFont boldSystemFontOfSize:18];
    [backgroudView addSubview:walletLabel];
    [walletLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backgroudView).offset(16);
        make.top.equalTo(backgroudView).offset(12);
    }];
    
    self.balanceLabel = [[UILabel alloc] init];
    self.balanceLabel.text = self.walletModel.balance;
    self.balanceLabel.font = [UIFont systemFontOfSize:38];
    self.balanceLabel.textColor = [UIColor colorWithHexString:@"0x4970BA"];
    [backgroudView addSubview:self.balanceLabel];
    [self.balanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(walletLabel.mas_bottom).offset(44);
        make.left.equalTo(backgroudView).offset(24);
    }];
    
    UIButton *withdrawButton = [[UIButton alloc] init];
    [withdrawButton setTitle:@"提现" forState:normal];
    [withdrawButton setTitleColor:[UIColor colorWithHexString:@"0x4970ba"] forState:normal];
    [withdrawButton addTarget:self action:@selector(goToWithdrawVC) forControlEvents:UIControlEventTouchDown];
    withdrawButton.clipsToBounds = YES;
    withdrawButton.layer.cornerRadius = 5;
    withdrawButton.layer.borderColor = [UIColor colorWithHexString:@"0x4970ba"].CGColor;
    withdrawButton.layer.borderWidth = 1;
    withdrawButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [backgroudView addSubview:withdrawButton];
    [withdrawButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backgroudView).offset(16);
        make.top.equalTo(self.balanceLabel.mas_bottom).offset(24);
        make.bottom.equalTo(backgroudView).offset(-16);
        make.height.mas_equalTo(35);
    }];
    
    UIButton *rechargeButton = [[UIButton alloc] init];
    [rechargeButton setTitle:@"充值" forState:normal];
    [rechargeButton addTarget:self action:@selector(goToRechargeVC) forControlEvents:UIControlEventTouchDown];
    [rechargeButton setTitleColor:UIColor.whiteColor forState:normal];
    rechargeButton.backgroundColor = [UIColor colorWithHexString:@"0x4970ba"];
    rechargeButton.clipsToBounds = YES;
    rechargeButton.layer.cornerRadius = 5;
    rechargeButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [backgroudView addSubview:rechargeButton];
    [rechargeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(withdrawButton.mas_right).offset(8);
        make.right.equalTo(backgroudView).offset(-16);
        make.top.equalTo(self.balanceLabel.mas_bottom).offset(24);
        make.bottom.equalTo(backgroudView).offset(-16);
        make.height.mas_equalTo(35);
        make.width.equalTo(withdrawButton);
    }];
}

- (void)goToDetailVC {
    WalletDetailViewController *vc = [[WalletDetailViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToRechargeVC {
    RechargeViewController *vc = [[RechargeViewController alloc] init];
    vc.walletModel = self.walletModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToWithdrawVC {
    if (!self.hasTradePwd) {
        NewTradePasswordViewController *vc = [[NewTradePasswordViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    WithdrawViewController *vc = [[WithdrawViewController alloc] init];
    vc.walletModel = self.walletModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)getWalletInfo {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"读取中...";
    [hud showAnimated:YES];
    
    [AppService.sharedAppService getWalletInfo:^(WalletInfoModel * _Nonnull model) {
        self.walletModel = model;
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            self.balanceLabel.text = self.walletModel.balance;
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
        });
    }];
}


@end
