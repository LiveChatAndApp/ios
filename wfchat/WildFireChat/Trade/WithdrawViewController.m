#import "WithdrawViewController.h"

#import "AppService.h"
#import "UIColor+YH.h"
#import "MBProgressHUD.h"
#import "WithdrawMethodViewController.h"

@interface WithdrawViewController ()

@property(nonatomic, strong)UITextField *amountField;
@property(nonatomic, strong)UILabel *withdrawMethodLabel;
@property(nonatomic, strong)UITableView *infoTableView;
@property(nonatomic, assign)NSInteger selectedIndex;
@property(nonatomic, strong)UILabel *userBankAccountLabel;
@property(nonatomic, strong)UILabel *userBankNameLabel;
@property(nonatomic, strong)UILabel *userPayeeLabel;
@property(nonatomic, strong)NSArray<WithdrawMethod *> *withdrawMethods;
@property(nonatomic, strong)UIButton *applyButton;
@property(nonatomic, strong)MASConstraint *applyButtonConstraint;

@end

@implementation WithdrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getWithdrawMethod];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.applyButtonConstraint.offset(self.view.frame.size.height - 20);
}

- (void)setup {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"提现";
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.selectedIndex = -1;
    
    UIScrollView *contentView = [[UIScrollView alloc] init];
    [self.view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    UIButton *navButton = [[UIButton alloc] init];
    navButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [navButton setTitle:@"银行卡" forState:UIControlStateNormal];
    [navButton setTitleColor:[UIColor colorWithHexString:@"0x4970BA"] forState:UIControlStateNormal];
    [navButton addTarget:self action:@selector(gotoWithDrawPaymentVC) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:navButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIView *withdrawView = [[UIView alloc] init];
    withdrawView.backgroundColor = UIColor.whiteColor;
    [contentView addSubview:withdrawView];
    [withdrawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.left.right.equalTo(contentView);
        make.top.equalTo(contentView).offset(8);
    }];
    
    UILabel *withdrawLabel = [[UILabel alloc] init];
    withdrawLabel.text = @"提现金额";
    withdrawLabel.font = [UIFont boldSystemFontOfSize:15];
    [withdrawView addSubview:withdrawLabel];
    [withdrawLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(withdrawView).offset(10);
        make.top.equalTo(withdrawView).offset(15);
    }];
    
    self.amountField = [[UITextField alloc] init];
    self.amountField.placeholder = @"请输入提现金额";
    self.amountField.keyboardType = UIKeyboardTypeDecimalPad;
    [withdrawView addSubview:self.amountField];
    [self.amountField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(withdrawView).offset(15);
        make.right.equalTo(withdrawView).offset(-15);
        make.top.equalTo(withdrawLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(25);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [withdrawView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.amountField);
        make.top.equalTo(self.amountField.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *channelLabel = [[UILabel alloc] init];
    channelLabel.text = @"收款银行";
    channelLabel.font = [UIFont boldSystemFontOfSize:15];
    [withdrawView addSubview:channelLabel];
    [channelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(withdrawView).offset(15);
        make.top.equalTo(self.amountField.mas_bottom).offset(25);
    }];
    
    UIView *methodListView = [[UIView alloc] init];
    methodListView.layer.borderWidth = 1.0f;
    methodListView.userInteractionEnabled = YES;
    methodListView.layer.cornerRadius = 2.0f;
    methodListView.layer.borderColor = [UIColor colorWithHexString:@"0xe4e4e5"].CGColor;
    [methodListView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onInfoLabelTouched)]];
    [withdrawView addSubview:methodListView];
    [methodListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(withdrawView).offset(15);
        make.right.equalTo(withdrawView).offset(-15);
        make.top.equalTo(channelLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(48);
    }];
    
    self.withdrawMethodLabel = [[UILabel alloc] init];
    self.withdrawMethodLabel.text = @"选择银行卡";
    self.withdrawMethodLabel.font = [UIFont systemFontOfSize:16];
    [methodListView addSubview:self.withdrawMethodLabel];
    [self.withdrawMethodLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(methodListView);
        make.left.equalTo(methodListView).offset(16);
    }];
    
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_drop_down"]];
    [methodListView addSubview:arrow];
    [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.withdrawMethodLabel.mas_right);
        make.right.equalTo(methodListView).offset(-9);
        make.centerY.equalTo(methodListView);
        make.height.equalTo(arrow.mas_width);
        make.height.mas_equalTo(24);
    }];
    
    UILabel *bankAccountLabel = [[UILabel alloc] init];
    bankAccountLabel.text = @"银行账号";
    bankAccountLabel.font = [UIFont boldSystemFontOfSize:13];
    bankAccountLabel.textColor = [UIColor colorWithHexString:@"0xadadad"];
    [withdrawView addSubview:bankAccountLabel];
    [bankAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(withdrawView).offset(24);
        make.top.equalTo(methodListView.mas_bottom).offset(12);
    }];
    
    self.userBankAccountLabel = [[UILabel alloc] init];
    self.userBankAccountLabel.numberOfLines = 0;
    self.userBankAccountLabel.font = [UIFont boldSystemFontOfSize:13];
    self.userBankAccountLabel.textColor = [UIColor colorWithHexString:@"0x242424"];
    self.userBankAccountLabel.text = @" ";
    [withdrawView addSubview:self.userBankAccountLabel];
    [self.userBankAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(withdrawView).offset(36);
        make.right.equalTo(withdrawView).offset(-36);
        make.top.equalTo(bankAccountLabel.mas_bottom).offset(8);
    }];
    
    UILabel *bankNameLabel = [[UILabel alloc] init];
    bankNameLabel.text = @"银行名称";
    bankNameLabel.font = [UIFont boldSystemFontOfSize:13];
    bankNameLabel.textColor = [UIColor colorWithHexString:@"0xadadad"];
    [withdrawView addSubview:bankNameLabel];
    [bankNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(withdrawView).offset(24);
        make.top.equalTo(self.userBankAccountLabel.mas_bottom).offset(14);
    }];
    
    self.userBankNameLabel = [[UILabel alloc] init];
    self.userBankNameLabel.numberOfLines = 0;
    self.userBankNameLabel.font = [UIFont boldSystemFontOfSize:13];
    self.userBankNameLabel.textColor = [UIColor colorWithHexString:@"0x242424"];
    self.userBankNameLabel.text = @" ";
    [withdrawView addSubview:self.userBankNameLabel];
    [self.userBankNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(withdrawView).offset(36);
        make.right.equalTo(withdrawView).offset(-36);
        make.top.equalTo(bankNameLabel.mas_bottom).offset(8);
    }];
    
    UILabel *payeeLabel = [[UILabel alloc] init];
    payeeLabel.text = @"收款人姓名";
    payeeLabel.font = [UIFont boldSystemFontOfSize:13];
    payeeLabel.textColor = [UIColor colorWithHexString:@"0xadadad"];
    [withdrawView addSubview:payeeLabel];
    [payeeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(withdrawView).offset(24);
        make.top.equalTo(self.userBankNameLabel.mas_bottom).offset(12);
    }];
    
    self.userPayeeLabel = [[UILabel alloc] init];
    self.userPayeeLabel.numberOfLines = 0;
    self.userPayeeLabel.font = [UIFont boldSystemFontOfSize:13];
    self.userPayeeLabel.textColor = [UIColor colorWithHexString:@"0x242424"];
    self.userPayeeLabel.text = @" ";
    [withdrawView addSubview:self.userPayeeLabel];
    [self.userPayeeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(withdrawView).offset(36);
        make.right.equalTo(withdrawView).offset(-36);
        make.top.equalTo(payeeLabel.mas_bottom).offset(8);
        make.bottom.equalTo(withdrawView).offset(-20);
    }];
    
    UIButton *applyButton = [[UIButton alloc] init];
    applyButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    applyButton.backgroundColor = [UIColor colorWithHexString:@"0x4970ba"];
    applyButton.clipsToBounds = YES;
    applyButton.layer.cornerRadius = 5;
    [applyButton setTitle:@"确认提交" forState:normal];
    [applyButton setTitleColor:UIColor.whiteColor forState:normal];
    [applyButton addTarget:self action:@selector(onApplyButton) forControlEvents:UIControlEventTouchDown];
    [contentView addSubview:applyButton];
    [applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.bottom.equalTo(contentView).offset(-20);
        self.applyButtonConstraint = make.bottom.greaterThanOrEqualTo(contentView.mas_top).offset(self.view.frame.size.height - 20);
        make.height.mas_equalTo(50);
    }];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"提现需要人工审核，请耐心等候，可在我的钱包>明细查询提现状态";
    tipLabel.textColor = [UIColor colorWithHexString:@"0xadadad"];
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.numberOfLines = 0;
    [contentView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(applyButton.mas_top).offset(-10);
        make.top.greaterThanOrEqualTo(withdrawView.mas_bottom).offset(20);
    }];
    
    self.infoTableView = [[UITableView alloc] init];
    self.infoTableView.delegate = self;
    self.infoTableView.dataSource = self;
    self.infoTableView.hidden = YES;
    self.infoTableView.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.infoTableView.layer.cornerRadius = 5;
    self.infoTableView.clipsToBounds = YES;
    self.infoTableView.layer.borderColor = UIColor.grayColor.CGColor;
    self.infoTableView.layer.borderWidth = 1.0f;
    [self.infoTableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"channelInfoCell"];
    [self.view addSubview:self.infoTableView];
    [self.infoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(methodListView.mas_bottom);
        make.left.right.equalTo(methodListView);
        make.height.mas_equalTo(200);
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard)];
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
    [contentView addGestureRecognizer:tap];
}

