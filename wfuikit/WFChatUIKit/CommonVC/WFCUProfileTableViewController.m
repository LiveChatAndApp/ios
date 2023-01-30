//
//  WFCUProfileTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/22.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUProfileTableViewController.h"
#import <SDWebImage/SDWebImage.h>
#import <WFChatClient/WFCChatClient.h>
#import <WFChatUIKit/SDPhotoBrowser.h>
#import "WFCUMessageListViewController.h"
#import "MBProgressHUD.h"
#import "WFCUMyPortraitViewController.h"
#import "WFCUVerifyRequestViewController.h"
#import "WFCUGeneralModifyViewController.h"
#import "WFCUVideoViewController.h"
#if WFCU_SUPPORT_VOIP
#import <WFAVEngineKit/WFAVEngineKit.h>
#endif
#import "UIFont+YH.h"
#import "UIColor+YH.h"
#import "UIView+Toast.h"
#import "WFCUConfigManager.h"
#import "WFCUUserMessageListViewController.h"
#import "WFCUImage.h"
#import "masonry.h"

@interface WFCUProfileTableViewController () <UITableViewDelegate, UITableViewDataSource, SDPhotoBrowserDelegate>
@property (strong, nonatomic)UIImageView *portraitView;
@property (strong, nonatomic)UILabel *starLabel;
@property (strong, nonatomic)UITableViewCell *headerCell;

@property (strong, nonatomic)UITableViewCell *sendMessageCell;
@property (strong, nonatomic)UITableViewCell *voipCallCell;
@property (strong, nonatomic)UITableViewCell *addFriendCell;
@property (strong, nonatomic)UITableViewCell *momentCell;
@property (nonatomic, strong)UITableViewCell *userMessagesCell;

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray<UITableViewCell *> *cells;

@property (nonatomic, strong)WFCCUserInfo *IMUserInfo;
@property (nonatomic, strong)WFCCUserInfo *userInfo;
@property (nonatomic, strong)dispatch_group_t dispatchGroup;
@property (nonatomic, assign)BOOL isFriend;
@end

@implementation WFCUProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    }
    self.title = WFCString(@"UserInfomation");
    self.dispatchGroup = dispatch_group_create();
    self.isFriend = [[WFCCIMService sharedWFCIMService] isMyFriend:self.userId];
    
    UIButton *button = [[UIButton alloc] init];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [button setTitle:@"更多" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"0x4970ba"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onRightBtn:) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    __weak typeof(self)ws = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kUserInfoUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if ([ws.userId isEqualToString:note.object]) {
            WFCCUserInfo *userInfo = note.userInfo[@"userInfo"];
            ws.IMUserInfo = userInfo;
            [ws loadData];
        }
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.1)];
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    
    [self getUserInfo];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    keyWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    [keyWindow tintColorDidChange];
}

- (void)getUserInfo {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"读取中...";
    [hud showAnimated:YES];
    dispatch_group_enter(self.dispatchGroup);
    [WFCUConfigManager.globalManager.appServiceProvider getWFCCUserInfo:self.userId success:^(WFCCUserInfo * _Nonnull info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.userInfo = info;
            [self loadData];
            dispatch_group_leave(self.dispatchGroup);
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:message];
            dispatch_group_leave(self.dispatchGroup);
        });
    }];
    
    dispatch_group_enter(self.dispatchGroup);
    self.IMUserInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.userId refresh:YES];
    dispatch_group_leave(self.dispatchGroup);
    
    dispatch_group_notify(self.dispatchGroup, dispatch_get_main_queue(), ^{
        [self loadData];
        [hud hideAnimated:YES];
    });
}

