#import "RadioButton.h"

#import "UIColor+YH.h"
#import "masonry.h"

@interface RadioButton ()

@property(nonatomic, strong)UIView *radioView;
@property(nonatomic, strong)UILabel *textLabel;
@property(nonatomic, strong)UIView *circleView;
@property(nonatomic, strong)UIView *soildView;

@end

@implementation RadioButton

- (instancetype)init {
    self = [super init];
    
    if (self != nil) {
        [self setup];
        self.selectedRadioColor = [UIColor colorWithHexString:@"0x4970ba"];
        self.radioColor = UIColor.blackColor;
        self.selected = NO;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.circleView layoutIfNeeded];
    [self.soildView layoutIfNeeded];
    self.circleView.layer.cornerRadius = self.circleView.frame.size.width / 2.0f;
    self.soildView.layer.cornerRadius = self.soildView.frame.size.width / 2.0f;
}

- (void)setup {
    self.radioView = [[UIView alloc] init];
    self.radioView.userInteractionEnabled = NO;
    [self addSubview:self.radioView];
    [self.radioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self);
        make.height.equalTo(self.radioView.mas_width);
        make.top.bottom.equalTo(self);
        make.left.equalTo(self).offset(4);
        make.height.mas_greaterThanOrEqualTo(20);
    }];
    
    self.circleView = [[UIView alloc] init];
    self.circleView.layer.borderWidth = 1.5f;
    self.circleView.clipsToBounds = YES;
    [self.radioView addSubview:self.circleView];
    [self.circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.radioView);
        make.height.width.equalTo(self.radioView).multipliedBy(0.6);
    }];
    
    self.soildView = [[UIView alloc] init];
    self.soildView.clipsToBounds = YES;
    [self.radioView addSubview:self.soildView];
    [self.soildView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.radioView);
        make.height.width.equalTo(self.radioView).multipliedBy(0.35);
    }];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.text = self.title;
    [self addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.radioView.mas_right);
        make.top.equalTo(self).offset(4);
        make.bottom.equalTo(self).offset(-4);
        make.right.equalTo(self).offset(-5);
    }];
}

- (void)selectedRadioColor:(UIColor *)color {
    _selectedRadioColor = color;
    if (self.selected) {
        self.circleView.layer.borderColor = color.CGColor;
        self.soildView.backgroundColor = color;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.soildView.alpha = 0;
        self.soildView.hidden = NO;
        [UIView animateWithDuration:0.1 animations:^{
            self.circleView.layer.borderColor = self.selectedRadioColor.CGColor;
            self.soildView.backgroundColor = self.selectedRadioColor;
            self.soildView.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            self.circleView.layer.borderColor = self.radioColor.CGColor;
            self.soildView.alpha = 0;
            self.soildView.hidden = NO;
        }];
    }
    
//    self.soildView.hidden = !selected;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.textLabel.text = title;
}

@end
