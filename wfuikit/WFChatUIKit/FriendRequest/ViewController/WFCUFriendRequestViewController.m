//
//  FriendRequestViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/7.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUFriendRequestViewController.h"

#import "Masonry.h"
#import "MBProgressHUD.h"
#import "WFCUAddFriendViewController.h"
#import "WFCUConfigManager.h"
#import "WFCUFriendRequestTableViewCell.h"
#import "UIView+Toast.h"
#import "UIColor+YH.h"

@interface WFCUFriendRequestViewController () <UITableViewDataSource, UITableViewDelegate, WFCUFriendRequestTableViewCellDelegate>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSArray<FriendRequest *> *requestList;

@end

@implementation WFCUFriendRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSearchUIAndData];
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
    
    [[WFCCIMService sharedWFCIMService] clearUnreadFriendRequestStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self getFriendRequest];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[WFCCIMService sharedWFCIMService] clearUnreadFriendRequestStatus];
}

- (void)onUserInfoUpdated:(NSNotification *)notification {
    [self getFriendRequest];
}

- (void)getFriendRequest {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"读取中...";
    [hud showAnimated:YES];
    
    [WFCUConfigManager.globalManager.appServiceProvider getFriendRequest:^(NSArray<FriendRequest *> * _Nonnull list) {
        self.requestList = list;
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.tableView reloadData];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
            [self.tableView reloadData];
        });
    }];
}

- (void)initSearchUIAndData {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.navigationItem.title = @"好友请求";
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    }
    
    UIButton *rightButton = [[UIButton alloc] init];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [rightButton setTitle:@"添加" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"0x4970ba"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(gotoAddFriendVC) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];

    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = YES;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.1)];
    self.tableView.tableHeaderView = nil;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
}

- (void)respondFriendRequest:(FriendRequest *)request verifyText:(NSString *)text reply:(NSInteger)reply{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = WFCString(@"Updating");
    [hud showAnimated:YES];
    
    [WFCUConfigManager.globalManager.appServiceProvider responseFriendRequestWithUID:request.uid verifyText:text reply:reply success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            if (reply == 1) {
                [self.view makeToast:@"通过验证，已添加好友"];
            } else {
                [self.view makeToast:@"已拒絕"];
            }
            
            [self getFriendRequest];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
            [self getFriendRequest];
        });
    }];
}

- (void)showVerifyTextInputAlert:(void (^)(NSString * text))successBlock {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"好友验证请求" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入好友验证";
        textField.secureTextEntry = YES;
    }];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (successBlock != nil) {
            successBlock(vc.textFields[0].text);
        }
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)gotoAddFriendVC {
    WFCUAddFriendViewController *addFriendVC = [[WFCUAddFriendViewController alloc] init];
    addFriendVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addFriendVC animated:YES];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
      return [self.requestList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *requestFlag = @"request_cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:requestFlag];
  
  if (cell == nil) {
    cell = [[WFCUFriendRequestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:requestFlag];
  }
  
  WFCUFriendRequestTableViewCell *frCell = (WFCUFriendRequestTableViewCell *)cell;
  frCell.delegate = self;
  frCell.friendRequest = self.requestList[indexPath.row];
  
  cell.userInteractionEnabled = YES;
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *view = [[UIView alloc] init];
        UILabel *label = [[UILabel alloc] init];
        label.text = @"新的朋友";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithHexString:@"0xadadad"];
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.right.equalTo(view);
            make.height.mas_equalTo(30);
            make.left.equalTo(view).offset(15);
        }];
        
        return view;
    }
    
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 30;
    }
    
    return 0;
}

#pragma mark - FriendRequestTableViewCellDelegate
- (void)onAcceptBtn:(FriendRequest *)request {
    if (request.verify.boolValue) {
        [self showVerifyTextInputAlert:^(NSString *text) {
            [self respondFriendRequest:request verifyText:text reply:1];
        }];
        
        return;
    }

    [self respondFriendRequest:request verifyText:@"" reply:1];
}

- (void)onRejectBtn:(FriendRequest *)request {
    [self respondFriendRequest:request verifyText:@"" reply:0];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