- (void)onRightBtn:(id)sender {
    __weak typeof(self)ws = self;
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:WFCString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [actionSheet addAction:actionCancel];
    
    if (self.isFriend) {
        UIAlertAction *deleteFriendAction = [UIAlertAction actionWithTitle:WFCString(@"DeleteFriend") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
            hud.label.text = @"处理中...";
            [hud showAnimated:YES];
            
            [[WFCCIMService sharedWFCIMService] deleteFriend:ws.userId success:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES];
                    
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = @"处理成功";
                    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                    [hud hideAnimated:YES afterDelay:1.f];
                });
            } error:^(int error_code) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES];
                    
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = @"处理失败";
                    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                    [hud hideAnimated:YES afterDelay:1.f];
                });
            }];
        }];
        
        [actionSheet addAction:deleteFriendAction];
    } else {
        UIAlertAction *addFriendAction = [UIAlertAction actionWithTitle:WFCString(@"AddFriend") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            WFCUVerifyRequestViewController *vc = [[WFCUVerifyRequestViewController alloc] init];
            vc.userId = ws.userId;
            vc.sourceType = ws.sourceType;
            vc.sourceTargetId = ws.sourceTargetId;
            [ws.navigationController pushViewController:vc animated:YES];
        }];
        [actionSheet addAction:addFriendAction];
    }
    
    if ([[WFCCIMService sharedWFCIMService] isBlackListed:self.userId]) {
        UIAlertAction *addFriendAction = [UIAlertAction actionWithTitle:WFCString(@"RemoveFromBlacklist") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
            hud.label.text = @"处理中...";
            [hud showAnimated:YES];
            
            [[WFCCIMService sharedWFCIMService] setBlackList:ws.userId isBlackListed:NO success:^{
                [hud hideAnimated:YES];
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"处理成功";
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:1.f];
            } error:^(int error_code) {
                [hud hideAnimated:YES];
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"处理失败";
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:1.f];
            }];
        }];
        [actionSheet addAction:addFriendAction];
    } else if (self.IMUserInfo.type == 0) {  //Only normal user can add to blacklist, robot user not allowed.
        UIAlertAction *addFriendAction = [UIAlertAction actionWithTitle:WFCString(@"Add2Blacklist") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
            hud.label.text = @"处理中...";
            [hud showAnimated:YES];
            
            [[WFCCIMService sharedWFCIMService] setBlackList:ws.userId isBlackListed:YES success:^{
                [hud hideAnimated:YES];
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"处理成功";
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:1.f];
            } error:^(int error_code) {
                [hud hideAnimated:YES];
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"处理失败";
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:1.f];
            }];
        }];
        [actionSheet addAction:addFriendAction];
    }
    
    
    UIAlertAction *aliasAction = [UIAlertAction actionWithTitle:WFCString(@"SetAlias") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws setFriendNote];
    }];
    [actionSheet addAction:aliasAction];
    
    if (self.isFriend) {
        if ([[WFCCIMService sharedWFCIMService] isFavUser:self.userId]) {
            UIAlertAction *cancelStarAction = [UIAlertAction actionWithTitle:@"取消星标好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [ws setFavUser];
            }];
            [actionSheet addAction:cancelStarAction];
        } else {
            UIAlertAction *setStarAction = [UIAlertAction actionWithTitle:@"设置星标好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [ws setFavUser];
            }];
            [actionSheet addAction:setStarAction];
        }
    }
    
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}
- (void)loadData {
    self.cells = [[NSMutableArray alloc] init];
    
    self.headerCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self.headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.portraitView = [[UIImageView alloc] init];
    self.portraitView.layer.cornerRadius = 29;
    self.portraitView.layer.masksToBounds = YES;
    self.portraitView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPortrait)];
    [self.portraitView addGestureRecognizer:tap];
    [self.portraitView sd_setImageWithURL:[NSURL URLWithString:[self.IMUserInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage: [WFCUImage imageNamed:@"PersonalChat"]];
    [self.headerCell.contentView addSubview:self.portraitView];
    [self.portraitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerCell.contentView).offset(20);
        make.top.equalTo(self.headerCell.contentView).offset(22);
        make.bottom.equalTo(self.headerCell.contentView).offset(-22);
        make.height.equalTo(self.portraitView.mas_width);
    }];
    
    UILabel *displayNameLabel = [[UILabel alloc] init];
    displayNameLabel.text = self.IMUserInfo.displayName;
    displayNameLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.headerCell.contentView addSubview:displayNameLabel];
    [displayNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portraitView.mas_right).offset(20);
        make.right.equalTo(self.headerCell.contentView).offset(-10);
    }];
    
    
    UILabel *userLabel = [[UILabel alloc] init];
    userLabel.text = [NSString stringWithFormat:@"账号：%@", self.IMUserInfo.name];
    userLabel.font = [UIFont systemFontOfSize:16];
    [self.headerCell.contentView addSubview:userLabel];
    [userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portraitView.mas_right).offset(20);
        make.right.equalTo(self.headerCell.contentView).offset(-10);
        make.centerY.equalTo(self.headerCell);
        make.top.equalTo(displayNameLabel.mas_bottom).offset(1);
    }];
    
    UILabel *genderLabel = [[UILabel alloc] init];
    genderLabel.text = [NSString stringWithFormat:@"性别：%@", self.userInfo.genderString];
    genderLabel.font = [UIFont systemFontOfSize:16];
    [self.headerCell.contentView addSubview:genderLabel];
    [genderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portraitView.mas_right).offset(20);
        make.right.equalTo(self.headerCell.contentView).offset(-10);
        make.top.equalTo(userLabel.mas_bottom).offset(1);
    }];
    
    if ([[WFCCIMService sharedWFCIMService] isFavUser:self.userId]) {
        self.starLabel = [[UILabel alloc] initWithFrame:CGRectMake(width - 16 - 20, userLabel.frame.origin.y, 20, 20)];
        self.starLabel.text = @"☆";
        self.starLabel.font = [UIFont systemFontOfSize:18];
        self.starLabel.textColor = [UIColor yellowColor];
        
        [self.headerCell.contentView addSubview:self.starLabel];
    }
    
    if (self.IMUserInfo.type == 1) {
        [self setupSendMessageCell];
    } else {
        if (self.fromConversation.type == Group_Type) {
            [self setupUserMessagesCell];
        }
        
        if (self.IMUserInfo.type == 0) {
            [self setupMomentCell];
        }
        
        if (self.isFriend) {
            [self setupSendMessageCell];
#if WFCU_SUPPORT_VOIP
            [self setupVOIPCallCell];
#endif
        } else if(![[WFCCNetworkService sharedInstance].userId isEqualToString:self.userId]) {
            [self setupAddFriendCell];
        }
    }
    [self.tableView reloadData];
}

