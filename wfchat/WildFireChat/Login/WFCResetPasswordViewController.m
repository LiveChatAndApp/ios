//
//  WFCResetPasswordViewController.m
//  WildFireChat
//
//  Created by Rain on 2022/8/4.
//  Copyright © 2022 WildFireChat. All rights reserved.
//

#import "WFCResetPasswordViewController.h"

#import "AppService.h"
#import "MBProgressHUD.h"
#import "WFCSetNewPasswordViewController.h"
#import "UIColor+YH.h"
#import "UIFont+YH.h"

@interface WFCResetPasswordViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *userNameField;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UITextField *resetCodeField;
@property (strong, nonatomic) UIButton *sendCodeBtn;
@property (strong, nonatomic) UIButton *nextButton;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, assign) NSTimeInterval sendCodeTime;
@end

@implementation WFCResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    }
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"忘记密码";
    titleLabel.font = [UIFont boldSystemFontOfSize:30];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.view).offset(20);
    }];
    
    UILabel *userNameLabel = [[UILabel alloc] init];
    userNameLabel.text = @"手机号";
    userNameLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:userNameLabel];
    [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(titleLabel.mas_bottom).offset(40);
    }];
    
    self.userNameField = [[UITextField alloc] init];
    self.userNameField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.userNameField.placeholder = @"请输入手机号";
    self.userNameField.returnKeyType = UIReturnKeyNext;
    self.userNameField.keyboardType = UIKeyboardTypePhonePad;
    self.userNameField.delegate = self;
    self.userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.userNameField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.userNameField];
    [self.userNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(userNameLabel.mas_bottom).offset(16);
    }];
    
    UIView *userNameLine = [[UIView alloc] init];
    userNameLine.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [self.view addSubview:userNameLine];
    [userNameLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.left.right.equalTo(self.userNameField);
    }];
    
    UILabel *verificationCodeLabel = [[UILabel alloc] init];
    verificationCodeLabel.text = @"验证码";
    verificationCodeLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:verificationCodeLabel];
    [verificationCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.userNameField.mas_bottom).offset(27);
    }];
    
    self.resetCodeField = [[UITextField alloc] init];
    self.resetCodeField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.resetCodeField.placeholder = @"请输入验证码";
    self.resetCodeField.returnKeyType = UIReturnKeyDone;
    self.resetCodeField.keyboardType = UIKeyboardTypeNumberPad;
    self.resetCodeField.delegate = self;
    self.resetCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.resetCodeField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.resetCodeField];
    [self.resetCodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(verificationCodeLabel.mas_bottom).offset(16);
    }];
    
    UIView *verificationCodeLine = [[UIView alloc] init];
    verificationCodeLine.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [self.view addSubview:verificationCodeLine];
    [verificationCodeLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.left.right.equalTo(self.resetCodeField);
    }];
    
    self.sendCodeBtn = [[UIButton alloc] init];
    [self.sendCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    self.sendCodeBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
    self.sendCodeBtn.backgroundColor = [UIColor colorWithHexString:@"0xe1e1e1"];
    self.sendCodeBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    self.sendCodeBtn.layer.cornerRadius = 4;
    self.sendCodeBtn.enabled = NO;
    [self.sendCodeBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.sendCodeBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.sendCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendCodeBtn addTarget:self action:@selector(onSendCode:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.sendCodeBtn];
    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-15);
        make.left.equalTo(self.resetCodeField.mas_right).offset(12);
        make.bottom.equalTo(self.resetCodeField);
        make.width.mas_greaterThanOrEqualTo(50);
    }];
    
    self.nextButton = [[UIButton alloc] init];
    self.nextButton.layer.masksToBounds = YES;
    self.nextButton.layer.cornerRadius = 4.f;
    self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.nextButton.backgroundColor = [UIColor colorWithHexString:@"0xe1e1e1"];
    self.nextButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
    self.nextButton.enabled = NO;
    [self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(onNextBtn:) forControlEvents:UIControlEventTouchDown];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:self.nextButton];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(52);
    }];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard:)]];
}

- (void)onSendCode:(id)sender {
    self.sendCodeBtn.enabled = NO;
    [self.sendCodeBtn setTitle:@"短信发送中" forState:UIControlStateNormal];
    [[AppService sharedAppService] sendResetCode:self.userNameField.text success:^{
        [self sendCodeDone:YES];
    } error:^(NSString * _Nonnull message) {
        [self sendCodeDone:NO];
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

- (void)onNextBtn:(id)sender {
    NSString *user = self.userNameField.text;
    NSString *resetCode = self.resetCodeField.text;
    
    WFCSetNewPasswordViewController *vc = [[WFCSetNewPasswordViewController alloc] init];
    vc.user = user;
    vc.resetCode = resetCode;
    [self.navigationController pushViewController:vc animated:YES];
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
    if (self.resetCodeField.text.length >= 1) {
        return YES;
    } else {
        return NO;
    }
}

- (void)resetKeyboard:(id)sender {
    [self.userNameField resignFirstResponder];
    [self.resetCodeField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (void)textDidChange:(id<UITextInput>)textInput {
    [self updateBtn];
}

- (void)updateBtn {
    if (![self isValidNumber]) {
        [self.sendCodeBtn setBackgroundColor:[UIColor grayColor]];
        self.sendCodeBtn.enabled = NO;
        [self.nextButton setBackgroundColor:[UIColor grayColor]];
        self.nextButton.enabled = NO;
        
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
        [self.nextButton setBackgroundColor:[UIColor colorWithHexString:@"0x4970ba"]];
        self.nextButton.enabled = YES;
    } else {
        [self.nextButton setBackgroundColor:[UIColor grayColor]];
        self.nextButton.enabled = NO;
    }
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
