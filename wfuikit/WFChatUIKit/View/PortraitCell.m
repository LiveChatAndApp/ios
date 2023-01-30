#import "PortraitCell.h"

#import "masonry.h"
#import "WFCUImage.h"

@interface PortraitCell ()

@property(nonatomic, strong)UIImageView *cameraIcon;

@end


@implementation PortraitCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.canEdit = YES;
        [self setupUI];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.canEdit = YES;
}

- (void)setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.control = [[UIControl alloc] init];
    [self.contentView addSubview:self.control];
    [self.control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.height.equalTo(self.control.mas_width);
        make.top.equalTo(self.contentView).offset(15);
        make.bottom.equalTo(self.contentView).offset(-15);
    }];
    
    self.portraitView = [[UIImageView alloc] init];
    self.portraitView.clipsToBounds = YES;
    self.portraitView.layer.cornerRadius = 33;
    [self.control addSubview:self.portraitView];
    [self.portraitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.control);
    }];
    
    self.cameraIcon = [[UIImageView alloc] initWithImage:[WFCUImage imageNamed:@"camera"]];
    [self.control addSubview:self.cameraIcon];
    [self.cameraIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self.control);
        make.height.width.equalTo(self.control).multipliedBy(0.3);
    }];
}

- (void)setCanEdit:(BOOL)canEdit {
    _canEdit = canEdit;
    self.cameraIcon.hidden = !canEdit;
}

@end
