#import "WFCSMSChangePasswordViewController.h"

#import <WFChatUIKit/PasswordTextField.h>

#import "AppService.h"
#import "MBProgressHUD.h"
#import "UIColor+YH.h"
#import "UIFont+YH.h"

@interface WFCSMSChangePasswordViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UITextField *passwordConfirmField;
@property (strong, nonatomic) UITextField *resetCodeField;
@property (strong, nonatomic) UIButton *sendCodeBtn;
@property (strong, nonatomic) UIButton *saveButton;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, assign) NSTimeInterval sendCodeTime;
@property (nonatomic, strong) NSString *resetCode;
@end

@implementation WFCSMSChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.title = @"修改密码";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIView *passwordView = [[UIView alloc] init];
    passwordView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:passwordView];
    [passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(8);
        make.right.left.equalTo(self.view);
    }];
    
    UIView *passwordContainer = [[UIView alloc] init];
    [passwordView addSubview:passwordContainer];
    [passwordContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(passwordView);
    }];
    
    UILabel *passwordLabel = [[UILabel alloc] init];
    passwordLabel.text = @"设置新密码";
    passwordLabel.font = [UIFont boldSystemFontOfSize:17];
    [passwordContainer addSubview:passwordLabel];
    [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(passwordContainer).offset(15);
        make.top.equalTo(passwordContainer).offset(10);
    }];
    
    self.passwordField = [[PasswordTextField alloc] init];
    self.passwordField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.passwordField.placeholder = @"请输入新密码";
    self.passwordField.returnKeyType = UIReturnKeyNext;
    self.passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordField.delegate = self;
    [self.passwordField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [passwordContainer addSubview:self.passwordField];
    [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(passwordContainer).offset(15);
        make.right.equalTo(passwordContainer).offset(-15);
        make.bottom.equalTo(passwordContainer).offset(-14);
        make.top.equalTo(passwordLabel.mas_bottom).offset(20);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [passwordContainer addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.left.right.equalTo(self.passwordField);
    }];
    
    UIView *passwordConfirmContainer = [[UIView alloc] init];
    [passwordView addSubview:passwordConfirmContainer];
    [passwordConfirmContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passwordContainer.mas_bottom);
        make.left.right.equalTo(passwordView);
    }];
    
    UILabel *passwordConfirmLabel = [[UILabel alloc] init];
    passwordConfirmLabel.text = @"确认密码";
    passwordConfirmLabel.font = [UIFont boldSystemFontOfSize:17];
    [passwordConfirmContainer addSubview:passwordConfirmLabel];
    [passwordConfirmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(passwordConfirmContainer).offset(15);
        make.top.equalTo(passwordConfirmContainer).offset(10);
    }];

    self.passwordConfirmField = [[PasswordTextField alloc] init];
    self.passwordConfirmField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.passwordConfirmField.placeholder = @"请再次输入新密码";
    self.passwordConfirmField.returnKeyType = UIReturnKeyNext;
    self.passwordConfirmField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordConfirmField.delegate = self;
    [self.passwordConfirmField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [passwordConfirmContainer addSubview:self.passwordConfirmField];
    [self.passwordConfirmField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(passwordConfirmContainer).offset(15);
        make.right.equalTo(passwordConfirmContainer).offset(-15);
        make.bottom.equalTo(passwordConfirmContainer).offset(-14);
        make.top.equalTo(passwordConfirmLabel.mas_bottom).offset(20);
    }];
    
    line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [passwordConfirmContainer addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.left.right.equalTo(self.passwordConfirmField);
    }];

    UIView *verificationCodeContainer  = [[UIView alloc] init];
    [passwordView addSubview:verificationCodeContainer];
    [verificationCodeContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passwordConfirmContainer.mas_bottom);
        make.bottom.left.right.equalTo(passwordView);
    }];
    
    UILabel *verificationCodeLabel = [[UILabel alloc] init];
    verificationCodeLabel.text = @"验证码";
    verificationCodeLabel.font = [UIFont boldSystemFontOfSize:17];
    [verificationCodeContainer addSubview:verificationCodeLabel];
    [verificationCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(verificationCodeContainer).offset(15);
        make.top.equalTo(verificationCodeContainer).offset(10);
    }];
    
    self.resetCodeField = [[UITextField alloc] init];
    self.resetCodeField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.resetCodeField.placeholder = @"请输入验证码";
    self.resetCodeField.returnKeyType = UIReturnKeyDone;
    self.resetCodeField.keyboardType = UIKeyboardTypeNumberPad;
    self.resetCodeField.delegate = self;
    self.resetCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.resetCodeField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [verificationCodeContainer addSubview:self.resetCodeField];
    [self.resetCodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(verificationCodeContainer).offset(15);
        make.bottom.equalTo(verificationCodeContainer).offset(-14);
        make.top.equalTo(verificationCodeLabel.mas_bottom).offset(20);
    }];
    
    line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [verificationCodeContainer addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.left.right.equalTo(self.resetCodeField);
    }];
    
    self.sendCodeBtn = [[UIButton alloc] init];
    [self.sendCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    self.sendCodeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    self.sendCodeBtn.backgroundColor = [UIColor colorWithHexString:@"0xe1e1e1"];
    self.sendCodeBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    self.sendCodeBtn.layer.cornerRadius = 4;
    [self.sendCodeBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.sendCodeBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.sendCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.sendCodeBtn addTarget:self action:@selector(onSendCode:) forControlEvents:UIControlEventTouchDown];
    [verificationCodeContainer addSubview:self.sendCodeBtn];
    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(verificationCodeContainer).offset(-15);
        make.bottom.equalTo(self.resetCodeField);
        make.left.equalTo(self.resetCodeField.mas_right).offset(12);
        make.height.mas_equalTo(30);
        make.width.mas_greaterThanOrEqualTo(50);
    }];
    
    self.saveButton = [[UIButton alloc] init];
    self.saveButton.layer.masksToBounds = YES;
    self.saveButton.layer.cornerRadius = 4.f;
    [self.saveButton setTitle:@"保存" forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.saveButton addTarget:self action:@selector(changePassword) forControlEvents:UIControlEventTouchDown];
    self.saveButton.backgroundColor = [UIColor colorWithHexString:@"0xe1e1e1"];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveButton.enabled = NO;
    [self.view addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(52);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard:)]];
}

