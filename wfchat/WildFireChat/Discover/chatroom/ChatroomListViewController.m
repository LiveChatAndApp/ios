//
//  ChatroomListViewController.m
//  WildFireChat
//
//  Created by heavyrain lee on 2018/8/24.
//  Copyright © 2018 WildFireChat. All rights reserved.
//

#import "ChatroomListViewController.h"

#import <WFChatClient/WFCChatClient.h>
#import <WFChatUIKit/WFChatUIKit.h>

#import "AppService.h"
#import "ChatroomItemCell.h"
#import "MBProgressHUD.h"
#import "UIColor+YH.h"

@interface ChatroomListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSArray<ChatRoomListModel *> *chatroomIds;

@end

static NSString * identifier = @"cxCellID";

@implementation ChatroomListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"聊天室列表";
    [self setupUI];
}

- (void)setupUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    
    self.tableView = [[UITableView alloc] init];
    [self.tableView registerClass:ChatroomItemCell.class forCellReuseIdentifier:identifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(8);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getChatRoomId];
}

- (void)getChatRoomId {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"读取中...";
    [hud showAnimated:YES];
    [AppService.sharedAppService getChatRoomList:^(NSArray<ChatRoomListModel *> * _Nonnull lists) {
        self.chatroomIds = lists;
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.tableView reloadData];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
        });
    }];
}

#pragma mark - deleDate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatroomIds.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatroomItemCell * cell = (ChatroomItemCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.chatroomInfo = [self.chatroomIds objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatRoomListModel *chatroomInfo = [self.chatroomIds objectAtIndex:indexPath.row];
    WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
    mvc.conversation = [WFCCConversation conversationWithType:Chatroom_Type target:chatroomInfo.cid line:0];
    [self.navigationController pushViewController:mvc animated:YES];
}

@end
