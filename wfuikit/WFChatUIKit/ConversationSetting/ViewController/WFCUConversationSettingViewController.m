//
//  ConversationSettingViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/11/2.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUConversationSettingViewController.h"
#import <SDWebImage/SDWebImage.h>
#import <WFChatClient/WFCChatClient.h>
#import "WFCUCreateConversationViewController.h"
#import "WFCUConversationSettingMemberCollectionViewLayout.h"
#import "WFCUConversationSettingMemberCell.h"
#import "WFCUContactListViewController.h"
#import "WFCUMessageListViewController.h"
#import "WFCUGeneralModifyViewController.h"
#import "WFCUSwitchTableViewCell.h"
#import "WFCUCreateGroupViewController.h"
#import "WFCUProfileTableViewController.h"
#import "GroupManageTableViewController.h"
#import "WFCUGroupMemberCollectionViewController.h"
#import "WFCUFilesViewController.h"

#import "MBProgressHUD.h"
#import "WFCUMyProfileTableViewController.h"
#import "WFCUConversationSearchTableViewController.h"
#import "WFCUChannelProfileViewController.h"
#import "QrCodeHelper.h"
#import "UIView+Toast.h"
#import "WFCUConfigManager.h"
#import "WFCUUtilities.h"
#import "WFCUGroupAnnouncementViewController.h"
#import "UIFont+YH.h"
#import "UIColor+YH.h"
#import "WFCUEnum.h"
#import "WFCUImage.h"
#import "PortraitCell.h"
#import "masonry.h"
#import "ConversationSettingRedButtonCell.h"

@interface WFCUConversationSettingViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong)PortraitCell *portraitCell;
@property (nonatomic, strong)UICollectionView *memberCollectionView;
@property (nonatomic, strong)UITableViewCell *memberCell;
@property (nonatomic, strong)WFCUConversationSettingMemberCollectionViewLayout *memberCollectionViewLayout;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)WFCCGroupInfo *groupInfo;
@property (nonatomic, strong)WFCCUserInfo *userInfo;
@property (nonatomic, strong)WFCCChannelInfo *channelInfo;
@property (nonatomic, strong)NSArray<WFCCGroupMember *> *memberList;
@property (nonatomic, strong)NSArray<NSArray<NSString *> *> *tableViewList;

@property (nonatomic, strong)UIImageView *channelPortrait;
@property (nonatomic, strong)UILabel *channelName;
@property (nonatomic, strong)UILabel *channelDesc;

@property (nonatomic, strong)WFCUGroupAnnouncement *groupAnnouncement;

@property (nonatomic, assign)BOOL showMoreMember;
@property (nonatomic, assign)int extraBtnNumber;
@property (nonatomic, assign)int memberCollectionCount;
@property (nonatomic, assign)BOOL isBroadcast;
@end

