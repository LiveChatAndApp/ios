#import "TabBarTitleView.h"

#import "masonry.h"
#import "WFCUAddFriendViewController.h"
#import "WFCUCreateConversationViewController.h"
#import "WFCUContactListViewController.h"
#import "WFCUSearchChannelViewController.h"
#import "WFCUSeletedUserViewController.h"
#import "WFCUMessageListViewController.h"
#import "WFCUImage.h"
#import "KxMenu.h"
#import "QrCodeHelper.h"

@interface TabBarTitleView ()

@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, readonly)UIViewController *currentViewController;
@property(nonatomic, strong)NSArray<KxMenuItem *> *menuItems;
@end

@implementation TabBarTitleView

- (instancetype)initWithRightButtonStyle:(RightButtonStyle)style
{
    self = [super init];
    if (self) {
        self.rightButtonStyle = style;
        [self setupUI];
        [self initMenu];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = UIColor.whiteColor;
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @" ";
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.top.equalTo(self).offset(33);
        make.bottom.equalTo(self);
    }];
    
    UIButton *barButton = [[UIButton alloc] init];
    if (self.rightButtonStyle == RightButtonStyleQRCode) {
        [barButton setImage:[WFCUImage imageNamed:@"qrcode"] forState:UIControlStateNormal];
    } else {
        [barButton setImage:[WFCUImage imageNamed:@"bar_plus"] forState:UIControlStateNormal];
    }
    
    [barButton addTarget:self action:@selector(onRightButtonTouched) forControlEvents:UIControlEventTouchDown];
    [self addSubview:barButton];
    [barButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.top.equalTo(self).offset(33);
        make.height.width.mas_equalTo(22);
        make.left.greaterThanOrEqualTo(self.titleLabel.mas_right);
    }];
}

- (void)initMenu {
    if ([[WFCCIMService sharedWFCIMService] isEnableSecretChat] && [[WFCCIMService sharedWFCIMService] isUserEnableSecretChat]) {
        self.menuItems = @[
            [KxMenuItem menuItem:WFCString(@"StartChat")
                           image:[WFCUImage imageNamed:@"menu_start_chat"]
                          target:self
                          action:@selector(startChatAction:)],
            [KxMenuItem menuItem:WFCString(@"StartSecretChat")
                           image:[WFCUImage imageNamed:@"menu_start_chat"]
                          target:self
                          action:@selector(startSecretChatAction:)],
            [KxMenuItem menuItem:@"添加朋友"
                           image:[WFCUImage imageNamed:@"menu_add_friends"]
                          target:self
                          action:@selector(addFriendsAction:)],
            [KxMenuItem menuItem:WFCString(@"SubscribeChannel")
                           image:[WFCUImage imageNamed:@"menu_listen_channel"]
                          target:self
                          action:@selector(listenChannelAction:)],
            [KxMenuItem menuItem:WFCString(@"ScanQRCode")
                           image:[WFCUImage imageNamed:@"menu_scan_qr"]
                          target:self
                          action:@selector(scanQrCodeAction:)]
        ];
    } else {
        self.menuItems = @[
            [KxMenuItem menuItem:WFCString(@"StartChat")
                           image:[WFCUImage imageNamed:@"menu_start_chat"]
                          target:self
                          action:@selector(startChatAction:)],
            [KxMenuItem menuItem:@"添加朋友"
                           image:[WFCUImage imageNamed:@"menu_add_friends"]
                          target:self
                          action:@selector(addFriendsAction:)],
            [KxMenuItem menuItem:WFCString(@"ScanQRCode")
                           image:[WFCUImage imageNamed:@"menu_scan_qr"]
                          target:self
                          action:@selector(scanQrCodeAction:)]
        ];
    }
}

