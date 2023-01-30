#import "RechargeViewController.h"

#import <WFChatUIKit/RadioButton.h>

#import "AppService.h"
#import "UIColor+YH.h"
#import "ConfirmOrderViewController.h"
#import "MBProgressHUD.h"

@interface RechargeViewController ()

@property(nonatomic, strong)UITextField *amountField;
@property(nonatomic, strong)NSArray<RadioButton *> *radioButtonGroup;
@property(nonatomic, strong)UILabel *channelInfoLabel;
@property(nonatomic, strong)NSArray<RechargeChannelModel *> *currentChannelModels;
@property(nonatomic, strong)UITableView *infoView;
@property(nonatomic, assign)NSInteger selectedIndex;

@end

@implementation RechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getRechargeChannelInfo:self.radioButtonGroup.firstObject.tag];
    [self onRadioButton:self.radioButtonGroup.firstObject];
}

- (void)setup {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"充值";
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.selectedIndex = 0;
    
    UIView *rechargeView = [[UIView alloc] init];
    rechargeView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:rechargeView];
    [rechargeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(8);
        make.left.right.equalTo(self.view);
    }];
    
    UILabel *payChannelLabel = [[UILabel alloc] init];
    payChannelLabel.text = @"支付渠道";
    payChannelLabel.font = [UIFont boldSystemFontOfSize:16];
    [rechargeView addSubview:payChannelLabel];
    [payChannelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rechargeView).offset(10);
        make.top.equalTo(rechargeView).offset(15);
    }];
    
    UIView *radioView = [[UIView alloc] init];
    [rechargeView addSubview:radioView];
    [radioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(payChannelLabel.mas_bottom).offset(20);
        make.left.equalTo(rechargeView).offset(10);
        make.right.equalTo(rechargeView).offset(-15);
    }];
    
    RadioButton *cardButton = [[RadioButton alloc] init];
    cardButton.title = @"银行卡";
    cardButton.tag = RechargeChannelTypeCard;
    [cardButton addTarget:self action:@selector(onRadioButton:) forControlEvents:UIControlEventTouchDown];
    [radioView addSubview:cardButton];
    [cardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(radioView);
    }];
    
    RadioButton *weixinButton = [[RadioButton alloc] init];
    weixinButton.title = @"微信";
    weixinButton.tag = RechargeChannelTypeWeixin;
    [weixinButton addTarget:self action:@selector(onRadioButton:) forControlEvents:UIControlEventTouchDown];
    [radioView addSubview:weixinButton];
    [weixinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(radioView);
        make.top.bottom.equalTo(radioView);
        make.left.greaterThanOrEqualTo(cardButton.mas_right);
    }];
    
    RadioButton *alipayButton = [[RadioButton alloc] init];
    alipayButton.title = @"支付宝";
    alipayButton.tag = RechargeChannelTypeAlipay;
    [alipayButton addTarget:self action:@selector(onRadioButton:) forControlEvents:UIControlEventTouchDown];
    [radioView addSubview:alipayButton];
    [alipayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(radioView);
        make.left.greaterThanOrEqualTo(weixinButton.mas_right);
    }];
    
    UILabel *amountLabel = [[UILabel alloc] init];
    amountLabel.text = @"充值金额";
    amountLabel.font = [UIFont boldSystemFontOfSize:16];
    [rechargeView addSubview:amountLabel];
    [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rechargeView).offset(15);
        make.top.equalTo(cardButton.mas_bottom).offset(25);
    }];
    
    self.amountField = [[UITextField alloc] init];
    self.amountField.placeholder = @"请输入充值金额";
    self.amountField.keyboardType = UIKeyboardTypeDecimalPad;
    [rechargeView addSubview:self.amountField];
    [self.amountField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rechargeView).offset(15);
        make.right.equalTo(rechargeView).offset(-15);
        make.top.equalTo(amountLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(30);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [rechargeView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.amountField);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *channelLabel = [[UILabel alloc] init];
    channelLabel.text = @"选择渠道";
    channelLabel.font = [UIFont boldSystemFontOfSize:16];
    [rechargeView addSubview:channelLabel];
    [channelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rechargeView).offset(15);
        make.top.equalTo(self.amountField.mas_bottom).offset(25);
    }];
    
    UIView *channelInfoView = [[UIView alloc] init];
    channelInfoView.layer.borderColor = [UIColor colorWithHexString:@"0xe4e4e4"].CGColor;
    channelInfoView.layer.borderWidth = 1;
    channelInfoView.layer.cornerRadius = 2;
    channelInfoView.userInteractionEnabled = YES;
    [rechargeView addSubview:channelInfoView];
    [channelInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rechargeView).offset(15);
        make.right.equalTo(rechargeView).offset(-15);
        make.top.equalTo(channelLabel.mas_bottom).offset(20);
        make.bottom.equalTo(rechargeView).offset(-20);
        make.height.mas_equalTo(48);
    }];
    
    [channelInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onInfoLabelTouched)]];
    
    self.channelInfoLabel = [[UILabel alloc] init];
    [channelInfoView addSubview:self.channelInfoLabel];
    [self.channelInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(channelInfoView).offset(16);
        make.top.bottom.equalTo(channelInfoView);
    }];
    
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_drop_down"]];
    [channelInfoView addSubview:arrow];
    [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(channelInfoView).offset(10);
        make.right.centerY.equalTo(channelInfoView);
        make.left.greaterThanOrEqualTo(self.channelInfoLabel.mas_right);
        make.height.equalTo(arrow.mas_width);
    }];
    
    self.infoView = [[UITableView alloc] init];
    self.infoView.delegate = self;
    self.infoView.dataSource = self;
    self.infoView.hidden = YES;
    self.infoView.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.infoView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.infoView.layer.cornerRadius = 5;
    self.infoView.clipsToBounds = YES;
    self.infoView.layer.borderColor = UIColor.grayColor.CGColor;
    self.infoView.layer.borderWidth = 1.0f;
    [self.infoView registerClass:UITableViewCell.class forCellReuseIdentifier:@"channelInfoCell"];
    [self.view addSubview:self.infoView];
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(channelInfoView.mas_bottom);
        make.left.right.equalTo(channelInfoView);
        make.height.mas_equalTo(200);
    }];
    
    UIButton *rechargeButton = [[UIButton alloc] init];
    [rechargeButton setTitle:@"发起订单" forState:normal];
    [rechargeButton setBackgroundColor:[UIColor colorWithHexString:@"0x4970ba"]];
    [rechargeButton setTitleColor:UIColor.whiteColor forState:normal];
    [rechargeButton addTarget:self action:@selector(applyOrder) forControlEvents:UIControlEventTouchDown];
    rechargeButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    rechargeButton.clipsToBounds = YES;
    rechargeButton.layer.cornerRadius = 5;
    [self.view addSubview:rechargeButton];
    [rechargeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(52);
    }];
    
    self.radioButtonGroup = @[cardButton, weixinButton, alipayButton];
    cardButton.selected = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard)];
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)getRechargeChannelInfo:(RechargeChannelType)type {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"读取中...";
    [hud showAnimated:YES];
    [AppService.sharedAppService getRechargeChannelWithType:type success:^(NSArray<RechargeChannelModel *> * _Nonnull channels) {
        self.currentChannelModels = channels;
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.infoView reloadData];
            if (channels.count != 0) {
                self.channelInfoLabel.text = channels.firstObject.name;
            }
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
        });
    }];
}