#define Group_Member_Cell_Reuese_ID @"Group_Member_Cell_Reuese_ID"
#define Group_Member_Visible_Lines 9
@implementation WFCUConversationSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isBroadcast = NO;
    if (self.conversation.type == Channel_Type) {
        self.title = @"频道详情";
    } else if (self.conversation.type == Group_Type) {
        self.title = @"群聊详情";
    } else {
        self.title = @"会话详情";
    }
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    }
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (self.conversation.type == Single_Type) {
        self.userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.conversation.target refresh:YES];
        self.memberList = @[self.conversation.target];
    } else if(self.conversation.type == Group_Type){
        self.groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:self.conversation.target refresh:YES];
        self.memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.conversation.target forceUpdate:YES];
        self.isBroadcast = [WFCUUtilities isBroadcastGroup:self.groupInfo.extra];
        if (!self.isBroadcast) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[WFCUImage imageNamed:@"qrcode"] style:UIBarButtonItemStylePlain target:self action:@selector(showQRCode)];
        }
    } else if(self.conversation.type == Channel_Type) {
        self.channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:self.conversation.target refresh:YES];
        self.memberList = @[self.conversation.target];
    } else if(self.conversation.type == SecretChat_Type) {
        WFCCSecretChatInfo *secretChatInfo = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:self.conversation.target];
        if(!secretChatInfo) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        NSString *userId = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:self.conversation.target].userId;
        self.userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userId refresh:YES];
        self.memberList = @[userId];
    }
    
    [self createTableViewList];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    UIView *footerView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 146)];
    footerView.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    self.tableView.tableFooterView = footerView;
    if (self.conversation.type  != Group_Type) {
        footerView.frame = CGRectMake(0, 0, 0, 0);
    }
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    if(self.conversation.type == Group_Type) {
        __weak typeof(self)ws = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:kGroupMemberUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([ws.conversation.target isEqualToString:note.object]) {
                ws.groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:ws.conversation.target refresh:NO];
                ws.memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:ws.conversation.target forceUpdate:NO];
                [ws setupMemberCollectionView];
                [ws.memberCollectionView reloadData];
            }
        }];
        [[WFCUConfigManager globalManager].appServiceProvider getGroupAnnouncement:self.conversation.target success:^(WFCUGroupAnnouncement *announcement) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ws.groupAnnouncement = announcement;
                [ws.tableView reloadData];
            });
        } error:^(int error_code) {
            
        }];
    } else if(self.conversation.type == Channel_Type) {
        CGFloat portraitWidth = 80;
        CGFloat top = 40;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        self.channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:self.conversation.target refresh:YES];
        
        self.channelPortrait = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth - portraitWidth)/2, top, portraitWidth, portraitWidth)];
        [self.channelPortrait sd_setImageWithURL:[NSURL URLWithString:self.channelInfo.portrait] placeholderImage:[WFCUImage imageNamed:@"channel_default_portrait"]];
        self.channelPortrait.userInteractionEnabled = YES;
        [self.channelPortrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapChannelPortrait:)]];
        
        top += portraitWidth;
        top += 20;
        self.channelName = [[UILabel alloc] initWithFrame:CGRectMake(40, top, screenWidth - 40 - 40, 18)];
        self.channelName.font = [UIFont systemFontOfSize:18];
        self.channelName.textAlignment = NSTextAlignmentCenter;
        self.channelName.text = self.channelInfo.name;
        

        top += 18;
        top += 20;
        
        if (self.channelInfo.desc) {
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.channelInfo.desc];
            UIFont *font = [UIFont systemFontOfSize:14];
            [attributeString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.channelInfo.desc.length)];
            NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
            CGRect rect = [attributeString boundingRectWithSize:CGSizeMake(screenWidth - 80, CGFLOAT_MAX) options:options context:nil];
            
            self.channelDesc = [[UILabel alloc] initWithFrame:CGRectMake(40, top, screenWidth - 80, rect.size.height)];
            self.channelDesc.font = [UIFont systemFontOfSize:14];
            self.channelDesc.textAlignment = NSTextAlignmentCenter;
            self.channelDesc.text = self.channelInfo.desc;
            self.channelDesc.numberOfLines = 0;
            [self.channelDesc sizeToFit];
            
            top += rect.size.height;
            top += 20;
        }
        
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, top)];
        [container addSubview:self.channelPortrait];
        [container addSubview:self.channelName];
        [container addSubview:self.channelDesc];
        self.tableView.tableHeaderView = container;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.conversation.type == Single_Type) {
        self.userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.conversation.target refresh:NO];
        self.memberList = @[self.conversation.target];
    } else if(self.conversation.type == Group_Type) {
        self.groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:self.conversation.target refresh:NO];
        self.memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.conversation.target forceUpdate:NO];
    } else if(self.conversation.type == Channel_Type) {
        self.channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:self.conversation.target refresh:NO];
        self.memberList = @[self.conversation.target];
    } else if(self.conversation.type == SecretChat_Type) {
        NSString *userId = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:self.conversation.target].userId;
        self.userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userId refresh:NO];
        self.memberList = @[userId];
    }
    [self setupMemberCollectionView];
    
    [self.memberCollectionView reloadData];
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createTableViewList {
    switch (self.conversation.type) {
        case Single_Type:
            self.tableViewList = @[@[@"Member"],
                                   @[@"SearchMessage"],
                                   @[@"MessageSilent", @"SetTop"],
                                   @[@"ClearMessage"]];
            break;
        case SecretChat_Type:
            self.tableViewList = @[@[@"Member"],
                                   @[@"SearchMessage"],
                                   @[@"MessageSilent", @"SetTop"],
                                   @[@"BurnTime"],
                                   @[@"ClearMessage", @"DestroySecretChat"]];
            break;
        case Channel_Type:
            self.tableViewList = @[@[@"Portrait"],
                                   @[@"Member"],
                                   @[@"SearchMessage"],
                                   @[@"MessageSilent", @"SetTop"],
                                   @[@"ClearMessage"],
                                   @[@"UnsubscribeChannel"]];
            break;
        case Group_Type:
            if (self.isBroadcast) {
                self.tableViewList = @[@[@"Portrait"],
                                       @[@"GroupName", @"GroupAnnouncement"],
                                       @[@"SearchMessage"],
                                       @[@"MessageSilent", @"SetTop"],
                                       @[@"ShowNameCard"]];
            } else if (self.groupInfo.type == GroupType_Restricted) {
                self.tableViewList = @[@[@"Portrait"],
                                       @[@"Member"],
                                       @[@"GroupName", @"GroupAnnouncement", @"GroupRemark"],
                                       @[@"SearchMessage"],
                                       @[@"MessageSilent", @"SetTop", @"SaveGroup"],
                                       @[@"GroupNameCard", @"ShowNameCard"],
                                       @[@"ClearMessage", @"QuitGroup"]];
            } else {
                self.tableViewList = @[@[@"Portrait"],
                                       @[@"Member"],
                                       @[@"GroupName", @"GroupAnnouncement", @"GroupRemark", @"GroupManage"],
                                       @[@"SearchMessage"],
                                       @[@"MessageSilent", @"SetTop", @"SaveGroup"],
                                       @[@"GroupNameCard", @"ShowNameCard"],
                                       @[@"ClearMessage", @"QuitGroup"]];
            }
            break;
        default:
            self.tableViewList = @[];
            break;
    }
}

