#import "WalletDetailViewController.h"

#import "AppService.h"
#import "ConfirmOrderViewController.h"
#import "UIColor+YH.h"
#import "MBProgressHUD.h"
#import "WithdrawDetailTableViewCell.h"

@interface WalletDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)NSArray<WalletOrderModel *> *orderList;
@property(nonatomic, strong)UITableView *tableView;

@end

@implementation WalletDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getWithdrawMethod];
}

- (void)setup {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"钱包明细";
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self.tableView registerClass:WithdrawDetailTableViewCell.class forCellReuseIdentifier:@"WithdrawDetailTableViewCell"];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(8);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)getWithdrawMethod {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"读取中...";
    [hud showAnimated:YES];
    
    [AppService.sharedAppService getOrderList:^(NSArray<WalletOrderModel *> * _Nonnull list) {
        self.orderList = list;
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.tableView reloadData];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
        });
    }];
}

- (void)gotoConfirmVC:(UIButton *)sender {
    WalletOrderModel *order = self.orderList[sender.tag];
    ConfirmOrderViewController *vc = [[ConfirmOrderViewController alloc] init];
    
    vc.rechargeType = order.rechargeChannel.paymentMethod;
    vc.payee = order.rechargeChannel.info.realName;
    vc.bankName = order.rechargeChannel.info.bankName;
    vc.account = order.rechargeChannel.info.bankAccount;
    vc.qrCodeURL = order.rechargeChannel.info.qrCodeImage;
    vc.orderId = order.orderId.stringValue;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.orderList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 4)];
    view.backgroundColor = self.tableView.backgroundColor;
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WithdrawDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WithdrawDetailTableViewCell" forIndexPath:indexPath];
    cell.order = self.orderList[indexPath.section];
    cell.tag = indexPath.section;
    [cell.confirmButton addTarget:self action:@selector(gotoConfirmVC:) forControlEvents:UIControlEventTouchDown];
    return cell;
}

@end
