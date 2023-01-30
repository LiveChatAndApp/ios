#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RightButtonStyle) {
    RightButtonStyleMenu,
    RightButtonStyleQRCode
};

@interface TabBarTitleView : UIView

@property(nonatomic, strong)NSString *title;
@property(nonatomic, assign)RightButtonStyle rightButtonStyle;

- (instancetype)initWithRightButtonStyle:(RightButtonStyle)style;

@end

NS_ASSUME_NONNULL_END