- (void)startChatAction:(id)sender {
    NSNumber *createGroupEnable = [NSUserDefaults.standardUserDefaults objectForKey:@"createGroupEnable"];
    if (createGroupEnable.integerValue == 0) {
        return;
    }
    
    WFCUContactListViewController *pvc = [[WFCUContactListViewController alloc] init];
    pvc.selectContact = YES;
    pvc.multiSelect = YES;
    pvc.disableUsersSelected = YES;
    pvc.title = @"发起群聊";
    pvc.isPushed = YES;
    pvc.disableUsers = [[NSMutableArray alloc] init];
    pvc.noBack = YES;
    pvc.hidesBottomBarWhenPushed = YES;
    [self.currentViewController.navigationController pushViewController:pvc animated:YES];
    
    pvc.selectResult = ^(NSArray<NSString *> *contacts) {
        WFCUCreateConversationViewController *vc = [[WFCUCreateConversationViewController alloc] init];
        vc.memberList = contacts;
        [self.currentViewController.navigationController pushViewController:vc animated:YES];
    };
}

- (void)startSecretChatAction:(id)sender {
    WFCUSeletedUserViewController *pvc = [[WFCUSeletedUserViewController alloc] init];
    pvc.type = Horizontal;
    pvc.maxSelectCount = 1;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;

    pvc.selectResult = ^(NSArray<NSString *> *contacts) {
        [navi dismissViewControllerAnimated:NO completion:nil];
        if (contacts.count == 1) {
            [[WFCCIMService sharedWFCIMService] createSecretChat:contacts[0] success:^(NSString *targetId, int line) {
                WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
                mvc.conversation = [WFCCConversation conversationWithType:SecretChat_Type target:targetId line:line];
                mvc.hidesBottomBarWhenPushed = YES;
                [self.currentViewController.navigationController pushViewController:mvc animated:YES];
            } error:^(int error_code) {
                
            }];
            
        }
    };
    
    [self.currentViewController.navigationController presentViewController:navi animated:YES completion:nil];
}

- (void)addFriendsAction:(id)sender {
    UIViewController *addFriendVC = [[WFCUAddFriendViewController alloc] init];
    addFriendVC.hidesBottomBarWhenPushed = YES;
    [self.currentViewController.navigationController pushViewController:addFriendVC animated:YES];
}

- (void)listenChannelAction:(id)sender {
    UIViewController *searchChannelVC = [[WFCUSearchChannelViewController alloc] init];
    searchChannelVC.hidesBottomBarWhenPushed = YES;
    [self.currentViewController.navigationController pushViewController:searchChannelVC animated:YES];
}

- (void)scanQrCodeAction:(id)sender {
    if (gQrCodeDelegate) {
        [gQrCodeDelegate scanQrCode:self.currentViewController.navigationController];
    }
}

- (void)goToQrCodeVC {
    if (gQrCodeDelegate) {
        [gQrCodeDelegate showQrCodeViewController:self.currentViewController.navigationController type:QRType_User target:[WFCCNetworkService sharedInstance].userId];
    }
}

- (void)onRightButtonTouched {
    if (self.rightButtonStyle == RightButtonStyleQRCode) {
        [self goToQrCodeVC];
    } else {
        [self showMenu];
    }
}

- (void)showMenu {
    if ([KxMenu isShowing]) {
        [KxMenu dismissMenu];
        return;
    }
    
    
    NSNumber *createGroupEnable = [NSUserDefaults.standardUserDefaults objectForKey:@"createGroupEnable"];
    if (createGroupEnable.integerValue == 0) {
        self.menuItems[0].foreColor = UIColor.grayColor;
    } else {
        self.menuItems[0].foreColor = UIColor.whiteColor;
    }
    
    [KxMenu showMenuInView:self.superview
                  fromRect:CGRectMake(self.bounds.size.width - 56, kStatusBarAndNavigationBarHeight, 48, 5)
                 menuItems:self.menuItems];
}

- (UIViewController *)currentViewController {
    UIResponder *responder = [self nextResponder];
        while (responder != nil) {
            if ([responder isKindOfClass:[UIViewController class]]) {
                return (UIViewController *)responder;
            }
            responder = [responder nextResponder];
        }
    
        return nil;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

@end
