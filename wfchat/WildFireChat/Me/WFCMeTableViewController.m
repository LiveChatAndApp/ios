//
//  MeTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/11/4.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCMeTableViewController.h"

#import <WFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>
#import <WFChatUIKit/WFChatUIKit.h>
#import <WFChatUIKit/TabBarTitleView.h>
#import <WFChatUIKit/UIView+Toast.h>

#import "AppService.h"
#import "CreateBarCodeViewController.h"
#import "WalletViewController.h"
#import "WFCFavoriteTableViewController.h"
#import "WFCSettingTableViewController.h"
#import "WFCSecurityTableViewController.h"
#import "WFCMeTableViewHeaderViewCell.h"
#import "WFCMeTableCell.h"
#import "UIColor+YH.h"
#import "MBProgressHUD.h"

@interface WFCMeTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UIImageView *portraitView;
@property (nonatomic, strong)NSArray *itemDataSource;
@property (nonatomic, strong)UserInfoModel *userInfo;
@property (nonatomic, strong)TabBarTitleView *titleView;

@end

#define Notification_Setting_Cell   0
#define Favorite_Settings_Cell      1
#define File_Settings_Cell 2
#define Safe_Setting_Cell 3
#define More_Setting_Cell 4
#define My_Wallet_Cell 5

@implementation WFCMeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.titleView = [[TabBarTitleView alloc] initWithRightButtonStyle:RightButtonStyleQRCode];
    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    if ([self.tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.bottom.equalTo(self.view);
    }];
    
    __weak typeof(self)ws = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kUserInfoUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if ([[WFCCNetworkService sharedInstance].userId isEqualToString:note.object]) {
            [ws.tableView reloadData];
        }
    }];
    
    if ([[WFCCIMService sharedWFCIMService] isCommercialServer]) {
        self.itemDataSource = @[
            @{@"title":@"我的钱包", @"image":@"favorite_settings", @"type":@(My_Wallet_Cell)},
            @{@"title":LocalizedString(@"Message"), @"image":@"notification_setting", @"type":@(Notification_Setting_Cell)},
            @{@"title":LocalizedString(@"Favorite"), @"image":@"favorite_settings", @"type":@(Favorite_Settings_Cell)},
            @{@"title":LocalizedString(@"File"), @"image":@"file_settings", @"type":@(File_Settings_Cell)},
            @{@"title":LocalizedString(@"AccountSafety"), @"image":@"safe_setting", @"type":@(Safe_Setting_Cell)},
            @{@"title":LocalizedString(@"Settings"), @"image":@"MoreSetting", @"type":@(More_Setting_Cell)}
        ];
    } else {
        self.itemDataSource = @[
            @{@"title":@"我的钱包", @"image":@"favorite_settings", @"type":@(My_Wallet_Cell)},
            @{@"title":LocalizedString(@"MessageNotification"), @"image":@"notification_setting", @"type":@(Notification_Setting_Cell)},
            @{@"title":LocalizedString(@"Favorite"), @"image":@"favorite_settings", @"type":@(Favorite_Settings_Cell)},
            @{@"title":LocalizedString(@"AccountSafety"), @"image":@"safe_setting", @"type":@(Safe_Setting_Cell)},
            @{@"title":LocalizedString(@"Settings"), @"image":@"MoreSetting", @"type":@(More_Setting_Cell)}
        ];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getUserInfo];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)getUserInfo {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"读取中...";
    [hud showAnimated:YES];
    
    NSString *userId = [WFCCNetworkService sharedInstance].userId;

    [AppService.sharedAppService getUserInfo:userId success:^(UserInfoModel * _Nonnull model) {
        [hud hideAnimated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            self.userInfo = model;
            self.titleView.title = self.userInfo.nickName;
            [self.tableView reloadData];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
        });
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.itemDataSource.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 9;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        WFCMeTableViewHeaderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell"];
        if (cell == nil) {
            cell = [[WFCMeTableViewHeaderViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"profileCell"];
        }
        
        cell.userInfo = self.userInfo;
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"styleDefault"];
        if (cell == nil || ![cell isKindOfClass:WFCMeTableCell.class]) {
            cell = [[WFCMeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"styleDefault"];
        }

        WFCMeTableCell *meCell = (WFCMeTableCell *)cell;
        meCell.leftLabel.text = self.itemDataSource[indexPath.section - 1][@"title"];

        if ([self.itemDataSource[indexPath.section - 1][@"type"] isEqualToNumber:@(My_Wallet_Cell)]) {
            if (self.userInfo != nil) {
                meCell.rightLabel.text = [NSString stringWithFormat:@"余额：%@", self.userInfo.balance];
            } else {
                meCell.rightLabel.text = @"余额：-.-";
            }
        }
        
        return meCell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 94;
    } else {
        return 60;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 9)];
    view.backgroundColor = self.tableView.backgroundColor;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        WFCUMyProfileTableViewController *vc = [[WFCUMyProfileTableViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        int type = [self.itemDataSource[indexPath.section-1][@"type"] intValue];
        if (type == Notification_Setting_Cell) {
           WFCUMessageSettingViewController *mnvc = [[WFCUMessageSettingViewController alloc] init];
           mnvc.hidesBottomBarWhenPushed = YES;
           [self.navigationController pushViewController:mnvc animated:YES];
       } else if(type == File_Settings_Cell) {
           WFCUFilesEntryViewController *fevc = [[WFCUFilesEntryViewController alloc] init];
           fevc.hidesBottomBarWhenPushed = YES;
           [self.navigationController pushViewController:fevc animated:YES];
       } else if (type == Favorite_Settings_Cell) {
           WFCFavoriteTableViewController *mnvc = [[WFCFavoriteTableViewController alloc] init];
           mnvc.hidesBottomBarWhenPushed = YES;
           [self.navigationController pushViewController:mnvc animated:YES];
       } else if(type == Safe_Setting_Cell) {
           WFCSecurityTableViewController * stvc = [[WFCSecurityTableViewController alloc] init];
           stvc.hidesBottomBarWhenPushed = YES;
           stvc.mobile = self.userInfo.mobile;
           stvc.hasTradePwd = self.userInfo.hasTradePwd;
           [self.navigationController pushViewController:stvc animated:YES];
       } else if(type == More_Setting_Cell) {
           WFCSettingTableViewController *vc = [[WFCSettingTableViewController alloc] init];
           vc.hidesBottomBarWhenPushed = YES;
           [self.navigationController pushViewController:vc animated:YES];
       } else if(type == My_Wallet_Cell) {
           WalletViewController *vc = [[WalletViewController alloc] init];
           vc.hidesBottomBarWhenPushed = YES;
           vc.hasTradePwd = self.userInfo.hasTradePwd;
           [self.navigationController pushViewController:vc animated:YES];
       }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
