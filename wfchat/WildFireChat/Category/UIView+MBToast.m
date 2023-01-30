#import "UIView+MBToast.h"

#import "MBProgressHUD.h"

@implementation UIView (MBToast)

- (void)showToast:(NSString *)text{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud hideAnimated:YES afterDelay:1.f];
}

@end
