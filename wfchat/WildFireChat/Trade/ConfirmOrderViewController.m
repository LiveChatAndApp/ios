#import "ConfirmOrderViewController.h"

#import <SDWebImage/SDWebImage.h>

#import "AppService.h"
#import "MBProgressHUD.h"
#import "UIColor+YH.h"
#import "WalletDetailViewController.h"
#import "WalletViewController.h"

@interface ConfirmOrderViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong)UIImageView *uploadView;
@property(nonatomic, strong)UIImageView *qrCodeView;
@property(nonatomic, strong)UIImage *uploadImage;
@property(nonatomic, strong)MASConstraint *applyButtonConstraint;

@end

@implementation ConfirmOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.applyButtonConstraint.offset(self.view.frame.size.height - 28);
}

- (void)setup {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"上传截图";
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf6f6f6"];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.equalTo(self.view);
    }];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.whiteColor;
    [scrollView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(scrollView).offset(8);
        make.left.right.equalTo(self.view);
        make.left.right.equalTo(scrollView);
    }];
    
    UILabel *payLabel = [[UILabel alloc] init];
    payLabel.font = [UIFont boldSystemFontOfSize:17];
    payLabel.text = @"付款信息";
    [view addSubview:payLabel];
    [payLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.top.equalTo(view).offset(12);
    }];

    UILabel *payeeLabel = [[UILabel alloc] init];
    [payeeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    payeeLabel.textColor = [UIColor colorWithHexString:@"0x767676"];
    if (self.rechargeType == RechargeChannelTypeCard) {
        payeeLabel.text = [NSString stringWithFormat:@"收款人姓名："];
    } else {
        payeeLabel.text = [NSString stringWithFormat:@"收款人账户姓名："];
    }
    [view addSubview:payeeLabel];
    [payeeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(28);
        make.top.equalTo(payLabel.mas_bottom).offset(16);
    }];
    
    UILabel *payeeValueLabel = [[UILabel alloc] init];
    [payeeValueLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [payeeValueLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    payeeValueLabel.text = self.payee;
    [view addSubview:payeeValueLabel];
    [payeeValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(payeeLabel);
        make.right.equalTo(view).offset(-20);
    }];
    
    UIButton *copyButton = [[UIButton alloc] init];
    [copyButton setImage:[UIImage imageNamed:@"copy"] forState:normal];
    [copyButton addTarget:self action:@selector(copyPayee) forControlEvents:UIControlEventTouchDown];
    [view addSubview:copyButton];
    [copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(payeeValueLabel);
        make.right.equalTo(payeeValueLabel.mas_left).offset(-4);
        make.left.greaterThanOrEqualTo(payeeLabel.mas_right).offset(2);
        make.height.equalTo(copyButton.mas_width);
        make.height.equalTo(payeeValueLabel);
    }];
    
    UIView *lastView;
    if (self.rechargeType == RechargeChannelTypeCard) {
        UILabel *bankNameLabel = [[UILabel alloc] init];
        bankNameLabel.text = [NSString stringWithFormat:@"银行名称："];
        bankNameLabel.textColor = [UIColor colorWithHexString:@"0x767676"];
        [payeeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [view addSubview:bankNameLabel];
        [bankNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(28);
            make.top.equalTo(payeeLabel.mas_bottom).offset(16);
        }];
        
        UILabel *bankNameValueLabel = [[UILabel alloc] init];
        bankNameValueLabel.text = self.bankName;
        [view addSubview:bankNameValueLabel];
        [bankNameValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bankNameLabel);
            make.left.greaterThanOrEqualTo(bankNameLabel.mas_right).offset(2);
            make.right.equalTo(view).offset(-20);
        }];
        
        UILabel *bankAccountLabel = [[UILabel alloc] init];
        bankAccountLabel.text = [NSString stringWithFormat:@"银行账号："];
        bankAccountLabel.textColor = [UIColor colorWithHexString:@"0x767676"];
        [bankAccountLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [view addSubview:bankAccountLabel];
        [bankAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(28);
            make.top.equalTo(bankNameLabel.mas_bottom).offset(16);
        }];
        
        UILabel *bankAccountValueLabel = [[UILabel alloc] init];
        bankAccountValueLabel.text = self.account;
        [bankAccountValueLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [bankAccountValueLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [view addSubview:bankAccountValueLabel];
        [bankAccountValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bankAccountLabel);
            make.right.equalTo(view).offset(-20);
        }];
        
        copyButton = [[UIButton alloc] init];
        [copyButton setImage:[UIImage imageNamed:@"copy"] forState:normal];
        [copyButton addTarget:self action:@selector(copyAccount) forControlEvents:UIControlEventTouchDown];
        [view addSubview:copyButton];
        [copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(copyButton.mas_width);
            make.height.equalTo(bankAccountValueLabel);
            make.left.greaterThanOrEqualTo(bankAccountLabel.mas_right).offset(2);
            make.centerY.equalTo(bankAccountValueLabel);
            make.right.equalTo(bankAccountValueLabel.mas_left).offset(-4);
        }];
        
        lastView = bankAccountLabel;
    } else if (self.rechargeType == RechargeChannelTypeWeixin) {
        UIView *qrCodeView = [self createQRCodeView];
        [view addSubview:qrCodeView];
        [qrCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(28);
            make.top.equalTo(payeeLabel.mas_bottom).offset(16);
            make.right.equalTo(view).offset(-16);
        }];
        
        lastView = qrCodeView;
    } else if (self.rechargeType == RechargeChannelTypeAlipay) {
        UILabel *bankAccountLabel = [[UILabel alloc] init];
        bankAccountLabel.text = [NSString stringWithFormat:@"账号："];
        bankAccountLabel.textColor = [UIColor colorWithHexString:@"0x767676"];
        [bankAccountLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [view addSubview:bankAccountLabel];
        [bankAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(28);
            make.top.equalTo(payeeLabel.mas_bottom).offset(16);
        }];
        
        UILabel *bankAccountValueLabel = [[UILabel alloc] init];
        bankAccountValueLabel.text = self.account;
        [bankAccountValueLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [bankAccountValueLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [view addSubview:bankAccountValueLabel];
        [bankAccountValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bankAccountLabel);
            make.right.equalTo(view).offset(-20);
        }];
        
        copyButton = [[UIButton alloc] init];
        [copyButton setImage:[UIImage imageNamed:@"copy"] forState:normal];
        [copyButton addTarget:self action:@selector(copyAccount) forControlEvents:UIControlEventTouchDown];
        [view addSubview:copyButton];
        [copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(copyButton.mas_width);
            make.height.equalTo(bankAccountValueLabel);
            make.left.greaterThanOrEqualTo(bankAccountLabel.mas_right).offset(2);
            make.centerY.equalTo(bankAccountValueLabel);
            make.right.equalTo(bankAccountValueLabel.mas_left).offset(-4);
        }];
        
        UIView *qrCodeView = [self createQRCodeView];
        [view addSubview:qrCodeView];
        [qrCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(28);
            make.top.equalTo(bankAccountLabel.mas_bottom).offset(16);
            make.right.equalTo(view).offset(-16);
        }];
        
        lastView = qrCodeView;
    }
    
    UILabel *uploadPictureLabel = [[UILabel alloc] init];
    uploadPictureLabel.text = @"上传【转账成功】截图";
    uploadPictureLabel.font = [UIFont boldSystemFontOfSize:17];
    [view addSubview:uploadPictureLabel];
    [uploadPictureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        
        if (lastView != nil) {
            make.top.equalTo(lastView.mas_bottom).offset(20);
        }
    }];
    
    UIControl *uploadControl = [self createUploadControl];
    [view addSubview:uploadControl];
    [uploadControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(uploadPictureLabel.mas_bottom).offset(16);
        make.height.equalTo(self.uploadView.mas_width);
        make.width.equalTo(view).multipliedBy(0.45);
        make.centerX.equalTo(view);
    }];
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.text = @"充值需要人工审核，请耐心等候，可在我的钱包>明细查询充值状态";
    tipsLabel.numberOfLines = 0;
    tipsLabel.font = [UIFont systemFontOfSize:14];
    tipsLabel.textColor = UIColor.lightGrayColor;
    [view addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(uploadControl.mas_bottom).offset(16);
        make.left.equalTo(view).offset(21);
        make.right.equalTo(view).offset(-21);
        make.bottom.equalTo(view).offset(-10);
    }];
    
    UIButton *applyButton = [[UIButton alloc] init];
    applyButton.backgroundColor = [UIColor colorWithHexString:@"0x4970ba"];
    applyButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    applyButton.layer.cornerRadius = 5.0f;
    [applyButton setTitle:@"确认提交" forState:UIControlStateNormal];
    [applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [applyButton addTarget:self action:@selector(confirmOrder) forControlEvents:UIControlEventTouchDown];
    [scrollView addSubview:applyButton];
    [applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.greaterThanOrEqualTo(view.mas_bottom).offset(20);
        make.height.mas_equalTo(52);
        make.bottom.equalTo(scrollView).offset(-20);
        self.applyButtonConstraint = make.bottom.greaterThanOrEqualTo(scrollView.mas_top).offset(self.view.frame.size.height - 28);
    }];
}

