#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RadioButton : UIControl

@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)UIColor *selectedRadioColor;
@property(nonatomic, strong)UIColor *radioColor;

@end

NS_ASSUME_NONNULL_END
