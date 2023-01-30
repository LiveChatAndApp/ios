#import "WFCRegisterViewController.h"

#import <WFChatClient/WFCChatClient.h>
#import <WFChatUIKit/WFChatUIKit.h>
#import "AppDelegate.h"
#import "WFCBaseTabBarController.h"
#import "WFCSetPasswordViewController.h"
#import "MBProgressHUD.h"
#import "WFCPrivacyViewController.h"
#import "AppService.h"
#import "UIColor+YH.h"
#import "UIFont+YH.h"

@interface WFCRegisterViewController () <UITextFieldDelegate>
@property (strong, nonatomic) UITextField *inviteCodeField;
@property (strong, nonatomic) UITextField *userNameField;
@property (strong, nonatomic) UITextField *verificationCodeField;
@property (strong, nonatomic) UIButton *registerBtn;
@property (strong, nonatomic) UIButton *sendCodeBtn;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, assign) NSTimeInterval sendCodeTime;
@end

@implementation WFCRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    
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
    
    UIControl *hintButton = [[UIControl alloc] init];
    [hintButton addTarget:self action:@selector(onLoginButton:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:hintButton];
    [hintButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.bottom.equalTo(view.mas_top).offset(-20);
    }];
    
    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.font = [UIFont boldSystemFontOfSize:30];
    hintLabel.text = @"登录";
    hintLabel.textColor = [UIColor colorWithHexString:@"0x767676"];
    [hintButton addSubview:hintLabel];
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(hintButton);
    }];
    
    UILabel *registerLabel = [[UILabel alloc] init];
    NSMutableAttributedString *registerText = [[NSMutableAttributedString alloc] initWithString:@"注册"];
    [registerText addAttribute:NSUnderlineStyleAttributeName value:@1 range:NSMakeRange(0, registerText.length)];
    [registerText addAttribute:NSUnderlineColorAttributeName value:[UIColor colorWithHexString:@"0x4970ba"] range:NSMakeRange(0, registerText.length)];
    registerLabel.attributedText = registerText;
    registerLabel.font = [UIFont boldSystemFontOfSize:30];
    registerLabel.textColor = [UIColor colorWithHexString:@"0x4970ba"];
    [self.view addSubview:registerLabel];
    [registerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(hintButton.mas_right).offset(100);
        make.bottom.equalTo(view.mas_top).offset(-20);
    }];
    
    UILabel *inviteCodeLabel = [[UILabel alloc] init];
    inviteCodeLabel.text = @"邀请码";
    inviteCodeLabel.font = [UIFont boldSystemFontOfSize:20];
    [view addSubview:inviteCodeLabel];
    [inviteCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(view).offset(20);
    }];
    
    self.inviteCodeField = [[UITextField alloc] init];
    self.inviteCodeField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.inviteCodeField.placeholder = @"请输入邀请码";
    self.inviteCodeField.returnKeyType = UIReturnKeyNext;
    self.inviteCodeField.keyboardType = UIKeyboardTypeASCIICapable;
    self.inviteCodeField.delegate = self;
    self.inviteCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.inviteCodeField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.inviteCodeField];
    [self.inviteCodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(inviteCodeLabel.mas_bottom).offset(16);
        make.right.equalTo(view).offset(-20);
        make.left.equalTo(view).offset(20);
    }];
    
    UIView *inviteCodeLine = [[UIView alloc] init];
    inviteCodeLine.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [view addSubview:inviteCodeLine];
    [inviteCodeLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.left.right.equalTo(self.inviteCodeField);
    }];
    
    UILabel *userNameLabel = [[UILabel alloc] init];
    userNameLabel.text = @"手机号";
    userNameLabel.font = [UIFont boldSystemFontOfSize:20];
    [view addSubview:userNameLabel];
    [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.inviteCodeField.mas_bottom).offset(27);
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
    
    UILabel *verificationCodeLabel = [[UILabel alloc] init];
    verificationCodeLabel.text = @"验证码";
    verificationCodeLabel.font = [UIFont boldSystemFontOfSize:20];
    [view addSubview:verificationCodeLabel];
    [verificationCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.userNameField.mas_bottom).offset(27);
    }];
    
    self.verificationCodeField = [[UITextField alloc] init];
    self.verificationCodeField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.verificationCodeField.placeholder = @"请输入验证码";
    self.verificationCodeField.returnKeyType = UIReturnKeyDone;
    self.verificationCodeField.keyboardType = UIKeyboardTypeNumberPad;
    self.verificationCodeField.delegate = self;
    self.verificationCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.verificationCodeField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.verificationCodeField];
    [self.verificationCodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(verificationCodeLabel.mas_bottom).offset(16);
        make.left.equalTo(view).offset(20);
    }];
    
    UIView *verificationCodeLine = [[UIView alloc] init];
    verificationCodeLine.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [view addSubview:verificationCodeLine];
    [verificationCodeLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.left.right.equalTo(self.verificationCodeField);
    }];
    
    self.sendCodeBtn = [[UIButton alloc] init];
    [self.sendCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    self.sendCodeBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
    self.sendCodeBtn.backgroundColor = [UIColor colorWithHexString:@"0xe1e1e1"];
    self.sendCodeBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    self.sendCodeBtn.layer.cornerRadius = 4;
    [self.sendCodeBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.sendCodeBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.sendCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendCodeBtn addTarget:self action:@selector(onSendCode:) forControlEvents:UIControlEventTouchDown];
    self.sendCodeBtn.enabled = NO;
    [view addSubview:self.sendCodeBtn];
    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).offset(-15);
        make.left.equalTo(self.verificationCodeField.mas_right).offset(12);
        make.bottom.equalTo(self.verificationCodeField);
        make.width.mas_greaterThanOrEqualTo(50);
    }];
    
    self.registerBtn = [[UIButton alloc] init];
    [self.registerBtn addTarget:self action:@selector(onRegisterButton:) forControlEvents:UIControlEventTouchDown];
    self.registerBtn.layer.masksToBounds = YES;
    self.registerBtn.layer.cornerRadius = 4.f;
    [self.registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    self.registerBtn.backgroundColor = [UIColor colorWithHexString:@"0xe1e1e1"];
    [self.registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.registerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.registerBtn.enabled = NO;
    [self.view addSubview:self.registerBtn];
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(52);
    }];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)onSendCode:(id)sender {
    self.sendCodeBtn.enabled = NO;
    [self.sendCodeBtn setTitle:@"短信发送中" forState:UIControlStateNormal];
    __weak typeof(self)ws = self;
    [[AppService sharedAppService] sendLoginCode:self.userNameField.text success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws sendCodeDone:YES];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resetKeyboard:nil];
            [self.view showToast:message];
            [ws sendCodeDone:NO];
        });
    }];
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                self.sendCodeBtn.enabled = YES;
            });
        }
    });
}