- (void)onSendCode:(id)sender {
    self.sendCodeBtn.enabled = NO;
    [self.sendCodeBtn setTitle:@"短信发送中" forState:UIControlStateNormal];
    [[AppService sharedAppService] sendResetCode:self.mobile success:^{
        [self sendCodeDone:YES];
    } error:^(NSString * _Nonnull message) {
        [self sendCodeDone:NO];
        [self.view makeToast:message];
    }];
}

- (void)sendCodeDone:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"发送成功";
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            self.sendCodeTime = [NSDate date].timeIntervalSince1970;
            self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                target:self
                                                                 selector:@selector(updateCountdown:)
                                                              userInfo:nil
                                                               repeats:YES];
            [self.countdownTimer fire];
            
            [hud hideAnimated:YES afterDelay:1.f];
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"发送失败";
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                self.sendCodeBtn.enabled = YES;
            });
        }
    });
}

- (void)updateCountdown:(id)sender {
    int second = (int)([NSDate date].timeIntervalSince1970 - self.sendCodeTime);
    [self.sendCodeBtn setTitle:[NSString stringWithFormat:@"%ds", 60-second] forState:UIControlStateNormal];
    if (second >= 60) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
        [self.sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.sendCodeBtn.enabled = YES;
    }
}

- (void)resetKeyboard:(id)sender {
    [self.passwordField resignFirstResponder];
    [self.passwordConfirmField resignFirstResponder];
    [self.resetCodeField resignFirstResponder];
}

- (void)changePassword {
    if (![self checkPassword]) {
        return;
    }
    
    NSString *code = self.resetCodeField.text;
    NSString *password = self.passwordConfirmField.text;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"保存中...";
    [hud showAnimated:YES];
    
    [AppService.sharedAppService resetPassword:self.mobile code:code newPassword:password success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.parentViewController.view makeToast:@"保存成功"];
            [self.navigationController popViewControllerAnimated:YES];
        });
    } error:^(int errCode, NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:message];
            [hud hideAnimated:YES];
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
    
    if (![self.passwordField.text isEqualToString:self.passwordConfirmField.text]) {
        [self.view showToast:@"两次输入的密码不一致"];
        return NO;
    }
    
    return YES;
}

#pragma mark - UITextFieldDelegate
- (void)textDidChange:(id<UITextInput>)textInput {
    [self updateBtn];
}

- (void)updateBtn {
    if (!self.countdownTimer) {
        [self.sendCodeBtn setBackgroundColor:[UIColor colorWithHexString:@"0x4970ba"]];
        self.sendCodeBtn.enabled = YES;
    } else {
        [self.sendCodeBtn setBackgroundColor:[UIColor grayColor]];
        self.sendCodeBtn.enabled = NO;
    }
    
    if ([self.passwordField.text isEqualToString:@""]) {
        [self.saveButton setBackgroundColor:[UIColor grayColor]];
        self.saveButton.enabled = NO;
        return;
    }
    
    if (self.resetCodeField.text.length == 0) {
        [self.saveButton setBackgroundColor:[UIColor grayColor]];
        self.saveButton.enabled = NO;
        return;
    }
    
    if (self.passwordField.text.length == self.passwordConfirmField.text.length) {
        [self.saveButton setBackgroundColor:[UIColor colorWithHexString:@"0x4970ba"]];
        self.saveButton.enabled = YES;
        
        return;
    }
    
    [self.saveButton setBackgroundColor:[UIColor grayColor]];
    self.saveButton.enabled = NO;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

@end
