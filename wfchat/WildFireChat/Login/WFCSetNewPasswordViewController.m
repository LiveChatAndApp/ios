#import "WFCSetNewPasswordViewController.h"

#import <WFChatUIKit/PasswordTextField.h>

#import "AppService.h"
#import "MBProgressHUD.h"
#import "UIColor+YH.h"
#import "UIFont+YH.h"

@interface WFCSetNewPasswordViewController () <UITextFieldDelegate>
@property (strong, nonatomic) UILabel *hintLabel;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UITextField *passwordConfirmField;
@property (strong, nonatomic) UIButton *saveBtn;
@end

@implementation WFCSetNewPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"设置新密码";
    titleLabel.font = [UIFont boldSystemFontOfSize:30];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.view).offset(20);
    }];
    
    UILabel *passwordLabel = [[UILabel alloc] init];
    passwordLabel.text = @"設置新密码";
    passwordLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:passwordLabel];
    [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(titleLabel.mas_bottom).offset(40);
    }];
    
    self.passwordField = [[PasswordTextField alloc] init];
    self.passwordField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.passwordField.placeholder = @"请输入新密码";
    self.passwordField.returnKeyType = UIReturnKeyNext;
    self.passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordField.delegate = self;
    [self.view addSubview:self.passwordField];
    [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(passwordLabel.mas_bottom).offset(16);
    }];
    
    UIView *passwordLine = [[UIView alloc] init];
    passwordLine.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [self.view addSubview:passwordLine];
    [passwordLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.left.right.equalTo(self.passwordField);
    }];
    
    UILabel *passwordConfirmLabel = [[UILabel alloc] init];
    passwordConfirmLabel.text = @"确认新密码";
    passwordConfirmLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:passwordConfirmLabel];
    [passwordConfirmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.passwordField.mas_bottom).offset(27);
    }];
    
    self.passwordConfirmField = [[PasswordTextField alloc] init];
    self.passwordConfirmField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.passwordConfirmField.placeholder = @"请再次输入新密码";
    self.passwordConfirmField.returnKeyType = UIReturnKeyNext;
    self.passwordConfirmField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordConfirmField.delegate = self;
    [self.view addSubview:self.passwordConfirmField];
    [self.passwordConfirmField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(passwordConfirmLabel.mas_bottom).offset(16);
    }];
    
    UIView *passwordConfirmLine = [[UIView alloc] init];
    passwordConfirmLine.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [self.view addSubview:passwordConfirmLine];
    [passwordConfirmLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.left.right.equalTo(self.passwordConfirmField);
    }];
    
    self.saveBtn = [[UIButton alloc] init];
    [self.saveBtn addTarget:self action:@selector(onSaveButton:) forControlEvents:UIControlEventTouchDown];
    self.saveBtn.layer.masksToBounds = YES;
    self.saveBtn.layer.cornerRadius = 4.f;
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    self.saveBtn.backgroundColor = [UIColor colorWithHexString:@"0xe1e1e1"];
    [self.saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
    self.saveBtn.enabled = NO;
    [self.view addSubview:self.saveBtn];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(52);
    }];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard:)]];
}

- (void)onSaveButton:(id)sender {
    if (![self checkPassword]) {
        return;
    }

    NSString *user = self.user;
    NSString *code = self.resetCode;
    NSString *password = self.passwordField.text;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[AppService sharedAppService] resetPassword:user code:code newPassword:password success:^{
        [hud hideAnimated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"保存成功";
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:0.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"保存失败";
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:0.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
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


- (void)resetKeyboard:(id)sender {
    [self.passwordField resignFirstResponder];
    [self.passwordConfirmField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *txt = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *anotherTxt = self.passwordField == textField ? self.passwordConfirmField.text : self.passwordField.text;

    if (anotherTxt.length != 0 && anotherTxt.length == txt.length) {
        self.saveBtn.backgroundColor = [UIColor colorWithHexString:@"0x4970ba"];
        self.saveBtn.enabled = YES;
    } else {
        self.saveBtn.backgroundColor = [UIColor colorWithHexString:@"0xe1e1e1"];
        self.saveBtn.enabled = NO;
    }

    return YES;
}

@end
