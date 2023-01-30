#import "NavgationCountView.h"

#import "masonry.h"
#import "UIColor+YH.h"

@interface NavgationCountView ()

@property(nonatomic, strong)UILabel *label;

@end

@implementation NavgationCountView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI {
    CGFloat height = 24;
    CGFloat width = 28;
    
    self.control = [[UIControl alloc] init];
    [self addSubview:self.control];
    [self.control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self);
        make.left.equalTo(self).offset(-12);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
    
    CAShapeLayer *background = [CAShapeLayer layer];
    background.frame = CGRectMake(0, 0, width, height);
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat radius = height / 2;
    CGFloat length = width - height;
    [path moveToPoint:CGPointMake(radius, 0)];
    [path addLineToPoint:CGPointMake(radius + length, 0)];
    [path addArcWithCenter:CGPointMake(radius + length, radius) radius:radius startAngle:1.5 * M_PI endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(radius, 2 * radius)];
    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI_2 endAngle:1.5 * M_PI clockwise:YES];
    background.path = path.CGPath;
    background.fillColor = [UIColor colorWithHexString:@"4970ba"].CGColor;
    [self.control.layer addSublayer:background];
    
    self.label = [[UILabel alloc] init];
    self.label.font = [UIFont systemFontOfSize:15];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = UIColor.whiteColor;
    [self.control addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.bottom.equalTo(self.control);
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.label.text = title;
}

@end
