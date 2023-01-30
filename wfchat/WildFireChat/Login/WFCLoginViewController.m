//
//  WFCLoginViewController.m
//  Wildfire Chat
//
//  Created by WF Chat on 2017/7/9.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCLoginViewController.h"

#import <WFChatClient/WFCChatClient.h>
#import <WFChatUIKit/WFChatUIKit.h>
#import <WFChatUIKit/PasswordTextField.h>

#import "AppDelegate.h"
#import "WFCBaseTabBarController.h"
#import "WFCResetPasswordViewController.h"
#import "WFCRegisterViewController.h"
#import "MBProgressHUD.h"
#import "WFCPrivacyViewController.h"
#import "AppService.h"
#import "UIColor+YH.h"
#import "UIFont+YH.h"

@interface WFCLoginViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *userNameField;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UIButton *loginBtn;
@end

@implementation WFCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    NSString *savedName = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedName"];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    }
    
    UIView *view = [[UIView alloc] init];
    view.layer.cornerRadius = 16;
    view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.78);
    }];
    
    UIView *bottomMaskView = [[UIView alloc] init];
    bottomMaskView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:bottomMaskView];
    [bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.mas_equalTo(20);
    }];
    
    UILabel *hintLabel = [[UILabel alloc] init];
    NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:@"登录"];
    [hintText addAttribute:NSUnderlineStyleAttributeName value:@1 range:NSMakeRange(0, hintText.length)];
    [hintText addAttribute:NSUnderlineColorAttributeName value:[UIColor colorWithHexString:@"0x4970ba"] range:NSMakeRange(0, hintText.length)];
    hintLabel.attributedText = hintText;
    hintLabel.textColor = [UIColor colorWithHexString:@"0x4970ba"];
    hintLabel.font = [UIFont boldSystemFontOfSize:30];
    [self.view addSubview:hintLabel];
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.bottom.equalTo(view.mas_top).offset(-20);
    }];
    
    UIControl *registerButton = [[UIControl alloc] init];
    [registerButton addTarget:self action:@selector(onRegister:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:registerButton];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(hintLabel.mas_right).offset(100);
        make.bottom.equalTo(view.mas_top).offset(-20);
    }];
    
    UILabel *registerLabel = [[UILabel alloc] init];
    registerLabel.font = [UIFont boldSystemFontOfSize:30];
    registerLabel.text = @"注册";
    registerLabel.textColor = [UIColor colorWithHexString:@"0x767676"];
    [registerButton addSubview:registerLabel];
    [registerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(registerButton);
    }];
    
    UILabel *userNameLabel = [[UILabel alloc] init];
    userNameLabel.text = @"手机号";
    userNameLabel.font = [UIFont boldSystemFontOfSize:20];
    [view addSubview:userNameLabel];
    [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(view).offset(20);
    }];
    
    self.userNameField = [[UITextField alloc] init];
    self.userNameField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.userNameField.placeholder = @"请输入手机号";
    self.userNameField.returnKeyType = UIReturnKeyNext;
    self.userNameField.keyboardType = UIKeyboardTypePhonePad;
    self.userNameField.delegate = self;
    self.userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.userNameField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.userNameField];
    [self.userNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userNameLabel.mas_bottom).offset(16);
        make.right.equalTo(view).offset(-20);
        make.left.equalTo(view).offset(20);
    }];
    
    UIView *userNameLine = [[UIView alloc] init];
    userNameLine.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [view addSubview:userNameLine];
    [userNameLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.left.right.equalTo(self.userNameField);
    }];
    
    UILabel *passwordLabel = [[UILabel alloc] init];
    passwordLabel.text = @"密码";
    passwordLabel.font = [UIFont boldSystemFontOfSize:20];
    [view addSubview:passwordLabel];
    [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.userNameField.mas_bottom).offset(27);
    }];
    
    self.passwordField = [[PasswordTextField alloc] init];
    self.passwordField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.passwordField.placeholder = @"请输入密码";
    self.passwordField.returnKeyType = UIReturnKeyDone;
    self.passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordField.delegate = self;
    [self.passwordField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.passwordField];
    [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passwordLabel.mas_bottom).offset(16);
        make.right.equalTo(view).offset(-20);
        make.left.equalTo(view).offset(20);
    }];
    
    UIView *passwordLine = [[UIView alloc] init];
    passwordLine.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [view addSubview:passwordLine];
    [passwordLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.left.right.equalTo(self.passwordField);
    }];
    
    self.loginBtn = [[UIButton alloc] init];
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = 4.f;
    self.loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.loginBtn.backgroundColor = [UIColor colorWithHexString:@"0xe1e1e1"];
    self.loginBtn.enabled = NO;
    [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginBtn addTarget:self action:@selector(onLoginButton:) forControlEvents:UIControlEventTouchDown];
    [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(52);
    }];

    self.userNameField.text = savedName;
    
    UIButton *forgetPassswordButton = [[UIButton alloc] init];
    NSMutableAttributedString *btnText = [[NSMutableAttributedString alloc] initWithString:@"忘记密码"];
    [btnText addAttribute:NSUnderlineStyleAttributeName value:@1 range:NSMakeRange(0, btnText.length)];
    [btnText addAttribute:NSUnderlineColorAttributeName value:[UIColor colorWithHexString:@"0x4970ba"] range:NSMakeRange(0, btnText.length)];
    [forgetPassswordButton setAttributedTitle:btnText forState:UIControlStateNormal];
    [forgetPassswordButton setTitleColor:[UIColor colorWithHexString:@"0x4970ba"] forState:UIControlStateNormal];
    forgetPassswordButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [forgetPassswordButton addTarget:self action:@selector(onForgetBtn:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:forgetPassswordButton];
    [forgetPassswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordField.mas_bottom).offset(4);
        make.right.equalTo(view).offset(-20);
    }];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.isKickedOff) {
        self.isKickedOff = NO;
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:@"您的账号已在其他手机登录" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];

        [actionSheet addAction:actionCancel];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)onRegister:(id)sender {
    WFCRegisterViewController *vc = [[WFCRegisterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)resetKeyboard:(id)sender {
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)onLoginButton:(id)sender {
    NSString *user = self.userNameField.text;
    NSString *password = self.passwordField.text;
  
    if (!user.length || !password.length) {
        return;
    }
    
    [self resetKeyboard:nil];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"登录中...";
    [hud showAnimated:YES];
    
    void(^errorBlock)(int errCode, NSString *message) = ^(int errCode, NSString *message) {
        NSLog(@"login error with code %d, message %@", errCode, message);
      dispatch_async(dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"登录失败";
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:1.f];
      });
    };
    
    void(^successBlock)(NSString *userId, NSString *token, BOOL newUser, NSString *resetCode) = ^(NSString *userId, NSString *token, BOOL newUser, NSString *resetCode) {
        [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"savedName"];
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"savedToken"];
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"savedUserId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        //需要注意token跟clientId是强依赖的，一定要调用getClientId获取到clientId，然后用这个clientId获取token，这样connect才能成功，如果随便使用一个clientId获取到的token将无法链接成功。
        [[WFCCNetworkService sharedInstance] connect:userId token:token];
        
        [hud hideAnimated:YES];
        WFCBaseTabBarController *tabBarVC = [WFCBaseTabBarController new];
        [UIApplication sharedApplication].delegate.window.rootViewController =  tabBarVC;
    };
    
    [[AppService sharedAppService] loginWithMobile:user password:password success:^(NSString *userId, NSString *token, BOOL newUser) {
        successBlock(userId, token, newUser, nil);
    } error:errorBlock];
}