- (void)setupMemberCollectionView {
    if (self.conversation.type == Single_Type || self.conversation.type == Group_Type) {
        self.memberCollectionViewLayout = [[WFCUConversationSettingMemberCollectionViewLayout alloc] initWithItemMargin:8];

        if (self.conversation.type == Single_Type) {
            self.extraBtnNumber = 1;
            self.memberCollectionCount = 2;
        } else if(self.conversation.type == Group_Type) {
            if ([self isGroupManager]) {
                self.extraBtnNumber = 2;
                self.memberCollectionCount = (int)self.memberList.count + self.extraBtnNumber;
            } else if(self.groupInfo.type == GroupType_Restricted) {
                if (self.groupInfo.joinType == 1 || self.groupInfo.joinType == 0) {
                    self.extraBtnNumber = 1;
                    self.memberCollectionCount = (int)self.memberList.count + self.extraBtnNumber;
                } else {
                    self.memberCollectionCount = (int)self.memberList.count;
                }
            } else {
                self.extraBtnNumber = 1;
                self.memberCollectionCount = (int)self.memberList.count + self.extraBtnNumber;
            }
            if (self.memberCollectionCount > Group_Member_Visible_Lines * 5) {
                self.memberCollectionCount = Group_Member_Visible_Lines * 5;
                self.showMoreMember = YES;
            }
        } else if(self.conversation.type == Channel_Type) {
            self.memberCollectionCount = 1;
        } else if(self.conversation.type == SecretChat_Type) {
            self.memberCollectionCount = 0;
            self.extraBtnNumber = 0;
        }
        
        self.memberCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.memberCollectionViewLayout];
        self.memberCollectionView.delegate = self;
        self.memberCollectionView.dataSource = self;
        self.memberCollectionView.backgroundColor = UIColor.whiteColor;
        [self.memberCollectionView registerClass:[WFCUConversationSettingMemberCell class] forCellWithReuseIdentifier:Group_Member_Cell_Reuese_ID];
        
        if (self.showMoreMember) {
            UIView *head = [[UIView alloc] init];
            [head addSubview:self.memberCollectionView];
            [self.memberCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(head);
                make.bottom.equalTo(head).offset(-36);
            }];
            
            UIButton *moreBtn = [[UIButton alloc] init];
            [moreBtn setTitle:WFCString(@"ShowAllMembers") forState:UIControlStateNormal];
            moreBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:17];
            [moreBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            moreBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            [moreBtn addTarget:self action:@selector(onViewAllMember:) forControlEvents:UIControlEventTouchDown];
            [head addSubview:moreBtn];
            [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.equalTo(head);
            }];
            
            head.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
            self.memberCell = [[UITableViewCell alloc] init];
            [self.memberCell.contentView addSubview:head];
            [head mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo(self.memberCell.contentView);
            }];
        } else {
            self.memberCell = [[UITableViewCell alloc] init];
            [self.memberCell.contentView addSubview:self.memberCollectionView];
            [self.memberCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo(self.memberCell.contentView);
            }];
        }
    }

}

- (void)onViewAllMember:(id)sender {
    WFCUGroupMemberCollectionViewController *vc = [[WFCUGroupMemberCollectionViewController alloc] init];
    vc.groupId = self.groupInfo.target;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTapChannelPortrait:(id)sender {
    WFCUChannelProfileViewController *pvc = [[WFCUChannelProfileViewController alloc] init];
    pvc.channelInfo = self.channelInfo;
    [self.navigationController pushViewController:pvc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (BOOL)isChannelOwner {
    if (self.conversation.type != Channel_Type) {
        return false;
    }
    
    return [self.channelInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId];
}

- (BOOL)isGroupOwner {
    if (self.conversation.type != Group_Type) {
        return false;
    }
    
    return [self.groupInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId];
}

- (BOOL)isGroupManager {
    if (self.conversation.type != Group_Type) {
        return false;
    }
    if ([self isGroupOwner]) {
        return YES;
    }
    __block BOOL isManager = false;
    [self.memberList enumerateObjectsUsingBlock:^(WFCCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.memberId isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
            if (obj.type == Member_Type_Manager || obj.type == Member_Type_Owner) {
                isManager = YES;
            }
            *stop = YES;
        }
    }];
    return isManager;
}
- (void)onDestroySecretChat:(id)sender {
    __weak typeof(self) ws = self;
    [[WFCCIMService sharedWFCIMService] destroySecretChat:self.conversation.target success:^{
        [ws.navigationController popToRootViewControllerAnimated:YES];
    } error:^(int error_code) {
        [ws.navigationController popToRootViewControllerAnimated:YES];
    }];
}
- (void)deleteAndQuit {
    if(self.conversation.type == Group_Type) {
        if ([self isGroupOwner]) {
            __weak typeof(self) ws = self;
            [[WFCCIMService sharedWFCIMService] removeConversation:self.conversation clearMessage:YES];
            [[WFCCIMService sharedWFCIMService] dismissGroup:self.conversation.target notifyLines:@[@(0)] notifyContent:nil success:^{
                [ws.navigationController popToRootViewControllerAnimated:YES];
            } error:^(int error_code) {
                
            }];
        } else {
            __weak typeof(self) ws = self;
            [[WFCCIMService sharedWFCIMService] quitGroup:self.conversation.target notifyLines:@[@(0)] notifyContent:nil success:^{
                [ws.navigationController popToRootViewControllerAnimated:YES];
            } error:^(int error_code) {
                
            }];
        }
    } else {
        if ([self isChannelOwner]) {
            __weak typeof(self) ws = self;
            [[WFCCIMService sharedWFCIMService] destoryChannel:self.conversation.target success:^{
                [[WFCCIMService sharedWFCIMService] removeConversation:ws.conversation clearMessage:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ws.navigationController popToRootViewControllerAnimated:YES];
                });
            } error:^(int error_code) {
                
            }];
        } else {
            __weak typeof(self) ws = self;
            [[WFCCIMService sharedWFCIMService] listenChannel:self.conversation.target listen:NO success:^{
                [[WFCCIMService sharedWFCIMService] removeConversation:ws.conversation clearMessage:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ws.navigationController popToRootViewControllerAnimated:YES];
                });
            } error:^(int error_code) {
                
            }];
        }
    }
}