#pragma mark - UI Event
- (void)onRadioButton:(RadioButton *)sender {
    sender.selected = YES;
    self.selectedIndex = 0;
    
    for (RadioButton *btn in self.radioButtonGroup) {
        if (btn != sender) {
            btn.selected = NO;
        }
    }
    
    [self getRechargeChannelInfo:sender.tag];
}

- (void)resetKeyboard {
    [self.amountField resignFirstResponder];
    self.infoView.hidden = YES;
}

- (void)onInfoLabelTouched {
    if (self.infoView.hidden == NO) {
        self.infoView.hidden = YES;
        return;
    }
    
    self.infoView.alpha = 0;
    [UIView animateWithDuration:0.2f animations:^{
        self.infoView.hidden = NO;
        self.infoView.alpha = 1;
    }];
}

- (void)applyOrder {
    ApplyRechargeRequestModel *model = [[ApplyRechargeRequestModel alloc] init];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    model.amount = [formatter numberFromString:self.amountField.text];
    
    if (model.amount == nil) {
        [self.view makeToast:@"充值金额格式错误"];
        return;
    }
    
    RechargeChannelModel *channelModel = self.currentChannelModels[self.selectedIndex];
    model.channelId = channelModel.channelId;
    model.currency = self.walletModel.currency;
    model.method = channelModel.paymentMethod;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"发送中...";
    [hud showAnimated:YES];

    [AppService.sharedAppService applyRecharge:model success:^(ApplyRechargeModel * _Nonnull model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            ConfirmOrderViewController *vc = [[ConfirmOrderViewController alloc] init];
            vc.rechargeType = model.method;
            vc.payee = channelModel.info.realName;
            vc.bankName = channelModel.info.bankName;
            vc.account = channelModel.info.bankAccount;
            vc.qrCodeURL = channelModel.info.qrCodeImage;
            vc.orderId = model.orderId.stringValue;
            vc.backToWallet = YES;
            [self.navigationController pushViewController:vc animated:YES];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
        });
    }];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentChannelModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"channelInfoCell"];
    cell.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    cell.textLabel.text = [self.currentChannelModels objectAtIndex:indexPath.row].name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    self.channelInfoLabel.text = [self.currentChannelModels objectAtIndex:indexPath.row].name;
    self.infoView.hidden = YES;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch {
    if ([touch.view.superview isKindOfClass:UITableViewCell.class]) {
        return NO;
    }
    
    return YES;
}

@end
