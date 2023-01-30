//
//  ModifyMyProfileViewController.m
//  WildFireChat
//
//  Created by heavyrain.lee on 2018/5/20.
//  Copyright © 2018 WildFireChat. All rights reserved.
//

#import "WFCUModifyMyProfileViewController.h"
#import "MBProgressHUD.h"
#import <WFChatClient/WFCChatClient.h>
#import <WFChatClient/UpdateProfileModel.h>
#import <WFChatUIKit/WFCUUtilities.h>
#import "WFCUConfigManager.h"
#import "UIView+Toast.h"
#import "masonry.h"
#import "UIColor+YH.h"

@interface WFCUModifyMyProfileViewController () <UITextFieldDelegate>
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UILabel *hintLabel;
@property(nonatomic, strong)UITextField *textField;
@property(nonatomic, assign)BOOL isAccount;
@end

@implementation WFCUModifyMyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isAccount = NO;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupUI];
    [self setModifyTypeData:self.modifyType];
    [self.textField becomeFirstResponder];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard)]];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(8);
        make.left.right.equalTo(self.view);
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"0x242424"];
    [view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.top.equalTo(view).offset(10);
    }];
    
    self.textField = [[UITextField alloc] init];
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
        make.left.equalTo(view).offset(15);
        make.right.equalTo(view).offset(-15);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"0xadadad"];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textField.mas_bottom).offset(1);
        make.left.right.equalTo(self.textField);
        make.height.mas_equalTo(1);
    }];
    
    self.hintLabel = [[UILabel alloc] init];
    self.hintLabel.numberOfLines = 0;
    self.hintLabel.textColor = [UIColor colorWithHexString:@"0xadadad"];
    self.hintLabel.font = [UIFont systemFontOfSize:13];
    [view addSubview:self.hintLabel];
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.right.equalTo(view).offset(-15);
        make.top.equalTo(self.textField.mas_bottom).offset(7);
        make.bottom.equalTo(view).offset(-24);
    }];
    
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor colorWithHexString:@"0x4970BA"];
    button.layer.cornerRadius = 4;
    button.clipsToBounds = YES;
    [button setTitle:@"保存" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onDone) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.bottom.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(52);
    }];
}

- (void)setModifyTypeData:(NSInteger)modifyType {
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFCCNetworkService sharedInstance].userId refresh:NO];
    
    switch (self.modifyType) {
        case Modify_Email:
            self.title = WFCString(@"ModifyEmail");
            self.textField.text = userInfo.email;
            self.textField.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        
        case Modify_Mobile:
            self.title = WFCString(@"ModifyMobile");
            self.textField.text = userInfo.mobile;
            self.textField.keyboardType = UIKeyboardTypePhonePad;
            break;
        
        case Modify_Social:
            self.title = WFCString(@"ModifySocialAccount");
            self.textField.text = userInfo.social;
            break;
            
        case Modify_Address:
            self.title = WFCString(@"ModifyAddress");
            self.textField.text = userInfo.address;
            break;
            
        case Modify_Company:
            self.title = WFCString(@"ModifyCompanyInfo");
            self.textField.text = userInfo.company;
            break;
            
        case Modify_DisplayName:
            self.title = WFCString(@"ModifyNickname");
            self.titleLabel.text = @"昵称";
            self.textField.text = userInfo.displayName;
            self.hintLabel.text = @"好名字可以让你的朋友更容易记住你。";
            break;
        case 100:
            self.title = @"修改账户名";
            self.textField.text = userInfo.name;
            self.isAccount = YES;
            self.textField.keyboardType = UIKeyboardTypeASCIICapable;
            break;
        default:
            break;
    }
}

- (void)resetKeyboard {
    [self.textField resignFirstResponder];
}

- (void)onDone {
    [self.textField resignFirstResponder];
    if (self.modifyType == Modify_DisplayName) {
        if (![self checkNickName:self.textField.text]) {
            return;
        }
    }
    
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = WFCString(@"Updating");
    [hud showAnimated:YES];
    
    UpdateProfileModel *model = [[UpdateProfileModel alloc] init];
    [model setValue:self.textField.text type:self.modifyType];
    
    [WFCUConfigManager.globalManager.appServiceProvider updateProfileWithModel:model progress:nil success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:NO];
            self.onModified(self.modifyType, self.textField.text);
            [self.navigationController popViewControllerAnimated:YES];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:NO];
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = message;
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
        });
    }];
}

- (BOOL)checkNickName:(NSString *)string {
    if (string.length == 0) {
        [self.view makeToast:@"请输入昵称"];
        return NO;
    }
    
    if (string.length > 20) {
        [self.view makeToast:@"用户昵称上限20个字"];
        return NO;
    }
    
    if ([WFCUUtilities containEmoji:string]) {
        [self.view makeToast:@"不能包含表情符号"];
        return NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.modifyType  == 100) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        BOOL ret = [string isEqualToString:filtered];
        if(!ret) {
            [self.view makeToast:@"不支持的字符！仅支持英文字母和数字！" duration:0.5 position:CSToastPositionCenter];
        }
        return ret;
    }
    return YES;
}

- (void)textFieldChange:(UITextField *)field {
    if ([field.text containsString:@"  "]) {
        [field resignFirstResponder];
        field.text = [field.text stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        [self.view makeToast:@"不可连续输入空白键"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onDone];
    return YES;
}

@end
