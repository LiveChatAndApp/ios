//
//  DiscoverViewController.m
//  Wildfire Chat
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "DiscoverViewController.h"

#import <WFChatUIKit/WFChatUIKit.h>
#import <WFChatClient/WFCCIMService.h>
#import <WFChatUIKit/TabBarTitleView.h>

#import "AppService.h"
#import "ChatroomListViewController.h"
#import "DiscoverMomentsTableViewCell.h"
#import "MBProgressHUD.h"
#import "UIColor+YH.h"

@interface DiscoverViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *dataSource;
@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = @[@{@"title":LocalizedString(@"Chatroom"),@"image":@"discover_chatroom",@"des":@"chatroom"},
                       @{@"title":LocalizedString(@"客服中心"),@"image":@"discover_custom_service",@"des":@"CustomerService"}];

    self.view.backgroundColor = UIColor.whiteColor;
    TabBarTitleView *titleView = [[TabBarTitleView alloc] initWithRightButtonStyle:RightButtonStyleMenu];
    titleView.title = @"发现";
    [self.view addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleView.mas_bottom).offset(10);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
    }];
}

- (void)onReceiveComments:(NSNotification *)notification {
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self updateUnreadStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)updateUnreadStatus {
    [self.tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    view.backgroundColor = UIColor.whiteColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *des = self.dataSource[indexPath.section][@"des"];
    if ([des isEqualToString:@"moment"]) {
         UIViewController *vc = [[NSClassFromString(@"SDTimeLineTableViewController") alloc] init];
                   vc.hidesBottomBarWhenPushed = YES;
                   [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([des isEqualToString:@"chatroom"]) {
        ChatroomListViewController *vc = [[ChatroomListViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        if (@available(iOS 11.0, *)) {
            self.navigationItem.backButtonTitle = @"";
        }
        [self.navigationController pushViewController:vc animated:YES];
    }

    if ([des isEqualToString:@"CustomerService"]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"开启中...";
        [hud showAnimated:YES];
        [AppService.sharedAppService getCustomerServiceURL:^(NSString * _Nonnull url) {
            [hud hideAnimated:YES];
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
        } error:^(NSString * _Nonnull message) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                [self.view makeToast:message];
            });
        }];
    }
    
    if ([des isEqualToString:@"Conference"]) {
        WFCUCreateConferenceViewController *vc = [[WFCUCreateConferenceViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.textLabel.text = self.dataSource[indexPath.section][@"title"];
    cell.imageView.image = [UIImage imageNamed:self.dataSource[indexPath.section][@"image"]];
    cell.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    cell.layer.cornerRadius = 12;
    cell.clipsToBounds = YES;

    return cell;
}

@end
