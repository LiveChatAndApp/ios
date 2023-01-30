#import "PasswordTextField.h"

#import "WFCUImage.h"
#import "masonry.h"

@interface PasswordTextField ()

@property(nonatomic, strong)UIButton *iconButton;

@end

@implementation PasswordTextField

- (instancetype)init {
    self = [super init];
    if (self) {
        self.secureTextEntry = YES;
        [self setupUI];
    }
    
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds.size.width -= bounds.size.height + 5;
    [super textRectForBounds:bounds];
    return bounds;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds.size.width -= bounds.size.height + 5;
    [super editingRectForBounds:bounds];
    return bounds;
}

- (void)setupUI {
    self.iconButton = [[UIButton alloc] init];
    [self.iconButton setBackgroundImage:[WFCUImage imageNamed:@"textField_visibility_off"] forState:UIControlStateNormal];
    [self.iconButton addTarget:self action:@selector(onVisibilityButton) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.iconButton];
    [self.iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-5);
        make.centerY.equalTo(self);
        make.height.width.equalTo(self.mas_height);
    }];
}

- (void)onVisibilityButton {
    self.secureTextEntry = !self.secureTextEntry;
    if (self.secureTextEntry) {
        [self.iconButton setBackgroundImage:[WFCUImage imageNamed:@"textField_visibility_off"] forState:UIControlStateNormal];
    } else {
        [self.iconButton setBackgroundImage:[WFCUImage imageNamed:@"textField_visibility_on"] forState:UIControlStateNormal];
    }
}

@end
