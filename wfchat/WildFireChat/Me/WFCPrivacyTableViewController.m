//
//  WFCPrivacyTableViewController.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/6.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCPrivacyTableViewController.h"
#import <WFChatClient/WFCChatClient.h>
#import <WFChatUIKit/WFChatUIKit.h>
#import "UIColor+YH.h"

#define BLACK_LIST_CELL_TAG 1
#define MOMENTS_CELL_TAG 2

@interface WFCPrivacyTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray<NSMutableArray<UITableViewCell *> *> *cells;
@end

@implementation WFCPrivacyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    }
    
    [self createCells];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.1)];
    [self.tableView reloadData];
    
    [self.view addSubview:self.tableView];
    
}

- (void)createCells {
    self.cells = [[NSMutableArray alloc] init];
    
    //Section 1
    {
        NSMutableArray *section1 = [[NSMutableArray alloc] init];
        [self.cells addObject:section1];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell_black_list"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = LocalizedString(@"Blacklist");
        cell.tag = BLACK_LIST_CELL_TAG;
        [section1 addObject:cell];
    }
    
    if([[WFCCIMService sharedWFCIMService] isEnableSecretChat] || [[WFCCIMService sharedWFCIMService] isReceiptEnabled]) {
        NSMutableArray *section2 = [[NSMutableArray alloc] init];
        [self.cells addObject:section2];
        if ([[WFCCIMService sharedWFCIMService] isReceiptEnabled]) {
            WFCUGeneralSwitchTableViewCell *switchCell = [[WFCUGeneralSwitchTableViewCell alloc] init];
            switchCell.textLabel.text = WFCString(@"MsgReceipt");
            if ([[WFCCIMService sharedWFCIMService] isUserEnableReceipt]) {
                switchCell.on = YES;
            } else {
                switchCell.on = NO;
            }
            __weak typeof(self)ws = self;
            [switchCell setOnSwitch:^(BOOL value, int type, void (^result)(BOOL success)) {
                [[WFCCIMService sharedWFCIMService] setUserEnableReceipt:value success:^{
                    result(YES);
                } error:^(int error_code) {
                    [ws.view makeToast:@"网络错误"];
                    result(NO);
                }];
            }];
            [section2 addObject:switchCell];
        }
        
        if ([[WFCCIMService sharedWFCIMService] isEnableSecretChat]) {
            WFCUGeneralSwitchTableViewCell *switchCell = [[WFCUGeneralSwitchTableViewCell alloc] init];
            switchCell.textLabel.text = @"密聊";
            if ([[WFCCIMService sharedWFCIMService] isUserEnableSecretChat]) {
                switchCell.on = YES;
            } else {
                switchCell.on = NO;
            }
            __weak typeof(self)ws = self;
            [switchCell setOnSwitch:^(BOOL value, int type, void (^result)(BOOL success)) {
                [[WFCCIMService sharedWFCIMService] setUserEnableSecretChat:value success:^{
                    result(YES);
                } error:^(int error_code) {
                    [ws.view makeToast:@"网络错误"];
                    result(NO);
                }];
            }];
            [section2 addObject:switchCell];
        }
    }
    //sections3
    if (NSClassFromString(@"MomentSettingsTableViewController")) {
        NSMutableArray *section3 = [[NSMutableArray alloc] init];
        [self.cells addObject:section3];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"moments_cell"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = LocalizedString(@"Moments");
        cell.tag = MOMENTS_CELL_TAG;
        [section3 addObject:cell];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == BLACK_LIST_CELL_TAG) {
        WFCUBlackListViewController *vc = [[WFCUBlackListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if(cell.tag == MOMENTS_CELL_TAG) {
        UIViewController *vc = [[NSClassFromString(@"MomentSettingsTableViewController") alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
    view.backgroundColor = tableView.backgroundColor;
    return view;
}

//#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cells.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cells[section].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cells[indexPath.section][indexPath.row];
}

@end