- (void)clearMessageAction {
    __weak typeof(self)weakSelf = self;

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:WFCString(@"ConfirmDelete") message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:WFCString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    UIAlertAction *actionLocalDelete = [UIAlertAction actionWithTitle:WFCString(@"DeleteLocalMsg") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[WFCCIMService sharedWFCIMService] clearMessages:self.conversation];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:NO];
            hud.label.text = WFCString(@"Deleted");
            hud.mode = MBProgressHUDModeText;
            hud.removeFromSuperViewOnHide = YES;
            [hud hideAnimated:NO afterDelay:1.5];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMessageListChanged object:weakSelf.conversation];
    }];
    
    UIAlertAction *actionRemoteDelete = [UIAlertAction actionWithTitle:WFCString(@"DeleteRemoteMsg") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        hud.label.text = WFCString(@"Deleting");
        [hud showAnimated:YES];
        
        [[WFCCIMService sharedWFCIMService] clearRemoteConversationMessage:weakSelf.conversation success:^{
            [hud hideAnimated:NO];
            hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:NO];
            hud.label.text = WFCString(@"Deleted");
            hud.mode = MBProgressHUDModeText;
            hud.removeFromSuperViewOnHide = YES;
            [hud hideAnimated:NO afterDelay:1.5];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMessageListChanged object:weakSelf.conversation];
        } error:^(int error_code) {
            [hud hideAnimated:NO];
            hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:NO];
            hud.label.text = WFCString(@"DeleteFailed");
            hud.mode = MBProgressHUDModeText;
            hud.removeFromSuperViewOnHide = YES;
            [hud hideAnimated:NO afterDelay:1.5];
        }];
    }];
    
    //把action添加到actionSheet里
    [actionSheet addAction:actionLocalDelete];
    if(self.conversation.type != SecretChat_Type) {
        [actionSheet addAction:actionRemoteDelete];
    }
    [actionSheet addAction:actionCancel];
    
    //相当于之前的[actionSheet show];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:actionSheet animated:YES completion:nil];
    });
}

- (void)setBurnTime:(int)ms {
    [[WFCCIMService sharedWFCIMService] setSecretChat:self.conversation.target burnTime:ms];
    [self.tableView reloadData];
}

- (void)onBurnTimeAction {
    __weak typeof(self)weakSelf = self;

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"设置销毁时间" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:WFCString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    UIAlertAction *actionNoBurn = [UIAlertAction actionWithTitle:@"不销毁" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setBurnTime:0];
    }];
    
    UIAlertAction *action3s = [UIAlertAction actionWithTitle:@"3秒钟" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setBurnTime:3000];
    }];
    
    UIAlertAction *action10s = [UIAlertAction actionWithTitle:@"10秒钟" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setBurnTime:10000];
    }];
    
    UIAlertAction *action30s = [UIAlertAction actionWithTitle:@"30秒钟" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setBurnTime:30000];
    }];
    
    UIAlertAction *action60s = [UIAlertAction actionWithTitle:@"1分钟" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setBurnTime:60000];
    }];
    
    UIAlertAction *action600s = [UIAlertAction actionWithTitle:@"10分钟" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setBurnTime:600000];
    }];
    

    //把action添加到actionSheet里
    [actionSheet addAction:actionNoBurn];
    [actionSheet addAction:action3s];
    [actionSheet addAction:action10s];
    [actionSheet addAction:action30s];
    [actionSheet addAction:action60s];
    [actionSheet addAction:action600s];
    [actionSheet addAction:actionCancel];
    
    //相当于之前的[actionSheet show];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)showQRCode {
    if (gQrCodeDelegate) {
        [gQrCodeDelegate showQrCodeViewController:self.navigationController type:QRType_Group target:self.groupInfo.target];
    }
}

