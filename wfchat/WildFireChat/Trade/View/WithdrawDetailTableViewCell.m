#import "WithdrawDetailTableViewCell.h"

#import "UIColor+YH.h"

@interface WithdrawDetailTableViewCell ()

@property(nonatomic, strong)UILabel *typeLabel;
@property(nonatomic, strong)UILabel *statusLabel;
@property(nonatomic, strong)UILabel *amountLabel;
@property(nonatomic, strong)UILabel *orderCodeLabel;
@property(nonatomic, strong)UILabel *createTimeLabel;

@end

@implementation WithdrawDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.typeLabel.text = @" ";
    self.amountLabel.text = @" ";
    self.orderCodeLabel.text = @" ";
    self.createTimeLabel.text = @" ";
    self.statusLabel.text = @" ";
    self.confirmButton.hidden = YES;
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_offset(0);
    }];
}

- (void)setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.typeLabel = [[UILabel alloc] init];
    self.typeLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:self.typeLabel];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentView).offset(10);
    }];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.contentView).offset(10);
    }];
    
    self.amountLabel = [[UILabel alloc] init];
    self.amountLabel.font = [UIFont systemFontOfSize:14];
    
    [self.contentView addSubview:self.amountLabel];
    [self.amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.typeLabel.mas_bottom).offset(12);
    }];
    
    self.orderCodeLabel = [[UILabel alloc] init];
    self.orderCodeLabel.font = [UIFont systemFontOfSize:13];
    self.orderCodeLabel.numberOfLines = 0;
    self.orderCodeLabel.textColor = [UIColor colorWithHexString:@"0xadadad"];
    [self.orderCodeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:self.orderCodeLabel];
    [self.orderCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.lessThanOrEqualTo(self.contentView).offset(-15);
        make.top.equalTo(self.amountLabel.mas_bottom).offset(4);
    }];
    
    self.createTimeLabel = [[UILabel alloc] init];
    self.createTimeLabel.font = [UIFont systemFontOfSize:13];
    self.createTimeLabel.textColor = [UIColor colorWithHexString:@"0xadadad"];
    [self.contentView addSubview:self.createTimeLabel];
    [self.createTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.orderCodeLabel.mas_bottom).offset(4);
        make.bottom.equalTo(self.contentView).offset(-14);
    }];
    
    self.confirmButton = [[UIButton alloc] init];
    self.confirmButton.backgroundColor = [UIColor colorWithHexString:@"0x4970BA"];
    self.confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.confirmButton.hidden = YES;
    self.confirmButton.contentEdgeInsets = UIEdgeInsetsMake(6, 10, 6, 10);
    self.confirmButton.clipsToBounds = YES;
    self.confirmButton.layer.cornerRadius = 4;
    [self.confirmButton setTitle:@"上传截图" forState:UIControlStateNormal];
    [self.contentView addSubview:self.confirmButton];
}

- (void)setOrder:(WalletOrderModel *)order {
    _order = order;
    [self setLabelText:order.typeString label:self.typeLabel];
    [self setLabelText:order.statusString label:self.statusLabel];
    [self setLabelText:[NSString stringWithFormat:@"%@金额：%@", order.typeString, order.amount] label:self.amountLabel];
    [self setLabelText:[NSString stringWithFormat:@"订单编号：%@", order.orderCode] label:self.orderCodeLabel];
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:order.createTime.doubleValue / 1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [self setLabelText:[formatter stringFromDate:createDate] label:self.createTimeLabel];
    self.statusLabel.textColor = self.order.statusStringColor;
    
    if (order.type.intValue == 1 && order.status.intValue == 0) {
        self.confirmButton.hidden = NO;
        [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-15);
            make.bottom.equalTo(self.contentView).offset(-14);
            make.left.greaterThanOrEqualTo(self.orderCodeLabel.mas_right).offset(2);
            make.height.mas_equalTo(32);
        }];
    }
}

- (void)setLabelText:(NSString *)text label:(UILabel *)label {
    if (text == nil || [text isEqualToString:@""]) {
        label.text = @" ";
        return;
    }
    
    label.text = text;
}

@end