- (void)setupUserMessagesCell {
    self.userMessagesCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    self.userMessagesCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if([self.userId isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
        self.userMessagesCell.textLabel.text = @"查看我的消息";
    } else {
        self.userMessagesCell.textLabel.text = @"查看他（她）的消息";
    }
    [self.cells addObject:self.userMessagesCell];
}

- (void)setupMomentCell {
    if(!NSClassFromString(@"SDTimeLineTableViewController")) {
        return;
    }
    
    self.momentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"momentCell"];
    self.momentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (UIView *subView in self.momentCell.subviews) {
        [subView removeFromSuperview];
    }
    
    UIButton *momentButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width - 100, 70)];
    [momentButton setTitle: @"朋友圈" forState:UIControlStateNormal];
    [momentButton setTitleColor:[WFCUConfigManager globalManager].textColor forState:UIControlStateNormal];
    momentButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    momentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [momentButton addTarget:self action:@selector(momentClick) forControlEvents:UIControlEventTouchUpInside];
    if (@available(iOS 14, *)) {
        [self.momentCell.contentView addSubview:momentButton];
    } else {
        [self.momentCell.contentView addSubview:momentButton];
    }
    self.momentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.momentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self.cells addObject:self.momentCell];
}

- (void)setupAddFriendCell {
    self.addFriendCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    self.addFriendCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIButton *btn = [[UIButton alloc] init];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [btn setTitleColor:[UIColor colorWithHexString:@"0x4970ba"] forState:UIControlStateNormal];
    [btn setTitle:WFCString(@"AddFriend") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onAddFriendBtn:) forControlEvents:UIControlEventTouchDown];
    [self.addFriendCell.contentView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.bottom.equalTo(self.addFriendCell.contentView);
    }];
    
    [self.cells addObject:self.addFriendCell];
}

- (void)setupVOIPCallCell {
    self.voipCallCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    self.voipCallCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIButton *btn = [[UIButton alloc] init];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [btn setTitle:WFCString(@"VOIPCall") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onVoipCallBtn:) forControlEvents:UIControlEventTouchDown];
    [btn setTitleColor:[UIColor colorWithHexString:@"0x4970ba"] forState:UIControlStateNormal];
    [self.voipCallCell.contentView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voipCallCell.contentView);
        make.top.bottom.equalTo(self.voipCallCell);
    }];
    
    [self.cells addObject:self.voipCallCell];
}

- (void)setupSendMessageCell {
    self.sendMessageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    self.sendMessageCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIButton *btn = [[UIButton alloc] init];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [btn setTitle:WFCString(@"SendMessage") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:@"0x4970ba"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onSendMessageBtn:) forControlEvents:UIControlEventTouchDown];
    [self.sendMessageCell.contentView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.sendMessageCell.contentView);
        make.top.bottom.equalTo(self.sendMessageCell);
    }];
    
    [self.cells addObject:self.sendMessageCell];
}

