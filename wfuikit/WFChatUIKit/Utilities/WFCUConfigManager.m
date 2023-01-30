//
//  WFCUConfigManager.m
//  WFChatUIKit
//
//  Created by heavyrain lee on 2019/9/22.
//  Copyright © 2019 WF Chat. All rights reserved.
//

#import "WFCUConfigManager.h"
#import "UIColor+YH.h"
#import <WFChatClient/WFCChatClient.h>
#import "UIImage+ERCategory.h"

static WFCUConfigManager *sharedSingleton = nil;
@implementation WFCUConfigManager

+ (WFCUConfigManager *)globalManager {
    if (sharedSingleton == nil) {
        @synchronized (self) {
            if (sharedSingleton == nil) {
                sharedSingleton = [[WFCUConfigManager alloc] init];
                sharedSingleton.conversationFilesDir = @"ConversationResource";
            }
        }
    }
    return sharedSingleton;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _selectedTheme = [[NSUserDefaults standardUserDefaults] integerForKey:@"WFC_THEME_TYPE"];
    }
    return self;
}

-(void)setSelectedTheme:(WFCUThemeType)themeType {
    _selectedTheme = themeType;
    
    [[NSUserDefaults standardUserDefaults] setInteger:themeType forKey:@"WFC_THEME_TYPE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setupNavBar];
}

- (void)setupNavBar {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    UINavigationBar *bar = [UINavigationBar appearance];
    bar.barTintColor = [WFCUConfigManager globalManager].naviBackgroudColor;
    bar.tintColor = [WFCUConfigManager globalManager].naviTextColor;
    bar.titleTextAttributes = @{NSForegroundColorAttributeName : [WFCUConfigManager globalManager].naviTextColor};
    bar.barStyle = UIBarStyleDefault;
    
    if (@available(iOS 13, *)) {
        UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
        bar.standardAppearance = navBarAppearance;
        bar.scrollEdgeAppearance = navBarAppearance;
        navBarAppearance.backgroundColor = [WFCUConfigManager globalManager].naviBackgroudColor;
        navBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName:[WFCUConfigManager globalManager].naviTextColor};
        navBarAppearance.shadowColor = UIColor.clearColor;
    } else {
        [[UINavigationBar appearance] setBackgroundImage: [UIImage imageWithColor:UIColor.whiteColor size:CGSizeMake(1, 1)] forBarMetrics: UIBarMetricsDefault];
        [UINavigationBar appearance].shadowImage = [[UIImage alloc] init];
    }
    
    [[UITabBar appearance] setBarTintColor:UIColor.whiteColor];
    [UITabBar appearance].translucent = YES;
}

- (UIColor *)backgroudColor {
    if (_backgroudColor) {
        return _backgroudColor;
    }
    
    return [UIColor colorWithHexString:@"0xf6f6f6"];
}

- (UIColor *)frameBackgroudColor {
    if (_frameBackgroudColor) {
        return _frameBackgroudColor;
    }
    BOOL darkModel = NO;
    if (@available(iOS 13.0, *)) {
        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            darkModel = YES;
        }
    }
    
    if (darkModel) {
        return [UIColor colorWithRed:39/255.f green:39/255.f blue:39/255.f alpha:1.0f];
    } else {
        return [UIColor colorWithRed:239/255.f green:239/255.f blue:239/255.f alpha:1.0f];
    }
}

- (UIColor *)textColor {
    if (_textColor) {
        return _textColor;
    }
    BOOL darkModel = NO;
    if (@available(iOS 13.0, *)) {
        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            darkModel = YES;
        }
    }
    
    if (darkModel) {
        return [UIColor whiteColor];
    } else {
        return [UIColor colorWithHexString:@"0x1d1d1d"];
    }
}

- (void)changeNaviBackgroudColor:(UIColor *)color {
    UINavigationBar *bar = [UINavigationBar appearance];
    bar.barTintColor = color;
    
    if (@available(iOS 13, *)) {
        UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
        bar.standardAppearance = navBarAppearance;
        bar.scrollEdgeAppearance = navBarAppearance;
        navBarAppearance.backgroundColor = color;
        navBarAppearance.shadowColor = UIColor.clearColor;
    } else {
        [[UINavigationBar appearance] setBackgroundImage: [UIImage imageWithColor:color size:CGSizeMake(1, 1)] forBarMetrics: UIBarMetricsDefault];
        [UINavigationBar appearance].shadowImage = [[UIImage alloc] init];
    }
}

- (UIColor *)naviBackgroudColor {
    if (_naviBackgroudColor) {
        return _naviBackgroudColor;
    }
    
    return [UIColor whiteColor];
}

- (UIColor *)naviTextColor {
    if (_naviTextColor) {
        return _naviTextColor;
    }
    
    return [UIColor colorWithHexString:@"0x242424"];
}

- (UIColor *)separateColor {
    if (_separateColor) {
        return _separateColor;
    }
    BOOL darkModel = NO;
    if (@available(iOS 13.0, *)) {
        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            darkModel = YES;
        }
    }
    
    if (darkModel) {
        return [UIColor colorWithHexString:@"0x3f3f3f"];
    } else {
        return [UIColor colorWithHexString:@"0xe7e7e7"];
    }
    
}

//file path document/conversationresource/conv_line/conv_type/conv_target/mediatype/
- (NSString *)cachePathOf:(WFCCConversation *)conversation mediaType:(WFCCMediaType)mediaType {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:self.conversationFilesDir];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d/%d/%@", conversation.line, (int)conversation.type, conversation.target]];
    
    NSString *type = @"general";
    if(mediaType == Media_Type_IMAGE) type = @"image";
    else if(mediaType == Media_Type_VOICE) type = @"voice";
    else if(mediaType == Media_Type_VIDEO) type = @"video";
    else if(mediaType == Media_Type_PORTRAIT) type = @"portrait";
    else if(mediaType == Media_Type_FAVORITE) type = @"favorite";
    else if(mediaType == Media_Type_STICKER) type = @"sticker";
    else if(mediaType == Media_Type_MOMENTS) type = @"moments";
    
    path = [path stringByAppendingPathComponent:type];

    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
@end
