//
//  WFCBaseTabBarController.m
//  Wildfire Chat
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCBaseTabBarController.h"
#import <WFChatClient/WFCChatClient.h>
#import <WFChatUIKit/WFChatUIKit.h>
#import "DiscoverViewController.h"
#import "UIColor+YH.h"
#import "WFCMeTableViewController.h"
#import "WFCConfig.h"
#ifdef WFC_MOMENTS
#import <WFMomentUIKit/WFMomentUIKit.h>
#import <WFMomentClient/WFMomentClient.h>
#endif
#import "UIImage+ERCategory.h"
#define kClassKey   @"rootVCClassString"
#define kTitleKey   @"title"
#define kImgKey     @"imageName"
#define kSelImgKey  @"selectedImageName"
#import "AppService.h"

@interface WFCBaseTabBarController ()
@property (nonatomic, strong)UINavigationController *firstNav;
@property (nonatomic, strong)UINavigationController *settingNav;
@end

@implementation WFCBaseTabBarController
- (void)viewDidLoad {
    [super viewDidLoad];
    [AppService.sharedAppService getImageDomain];
    UIViewController *vc = [WFCUConversationTableViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    UITabBarItem *item = nav.tabBarItem;
    item.image = [UIImage imageNamed:@"tabbar_chat"];
    item.selectedImage = [[UIImage imageNamed:@"tabbar_chat_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    [self addChildViewController:nav];
    
    self.firstNav = nav;
    
 
    vc = [[WFCUContactListViewController alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    vc.navigationItem.titleView = titleLabel;
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    item = nav.tabBarItem;
    item.image = [UIImage imageNamed:@"tabbar_contacts"];
    item.selectedImage = [[UIImage imageNamed:@"tabbar_contacts_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    [self addChildViewController:nav];
    
    if(WORK_PLATFORM_URL.length) {
        WFCUBrowserViewController *browserVC = [WFCUBrowserViewController new];
        browserVC.url = WORK_PLATFORM_URL;
        browserVC.hidenOpenInBrowser = YES;
        
        vc = browserVC;
        nav = [[UINavigationController alloc] initWithRootViewController:vc];
        item = nav.tabBarItem;
        item.image = [UIImage imageNamed:@"tabbar_work"];
        item.selectedImage = [[UIImage imageNamed:@"tabbar_work_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        [self addChildViewController:nav];
    }
    
    vc = [DiscoverViewController new];
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    item = nav.tabBarItem;
    item.image = [UIImage imageNamed:@"tabbar_discover"];
    item.selectedImage = [[UIImage imageNamed:@"tabbar_discover_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    [self addChildViewController:nav];
    
    vc = [WFCMeTableViewController new];
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    item = nav.tabBarItem;
    item.image = [UIImage imageNamed:@"tabbar_me"];
    item.selectedImage = [[UIImage imageNamed:@"tabbar_me_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    [self addChildViewController:nav];
    self.settingNav = nav;
#ifdef WFC_MOMENTS
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveComments:) name:kReceiveComments object:nil];
#endif
}

- (void)changeTabBarHeight {
    CGRect rect = self.tabBar.frame;
    
    if (@available(iOS 11.0, *)) {
        rect.size.height = self.view.safeAreaInsets.bottom + 56;
    } else {
        rect.size.height = 34 + 56;
    }
    
    rect.origin.y = self.view.frame.size.height - rect.size.height;
    self.tabBar.frame = rect;
}

- (void)onReceiveComments:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateBadgeNumber];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateBadgeNumber];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (@available(iOS 13.0, *)) {
        return;
    }
    
    [self changeTabBarHeight];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (@available(iOS 13.0, *)) {
    } else {
        [self changeTabBarHeight];
    }
}

- (void)updateBadgeNumber {
#ifdef WFC_MOMENTS
    int momentIndex = 2;
    if(WORK_PLATFORM_URL.length)
        momentIndex = 3;
    [self.tabBar showBadgeOnItemIndex:momentIndex badgeValue:[[WFMomentService sharedService] getUnreadCount]];
#endif
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(setupNavBar)]) {
                [[UIApplication sharedApplication].delegate performSelector:@selector(setupNavBar)];
            }
            UIView *superView = self.view.superview;
            [self.view removeFromSuperview];
            [superView addSubview:self.view];
        }
    }
}

@end
