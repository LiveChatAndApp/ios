#import "ChangeTradePasswordViewController.h"

#import <WFChatUIKit/PasswordTextField.h>

#import "AppService.h"
#import "MBProgressHUD.h"
#import "UIColor+YH.h"

@interface ChangeTradePasswordViewController ()

@property(nonatomic, strong)UITextField *oldPasswordField;
@property(nonatomic, strong)UITextField *passwordField;
@property(nonatomic, strong)UITextField *confirmField;
@property(nonatomic, strong)UIButton *saveButton;

@end

@implementation ChangeTradePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)setup {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"修改支付密码";
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(8);
    }];
    
    UILabel *oldPasswordLabel = [[UILabel alloc] init];
    oldPasswordLabel.text = @"原支付密码";
    oldPasswordLabel.font = [UIFont boldSystemFontOfSize:17];
    [view addSubview:oldPasswordLabel];
    [oldPasswordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.top.equalTo(view).offset(10);
    }];
    
    self.oldPasswordField = [[PasswordTextField alloc] init];
    self.oldPasswordField.placeholder = @"请输入原支付密码";
    [self.oldPasswordField addTarget:self action:@selector(inputChanged) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.oldPasswordField];
    [self.oldPasswordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.right.equalTo(view).offset(-15);
        make.top.equalTo(oldPasswordLabel.mas_bottom).offset(20);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.oldPasswordField);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *passwordLabel = [[UILabel alloc] init];
    passwordLabel.text = @"设置新支付密码";
    passwordLabel.font = [UIFont boldSystemFontOfSize:17];
    [view addSubview:passwordLabel];
    [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.top.equalTo(self.oldPasswordField.mas_bottom).offset(27);
    }];
    
    self.passwordField = [[PasswordTextField alloc] init];
    self.passwordField.placeholder = @"请输入新支付密码";
    [self.passwordField addTarget:self action:@selector(inputChanged) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.passwordField];
    [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.right.equalTo(view).offset(-15);
        make.top.equalTo(passwordLabel.mas_bottom).offset(20);
    }];
    
    line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.passwordField);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *confirmLabel = [[UILabel alloc] init];
    confirmLabel.text = @"确认新支付密码";
    confirmLabel.font = [UIFont boldSystemFontOfSize:17];
    [view addSubview:confirmLabel];
    [confirmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.top.equalTo(self.passwordField.mas_bottom).offset(27);
    }];

    self.confirmField = [[PasswordTextField alloc] init];
    self.confirmField.placeholder = @"请再次输入新支付密码";
    [self.confirmField addTarget:self action:@selector(inputChanged) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.confirmField];
    [self.confirmField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.right.equalTo(view).offset(-15);
        make.top.equalTo(confirmLabel.mas_bottom).offset(20);
        make.bottom.equalTo(view).offset(-23);
    }];
    
    line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.confirmField);
        make.height.mas_equalTo(1);
    }];
    
    self.saveButton = [[UIButton alloc] init];
    self.saveButton.clipsToBounds = YES;
    self.saveButton.layer.cornerRadius = 4;
    self.saveButton.enabled = NO;
    self.saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.saveButton setTitle:@"保存" forState:normal];
    [self.saveButton setBackgroundColor:UIColor.grayColor];
    [self.saveButton addTarget:self action:@selector(saveTradePassword) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.bottom.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(52);
    }];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard)]];
}

- (void)saveTradePassword {
    if (![self checkPassword]) {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"修改中...";
    [hud showAnimated:YES];
    
    [AppService.sharedAppService changeTradePasswordWithOldPassword:self.oldPasswordField.text newPassword:self.passwordField.text confirmPassword:self.confirmField.text success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.navigationController.viewControllers.firstObject.view showToast:@"修改成功"];
            // 因為在個人頁面才會取得資料，如果只跳到上一個頁面在點擊設置支付密碼會一樣到這個介面而不是修改介面
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    } error:^(NSString *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view showToast:message];
        });
    }];
}

- (BOOL)checkPassword {
    if (self.passwordField.text.length < 4 || self.passwordField.text.length > 20) {
        [self.view showToast:@"字数须介于 4 至 20 字元"];
        return NO;
    }
    
    if ([self.passwordField.text containsString:@" "]) {
        [self.view showToast:@"不能包含空白键"];
        return NO;
    }
    
    NSRange range = [self.passwordField.text rangeOfCharacterFromSet:NSCharacterSet.alphanumericCharacterSet.invertedSet];
    
    if (range.location != NSNotFound) {
        [self.view showToast:@"不能输入英文/数字以外字符"];
        return NO;
    }
    
    if (![self.passwordField.text isEqualToString:self.confirmField.text]) {
        [self.view showToast:@"两次输入的密码不一致"];
        return NO;
    }
    
    return YES;
}

- (void)resetKeyboard {
    [self.oldPasswordField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.confirmField resignFirstResponder];
}

- (void)inputChanged {
    if (self.oldPasswordField.text.length == 0 || self.passwordField.text.length == 0) {
        self.saveButton.enabled = NO;
        [self.saveButton setBackgroundColor:UIColor.grayColor];
        return;
    }
    
    if (self.passwordField.text.length == self.confirmField.text.length) {
        self.saveButton.enabled = YES;
        [self.saveButton setBackgroundColor:[UIColor colorWithHexString:@"0x4970ba"]];
        return;
    }
    
    self.saveButton.enabled = NO;
    [self.saveButton setBackgroundColor:UIColor.grayColor];
}

@end
