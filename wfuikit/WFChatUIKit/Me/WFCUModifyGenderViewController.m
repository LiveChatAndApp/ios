#import "WFCUModifyGenderViewController.h"
#import "MBProgressHUD.h"
#import <WFChatClient/WFCChatClient.h>
#import <WFChatClient/UpdateProfileModel.h>
#import "WFCUConfigManager.h"
#import "UIView+Toast.h"
#import "masonry.h"
#import "UIColor+YH.h"
#import "WFCUImage.h"

@interface WFCUModifyGenderViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)UILabel *genderLabel;
@property(nonatomic, assign)NSUInteger selectIndex;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSArray *genderArray;

@end

@implementation WFCUModifyGenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.genderArray = @[@"保留", @"男", @"女"];
    [self setupUI];
    self.selectIndex = [self.genderArray indexOfObject:self.userInfo.genderString];
    self.genderLabel.text = self.genderArray[self.selectIndex];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    self.title = @"性别";
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(8);
        make.left.right.equalTo(self.view);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"性别";
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.textColor = [UIColor colorWithHexString:@"0x242424"];
    [view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.top.equalTo(view).offset(10);
    }];
    
    UIView *genderView = [[UIView alloc] init];
    genderView.layer.borderWidth = 1;
    genderView.layer.cornerRadius = 2;
    genderView.userInteractionEnabled = YES;
    [genderView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onInfoLabelTouched)]];
    [view addSubview:genderView];
    [genderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.right.equalTo(view).offset(-15);
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(48);
        make.bottom.equalTo(view).offset(-20);
    }];
    
    self.genderLabel = [[UILabel alloc] init];
    self.genderLabel.font = [UIFont systemFontOfSize:16];
    self.genderLabel.layer.borderColor = [UIColor colorWithHexString:@"0xe4e4e4"].CGColor;
    [genderView addSubview:self.genderLabel];
    [self.genderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(genderView).offset(16);
        make.top.bottom.equalTo(genderView);

    }];
    
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[WFCUImage imageNamed:@"arrow_drop_down"]];
    [genderView addSubview:arrow];
    [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(genderView);
        make.left.greaterThanOrEqualTo(self.genderLabel.mas_right);
        make.top.equalTo(genderView).offset(5);
        make.height.equalTo(arrow.mas_width);
    }];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.layer.cornerRadius = 5;
    self.tableView.clipsToBounds = YES;
    self.tableView.layer.borderColor = UIColor.grayColor.CGColor;
    self.tableView.layer.borderWidth = 1.0f;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"channelInfoCell"];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.genderLabel.mas_bottom);
        make.left.right.equalTo(genderView);
        make.height.mas_equalTo(160);
    }];
    
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor colorWithHexString:@"0x4970BA"];
    button.layer.cornerRadius = 4;
    button.clipsToBounds = YES;
    [button setTitle:@"保存" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.bottom.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(52);
    }];
}

- (void)onInfoLabelTouched {
    if (self.tableView.hidden == NO) {
        self.tableView.hidden = YES;
        return;
    }
    
    self.tableView.alpha = 0;
    [UIView animateWithDuration:0.2f animations:^{
        self.tableView.hidden = NO;
        self.tableView.alpha = 1;
    }];
}

- (void)onDone:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = WFCString(@"Updating");
    [hud showAnimated:YES];
    
    UpdateProfileModel *model = [[UpdateProfileModel alloc] init];
    model.gender = self.selectIndex + 1;
    
    [WFCUConfigManager.globalManager.appServiceProvider updateProfileWithModel:model progress:nil success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:NO];
            [self.navigationController.view makeToast:WFCString(@"UpdateDone")];
            [self.navigationController popViewControllerAnimated:YES];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:NO];
            [self.view makeToast:message];
        });
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.genderArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = self.genderArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectIndex = indexPath.row;
    self.genderLabel.text = self.genderArray[indexPath.row];
    self.tableView.hidden = YES;
}

@end
