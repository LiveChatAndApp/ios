#import "AddWithdrawMethodViewController.h"

#import "AppService.h"
#import "UIColor+YH.h"
#import "MBProgressHUD.h"
#import "AddWithdrawMethodRequestModel.h"
#import "AddWithdrawMethodTableViewCell.h"

@interface AddWithdrawMethodViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)UITextField *balanceLabel;
@property(nonatomic, strong)NSMutableArray<AddWithdrawMethodTableViewCell *> *cells;
@end

@implementation AddWithdrawMethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createCell];
    [self setupUI];
}

- (void)setupUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"添加银行卡";
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 94;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    
    UIButton *addButton = [[UIButton alloc] init];
    addButton.backgroundColor = [UIColor colorWithHexString:@"0x4970BA"];
    addButton.layer.cornerRadius = 4;
    addButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [addButton setTitle:@"添加银行卡" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addWithdrawMethod) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:addButton];
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.bottom.equalTo(self.view).offset(-20);
        make.top.equalTo(self.tableView.mas_bottom);
        make.height.mas_equalTo(52);
    }];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard)]];
}

- (void)createCell {
    self.cells = [[NSMutableArray alloc] init];
    
    AddWithdrawMethodTableViewCell *cell = [[AddWithdrawMethodTableViewCell alloc] init];
    cell.label.text = @"银行卡名称";
    cell.textField.placeholder = @"请输入自定义银行卡名称";
    [self.cells addObject:cell];
    
    cell = [[AddWithdrawMethodTableViewCell alloc] init];
    cell.label.text = @"银行账号";
    cell.textField.placeholder = @"请输入银行账号";
    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    [self.cells addObject:cell];
    
    cell = [[AddWithdrawMethodTableViewCell alloc] init];
    cell.label.text = @"银行名称";
    cell.textField.placeholder = @"请输入银行名称";
    [self.cells addObject:cell];
    
    cell = [[AddWithdrawMethodTableViewCell alloc] init];
    cell.label.text = @"收款人姓名";
    cell.textField.placeholder = @"请输入收款人姓名";
    [self.cells addObject:cell];
}

- (BOOL)checkInput {
    for (NSUInteger i = 0 ; i < self.cells.count ; i++) {
        AddWithdrawMethodTableViewCell *cell = self.cells[i];
        if ([cell.textField.text isEqualToString:@""]) {
            [self.view makeToast:@"请填完全部资料"];
            return NO;
        }
        
        //  银行卡名称 20字内
        //  银行账号 30字内(键盘锁定只能输入数字)
        //  银行名称 20字内
        //  收款人名称20字内
        if (i == 0 && cell.textField.text.length > 20) {
            [self.view showToast:@"银行卡名称上限20个字"];
            return NO;
        }
        
        if (i == 1 && cell.textField.text.length > 30) {
            [self.view showToast:@"银行账号上限30个字"];
            return NO;
        }
        
        if (i == 2 && cell.textField.text.length > 20) {
            [self.view showToast:@"银行名称上限20个字"];
            return NO;
        }
        
        if (i == 3 && cell.textField.text.length > 20) {
            [self.view showToast:@"收款人名称上限20个字"];
            return NO;
        }
    }
    
    return YES;
}

- (void)addWithdrawMethod {
    if (![self checkInput]) {
        return;
    }

    AddWithdrawMethodRequestModel *model = [[AddWithdrawMethodRequestModel alloc] init];
    model.channel = @1;
    model.customName = self.cells[0].textField.text;
    model.info.bankCardNumber = self.cells[1].textField.text;
    model.info.bankName = self.cells[2].textField.text;
    model.info.name = self.cells[3].textField.text;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"添加中...";
    [hud showAnimated:YES];
    
    [AppService.sharedAppService addWithdrawMethod:model progress:nil success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.parentViewController.view makeToast:@"添加成功"];
            [self.navigationController popViewControllerAnimated:YES];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
        });
    }];
}

- (void)resetKeyboard {
    for (AddWithdrawMethodTableViewCell *cell in self.cells) {
        [cell.textField resignFirstResponder];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }

    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 2)];
    view.backgroundColor = self.tableView.backgroundColor;
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.cells[0];
    } else {
        return self.cells[indexPath.row + 1];
    }
}

@end
