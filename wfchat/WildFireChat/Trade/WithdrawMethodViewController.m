#import "WithdrawMethodViewController.h"

#import "AppService.h"
#import "UIColor+YH.h"
#import "MBProgressHUD.h"
#import "WithdrawMethodTableViewCell.h"
#import "AddWithdrawMethodViewController.h"

@interface WithdrawMethodViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)WalletInfoModel *walletModel;
@property(nonatomic, strong)UILabel *balanceLabel;
@property(nonatomic, strong)NSArray<WithdrawMethod *> *withdrawMethods;
@property(nonatomic, strong)UITableView *tableView;

@end

@implementation WithdrawMethodViewController

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
    self.title = @"银行卡列表";
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    
    UIButton *button = [[UIButton alloc] init];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [button setTitle:@"添加" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"0x4970BA"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(gotoAddWithdrawMethodVC) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:WithdrawMethodTableViewCell.class forCellReuseIdentifier:@"WithdrawMethodTableViewCell"];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)getWithdrawMethod {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"读取中...";
    [hud showAnimated:YES];
    
    [AppService.sharedAppService getWithdrawMethod:^(NSArray<WithdrawMethod *> * _Nonnull list) {
        self.withdrawMethods = list;
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

- (void)gotoAddWithdrawMethodVC {
    AddWithdrawMethodViewController *vc = [[AddWithdrawMethodViewController alloc] init];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showConfirmControllerWithCardName:(UIButton *)sender {
    NSString *title = [NSString stringWithFormat:@"确定要删除\"%@\"银行卡？", self.withdrawMethods[sender.tag].name];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelCction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteMethod:sender.tag];
    }];

    [vc addAction:cancelCction];
    [vc addAction:confirmAction];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)deleteMethod:(NSInteger)index {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"删除中...";
    [hud showAnimated:YES];

    NSString *methodId = self.withdrawMethods[index].methodId.stringValue;
    [AppService.sharedAppService deleteWithdrawMethod:methodId success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:@"删除成功"];
            [self getWithdrawMethod];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
        });
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.withdrawMethods.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 2)];
    view.backgroundColor = self.tableView.backgroundColor;
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WithdrawMethodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WithdrawMethodTableViewCell" forIndexPath:indexPath];
    cell.withdrawMethod = self.withdrawMethods[indexPath.section];
    cell.deleteButton.tag = indexPath.section;
    [cell.deleteButton removeTarget:self action:@selector(showConfirmControllerWithCardName:) forControlEvents:UIControlEventTouchDown];
    [cell.deleteButton addTarget:self action:@selector(showConfirmControllerWithCardName:) forControlEvents:UIControlEventTouchDown];
    return cell;
}

@end
