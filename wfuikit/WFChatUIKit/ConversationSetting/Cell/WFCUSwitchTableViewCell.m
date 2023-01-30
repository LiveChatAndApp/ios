//
//  SwitchTableViewCell.m
//  WildFireChat
//
//  Created by heavyrain lee on 27/12/2017.
//  Copyright © 2017 WildFireChat. All rights reserved.
//

#import "WFCUSwitchTableViewCell.h"
#import "MBProgressHUD.h"
#import "UIColor+YH.h"
#import "masonry.h"

@interface WFCUSwitchTableViewCell()
@property(nonatomic, strong)WFCCConversation *conversation;
@property(nonatomic, strong)UISwitch *valueSwitch;
@end

@implementation WFCUSwitchTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier conversation:(WFCCConversation*)conversation {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.switchDisable = NO;
        self.valueSwitch = [[UISwitch alloc] init];
        [self.contentView addSubview:self.valueSwitch];
        [self.valueSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-20);
            make.centerY.equalTo(self.contentView);
        }];
        [self.valueSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
        self.type = SwitchType_Conversation_None;
        self.conversation = conversation;
        self.valueSwitch.backgroundColor = [UIColor colorWithHexString:@"0x000000" alpha:0.38];
        self.valueSwitch.layer.cornerRadius = self.valueSwitch.frame.size.height / 2.0f;
        self.valueSwitch.onTintColor = [UIColor colorWithHexString:@"0x4970ba"];
        self.valueSwitch.clipsToBounds = YES;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.switchDisable = NO;
}

- (void)setSwitchDisable:(BOOL)switchDisable {
    _switchDisable = switchDisable;
    self.valueSwitch.enabled = !switchDisable;
    if (switchDisable) {
        self.textLabel.textColor = [UIColor colorWithHexString:@"0xadadad"];
    } else {
        if (@available(iOS 13.0, *)) {
            self.textLabel.textColor = UIColor.labelColor;
        } else {
            self.textLabel.textColor = UIColor.blackColor;
        }
    }
}

- (void)onSwitch:(id)sender {
    BOOL value = _valueSwitch.on;
    __weak typeof(self)ws = self;
    switch (_type) {
        case SwitchType_Conversation_Top:
        {
            [[WFCCIMService sharedWFCIMService] setConversation:_conversation top:value?1:0 success:nil error:^(int error_code) {
                [ws.valueSwitch setOn:!value];
            }];
            break;
        }
        case SwitchType_Conversation_Silent:
        {
            [[WFCCIMService sharedWFCIMService] setConversation:_conversation silent:value success:nil error:^(int error_code) {
                [ws.valueSwitch setOn:!value];
            }];
            break;
        }
        case SwitchType_Setting_Global_Silent:
        {
            [[WFCCIMService sharedWFCIMService] setGlobalSilent:!value success:^{
               
            } error:^(int error_code) {
               
            }];
            break;
        }
        case SwitchType_Setting_Show_Notification_Detail: {
            [[WFCCIMService sharedWFCIMService] setHiddenNotificationDetail:!value success:^{
                
            } error:^(int error_code) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ws.valueSwitch.on = !ws.valueSwitch.on; 
                });
            }];
            break;
        }
        case SwitchType_Conversation_Show_Alias: {
            [[WFCCIMService sharedWFCIMService] setHiddenGroupMemberName:!value group:self.conversation.target success:^{
                
            } error:^(int error_code) {
                
            }];
        }
            break;
        case SwitchType_Conversation_Save_To_Contact:
            [[WFCCIMService sharedWFCIMService] setFavGroup:self.conversation.target fav:value success:^{
                
            } error:^(int error_code) {
                
            }];
            break;
        case SwitchType_Setting_Sync_Draft:
            [[WFCCIMService sharedWFCIMService] setEnableSyncDraft:value success:^{
                
            } error:^(int error_code) {
                
            }];
            break;
            break;
        case SwitchType_Setting_Voip_Silent:
            [[WFCCIMService sharedWFCIMService] setVoipNotificationSilent:!value success:^{
               
            } error:^(int error_code) {
               
            }];
        default:
            break;
    }
}

- (void)updateView {
    BOOL value = false;
    switch (_type) {
        case SwitchType_Conversation_Top:
            value = [[WFCCIMService sharedWFCIMService] getConversationInfo:_conversation].isTop>0;
            break;
        case SwitchType_Conversation_Silent:
            value = [[WFCCIMService sharedWFCIMService] getConversationInfo:_conversation].isSilent;
            break;
        case SwitchType_Setting_Global_Silent: {
            value = ![[WFCCIMService sharedWFCIMService] isGlobalSilent];
            break;
        }
        case SwitchType_Setting_Show_Notification_Detail: {
            value = ![[WFCCIMService sharedWFCIMService] isHiddenNotificationDetail];
            break;
        }
        case SwitchType_Setting_Sync_Draft: {
            value = [[WFCCIMService sharedWFCIMService] isEnableSyncDraft];
            break;
        }
        case SwitchType_Conversation_Show_Alias: {
            value = ![[WFCCIMService sharedWFCIMService] isHiddenGroupMemberName:_conversation.target];
            break;
        }
        case SwitchType_Conversation_Save_To_Contact:{
            value = [[WFCCIMService sharedWFCIMService] isFavGroup:self.conversation.target];
            break;
        }
        case SwitchType_Setting_Voip_Silent: {
            value = ![[WFCCIMService sharedWFCIMService] isVoipNotificationSilent];
            break;
        }
        default:
            break;
    }

    self.valueSwitch.on = value;
}

- (void)setType:(SwitchType)type {
    _type = type;
    if (_conversation || type == SwitchType_Setting_Global_Silent || type == SwitchType_Setting_Show_Notification_Detail || type == SwitchType_Setting_Sync_Draft || type == SwitchType_Setting_Voip_Silent) {
        [self updateView];
    }
}
@end
