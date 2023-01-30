#import "WFCUCreateConversationViewController.h"

#import <SDWebImage/SDWebImage.h>

#import "MBProgressHUD.h"
#import "masonry.h"
#import "UIView+Toast.h"
#import "UIColor+YH.h"
#import "WFCUConfigManager.h"
#import "WFCUConversationSettingMemberCollectionViewLayout.h"
#import "WFCUConversationSettingMemberCell.h"
#import "WFCUContactListViewController.h"
#import "WFCUMessageListViewController.h"
#import "WFCUMyProfileTableViewController.h"
#import "WFCUProfileTableViewController.h"
#import "WFCUImage.h"

@interface WFCUCreateConversationViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong)UICollectionView *memberCollectionView;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)WFCUConversationSettingMemberCollectionViewLayout *memberCollectionViewLayout;
@property (nonatomic, strong)UIImageView *groupImageView;
@property (nonatomic, strong)UITextField *groupNameField;
@property (nonatomic, strong)UITableViewCell *groupImageCell;
@property (nonatomic, strong)UITableViewCell *memberCell;
@property (nonatomic, strong)UITableViewCell *groupNameCell;
@property (nonatomic, strong)NSString *imageUrl;

@end

#define Group_Member_Cell_Reuese_ID @"Group_Member_Cell_Reuese_ID"
#define Group_Member_Visible_Lines 9
@implementation WFCUCreateConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设定群聊资讯";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    UIView *footerView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 146)];
    footerView.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    self.tableView.tableFooterView = footerView;
    [self.view addSubview:self.tableView];
    
    UIButton *createButton = [[UIButton alloc] init];
    [createButton setTitle:@"建立" forState:UIControlStateNormal];
    [createButton setTitleColor:[UIColor colorWithHexString:@"0x4970BA"] forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(createGroup) forControlEvents:UIControlEventTouchDown];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:createButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)setMemberList:(NSArray<NSString *> *)memberList {
    _memberList = memberList;
    [self.tableView reloadData];
}

- (void)resetKeyboard {
    [self.groupNameField resignFirstResponder];
}

- (NSString *)groupDefaultName {
    NSString *name = WFCString(@"GroupChat");
    
    for (int i = 0; i < MIN(8, self.memberList.count); i++) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.memberList[i]  refresh:NO];
        if (userInfo.displayName.length > 0) {
            if (name.length + userInfo.displayName.length + 1 > 16) {
                name = [name stringByAppendingString:WFCString(@"Etc")];
                break;
            }
            
            if (i != 0) {
                name = [name stringByAppendingString:@","];
            }
            
            name = [name stringByAppendingFormat:@"%@", userInfo.displayName];
        }
    }
    
    return name;
}

- (UITableViewCell *)groupImageCell {
    if (_groupImageCell != nil) {
        return _groupImageCell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *groupImageView = [[UIView alloc] init];
    [cell.contentView addSubview:groupImageView];
    [groupImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(cell.contentView);
    }];
    
    UIControl *control = [[UIControl alloc] init];
    [control addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchDown];
    [groupImageView addSubview:control];
    [control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(groupImageView);
        make.centerY.equalTo(groupImageView);
        make.height.equalTo(groupImageView).multipliedBy(0.6);
        make.height.equalTo(control.mas_width);
    }];
    
    self.groupImageView = [[UIImageView alloc] initWithImage:[WFCUImage imageNamed:@"create_group_portrait"]];
    self.groupImageView.clipsToBounds = YES;
    [control addSubview:self.groupImageView];
    [self.groupImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(control);
    }];
    
    UIImageView *camera = [[UIImageView alloc] initWithImage:[WFCUImage imageNamed:@"camera"]];
    [control addSubview:camera];
    [camera mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(control);
        make.height.equalTo(camera.mas_width);
        make.width.equalTo(control).multipliedBy(0.3);
    }];
    
    _groupImageCell = cell;
    
    return cell;
}

- (UITableViewCell *)memberCell {
    if (_memberCell != nil) {
        return _memberCell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.memberCollectionViewLayout = [[WFCUConversationSettingMemberCollectionViewLayout alloc] initWithItemMargin:6];
    self.memberCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self.memberCollectionViewLayout getHeigthOfItemCount:(int)self.memberList.count + 2]) collectionViewLayout:self.memberCollectionViewLayout];
    self.memberCollectionView.delegate = self;
    self.memberCollectionView.dataSource = self;
    self.memberCollectionView.backgroundColor = UIColor.whiteColor;
    [self.memberCollectionView registerClass:[WFCUConversationSettingMemberCell class] forCellWithReuseIdentifier:Group_Member_Cell_Reuese_ID];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    [cell.contentView addSubview:self.memberCollectionView];
    
    _memberCell = cell;
    
    return cell;
}

- (UITableViewCell *)groupNameCell {
    if (_groupNameCell != nil) {
        return _groupNameCell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"群组名称";
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [cell.contentView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView).offset(20);
        make.top.equalTo(cell.contentView).offset(16);
        make.bottom.equalTo(cell.contentView).offset(-16);
    }];
    
    UITextField *groupNameField = [[UITextField alloc] init];
    groupNameField.textAlignment = NSTextAlignmentRight;
    groupNameField.placeholder = [self groupDefaultName];
    self.groupNameField = groupNameField;
    [cell.contentView addSubview:groupNameField];
    [groupNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label.mas_right).offset(5);
        make.top.bottom.equalTo(cell.contentView);
        make.right.equalTo(cell.contentView).offset(-10);
    }];
    
    _groupNameCell = cell;
    
    return cell;
}

