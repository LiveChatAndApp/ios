//
//  WFCUAppService.h
//  WFChatUIKit
//
//  Created by Heavyrain Lee on 2019/10/22.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WFChatClient/UpdateProfileModel.h>
#import <WFChatUIKit/FriendRequest.h>

#import "WFCUGroupAnnouncement.h"
#import "WFCUFavoriteItem.h"
#import "GroupListModel.h"
#import "InviteFriendRequestModel.h"

NS_ASSUME_NONNULL_BEGIN

@class WFCCPCOnlineInfo;
@protocol WFCUAppServiceProvider <NSObject>
- (void)getGroupAnnouncement:(NSString *)groupId
                     success:(void(^)(WFCUGroupAnnouncement *))successBlock
                       error:(void(^)(int error_code))errorBlock;

- (void)updateGroup:(NSString *)groupId
       announcement:(NSString *)announcement
            success:(void(^)(long timestamp))successBlock
              error:(void(^)(int error_code))errorBlock;

- (void)getGroupMembersForPortrait:(NSString *)groupId
                           success:(void(^)(NSArray<NSDictionary<NSString *, NSString *> *> *groupMembers))successBlock
                             error:(void(^)(int error_code))errorBlock;

- (void)showPCSessionViewController:(UIViewController *)baseController
                          pcClient:(WFCCPCOnlineInfo *)clientInfo;

- (void)changeName:(NSString *)newName success:(void(^)(void))successBlock error:(void(^)(int errorCode, NSString *message))errorBlock;


- (void)getFavoriteItems:(int )startId
                   count:(int)count
                     success:(void(^)(NSArray<WFCUFavoriteItem *> *items, BOOL hasMore))successBlock
                       error:(void(^)(int error_code))errorBlock;

- (void)addFavoriteItem:(WFCUFavoriteItem *)item
            success:(void(^)(void))successBlock
              error:(void(^)(int error_code))errorBlock;

- (void)removeFavoriteItem:(int)favId
                   success:(void(^)(void))successBlock
                     error:(void(^)(int error_code))errorBlock;

- (void)getWFCCUserInfo:(NSString *)userId success:(void (^)(WFCCUserInfo * _Nonnull info))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;

- (void)updateProfileWithModel:(UpdateProfileModel *)model progress:(nullable void (^)(NSProgress *progress))progress success:(void (^)(void))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;

- (void)getGroupList:(void (^)(GroupListModel *model))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)uploadImage:(UIImage *)image progress:(nullable void (^)(NSProgress *progress))progress success:(void (^)(NSString *url))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)inviteFriendWithModel:(InviteFriendRequestModel *)model success:(void (^)(void))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)getFriendRequest:(void (^)(NSArray<FriendRequest *> *list))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
- (void)responseFriendRequestWithUID:(NSString *)uid verifyText:(NSString *)text reply:(NSInteger)reply success:(void (^)(void))successBlock error:(void (^ __nullable)(NSString * message))errorBlock;
@end

NS_ASSUME_NONNULL_END