- (void)selectImage {
    if (self.isBroadcast) {
        return;
    }
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"修改群聊头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.delegate = self;
        if ([UIImagePickerController
             isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            [self.view makeToast:@"无法连接相机"];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
    UIAlertAction *actionAlubum = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }];

    [actionSheet addAction:actionCamera];
    [actionSheet addAction:actionAlubum];
    [actionSheet addAction:actionCancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)updateGroupPortrait:(NSString *)imageUrl image:(UIImage *)image{
    if (self.groupInfo == nil) {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = WFCString(@"Updating");
    [hud showAnimated:YES];

    [WFCCIMService.sharedWFCIMService modifyGroupInfo:self.groupInfo.target type:Modify_Group_Portrait newValue:imageUrl notifyLines:@[@(0)] notifyContent:nil success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:WFCString(@"UpdateDone")];
            // 下載圖片讓圖片進入 cache 下次就可以很快顯示圖片
            [self.portraitCell.portraitView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:image];
        });
    } error:^(int error_code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:WFCString(@"UpdateFailure")];
        });
    }];
}

#pragma mark - UITableViewDataSource<NSObject>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableViewList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewList[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
    view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"GroupAnnouncement"]) {
        float height = [WFCUUtilities getTextDrawingSize:self.groupAnnouncement.text font:[UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12] constrainedSize:CGSizeMake(self.view.bounds.size.width - 48, 1000)].height;
        if (height > 12 * 3.2) {
            height = 12 * 3.2;
        }
        return height + 50;
    } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"Portrait"]) {
        return 96;
    } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"Member"]) {
        CGFloat height = [self.memberCollectionViewLayout getHeigthOfItemCount:self.memberCollectionCount];
        if (self.showMoreMember) {
            height += 36;
        }
        
        return height;
    }
    
    return 54;
}

