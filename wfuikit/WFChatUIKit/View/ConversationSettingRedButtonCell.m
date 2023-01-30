#import "ConversationSettingRedButtonCell.h"

#import "UIColor+YH.h"
#import "masonry.h"

@implementation ConversationSettingRedButtonCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI {
    self.separatorInset = UIEdgeInsetsZero;
    self.label = [[UILabel alloc] init];
    
    self.label.font = [UIFont boldSystemFontOfSize:16];
    self.label.textColor = [UIColor colorWithHexString:@"0xF85151"];
    [self.contentView addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.bottom.equalTo(self.contentView);
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.label.text = title;
}

@end