- (void)getWithdrawMethod {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"读取中...";
    [hud showAnimated:YES];
    
    [AppService.sharedAppService getWithdrawMethod:^(NSArray<WithdrawMethod *> * _Nonnull list) {
        self.withdrawMethods = list;
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.infoTableView reloadData];
            [self resetSelected];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
        });
    }];
}

- (void)resetSelected {
    self.selectedIndex = -1;
    self.withdrawMethodLabel.text = @"选择银行卡";
    self.userBankAccountLabel.text = @" ";
    self.userBankNameLabel.text = @" ";
    self.userPayeeLabel.text = @" ";
}

- (void)showInputTradePasswordVCWithSuccess:(void (^)(NSString * tradePassword))successBlock {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请输入支付密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入支付密码";
        textField.secureTextEntry = YES;
    }];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (successBlock != nil) {
            successBlock(vc.textFields[0].text);
        }
    }]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)sendWithdrawOrder:(ApplyWithdrawRequestModel *)model {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"提交中...";
    [hud showAnimated:YES];

    [AppService.sharedAppService applyWithdraw:model success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.parentViewController.view makeToast:@"提交成功"];
            [self.navigationController popViewControllerAnimated:YES];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
        });
    }];
}

#pragma mark - UI Event
- (void)resetKeyboard {
    [self.amountField resignFirstResponder];
    self.infoTableView.hidden = YES;
}

