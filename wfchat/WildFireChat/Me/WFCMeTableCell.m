#import "WFCMeTableCell.h"

#import "UIColor+YH.h"

@interface WFCMeTableCell ()
@end

@implementation WFCMeTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self != nil) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.leftLabel = [[UILabel alloc] init];
    self.leftLabel.textColor = [UIColor colorWithHexString:@"0x242424"];
    self.leftLabel.font = [UIFont systemFontOfSize:16];
    [self.leftLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:self.leftLabel];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(12);
    }];
    
    
    self.rightLabel = [[UILabel alloc] init];
    self.rightLabel.textColor = [UIColor colorWithHexString:@"0x242424"];
    self.rightLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.rightLabel];
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-10);
    }];
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.accessoryView = nil;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor colorWithHexString:@"0xF6F6F6"];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 12;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.rightLabel.text = @"";
}

@end