- (UITableViewCell *)cellOfTable:(UITableView *)tableView WithTitle:(NSString *)title withDetailTitle:(NSString *)detailTitle withDisclosureIndicator:(BOOL)withDI withSwitch:(BOOL)withSwitch withSwitchType:(SwitchType)type {
    if (withSwitch) {
        WFCUSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"styleSwitch"];
        if(cell == nil) {
            cell = [[WFCUSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"styleSwitch" conversation:self.conversation];
        }
        cell.textLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        cell.textLabel.textColor = [WFCUConfigManager globalManager].textColor;
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        cell.textLabel.text = title;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.type = type;
        cell.separatorInset = UIEdgeInsetsZero;
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"style1Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"style1Cell"];
        }
        cell.textLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        cell.textLabel.text = title;
        cell.detailTextLabel.text = detailTitle;
        cell.detailTextLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:15];
        cell.accessoryType = withDI ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsZero;

        return cell;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"Portrait"]) {
        if (self.portraitCell == nil) {
            self.portraitCell = [[PortraitCell alloc] init];
            self.portraitCell.canEdit = !self.isBroadcast;
            [self.portraitCell.control addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchDown];
            if (self.conversation.type == Group_Type) {
                if (self.groupInfo.portrait == nil || [self.groupInfo.portrait isEqualToString:@""]) {
                    NSString *path = [WFCCUtilities getGroupGridPortrait:self.groupInfo.target width:80 generateIfNotExist:YES defaultUserPortrait:^UIImage *(NSString *userId) {
                        return [WFCUImage imageNamed:@"PersonalChat"];
                    }];
                    
                    if (path) {
                        self.portraitCell.portraitView.image = [UIImage imageWithContentsOfFile:path];
                    } else {
                        self.portraitCell.portraitView.image = [WFCUImage imageNamed:@"group_default_portrait"];
                    }
                } else {
                    [self.portraitCell.portraitView sd_setImageWithURL:[NSURL URLWithString:self.groupInfo.portrait] placeholderImage:[WFCUImage imageNamed:@"group_default_portrait"]];
                }
            } else {
                [self.portraitCell.portraitView sd_setImageWithURL:[NSURL URLWithString:self.groupInfo.portrait] placeholderImage:[WFCUImage imageNamed:@"PersonalChat"]];
            }
        }
        
        return self.portraitCell;
    } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"Member"]) {
        return self.memberCell;
    }else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"GroupName"]) {
      return [self cellOfTable:tableView WithTitle:WFCString(@"GroupName") withDetailTitle:self.groupInfo.name withDisclosureIndicator:YES withSwitch:NO withSwitchType:SwitchType_Conversation_None];
    } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"GroupManage"]) {
      return [self cellOfTable:tableView WithTitle:WFCString(@"GroupManage") withDetailTitle:nil withDisclosureIndicator:YES withSwitch:NO withSwitchType:SwitchType_Conversation_None];
    } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"GroupRemark"]) {
      return [self cellOfTable:tableView WithTitle:WFCString(@"GroupRemark") withDetailTitle:self.groupInfo.remark withDisclosureIndicator:YES withSwitch:NO withSwitchType:SwitchType_Conversation_None];
    } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"GroupAnnouncement"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"announcementCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"announcementCell"];
        }

        cell.textLabel.text = WFCString(@"GroupAnnouncement");
        cell.textLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        cell.detailTextLabel.text = self.groupAnnouncement.text;
        cell.detailTextLabel.numberOfLines = 3;
        cell.detailTextLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsZero;
      
        return cell;
      
    } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"SearchMessage"]) {
        return [self cellOfTable:tableView WithTitle:WFCString(@"SearchMessageContent") withDetailTitle:nil withDisclosureIndicator:YES withSwitch:NO withSwitchType:SwitchType_Conversation_None];
    } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"MessageSilent"]) {
        return [self cellOfTable:tableView WithTitle:@"消息免打扰" withDetailTitle:nil withDisclosureIndicator:NO withSwitch:YES withSwitchType:SwitchType_Conversation_Silent];
    } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"SetTop"]) {
        UITableViewCell *cell = [self cellOfTable:tableView WithTitle:WFCString(@"PinChat") withDetailTitle:nil withDisclosureIndicator:NO withSwitch:YES withSwitchType:SwitchType_Conversation_Top];
        if ([cell isMemberOfClass:WFCUSwitchTableViewCell.class] && self.isBroadcast) {
            WFCUSwitchTableViewCell *switchCell = (WFCUSwitchTableViewCell *)cell;
            switchCell.switchDisable = YES;
        }
        return cell;
    } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"SaveGroup"]) {
        return [self cellOfTable:tableView WithTitle:WFCString(@"SaveToContact") withDetailTitle:nil withDisclosureIndicator:NO withSwitch:YES withSwitchType:SwitchType_Conversation_Save_To_Contact];
    } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"GroupNameCard"]) {
        WFCCGroupMember *groupMember = [[WFCCIMService sharedWFCIMService] getGroupMember:self.conversation.target memberId:[WFCCNetworkService sharedInstance].userId];
        if (groupMember.alias.length) {
            return [self cellOfTable:tableView WithTitle:WFCString(@"NicknameInGroup") withDetailTitle:groupMember.alias withDisclosureIndicator:YES withSwitch:NO withSwitchType:SwitchType_Conversation_None];
        } else {
            return [self cellOfTable:tableView WithTitle:WFCString(@"NicknameInGroup") withDetailTitle:WFCString(@"Unset") withDisclosureIndicator:YES withSwitch:NO withSwitchType:SwitchType_Conversation_None];
        }
    } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"ShowNameCard"]) {
        return [self cellOfTable:tableView WithTitle:WFCString(@"ShowMemberNickname") withDetailTitle:nil withDisclosureIndicator:NO withSwitch:YES withSwitchType:SwitchType_Conversation_Show_Alias];
    } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"ClearMessage"]) {
        ConversationSettingRedButtonCell *cell = [[ConversationSettingRedButtonCell alloc] init];
        cell.title = WFCString(@"ClearChatHistory");
        return cell;
    } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"QuitGroup"]) {
        ConversationSettingRedButtonCell *cell = [[ConversationSettingRedButtonCell alloc] init];
        if ([self isGroupOwner]) {
            cell.title = @"解散并删除";
        } else {
            cell.title = WFCString(@"QuitGroup");
        }
        
        return cell;
    } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"UnsubscribeChannel"]) {
        ConversationSettingRedButtonCell *cell = [[ConversationSettingRedButtonCell alloc] init];
        if ([self isChannelOwner]) {
            cell.title = WFCString(@"DestroyChannel");
        } else {
            cell.title = WFCString(@"UnscribeChannel");
        }
        
        return cell;
    } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"Files"]) {
              return [self cellOfTable:tableView WithTitle:WFCString(@"ConvFiles") withDetailTitle:nil withDisclosureIndicator:YES withSwitch:NO withSwitchType:SwitchType_Conversation_None];
    } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"DestroySecretChat"]) {
        ConversationSettingRedButtonCell *cell = [[ConversationSettingRedButtonCell alloc] init];
        cell.title = @"销毁私密聊天";
        return cell;
    } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"BurnTime"]) {
        NSString *subTitle = @"关闭";
        WFCCSecretChatInfo *info = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:self.conversation.target];
        if(info.burnTime) {
            subTitle = [NSString stringWithFormat:@"%d秒", info.burnTime/1000];
        }
        return [self cellOfTable:tableView WithTitle:@"设置密聊焚毁时间" withDetailTitle:subTitle withDisclosureIndicator:NO withSwitch:NO withSwitchType:SwitchType_Conversation_None];
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self)weakSelf = self;
  if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"GroupName"]) {
      if (self.groupInfo.type == GroupType_Restricted && ![self isGroupManager]) {
          [self.view makeToast:WFCString(@"OnlyManangerCanChangeGroupNameHint") duration:1 position:CSToastPositionCenter];
          return;
      }
    WFCUGeneralModifyViewController *gmvc = [[WFCUGeneralModifyViewController alloc] init];
    gmvc.defaultValue = self.groupInfo.name;
    gmvc.titleText = WFCString(@"ModifyGroupName");
    gmvc.canEmpty = NO;
    gmvc.limitLength = 20;
    gmvc.tryModify = ^(NSString *newValue, void (^result)(BOOL success)) {
      [[WFCCIMService sharedWFCIMService] modifyGroupInfo:self.groupInfo.target type:Modify_Group_Name newValue:newValue notifyLines:@[@(0)] notifyContent:nil success:^{
        result(YES);
          weakSelf.groupInfo.name = newValue;
          [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      } error:^(int error_code) {
        result(NO);
      }];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:gmvc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
  } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"GroupManage"]) {
      GroupManageTableViewController *gmvc = [[GroupManageTableViewController alloc] init];
      gmvc.groupInfo = self.groupInfo;
      [self.navigationController pushViewController:gmvc animated:YES];
  } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"SearchMessage"]) {
      WFCUConversationSearchTableViewController *mvc = [[WFCUConversationSearchTableViewController alloc] init];
      mvc.conversation = self.conversation;
      mvc.hidesBottomBarWhenPushed = YES;
      [self.navigationController pushViewController:mvc animated:YES];
  } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"GroupNameCard"]) {
    WFCUGeneralModifyViewController *gmvc = [[WFCUGeneralModifyViewController alloc] init];
    WFCCGroupMember *groupMember = [[WFCCIMService sharedWFCIMService] getGroupMember:self.conversation.target memberId:[WFCCNetworkService sharedInstance].userId];
    gmvc.defaultValue = groupMember.alias;
    gmvc.titleText = WFCString(@"ModifyMyGroupNameCard");
    gmvc.canEmpty = NO;
    gmvc.tryModify = ^(NSString *newValue, void (^result)(BOOL success)) {
      [[WFCCIMService sharedWFCIMService] modifyGroupAlias:self.conversation.target alias:newValue notifyLines:@[@(0)] notifyContent:nil success:^{
        result(YES);
          [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      } error:^(int error_code) {
        result(NO);
      }];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:gmvc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
  } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"GroupAnnouncement"]) {
      WFCUGroupAnnouncementViewController *vc = [[WFCUGroupAnnouncementViewController alloc] init];
      vc.announcement = self.groupAnnouncement;
      vc.isManager = [self isGroupManager];
      [self.navigationController pushViewController:vc animated:YES];
  } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"Files"]) {
      WFCUFilesViewController *vc = [[WFCUFilesViewController alloc] init];
      vc.conversation = self.conversation;
      [self.navigationController pushViewController:vc animated:YES];
  } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"BurnTime"]) {
      [self onBurnTimeAction];
  } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"GroupRemark"]) {
      WFCUGeneralModifyViewController *gmvc = [[WFCUGeneralModifyViewController alloc] init];
      gmvc.defaultValue = self.groupInfo.remark;
      gmvc.titleText = WFCString(@"ModifyGroupRemark");
      gmvc.canEmpty = YES;
      gmvc.limitLength = 20;
      gmvc.tryModify = ^(NSString *newValue, void (^result)(BOOL success)) {
          [[WFCCIMService sharedWFCIMService] setGroup:self.conversation.target remark:newValue success:^{
              result(YES);
              weakSelf.groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:weakSelf.conversation.target refresh:NO];
              [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
          } error:^(int error_code) {
              result(NO);
          }];
      };
      UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:gmvc];
      [self.navigationController presentViewController:nav animated:YES completion:nil];
  } else if ([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"ClearMessage"]) {
      [self clearMessageAction];
  } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"QuitGroup"]) {
      [self deleteAndQuit];
  } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"UnsubscribeChannel"]) {
      [self deleteAndQuit];
  } else if([self.tableViewList[indexPath.section][indexPath.row] isEqualToString:@"DestroySecretChat"]) {
      [self deleteAndQuit];
  }
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.conversation.type == Group_Type || self.conversation.type == Single_Type) {
        return self.memberCollectionCount;
    } else if(self.conversation.type == Channel_Type) {
        return self.memberList.count;
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WFCUConversationSettingMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Group_Member_Cell_Reuese_ID forIndexPath:indexPath];
    if (indexPath.row < self.memberCollectionCount-self.extraBtnNumber) {
        WFCCGroupMember *member = self.memberList[indexPath.row];
        [cell setModel:member withType:self.conversation.type];
    } else {
        if (indexPath.row == self.memberCollectionCount-self.extraBtnNumber) {
            [cell.headerImageView setImage:[WFCUImage imageNamed:@"addmember"]];
            cell.nameLabel.text = nil;
            cell.nameLabel.hidden = YES;
            cell.isfunctionCell = YES;
        } else {
            [cell.headerImageView setImage:[WFCUImage imageNamed:@"removemember"]];
            cell.nameLabel.text = nil;
            cell.nameLabel.hidden = YES;
            cell.isfunctionCell = YES;
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self)ws = self;
    if (indexPath.row == self.memberCollectionCount-self.extraBtnNumber) {
        WFCUContactListViewController *pvc = [[WFCUContactListViewController alloc] init];
        pvc.selectContact = YES;
        pvc.multiSelect = YES;
        NSMutableArray *disabledUser = [[NSMutableArray alloc] init];
      if(self.conversation.type == Group_Type) {
          
        for (WFCCGroupMember *member in [[WFCCIMService sharedWFCIMService] getGroupMembers:self.groupInfo.target forceUpdate:NO]) {
            [disabledUser addObject:member.memberId];
        }
          
        NSString *memberExtra = nil;
          
        pvc.selectResult = ^(NSArray<NSString *> *contacts) {
            [[WFCCIMService sharedWFCIMService] addMembers:contacts toGroup:ws.conversation.target memberExtra:memberExtra notifyLines:@[@(0)] notifyContent:nil success:^{
              [[WFCCIMService sharedWFCIMService] getGroupMembers:ws.conversation.target forceUpdate:YES];
                
            } error:^(int error_code) {
                if (error_code == ERROR_CODE_GROUP_EXCEED_MAX_MEMBER_COUNT) {
                    [ws.view makeToast:WFCString(@"ExceedGroupMaxMemberCount") duration:1 position:CSToastPositionCenter];
                } else {
                    [ws.view makeToast:WFCString(@"NetworkError") duration:1 position:CSToastPositionCenter];
                }
            }];
        };
        pvc.disableUsersSelected = YES;
      } else {
        [disabledUser addObject:self.conversation.target];
        pvc.selectResult = ^(NSArray<NSString *> *contacts) {
            WFCUCreateConversationViewController *vc = [[WFCUCreateConversationViewController alloc] init];
            NSMutableArray *newContacts = contacts.mutableCopy;
            [newContacts insertObject:self.conversation.target atIndex:0];
            vc.memberList = newContacts;
            [self.navigationController pushViewController:vc animated:YES];
        };
          
        pvc.title = @"发起群聊";
        pvc.disableUsersSelected = YES;
        pvc.noBack = YES;
      }
        pvc.disableUsers = disabledUser;
        pvc.isPushed = YES;
        [self.navigationController pushViewController:pvc animated:YES];
    } else if(indexPath.row == self.memberCollectionCount-self.extraBtnNumber + 1) {
        WFCUContactListViewController *pvc = [[WFCUContactListViewController alloc] init];
        pvc.selectContact = YES;
        pvc.multiSelect = YES;
        __weak typeof(self)ws = self;
        pvc.selectResult = ^(NSArray<NSString *> *contacts) {
          [[WFCCIMService sharedWFCIMService] kickoffMembers:contacts fromGroup:self.conversation.target notifyLines:@[@(0)] notifyContent:nil success:^{
            [[WFCCIMService sharedWFCIMService] getGroupMembers:ws.conversation.target forceUpdate:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
              NSMutableArray *tmpArray = [ws.memberList mutableCopy];
              NSMutableArray *removeArray = [[NSMutableArray alloc] init];
              [tmpArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WFCCGroupMember *member = obj;
                if([contacts containsObject:member.memberId]) {
                  [removeArray addObject:member];
                }
              }];
              [tmpArray removeObjectsInArray:removeArray];
              ws.memberList = [tmpArray mutableCopy];
              [ws setupMemberCollectionView];
              [ws.memberCollectionView reloadData];
            });
          } error:^(int error_code) {
            
          }];
      };
        NSMutableArray *candidateUsers = [[NSMutableArray alloc] init];
        NSMutableArray *disableUsers = [[NSMutableArray alloc] init];
        BOOL isOwner = [self isGroupOwner];
        
        for (WFCCGroupMember *member in [[WFCCIMService sharedWFCIMService] getGroupMembers:self.groupInfo.target forceUpdate:NO]) {
            [candidateUsers addObject:member.memberId];
            if (!isOwner && (member.type == Member_Type_Manager || [self.groupInfo.owner isEqualToString:member.memberId])) {
                [disableUsers addObject:member.memberId];
            }
        }
        [disableUsers addObject:[WFCCNetworkService sharedInstance].userId];
        pvc.candidateUsers = candidateUsers;
        pvc.disableUsers = [disableUsers copy];
        pvc.isPushed = YES;
        [self.navigationController pushViewController:pvc animated:YES];
    } else {
      NSString *userId;
      if(self.conversation.type == Group_Type) {
        WFCCGroupMember *member = [self.memberList objectAtIndex:indexPath.row];
        userId = member.memberId;
          
        if (self.groupInfo.privateChat) {
          if (![self.groupInfo.owner isEqualToString:userId] && ![self.groupInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
              WFCCGroupMember *gm = [[WFCCIMService sharedWFCIMService] getGroupMember:self.conversation.target memberId:[WFCCNetworkService sharedInstance].userId];
              if (gm.type != Member_Type_Manager) {
                  WFCCGroupMember *gm = [[WFCCIMService sharedWFCIMService] getGroupMember:self.conversation.target memberId:userId];
                  if (gm.type != Member_Type_Manager) {
                      [self.view makeToast:WFCString(@"NotAllowTemporarySession") duration:1 position:CSToastPositionCenter];
                      return;
                  }
              }
          }
        }

      } else {
        userId = self.conversation.target;
      }
        WFCUProfileTableViewController *vc = [[WFCUProfileTableViewController alloc] init];
        vc.userId = userId;
        vc.fromConversation = self.conversation;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"上传中...";
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    [hud showAnimated:YES];
    
    [WFCUConfigManager.globalManager.appServiceProvider uploadImage:image progress:^(NSProgress * _Nonnull progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.progress = progress.fractionCompleted;
        });
    } success:^(NSString * _Nonnull url) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self updateGroupPortrait:url image:image];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:@"上传失败"];
        });
    }];
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