- (void)onInfoLabelTouched {
    if (self.infoTableView.hidden == NO) {
        self.infoTableView.hidden = YES;
        return;
    }
    
    self.infoTableView.alpha = 0;
    [UIView animateWithDuration:0.2f animations:^{
        self.infoTableView.hidden = NO;
        self.infoTableView.alpha = 1;
    }];
}

- (void)gotoWithDrawPaymentVC {
    WithdrawMethodViewController *vc = [[WithdrawMethodViewController alloc] init];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onApplyButton {
    if (self.selectedIndex == -1) {
        [self.view makeToast:@"请选择银行卡"];
        return;
    }
    
    ApplyWithdrawRequestModel *model = [[ApplyWithdrawRequestModel alloc] init];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    model.amount = [formatter numberFromString:self.amountField.text];
    
    if (model.amount == nil) {
        [self.view makeToast:@"充值金额格式错误"];
        return;
    }
    
    WithdrawMethod *methodModel = self.withdrawMethods[self.selectedIndex];
    model.channel = methodModel.paymentMethod;
    model.currency = self.walletModel.currency;
    model.paymentMethodId = methodModel.methodId;
    
    [self showInputTradePasswordVCWithSuccess:^(NSString *tradePassword) {
        model.tradePwd = tradePassword.sha256String;
        [self sendWithdrawOrder:model];
    }];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.withdrawMethods.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"channelInfoCell"];
    cell.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    cell.textLabel.text = [self.withdrawMethods objectAtIndex:indexPath.row].name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.withdrawMethods[indexPath.row].name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    self.withdrawMethodLabel.text = self.withdrawMethods[indexPath.row].name;
    self.userBankAccountLabel.text = self.withdrawMethods[indexPath.row].info.bankCardNumber;
    self.userBankNameLabel.text = self.withdrawMethods[indexPath.row].info.bankName;
    self.userPayeeLabel.text = self.withdrawMethods[indexPath.row].info.name;
    self.infoTableView.hidden = YES;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch {
    if ([touch.view.superview isKindOfClass:UITableViewCell.class]) {
        return NO;
    }
    
    return YES;
}

@end
