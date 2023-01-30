#import "WithdrawMethodTableViewCell.h"

@interface WithdrawMethodTableViewCell ()

@property(nonatomic, strong)UILabel *customNameLabel;
@property(nonatomic, strong)UILabel *bankNameLabel;
@property(nonatomic, strong)UILabel *bankAccountLabel;
@property(nonatomic, strong)UILabel *payeeLabel;

@end

@implementation WithdrawMethodTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    [self setupUI];
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.customNameLabel.text = @" ";
    self.bankNameLabel.text = @" ";
    self.bankAccountLabel.text = @" ";
    self.payeeLabel.text = @" ";
}

- (void)setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 12;
    
    self.customNameLabel = [[UILabel alloc] init];
    self.customNameLabel.numberOfLines = 0;
    self.customNameLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.contentView addSubview:self.customNameLabel];
    [self.customNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(12);
    }];
    
    self.deleteButton = [[UIButton alloc] init];
    [self.deleteButton setImage:[UIImage imageNamed:@"withdraw_method_delete"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.deleteButton];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.customNameLabel.mas_right);
        make.right.equalTo(self.contentView).offset(-10);
        make.top.equalTo(self.contentView).offset(10);
        make.height.width.mas_equalTo(24);
    }];
    
    self.bankNameLabel = [[UILabel alloc] init];
    self.bankNameLabel.font = [UIFont systemFontOfSize:16];
    self.bankNameLabel.numberOfLines = 0;
    [self.contentView addSubview:self.bankNameLabel];
    [self.bankNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(24);
        make.right.equalTo(self.contentView).offset(-24);
        make.top.equalTo(self.customNameLabel.mas_bottom).offset(14);
    }];
    
    self.bankAccountLabel = [[UILabel alloc] init];
    self.bankAccountLabel.font = [UIFont systemFontOfSize:16];
    self.bankAccountLabel.numberOfLines = 0;
    [self.contentView addSubview:self.bankAccountLabel];
    [self.bankAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(24);
        make.right.equalTo(self.contentView).offset(-24);
        make.top.equalTo(self.bankNameLabel.mas_bottom).offset(12);
    }];
    
    self.payeeLabel = [[UILabel alloc] init];
    self.payeeLabel.font = [UIFont systemFontOfSize:16];
    self.payeeLabel.numberOfLines = 0;
    [self.contentView addSubview:self.payeeLabel];
    [self.payeeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(24);
        make.right.equalTo(self.contentView).offset(-24);
        make.top.equalTo(self.bankAccountLabel.mas_bottom).offset(12);
        make.bottom.equalTo(self.contentView).offset(-28);
    }];
}

- (void)setWithdrawMethod:(WithdrawMethod *)withdrawMethod {
    _withdrawMethod = withdrawMethod;
    [self setLabelText:withdrawMethod.name label:self.customNameLabel];
    [self setLabelText:withdrawMethod.info.bankName label:self.bankNameLabel];
    [self setLabelText:withdrawMethod.info.bankCardNumber label:self.bankAccountLabel];
    [self setLabelText:withdrawMethod.info.name label:self.payeeLabel];
}

- (void)setLabelText:(NSString *)text label:(UILabel *)label {
    if (text == nil || [text isEqualToString:@""]) {
        label.text = @" ";
        return;
    }
    
    label.text = text;
}

@end