- (UIView *)createQRCodeView {
    UIView *view = [[UIView alloc] init];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"收款码：";
    label.textColor = [UIColor colorWithHexString:@"0x767676"];
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(view);
    }];
    
    UIControl *downloadControl = [[UIControl alloc] init];
    [downloadControl addTarget:self action:@selector(saveQRCode) forControlEvents:UIControlEventTouchDown];
    [view addSubview:downloadControl];
    [downloadControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view);
        make.centerY.equalTo(label);
    }];
    
    UILabel *downloadLabel = [[UILabel alloc] init];
    downloadLabel.text = @"下载二维码";
    downloadLabel.textColor = [UIColor colorWithHexString:@"0x4970ba"];
    [downloadLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [downloadControl addSubview:downloadLabel];
    [downloadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(downloadControl);
    }];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"download_qrcode"]];
    [downloadControl addSubview:icon];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(downloadLabel.mas_left).offset(-4);
        make.left.equalTo(downloadControl);
        make.width.equalTo(icon.mas_height);
        make.height.equalTo(downloadLabel);
    }];
    
    self.qrCodeView = [[UIImageView alloc] init];
    [self.qrCodeView sd_setImageWithURL:[NSURL URLWithString:self.qrCodeURL] placeholderImage:[UIImage imageNamed:@"download_qrcode"]];
    [view addSubview:self.qrCodeView];
    [self.qrCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.qrCodeView.mas_width);
        make.width.equalTo(view).multipliedBy(0.3);
        make.top.equalTo(label.mas_bottom).offset(16);
        make.centerX.bottom.equalTo(view);
    }];
    
    return view;
}

