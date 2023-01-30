//
//  FavGroupTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/13.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUFavGroupTableViewController.h"
#import "WFCUGroupTableViewCell.h"
#import "WFCUMessageListViewController.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFCUGroupMemberTableViewController.h"
#import "WFCUInviteGroupMemberViewController.h"
#import "UIView+Toast.h"
#import "WFCUConfigManager.h"
#import "WFCUContactListViewController.h"
#import "WFCUCreateConversationViewController.h"
#import "UIColor+YH.h"

@interface WFCUFavGroupTableViewController ()
@property (nonatomic, strong)NSMutableArray<WFCCGroupInfo *> *groups;
@end

@implementation WFCUFavGroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    }
    self.groups = [[NSMutableArray alloc] init];
    self.title = WFCString(@"MyGroup");
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.1)];
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    
    NSNumber *createGroupEnable = [NSUserDefaults.standardUserDefaults objectForKey:@"createGroupEnable"];
    if (createGroupEnable.integerValue == 1) {
        UIButton *rightButton = [[UIButton alloc] init];
        rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [rightButton setTitle:@"发起群聊" forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor colorWithHexString:@"0x4970ba"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(createChatGroup) forControlEvents:UIControlEventTouchDown];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createChatGroup {
    WFCUContactListViewController *pvc = [[WFCUContactListViewController alloc] init];
    pvc.selectContact = YES;
    pvc.multiSelect = YES;
    pvc.disableUsersSelected = YES;
    pvc.title = @"发起群聊";
    pvc.isPushed = YES;
    pvc.disableUsers = [[NSMutableArray alloc] init];
    pvc.noBack = YES;
    [self.navigationController pushViewController:pvc animated:YES];
    
    pvc.selectResult = ^(NSArray<NSString *> *contacts) {
        WFCUCreateConversationViewController *vc = [[WFCUCreateConversationViewController alloc] init];
        vc.memberList = contacts;
        [self.navigationController pushViewController:vc animated:YES];
    };
}

- (void)refreshList {
    NSArray *ids = [[WFCCIMService sharedWFCIMService] getFavGroups];
    [self.groups removeAllObjects];
    
    for (NSString *groupId in ids) {
        WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:groupId refresh:NO];
        if (groupInfo) {
            groupInfo.target = groupId;
            [self.groups addObject:groupInfo];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupInfoUpdated:) name:kGroupInfoUpdated object:nil];
    [self.tableView reloadData];
}

- (void)onGroupInfoUpdated:(NSNotification *)notification {
    WFCCGroupInfo *groupInfo = notification.userInfo[@"groupInfo"];
    for (int i = 0; i < self.groups.count; i++) {
        if([self.groups[i].target isEqualToString:groupInfo.target]) {
            self.groups[i] = groupInfo;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshList];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.1)];
    view.backgroundColor = tableView.backgroundColor;
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WFCUGroupTableViewCell *cell = (WFCUGroupTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"groupCellId"];
    if (cell == nil) {
        cell = [[WFCUGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupCellId"];
    }
    
    cell.groupInfo = self.groups[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WFCCGroupInfo *groupInfo = self.groups[indexPath.row];
    
    WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
    NSString *groupId = groupInfo.target;
    mvc.conversation = [WFCCConversation conversationWithType:Group_Type target:groupId line:0];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *groupId = self.groups[indexPath.row].target;
    __weak typeof(self) ws = self;
    
    
    UITableViewRowAction *cancel = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:WFCString(@"Remove") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [[WFCCIMService sharedWFCIMService] setFavGroup:groupId fav:NO success:^{
            [ws.view makeToast:WFCString(@"Removed") duration:2 position:CSToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws refreshList];
            });
            
        } error:^(int error_code) {
            [ws.view makeToast:WFCString(@"OperationFailure") duration:2 position:CSToastPositionCenter];
        }];
    }];
    
    cancel.backgroundColor = [UIColor redColor];

    return @[cancel];
};

@end
