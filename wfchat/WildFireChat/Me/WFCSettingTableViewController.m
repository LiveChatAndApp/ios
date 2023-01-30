//
//  SettingTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/6.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCSettingTableViewController.h"
#import <WFChatClient/WFCChatClient.h>
#import <WFChatUIKit/WFChatUIKit.h>
#import "WFCPrivacyTableViewController.h"
#import "WFCDiagnoseViewController.h"
#import "UIColor+YH.h"
#import "UIFont+YH.h"
#import "AppService.h"

@interface WFCSettingTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@end

@implementation WFCSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LocalizedString(@"Settings");
    self.view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.1)];
    [self.tableView reloadData];
    
    [self.view addSubview:self.tableView];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        WFCPrivacyTableViewController *pvc = [[WFCPrivacyTableViewController alloc] init];
        pvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pvc animated:YES];
    }else if(indexPath.section == 1 && indexPath.row == 0) {
        WFCDiagnoseViewController *vc = [[WFCDiagnoseViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
        v.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
        return v;
    }

}

//#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2; //
    } else {
        return 1;
    }
}


- (UIEdgeInsets)hiddenSeparatorLine:(UITableViewCell *)cell {
    return cell.separatorInset = UIEdgeInsetsMake(self.view.frame.size.width, 0, 0, 0);
}

- (void)showSeparatorLine:(UITableViewCell *)cell {
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)setLastCellSeperatorToLeft:(UITableViewCell*) cell
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }

    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"style1Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"style1Cell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if(indexPath.section == 0) {
        cell.textLabel.text = LocalizedString(@"PrivacySettings");
        [self hiddenSeparatorLine:cell];
    } else if(indexPath.section == 1 && indexPath.row == 0) {
        [self hiddenSeparatorLine:cell];
        cell.textLabel.text = LocalizedString(@"Diagnose");
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        cell.textLabel.text = LocalizedString(@"CurrentVersion");
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@(%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[WFCCNetworkService sharedInstance] getProtoRevision]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.section == 2) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"buttonCell"];
        for (UIView *subView in cell.subviews) {
            [subView removeFromSuperview];
        }
       [self setLastCellSeperatorToLeft:cell];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 48)];
        [btn setTitle:LocalizedString(@"Logout") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onLogoutBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        [btn setTitleColor:[UIColor colorWithHexString:@"0xf95569"]
                  forState:UIControlStateNormal];
        
        if (@available(iOS 14, *)) {
            [cell.contentView addSubview:btn];
        } else {
            [cell addSubview:btn];
        }
    }
    
    return cell;
}
 
- (void)onLogoutBtn:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:LocalizedString(@"Quit") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:LocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *actionLogout = [UIAlertAction actionWithTitle:LocalizedString(@"Logout") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedToken"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedUserId"];
        [[AppService sharedAppService] clearAppServiceAuthInfos];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //退出后就不需要推送了，第一个参数为YES
        //如果希望再次登录时能够保留历史记录，第二个参数为NO。如果需要清除掉本地历史记录第二个参数用YES
        [[WFCCNetworkService sharedInstance] disconnect:YES clearSession:NO];
    }];
    
    //把action添加到actionSheet里
    [actionSheet addAction:actionLogout];
    [actionSheet addAction:actionCancel];
    
    //相当于之前的[actionSheet show];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end