- (void)resetKeyboard:(id)sender {
    [self.inviteCodeField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    [self.verificationCodeField resignFirstResponder];
}

- (void)onLoginButton:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)onRegisterButton:(id)sender {
    NSString *user = self.userNameField.text;
    NSString *inviteCode = self.inviteCodeField.text;
    NSString *verificationCode = self.verificationCodeField.text;
  
    if (!user.length || !verificationCode.length) {
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
        [hud hideAnimated:YES];
        if (resetCode == nil || [resetCode isEqualToString:@""]) {
            return;
        }
        
        WFCSetPasswordViewController *vc = [[WFCSetPasswordViewController alloc] init];
        vc.resetCode = resetCode;
        vc.hidesBottomBarWhenPushed = YES;
        vc.successBlock = ^{
            [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"savedName"];
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"savedToken"];
            [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"savedUserId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //需要注意token跟clientId是强依赖的，一定要调用getClientId获取到clientId，然后用这个clientId获取token，这样connect才能成功，如果随便使用一个clientId获取到的token将无法链接成功。
            [[WFCCNetworkService sharedInstance] connect:userId token:token];
        };
        
        if (@available(iOS 11.0, *)) {
            self.navigationItem.backButtonTitle = @"";
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:YES];
        });
    };

    [[AppService sharedAppService] loginWithMobile:user inviteCode:inviteCode verifyCode:verificationCode success:^(NSString * _Nonnull userId, NSString * _Nonnull token, BOOL newUser, NSString * _Nonnull resetCode) {
        successBlock(userId, token, newUser, resetCode);
    } error:errorBlock];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userNameField) {
        [self.verificationCodeField becomeFirstResponder];
    } else if(textField == self.verificationCodeField) {
        [self onLoginButton:nil];
    }
    return NO;
}

#pragma mark - UITextInputDelegate
- (void)textDidChange:(id<UITextInput>)textInput {
    if (textInput == self.userNameField) {
        [self updateBtn];
    } else if (textInput == self.verificationCodeField) {
        [self updateBtn];
    }
}

- (void)updateBtn {
    if (![self isValidNumber]) {
        [self.sendCodeBtn setBackgroundColor:[UIColor grayColor]];
        self.sendCodeBtn.enabled = NO;
        [self.registerBtn setBackgroundColor:[UIColor grayColor]];
        self.registerBtn.enabled = NO;
        
        return;
    }
    
    if (!self.countdownTimer) {
        [self.sendCodeBtn setBackgroundColor:[UIColor colorWithHexString:@"0x4970ba"]];
        self.sendCodeBtn.enabled = YES;
    } else {
        [self.sendCodeBtn setBackgroundColor:[UIColor grayColor]];
        self.sendCodeBtn.enabled = NO;
    }
    
    if ([self isValidCode]) {
        [self.registerBtn setBackgroundColor:[UIColor colorWithHexString:@"0x4970ba"]];
        self.registerBtn.enabled = YES;
    } else {
        [self.registerBtn setBackgroundColor:[UIColor grayColor]];
        self.registerBtn.enabled = NO;
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
    if (self.verificationCodeField.text.length >= 1) {
        return YES;
    } else {
        return NO;
    }
}
@end
