#import <UIKit/UIKit.h>

#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface PortraitCell : UITableViewCell

@property(nonatomic, strong)UIControl *control;
@property(nonatomic, strong)UIImageView *portraitView;
@property(nonatomic, assign)BOOL canEdit;

@end

NS_ASSUME_NONNULL_END
