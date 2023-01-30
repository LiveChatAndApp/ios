#import "WFCCNotificationMessageContent.h"

#import "WFCCQuoteInfo.h"

/**
 修改群名的通知消息
 */
@interface WFCCSensitiveWordContent : WFCCNotificationMessageContent

/**
 群组ID
 */
@property (nonatomic, strong)NSString *text;

/**
 提醒类型，1，提醒部分对象（mentinedTarget）。2，提醒全部。其他不提醒
 */
@property (nonatomic, assign)int mentionedType;

/**
 提醒对象，mentionedType 1时有效
 */
@property (nonatomic, strong)NSArray<NSString *> *mentionedTargets;

/**
 引用信息
 */
@property (nonatomic, strong)WFCCQuoteInfo *quoteInfo;
@end
