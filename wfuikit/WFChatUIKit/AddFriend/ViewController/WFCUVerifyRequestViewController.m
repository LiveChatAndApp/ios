//
//  WFCUVerifyRequestViewController.m
//  WFChatUIKit
//
//  Created by WF Chat on 2018/11/4.
//  Copyright © 2018 WF Chat. All rights reserved.
//

#import "WFCUVerifyRequestViewController.h"

#import <WFChatClient/WFCChatClient.h>

#import "RadioButton.h"
#import "MBProgressHUD.h"
#import "WFCUConfigManager.h"
#import "masonry.h"
#import "UIColor+YH.h"
#import "UIView+Toast.h"

@interface WFCUVerifyRequestViewController ()

@property(nonatomic, strong)UITextField *messageField;
@property(nonatomic, strong)UITextField *verificationField;
@property(nonatomic, strong)NSArray<RadioButton *> *radioButtonGroup;
@property(nonatomic, assign)BOOL verification;
@property(nonatomic, strong)UIView *verificationFieldView;
@property (nonatomic, strong)MASConstraint *verificationConstraint;

@end

@implementation WFCUVerifyRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.verification = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"发送好友邀请";
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    
    UIView *messageView = [self createMessageView];
    [self.view addSubview:messageView];
    [messageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(8);
    }];
    
    UIView *verificationView = [self createVerificationView];
    [self.view addSubview:verificationView];
    [verificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(messageView.mas_bottom).offset(8);
    }];
    
    UIButton *rightButton = [[UIButton alloc] init];
    [rightButton setTitle:WFCString(@"Send") forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"0x4970BA"] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [rightButton addTarget:self action:@selector(onSend) forControlEvents:UIControlEventTouchDown];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard)]];
}

- (UIView *)createMessageView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.whiteColor;
    
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.text = @"发送信息";
    messageLabel.font = [UIFont boldSystemFontOfSize:15];
    [view addSubview:messageLabel];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.top.equalTo(view).offset(10);
    }];
    
    self.messageField = [[UITextField alloc] init];
    self.messageField.font = [UIFont systemFontOfSize:16];
    self.messageField.placeholder = @"请输入";
    [view addSubview:self.messageField];
    [self.messageField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.right.equalTo(view).offset(-15);
        make.top.equalTo(messageLabel.mas_bottom).offset(20);
    }];
    
    WFCCUserInfo *me = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFCCNetworkService sharedInstance].userId refresh:NO];
    if (me != nil) {
        self.messageField.text = [NSString stringWithFormat:WFCString(@"DefaultAddFriendReason"), me.displayName];
    }
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.messageField);
        make.top.equalTo(self.messageField.mas_bottom).offset(1);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.text = @"发送好友邀请需等对方接受，才会成为好友";
    hintLabel.font = [UIFont systemFontOfSize:13];
    hintLabel.textColor = [UIColor colorWithHexString:@"0xadadad"];
    [view addSubview:hintLabel];
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.right.equalTo(view).offset(-15);
        make.top.equalTo(self.messageField.mas_bottom).offset(4);
        make.bottom.equalTo(view).offset(-20);
    }];
    
    return view;
}

- (UIView *)createVerificationView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.whiteColor;
    
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.text = @"好友验证";
    messageLabel.font = [UIFont boldSystemFontOfSize:15];
    [view addSubview:messageLabel];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.top.equalTo(view).offset(10);
    }];
    
    RadioButton *noVerificationButton = [[RadioButton alloc] init];
    noVerificationButton.title = @"免验证直接通过";
    noVerificationButton.tag = 0;
    noVerificationButton.selected = YES;
    [noVerificationButton addTarget:self action:@selector(onRadioButton:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:noVerificationButton];
    [noVerificationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(17);
        make.top.equalTo(messageLabel.mas_bottom).offset(20);
    }];
    
    RadioButton *verificationButton = [[RadioButton alloc] init];
    verificationButton.title = @"需要对方验证通过";
    verificationButton.tag = 1;
    [verificationButton addTarget:self action:@selector(onRadioButton:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:verificationButton];
    [verificationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(17);
        make.top.equalTo(noVerificationButton.mas_bottom).offset(24);
    }];
    
    self.verificationFieldView = [[UIView alloc] init];
    self.verificationFieldView.hidden = YES;
    [view addSubview:self.verificationFieldView];
    [self.verificationFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(view);
        make.top.equalTo(verificationButton.mas_bottom).offset(22);
        make.bottom.equalTo(view).offset(-10);
        self.verificationConstraint = make.height.mas_equalTo(1);
    }];

    self.verificationField = [[UITextField alloc] init];
    self.verificationField.font = [UIFont systemFontOfSize:16];
    self.verificationField.placeholder = @"请设置好友验证";
    [self.verificationFieldView addSubview:self.verificationField];
    [self.verificationField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.verificationFieldView).offset(15);
        make.right.equalTo(self.verificationFieldView).offset(-15);
        make.top.equalTo(self.verificationFieldView);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [self.verificationFieldView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.verificationField);
        make.top.equalTo(self.verificationField.mas_bottom).offset(1);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.text = @"对方需要输入您设置的好友验证，才会成为好友";
    hintLabel.font = [UIFont systemFontOfSize:13];
    hintLabel.textColor = [UIColor colorWithHexString:@"0xadadad"];
    [self.verificationFieldView addSubview:hintLabel];
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.verificationFieldView).offset(15);
        make.right.equalTo(self.verificationFieldView).offset(-15);
        make.top.equalTo(self.verificationField.mas_bottom).offset(4);
        make.bottom.equalTo(self.verificationFieldView).offset(-12);
    }];
    
    self.radioButtonGroup = @[verificationButton, noVerificationButton];
    
    return view;
}

- (void)resetKeyboard {
    [self.messageField resignFirstResponder];
    [self.verificationField resignFirstResponder];
}

- (void)setVerification:(BOOL)verification {
    _verification = verification;
    if (self.verificationFieldView == nil) {
        return;
    }
    
    if (verification) {
        [UIView animateWithDuration:0.4 animations:^{
            self.verificationFieldView.hidden = NO;
            [self.verificationConstraint deactivate];
            [self.view layoutIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            self.verificationField.text = @"";
            self.verificationFieldView.hidden = YES;
            [self.verificationConstraint activate];
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)onRadioButton:(RadioButton *)sender {
    for (RadioButton *btn in self.radioButtonGroup) {
        if (btn != sender) {
            btn.selected = NO;
        }
    }
    
    sender.selected = YES;
    if (sender.tag == 1) {
        self.verification = YES;
        return;
    }
    
    self.verification = NO;
}

- (void)onSend {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = WFCString(@"Sending");
    [hud showAnimated:YES];
    
    InviteFriendRequestModel *model = [[InviteFriendRequestModel alloc] init];
    model.helloText = self.messageField.text;
    model.uid = self.userId;
    model.verify = [NSNumber numberWithBool:self.verification];
    model.verifyText = self.verificationField.text;
    
    [WFCUConfigManager.globalManager.appServiceProvider inviteFriendWithModel:model success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.parentViewController.view makeToast:@"发送好友已申请"];
            [self.navigationController popViewControllerAnimated:YES];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
        });
    }];
}

@end