- (void)onForgetBtn:(id)sender {
    WFCResetPasswordViewController *vc = [[WFCResetPasswordViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userNameField) {
        [self.passwordField becomeFirstResponder];
    } else if(textField == self.passwordField) {
        [self onLoginButton:nil];
    }
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    return YES;
}
#pragma mark - UITextInputDelegate
- (void)textDidChange:(id<UITextInput>)textInput {
    if (textInput == self.userNameField) {
        [self updateBtn];
    } else if (textInput == self.passwordField) {
        [self updateBtn];
    }
}

- (void)updateBtn {
    if (![self isValidNumber]) {
        [self.loginBtn setBackgroundColor:[UIColor grayColor]];
        self.loginBtn.enabled = NO;
        
        return;
    }
    
    if ([self isValidCode]) {
        [self.loginBtn setBackgroundColor:[UIColor colorWithHexString:@"0x4970ba"]];
        self.loginBtn.enabled = YES;
    } else {
        [self.loginBtn setBackgroundColor:[UIColor grayColor]];
        self.loginBtn.enabled = NO;
    }
}

- (BOOL)isValidNumber {
    NSString * MOBILE = @"^((1[23456789]))\\d{9}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    if (self.userNameField.text.length == 11 && ([regextestmobile evaluateWithObject:self.userNameField.text] == YES)) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isValidCode {
    if (self.passwordField.text.length >= 1) {
        return YES;
    } else {
        return NO;
    }
}
@end
