#import "WFCSetPasswordViewController.h"

#import <WFChatUIKit/PasswordTextField.h>

#import "AppService.h"
#import "MBProgressHUD.h"
#import "UIColor+YH.h"
#import "UIFont+YH.h"
#import "WFCBaseTabBarController.h"

@interface WFCSetPasswordViewController () <UITextFieldDelegate>
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UITextField *passwordConfirmField;
@property (strong, nonatomic) UIButton *confirmBtn;
@end

@implementation WFCSetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UILabel *hintLabel = [[UILabel alloc] init];
    NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:@"設置密码"];
    [hintLabel setAttributedText:hintText];
    hintLabel.textAlignment = NSTextAlignmentLeft;
    hintLabel.textColor = [UIColor blackColor];
    hintLabel.font = [UIFont boldSystemFontOfSize:30];
    [self.view addSubview:hintLabel];
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.left.equalTo(self.view).offset(20);
    }];

    UILabel *passwordLabel = [[UILabel alloc] init];
    passwordLabel.text = @"設置密码";
    passwordLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:passwordLabel];
    [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(hintLabel.mas_bottom).offset(40);
    }];
    
    self.passwordField = [[PasswordTextField alloc] init];
    self.passwordField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.passwordField.placeholder = @"请输入密码";
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
    passwordConfirmLabel.text = @"确认密码";
    passwordConfirmLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:passwordConfirmLabel];
    [passwordConfirmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.passwordField.mas_bottom).offset(27);
    }];

    self.passwordConfirmField = [[PasswordTextField alloc] init];
    self.passwordConfirmField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.passwordConfirmField.placeholder = @"请再次输入密码";
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

    self.confirmBtn = [[UIButton alloc] init];
    
    self.confirmBtn.layer.masksToBounds = YES;
    self.confirmBtn.layer.cornerRadius = 4.f;
    self.confirmBtn.backgroundColor = [UIColor colorWithHexString:@"0xe1e1e1"];
    self.confirmBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
    self.confirmBtn.enabled = NO;
    [self.confirmBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.confirmBtn addTarget:self action:@selector(onConfirmButton:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.confirmBtn];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(52);
    }];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard:)]];
}

- (UIAlertController *)createHintController {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"设置个人资料" message:@"设置头像与昵称让别人快速认识你" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelCction = [UIAlertAction actionWithTitle:@"暂时不要" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertAction *goAction = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIViewController *vc = UIApplication.sharedApplication.delegate.window.rootViewController.childViewControllers.firstObject;
        if ([vc isKindOfClass:UINavigationController.class]) {
            WFCUMyProfileTableViewController *profileVC = [[WFCUMyProfileTableViewController alloc] init];
            profileVC.hidesBottomBarWhenPushed = YES;
            [(UINavigationController *)vc pushViewController:profileVC animated:YES];
        }
    }];

    [vc addAction:cancelCction];
    [vc addAction:goAction];
    return vc;
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


- (void)onConfirmButton:(id)sender {
    if (![self checkPassword]) {
        return;
    }
    
    NSString *code = self.resetCode;
    NSString *password = self.passwordField.text;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"保存中...";
    [hud showAnimated:YES];
    
    [[AppService sharedAppService] resetPassword:@"" code:code newPassword:password success:^{
        [hud hideAnimated:YES];
        if (self.successBlock != nil) {
            self.successBlock();
        }
        
        WFCBaseTabBarController *tabBarVC = [WFCBaseTabBarController new];
        [UIApplication sharedApplication].delegate.window.rootViewController = tabBarVC;
        if ([tabBarVC.childViewControllers.firstObject isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)tabBarVC.childViewControllers.firstObject;
            [nav presentViewController:[self createHintController] animated:YES completion:nil];
        }
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"保存失败";
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:1.f];
    }];
}

- (void)resetKeyboard:(id)sender {
    [self.passwordField resignFirstResponder];
    [self.passwordConfirmField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *password = self.passwordField.text;
    NSString *repeat = self.passwordConfirmField.text;

    if (password.length && [password isEqualToString:repeat]) {
        [self onConfirmButton:nil];
    }
    
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *txt = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *anotherTxt = self.passwordField == textField ? self.passwordConfirmField.text : self.passwordField.text;

    if (anotherTxt.length != 0 && anotherTxt.length == txt.length) {
        self.confirmBtn.backgroundColor = [UIColor colorWithHexString:@"0x4970ba"];
        self.confirmBtn.enabled = YES;
    } else {
        self.confirmBtn.backgroundColor = [UIColor colorWithHexString:@"0xe1e1e1"];
        self.confirmBtn.enabled = NO;
    }

    return YES;
}

@end
