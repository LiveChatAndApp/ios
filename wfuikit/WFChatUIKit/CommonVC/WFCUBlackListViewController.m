//
//  WFCUBlackListViewController.m
//  WFChatUIKit
//
//  Created by Heavyrain.Lee on 2019/7/31.
//  Copyright © 2019 Wildfire Chat. All rights reserved.
//

#import "WFCUBlackListViewController.h"
#import <WFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>
#import "WFCUImage.h"
#import "UIColor+YH.h"

@interface WFCUBlackListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)  UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@end

@implementation WFCUBlackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = WFCString(@"Blacklist");
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.dataArr = [[[WFCCIMService sharedWFCIMService] getBlackList:YES] mutableCopy];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.1)];
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
    view.backgroundColor = tableView.backgroundColor;
    return view;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *userId = [self.dataArr objectAtIndex:indexPath.row];
        __weak typeof(self) ws = self;
        [[WFCCIMService sharedWFCIMService] setBlackList:userId isBlackListed:NO success:^{
            [ws.dataArr removeObject:userId];
            [ws.tableView reloadData];
        } error:^(int error_code) {
            
        }];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return WFCString(@"Delete");
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[self.dataArr objectAtIndex:indexPath.row] refresh:NO];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[WFCUImage imageNamed:@"PersonalChat"]];
    cell.textLabel.text = userInfo.displayName;
    return cell;
}

@end