- (void)addMember:(NSArray<NSString *> *) users{
    NSMutableArray *newMembers = self.memberList.mutableCopy;
    for (NSString *userId in users) {
        if (![newMembers containsObject:userId]) {
            [newMembers addObject:userId];
        }
    }
    
    self.memberList = newMembers;
}

- (void)deleteMember:(NSArray<NSString *> *) users{
    NSMutableArray *newMembers = self.memberList.mutableCopy;
    for (NSString *userId in users) {
        if ([newMembers containsObject:userId]) {
            [newMembers removeObject:userId];
        }
    }
    
    self.memberList = newMembers;
}

#pragma mark - UITableViewDataSource<NSObject>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 9;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,9)];
    view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        if (self.memberCollectionViewLayout != nil) {
            return [self.memberCollectionViewLayout getHeigthOfItemCount:(int)self.memberList.count + 2];
        } else {
            return 50;
        }
    }
    
    if (indexPath.section == 2) {
        return UITableViewAutomaticDimension;
    }
    
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    if (indexPath.section == 0) {
        return self.groupImageCell;
    } else if (indexPath.section == 1) {
        return self.memberCell;
    } else if (indexPath.section == 2) {
        return self.groupNameCell;
    }
    
    return [[UITableViewCell alloc] init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.memberList.count + 2;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WFCUConversationSettingMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Group_Member_Cell_Reuese_ID forIndexPath:indexPath];
    
    if (indexPath.row == self.memberList.count) {
        [cell.headerImageView setImage:[WFCUImage imageNamed:@"addmember"]];
        cell.nameLabel.text = nil;
        cell.nameLabel.hidden = YES;
        cell.isfunctionCell = YES;
    } else if (indexPath.row == self.memberList.count + 1) {
        [cell.headerImageView setImage:[WFCUImage imageNamed:@"removemember"]];
        cell.nameLabel.text = nil;
        cell.nameLabel.hidden = YES;
        cell.isfunctionCell = YES;
    } else {
        WFCCUserInfo *info = [[WFCCIMService sharedWFCIMService] getUserInfo:self.memberList[indexPath.row]  refresh:NO];
        [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:[info.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[WFCUImage imageNamed:@"PersonalChat"]];
        cell.nameLabel.text = info.displayName;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.memberList.count) {
        WFCUContactListViewController *pvc = [[WFCUContactListViewController alloc] init];
        pvc.selectContact = YES;
        pvc.multiSelect = YES;
        pvc.disableUsers = self.memberList;
        pvc.disableUsersSelected = YES;
        pvc.selectResult = ^(NSArray<NSString *> *contacts) {
            [self addMember:contacts];
            [self.memberCollectionView reloadData];
        };
        
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
        navi.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navi animated:YES completion:nil];
    } else if (indexPath.row == self.memberList.count + 1) {
        WFCUContactListViewController *pvc = [[WFCUContactListViewController alloc] init];
        pvc.selectContact = YES;
        pvc.multiSelect = YES;
        pvc.candidateUsers = self.memberList;
        pvc.selectResult = ^(NSArray<NSString *> *contacts) {
            [self deleteMember:contacts];
            [self.memberCollectionView reloadData];
        };
        
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
        navi.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navi animated:YES completion:nil];
    } else {
        WFCUProfileTableViewController *vc = [[WFCUProfileTableViewController alloc] init];
        vc.userId = self.memberList[indexPath.row];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.groupImageView.image = image;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"上传中...";
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    [hud showAnimated:YES];
    
    [WFCUConfigManager.globalManager.appServiceProvider uploadImage:image progress:^(NSProgress * _Nonnull progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.progress = progress.fractionCompleted;
        });
    } success:^(NSString * _Nonnull url) {
        self.imageUrl = url;
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:@"上传成功"];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.view makeToast:@"上传失败"];
        });
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI Event
- (void)selectImage {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"修改头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
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
    
    //把action添加到actionSheet里
    [actionSheet addAction:actionCamera];
    [actionSheet addAction:actionAlubum];
    [actionSheet addAction:actionCancel];
    
    //相当于之前的[actionSheet show];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)createGroup {
    if (self.groupNameField.text.length > 20) {
        [self.view makeToast:@"群组名称上限为20个字"];
        return;
    }
    
    NSString *groupName = WFCString(@"GroupChat");
    
    if ([self.groupNameField.text isEqualToString:@""]) {
        groupName = self.groupNameField.placeholder;
    } else {
        groupName = self.groupNameField.text;
    }

    [[WFCCIMService sharedWFCIMService] createGroup:nil name:groupName portrait:self.imageUrl type:GroupType_Restricted groupExtra:nil members:self.memberList memberExtra:nil notifyLines:@[@(0)] notifyContent:nil success:^(NSString *groupId) {
        if (groupId == nil || [groupId isEqualToString:@""]) {
            [self.navigationController.view makeToast:@"创建群失败"];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
        mvc.conversation = [[WFCCConversation alloc] init];
        mvc.conversation.type = Group_Type;
        mvc.conversation.target = groupId;
        mvc.conversation.line = 0;
        mvc.hidesBottomBarWhenPushed = YES;
        NSMutableArray<UIViewController *> *array = [self.navigationController.viewControllers mutableCopy];
        
        if (array.count > 1) {
            [array removeObjectsInRange:NSMakeRange(1, array.count - 1)];
        }
        [array addObject:mvc];
        [self.navigationController setViewControllers:array animated:YES];
    } error:^(int error_code) {
        [self.view makeToast:WFCString(@"CreateGroupFailure")
                    duration:1
                    position:CSToastPositionCenter];
    }];
}

@end
