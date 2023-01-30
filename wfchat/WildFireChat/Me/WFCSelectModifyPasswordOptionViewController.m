#import "WFCSelectModifyPasswordOptionViewController.h"

#import "WFCSMSChangePasswordViewController.h"
#import "UIColor+YH.h"

@interface WFCSelectModifyPasswordOptionViewController ()

@end

@implementation WFCSelectModifyPasswordOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:@"0x000000" alpha:0.33];
    
    UIView *selectView = [[UIView alloc] init];
    selectView.backgroundColor = UIColor.whiteColor;
    selectView.layer.cornerRadius = 10;
    selectView.clipsToBounds = YES;
    [self.view addSubview:selectView];
    [selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.greaterThanOrEqualTo(self.view).multipliedBy(0.57);
        make.height.mas_equalTo(120);
        make.centerX.centerY.equalTo(self.view);
    }];
    
    UIControl *smsControl = [self createOptionControlWithIcon:[UIImage imageNamed:@"modify_password_sms"] text:@"短信验证码验证"];
    smsControl.tag = 1;
    [smsControl addTarget:self action:@selector(onSelected:) forControlEvents:UIControlEventTouchDown];
    [selectView addSubview:smsControl];
    [smsControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(selectView);
        make.height.equalTo(selectView).multipliedBy(0.5);
    }];
    
    UIControl *passwordControl = [self createOptionControlWithIcon:[UIImage imageNamed:@"modify_password"] text:@"密码验证"];
    passwordControl.tag = 2;
    [passwordControl addTarget:self action:@selector(onSelected:) forControlEvents:UIControlEventTouchDown];
    [selectView addSubview:passwordControl];
    [passwordControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(selectView);
        make.height.equalTo(selectView).multipliedBy(0.5);
        make.top.equalTo(smsControl.mas_bottom);
    }];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewController)]];
}

- (void)onSelected:(UIControl *)sender {
    if (self.onSelected != nil) {
        self.onSelected(sender.tag);
    }
}

- (UIControl *)createOptionControlWithIcon:(UIImage *)image text:(NSString *)text {
    UIControl *control = [[UIControl alloc] init];
    UIImageView *icon = [[UIImageView alloc] initWithImage:image];
    [control addSubview:icon];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(control);
        make.left.equalTo(control).offset(24);
        make.height.equalTo(icon.mas_width);
        make.height.equalTo(control).multipliedBy(0.33);
    }];
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:18];
    [control addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(icon.mas_right).offset(16);
        make.top.bottom.equalTo(control);
        make.right.equalTo(control).offset(-34);
    }];
    
    return control;
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
