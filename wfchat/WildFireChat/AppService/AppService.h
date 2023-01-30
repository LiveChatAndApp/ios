//
//  AppService.h
//  WildFireChat
//
//  Created by Heavyrain Lee on 2019/10/22.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WFChatUIKit/WFChatUIKit.h>
#import <WFChatClient/WFCChatClient.h>
#import <WFChatClient/UpdateProfileModel.h>
#import <WFChatUIKit/GroupListModel.h>
#import <WFChatUIKit/InviteFriendRequestModel.h>
#import <WFChatUIKit/FriendRequest.h>

#import "AddWithdrawMethodRequestModel.h"
#import "ApplyRechargeModel.h"
#import "ApplyRechargeRequestModel.h"
#import "ApplyWithdrawRequestModel.h"
#import "ChatRoomListModel.h"
#import "Device.h"
#import "RechargeChannelModel.h"
#import "WalletInfoModel.h"
#import "WithdrawMethod.h"
#import "WalletOrderModel.h"
#import "UserInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppService : NSObject <WFCUAppServiceProvider>

+ (AppService *)sharedAppService;

- (void)loginWithMobile:(NSString *)mobile inviteCode:(NSString *)inviteCode verifyCode:(NSString *)verifyCode success:(void(^)(NSString *userId, NSString *token, BOOL newUser, NSString *resetCode))successBlock error:(void(^)(int errCode, NSString *message))errorBlock;

- (void)loginWithMobile:(NSString *)mobile password:(NSString *)password success:(void(^)(NSString *userId, NSString *token, BOOL newUser))successBlock error:(void(^)(int errCode, NSString *message))errorBlock;

- (void)resetPassword:(NSString *)mobile code:(NSString *)code newPassword:(NSString *)newPassword success:(void(^)(void))successBlock error:(void(^)(int errCode, NSString *message))errorBlock;

- (void)changePassword:(NSString *)oldPassword newPassword:(NSString *)newPassword success:(void(^)(void))successBlock error:(void(^)(int errCode, NSString *message))errorBlock;

- (void)sendLoginCode:(NSString *)phoneNumber success:(void(^)(void))successBlock error:(void(^)(NSString *message))errorBlock;

- (void)sendResetCode:(NSString *)phoneNumber success:(void(^)(void))successBlock error:(void(^)(NSString *message))errorBlock;

//发送删除账号验证码
- (void)sendDestroyAccountCode:(void(^)(void))successBlock error:(void(^)(int errorCode, NSString *message))errorBlock;

- (void)destroyAccount:(NSString *)code success:(void(^)(void))successBlock error:(void(^)(int errorCode, NSString *message))errorBlock;

- (void)pcScaned:(NSString *)sessionId success:(void(^)(void))successBlock error:(void(^)(int errorCode, NSString *message))errorBlock;

- (void)pcConfirmLogin:(NSString *)sessionId success:(void(^)(void))successBlock error:(void(^)(int errorCode, NSString *message))errorBlock;

- (void)pcCancelLogin:(NSString *)sessionId success:(nullable void(^)(void))successBlock error:(nullable void(^)(int errorCode, NSString *message))errorBlock;

- (void)uploadLogs:(void(^)(void))successBlock error:(void(^)(NSString *errorMsg))errorBlock;

- (void)showPCSessionViewController:(UIViewController *)baseController pcClient:(WFCCPCOnlineInfo *)clientInfo;

- (void)addDevice:(NSString *)name
         deviceId:(NSString *)deviceId
            owner:(NSArray<NSString *> *)owners
          success:(void(^)(Device *device))successBlock
            error:(void(^)(int error_code))errorBlock;

- (void)getMyDevices:(void(^)(NSArray<Device *> *devices))successBlock
               error:(void(^)(int error_code))errorBlock;

- (void)delDevice:(NSString *)deviceId
          success:(void(^)(Device *device))successBlock
            error:(void(^)(int error_code))errorBlock;

- (NSData *)getAppServiceCookies;
- (NSString *)getAppServiceAuthToken;
- (void)getCustomerServiceURL:(void (^ __nonnull)(NSString * url))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)updateProfileWithModel:(UpdateProfileModel *)model progress:(nullable void (^)(NSProgress *progress))progress success:(void (^)(void))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)getWalletInfo:(void (^)(WalletInfoModel * _Nonnull model))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)getUserInfo:(NSString *)userId success:(void (^)(UserInfoModel * _Nonnull model))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)getWFCCUserInfo:(NSString *)userId success:(void (^)(WFCCUserInfo * _Nonnull info))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)changeTradePasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword confirmPassword:(NSString *)confirmPassword success:(void (^)(void))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)getRechargeChannelWithType:(RechargeChannelType)channel success:(void (^)(NSArray<RechargeChannelModel *> *channels))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)applyRecharge:(ApplyRechargeRequestModel *)model success:(void (^)(ApplyRechargeModel * _Nonnull model))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)confirmRechargeWithId:(NSString *)orderId image:(UIImage *)image success:(void (^)(void))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)getGroupList:(void (^)(GroupListModel *model))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)getChatRoomList:(void (^)(NSArray<ChatRoomListModel *> *lists))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)getImageDomain;
- (void)uploadImage:(UIImage *)image progress:(nullable void (^)(NSProgress *progress))progress success:(void (^)(NSString *url))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)applyWithdraw:(ApplyWithdrawRequestModel *)order success:(void (^)(void))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)getWithdrawMethod:(void (^)(NSArray<WithdrawMethod *> *list))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)addWithdrawMethod:(AddWithdrawMethodRequestModel *)method progress:(nullable void (^)(NSProgress *progress))progress success:(void (^)(void))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)deleteWithdrawMethod:(NSString *)methodId success:(void (^)(void))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)getOrderList:(void (^)(NSArray<WalletOrderModel *> *list))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)inviteFriendWithModel:(InviteFriendRequestModel *)model success:(void (^)(void))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)getFriendRequest:(void (^)(NSArray<FriendRequest *> *list))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)responseFriendRequestWithUID:(NSString *)uid verifyText:(NSString *)text reply:(NSInteger)reply success:(void (^)(void))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
//清除应用服务认证cookies和认证token
- (void)clearAppServiceAuthInfos;
@end

NS_ASSUME_NONNULL_END
