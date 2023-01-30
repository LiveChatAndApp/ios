//
//  SettingTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/6.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCSecurityTableViewController.h"

#import "ChangeTradePasswordViewController.h"
#import "WFCChangePasswordViewController.h"
#import "WFCSelectModifyPasswordOptionViewController.h"
#import "WFCSMSChangePasswordViewController.h"
#import "NewTradePasswordViewController.h"
#import "UIColor+YH.h"

@interface WFCSecurityTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@end

@implementation WFCSecurityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LocalizedString(@"AccountSafety");
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.1)];
    [self.tableView reloadData];
    
    [self.view addSubview:self.tableView];
    
}

- (void)showPasswordVC {
    WFCSelectModifyPasswordOptionViewController *vc = [[WFCSelectModifyPasswordOptionViewController alloc] init];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    __weak typeof(vc) weakvc = vc;
    vc.onSelected = ^(NSInteger index) {
        [weakvc dismissViewControllerAnimated:NO completion:nil];
        if (index == 1) {
            WFCSMSChangePasswordViewController *vc = [[WFCSMSChangePasswordViewController alloc] init];
            vc.mobile = self.mobile;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (index == 2) {
            WFCChangePasswordViewController *vc = [[WFCChangePasswordViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    };
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"style1Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"style1Cell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0) {
        cell.textLabel.text = LocalizedString(@"ChangePassword");
    } else if (indexPath.row == 1) {
        if (self.hasTradePwd == 1) {
            cell.textLabel.text = @"修改支付密码";
        } else {
            cell.textLabel.text = @"設置支付密码";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self showPasswordVC];
    } else if (indexPath.row == 1) {
        if (self.hasTradePwd == 1) {
            ChangeTradePasswordViewController *vc = [[ChangeTradePasswordViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            NewTradePasswordViewController *vc = [[NewTradePasswordViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

@end