- (void)onViewPortrait:(id)sender {
    WFCUMyPortraitViewController *pvc = [[WFCUMyPortraitViewController alloc] init];
    pvc.userId = self.userId;
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)momentClick {
    Class cls = NSClassFromString(@"SDTimeLineTableViewController");
    UIViewController *vc = [[cls alloc] init];
    [vc performSelector:@selector(setUserId:) withObject:self.userId]; 
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)onSendMessageBtn:(id)sender {
    WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
    mvc.conversation = [WFCCConversation conversationWithType:Single_Type target:self.userId line:0];
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[WFCUMessageListViewController class]]) {
            WFCUMessageListViewController *old = (WFCUMessageListViewController*)vc;
            if (old.conversation.type == Single_Type && [old.conversation.target isEqualToString:self.userId]) {
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
        }
    }
    UINavigationController *nav = self.navigationController;
    [self.navigationController popToRootViewControllerAnimated:NO];
    mvc.hidesBottomBarWhenPushed = YES;
    [nav pushViewController:mvc animated:YES];
}

- (void)onVoipCallBtn:(id)sender {
#if WFCU_SUPPORT_VOIP
    __weak typeof(self)ws = self;
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:WFCString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *actionVoice = [UIAlertAction actionWithTitle:WFCString(@"VoiceCall") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        WFCCConversation *conversation = [WFCCConversation conversationWithType:Single_Type target:ws.IMUserInfo.userId line:0];
        WFCUVideoViewController *videoVC = [[WFCUVideoViewController alloc] initWithTargets:@[ws.IMUserInfo.userId] conversation:conversation audioOnly:YES];
        [[WFAVEngineKit sharedEngineKit] presentViewController:videoVC];
    }];
    
    UIAlertAction *actionVideo = [UIAlertAction actionWithTitle:WFCString(@"VideoCall") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        WFCCConversation *conversation = [WFCCConversation conversationWithType:Single_Type target:ws.IMUserInfo.userId line:0];
        WFCUVideoViewController *videoVC = [[WFCUVideoViewController alloc] initWithTargets:@[ws.IMUserInfo.userId] conversation:conversation audioOnly:NO];
        [[WFAVEngineKit sharedEngineKit] presentViewController:videoVC];
    }];
    
    //把action添加到actionSheet里
    [actionSheet addAction:actionVoice];
    [actionSheet addAction:actionVideo];
    [actionSheet addAction:actionCancel];
    
    
    //相当于之前的[actionSheet show];
    [self presentViewController:actionSheet animated:YES completion:nil];
#endif
}

- (void)onAddFriendBtn:(id)sender {
    WFCUVerifyRequestViewController *vc = [[WFCUVerifyRequestViewController alloc] init];
    vc.userId = self.userId;
    vc.sourceType = self.sourceType;
    vc.sourceTargetId = self.sourceTargetId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showPortrait {
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = self.portraitView;
    browser.imageCount = 1;
    browser.currentImageIndex = 0;
    browser.delegate = self;
    [browser show];
}

- (void)setFriendNote {
    WFCUGeneralModifyViewController *gmvc = [[WFCUGeneralModifyViewController alloc] init];
    NSString *previousAlias = [[WFCCIMService sharedWFCIMService] getFriendAlias:self.userId];
    gmvc.defaultValue = previousAlias;
    gmvc.titleText = @"设置备注";
    gmvc.canEmpty = YES;
    __weak typeof(self)ws = self;
    gmvc.tryModify = ^(NSString *newValue, void (^result)(BOOL success)) {
        if (![newValue isEqualToString:previousAlias]) {
            [[WFCCIMService sharedWFCIMService] setFriend:self.userId alias:newValue success:^{
                result(YES);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [ws loadData];
                });
            } error:^(int error_code) {
                result(NO);
            }];
        }
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:gmvc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)setFavUser {
    BOOL isFav = [[WFCCIMService sharedWFCIMService] isFavUser:self.userId];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"处理中...";
    [hud showAnimated:YES];
    __weak typeof(self)ws = self;
    [[WFCCIMService sharedWFCIMService] setFavUser:self.userId fav:!isFav success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];

            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"处理成功";
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws loadData];
            });
        });
    } error:^(int errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];

            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"处理失败";
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
        });
    }];
}

#pragma mark - SDPhotoBrowserDelegate
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    return self.portraitView.image;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return self.cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
       return self.headerCell;
    }
    
    return self.cells[indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.headerCell == nil) {
        return 0;
    }
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
    view.backgroundColor = tableView.backgroundColor;
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView cellForRowAtIndexPath:indexPath] == self.userMessagesCell) {
        WFCUUserMessageListViewController *vc = [[WFCUUserMessageListViewController alloc] init];
        vc.userId = self.userId;
        vc.conversation = self.fromConversation;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 100;
    }
    
    if ([self.cells[indexPath.row] isEqual:self.momentCell]) {
        return 70;
    } else {
        return 54;
    }
}

@end
