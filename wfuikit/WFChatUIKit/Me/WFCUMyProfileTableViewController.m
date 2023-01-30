//
//  WFCUProfileTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/22.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUMyProfileTableViewController.h"

#import <SDWebImage/SDWebImage.h>
#import <WFChatClient/WFCChatClient.h>

#import "masonry.h"
#import "MBProgressHUD.h"
#import "UIColor+YH.h"
#import "UIView+Toast.h"
#import "WFCUModifyMyProfileViewController.h"
#import "WFCUConfigManager.h"
#import "WFCUImage.h"
#import "PortraitCell.h"
#import "WFCUModifyGenderViewController.h"

@interface WFCUMyProfileTableViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray<UITableViewCell *> *cells1;
@property (nonatomic, strong)NSMutableArray<UITableViewCell *> *cells2;
@property (nonatomic, strong)WFCCUserInfo *IMUserInfo;
@property (nonatomic, strong)WFCCUserInfo *apiUserInfo;

@end

@implementation WFCUMyProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = WFCString(@"MyInformation");
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self.view addSubview:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getUserInfo:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getUserInfo:(BOOL)refresh {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"读取中...";
    [hud showAnimated:YES];
    
    NSString *userId = [WFCCNetworkService sharedInstance].userId;
    
    [[WFCUConfigManager globalManager].appServiceProvider getWFCCUserInfo:userId success:^(WFCCUserInfo * _Nonnull info) {
        self.apiUserInfo = info;
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self loadData:refresh];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self loadData:refresh];
            [self.view makeToast:message];
        });
    }];
}

- (void)onUserInfoUpdated:(NSNotification *)notification {
    WFCCUserInfo *userInfo = notification.userInfo[@"userInfo"];
    if ([[WFCCNetworkService sharedInstance].userId isEqualToString:userInfo.userId]) {
        [self getUserInfo:NO];
    }
}

- (void)loadData:(BOOL)refresh {
    self.cells1 = [[NSMutableArray alloc] init];
    self.cells2 = [[NSMutableArray alloc] init];
    self.IMUserInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFCCNetworkService sharedInstance].userId refresh:refresh];
    
    PortraitCell *headerCell = [[PortraitCell alloc] init];
    [headerCell.control addTarget:self action:@selector(onViewPortrait:) forControlEvents:UIControlEventTouchDown];
    [headerCell.portraitView sd_setImageWithURL:[NSURL URLWithString:[self.apiUserInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[WFCUImage imageNamed:@"PersonalChat"]];
    [self.cells1 addObject:headerCell];

    UITableViewCell *cell = [self createCellWithLeftText:WFCString(@"Nickname") rightText:self.IMUserInfo.displayName disable:NO line:YES];
    cell.tag = Modify_DisplayName;
    [self.cells2 addObject:cell];

    cell = [self createCellWithLeftText:@"账号" rightText:self.IMUserInfo.name disable:YES line:YES];
    cell.tag = 100;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.cells2 addObject:cell];

    cell = [self createCellWithLeftText:@"手机号" rightText:self.IMUserInfo.mobile disable:YES line:YES];
    cell.tag = Modify_Mobile;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.cells2 addObject:cell];

    cell = [self createCellWithLeftText:WFCString(@"Gender") rightText:self.IMUserInfo.genderString disable:NO line:NO];
    cell.tag = Modify_Gender;
    [self.cells2 addObject:cell];
    
    [self.tableView reloadData];
}

- (UITableViewCell *)createCellWithLeftText:(NSString *)leftText rightText:(NSString *)rightText disable:(BOOL)disable line:(BOOL)line{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    UILabel *leftLabel = [[UILabel alloc] init];
    leftLabel.text = leftText;
    [leftLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [cell.contentView addSubview:leftLabel];
    [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell.contentView);
        make.left.equalTo(cell.contentView).offset(20);
        make.top.bottom.equalTo(cell.contentView);
    }];

    UILabel * rightLabel = [[UILabel alloc] init];
    rightLabel.text = rightText;
    [cell.contentView addSubview:rightLabel];
    [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell.contentView);
        if (disable) {
            make.right.equalTo(cell.contentView).offset(-20);
        } else {
            make.right.equalTo(cell.contentView).offset(-10);
        }
        
        make.left.greaterThanOrEqualTo(leftLabel.mas_right).offset(10);
    }];
    
    if (disable) {
        rightLabel.textColor = [UIColor colorWithHexString:@"0xE4E4E4"];
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        rightLabel.textColor = [UIColor colorWithHexString:@"0xADADAD"];
    }
    
    if (line) {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor colorWithHexString:@"0xF6F6F6"];
        [cell.contentView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(cell.contentView);
            make.height.mas_equalTo(1);
        }];
    }
    
    return cell;
}

- (void)onViewPortrait:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:WFCString(@"ChangePortrait") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:WFCString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:WFCString(@"TakePhotos") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
    
    UIAlertAction *actionAlubum = [UIAlertAction actionWithTitle:WFCString(@"Album") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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

- (void)showGenderVC{
    WFCUModifyGenderViewController *vc = [[WFCUModifyGenderViewController alloc] init];
    vc.userInfo = self.apiUserInfo;
    [self.navigationController pushViewController:vc animated:YES];
    return;
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.cells1.count;
    }
    return self.cells2.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.cells1[indexPath.row];
    }
    return self.cells2[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag < 0 || cell.tag == Modify_Mobile || cell.tag == 100) {
        return;
    }
    
    if (cell.tag == Modify_Gender) {
        [self showGenderVC];
        return;
    }
    
    WFCUModifyMyProfileViewController *mpvc = [[WFCUModifyMyProfileViewController alloc] init];
    mpvc.modifyType = cell.tag;
    __weak typeof(self)ws = self;
    mpvc.onModified = ^(NSInteger modifyType, NSString *value) {
        NSArray *cells =ws.cells2;
        if (indexPath.section == 0) {
            cells = ws.cells1;
        }
        for (UITableViewCell *cell in cells) {
            if (cell.tag == modifyType) {
                for (UIView *view in cell.subviews) {
                    if (view.tag == 2) {
                        UILabel *label = (UILabel *)view;
                        label.text = value;
                    }
                }
            }
        }
    };
    
    [self.navigationController pushViewController:mpvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 96;
    } else {
        return 54 ;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
    view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    return view;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = WFCString(@"Updating");
    [hud showAnimated:YES];
  
    UpdateProfileModel *model = [[UpdateProfileModel alloc] init];
    [model setValue:[info objectForKey:UIImagePickerControllerEditedImage] type:Modify_Portrait];
    
    [WFCUConfigManager.globalManager.appServiceProvider updateProfileWithModel:model progress:^(NSProgress * _Nonnull progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.progress = progress.fractionCompleted;
        });
    } success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:WFCString(@"UpdateDone")];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:message];
        });
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