- (UIControl *)createUploadControl {
    UIControl *control = [[UIControl alloc] init];
    [control addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchDown];
    self.uploadView = [[UIImageView alloc] init];
    self.uploadView.backgroundColor = [UIColor colorWithHexString:@"0xe4e4e4"];
    self.uploadView.layer.cornerRadius = 4;
    self.uploadView.clipsToBounds = YES;
    [control addSubview:self.uploadView];
    [self.uploadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.bottom.equalTo(control);
    }];
    
    return control;
}

- (void)saveQRCode {
    UIImageWriteToSavedPhotosAlbum(self.qrCodeView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self.view makeToast:@"下载成功"];
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

- (void)confirmOrder {
    if (self.uploadImage == nil) {
        [self.view makeToast:@"请选择图片"];
        return;
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"上传中...";
    [hud showAnimated:YES];
    
    [AppService.sharedAppService confirmRechargeWithId:self.orderId image:self.uploadImage success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parentViewController.view makeToast:@"上传成功"];
            [hud hideAnimated:YES];
            [self goToDetailVC];
        });
    } error:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:message];
            [hud hideAnimated:YES];
        });
    }];
}

- (void)goToDetailVC {
    if (!self.backToWallet) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    NSMutableArray<UIViewController *> *array = [self.navigationController.viewControllers mutableCopy];
    WalletDetailViewController *detailVC = [[WalletDetailViewController alloc] init];
    NSUInteger index = NSNotFound;
    for (UIViewController *vc in array) {
        if ([vc isMemberOfClass:WalletViewController.class]) {
            index = [array indexOfObject:vc];
        }
    }
    
    if (index == NSNotFound || array.count < 3) {
        return;
    }
    
    [array removeObjectsInRange:NSMakeRange(2, array.count - 2)];
    [array addObject:detailVC];
    [self.navigationController setViewControllers:array animated:YES];
}

- (void)copyAccount {
    [UIPasteboard.generalPasteboard setString:self.account];
    [self.view makeToast:@"已复制"];
}

- (void)copyPayee {
    [UIPasteboard.generalPasteboard setString:self.payee];
    [self.view makeToast:@"已复制"];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.uploadView.image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.uploadImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
