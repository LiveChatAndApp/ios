//
//  AppService.m
//  WildFireChat
//
//  Created by Heavyrain Lee on 2019/10/22.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "AppService.h"

#import <WFChatClient/WFCChatClient.h>
#import <WFChatUIKit/WFChatUIKit.h>
#import <WebKit/WebKit.h>
#import <WFChatUIKit/NSString+hash.h>

#import "AFNetworking.h"
#import "WFCConfig.h"
#import "PCSessionViewController.h"
#import "ResponseModel.h"
#import "SharePredefine.h"


static AppService *sharedSingleton = nil;

#define WFC_APPSERVER_COOKIES @"WFC_APPSERVER_COOKIES"
#define WFC_APPSERVER_AUTH_TOKEN  @"WFC_APPSERVER_AUTH_TOKEN"

#define AUTHORIZATION_HEADER @"authToken"

@implementation AppService 
+ (AppService *)sharedAppService {
    if (sharedSingleton == nil) {
        @synchronized (self) {
            if (sharedSingleton == nil) {
                sharedSingleton = [[AppService alloc] init];
            }
        }
    }

    return sharedSingleton;
}

- (void)loginWithMobile:(NSString *)mobile inviteCode:(NSString *)inviteCode verifyCode:(NSString *)verifyCode success:(void(^)(NSString *userId, NSString *token, BOOL newUser, NSString *resetCode))successBlock error:(void(^)(int errCode, NSString *message))errorBlock {
    int platform = Platform_iOS;
    //如果使用pad端类型，这里平台改成pad类型，另外app_callback.mm文件中把平台也改成ipad，请搜索"iPad"
    //if(当前设备是iPad)
    //platform = Platform_iPad
    [self post:@"/login" data:@{@"mobile":mobile, @"inviteCode":inviteCode, @"code":verifyCode, @"clientId":[[WFCCNetworkService sharedInstance] getClientId], @"platform":@(platform)} isLogin:YES success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            NSString *userId = dict[@"result"][@"userId"];
            NSString *token = dict[@"result"][@"token"];
            BOOL newUser = [dict[@"result"][@"register"] boolValue];
            NSString *resetCode = dict[@"result"][@"resetCode"];
            if(successBlock) successBlock(userId, token, newUser, resetCode);
            if (dict[@"result"][@"createGroupEnable"] != nil) {
                NSNumber *createGroupEnable = dict[@"result"][@"createGroupEnable"];
                [[NSUserDefaults standardUserDefaults] setObject:createGroupEnable forKey:@"createGroupEnable"];
            }
            
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue], dict[@"message"]);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1, error.description);
    }];
}

- (void)loginWithMobile:(NSString *)mobile password:(NSString *)password success:(void(^)(NSString *userId, NSString *token, BOOL newUser))successBlock error:(void(^)(int errCode, NSString *message))errorBlock {
    int platform = Platform_iOS;
    //如果使用pad端类型，这里平台改成pad类型，另外app_callback.mm文件中把平台也改成ipad，请搜索"iPad"
    //if(当前设备是iPad)
    //platform = Platform_iPad
    [self post:@"/login_pwd" data:@{@"mobile":mobile, @"password":password.sha256String, @"clientId":[[WFCCNetworkService sharedInstance] getClientId], @"platform":@(platform)} isLogin:YES success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            NSString *userId = dict[@"result"][@"userId"];
            NSString *token = dict[@"result"][@"token"];
            BOOL newUser = [dict[@"result"][@"register"] boolValue];
            
            if (dict[@"result"][@"createGroupEnable"] != nil) {
                NSNumber *createGroupEnable = dict[@"result"][@"createGroupEnable"];
                [[NSUserDefaults standardUserDefaults] setObject:createGroupEnable forKey:@"createGroupEnable"];
            }
            
            if(successBlock) successBlock(userId, token, newUser);
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue], dict[@"message"]);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1, error.description);
    }];
}

- (void)resetPassword:(NSString *)mobile code:(NSString *)code newPassword:(NSString *)newPassword success:(void(^)(void))successBlock error:(void(^)(int errCode, NSString *message))errorBlock {
    NSDictionary *data;
    if (mobile.length == 0) {
        data = @{@"mobile":mobile, @"resetCode":code, @"newPassword":newPassword.sha256String};
    } else {
        data = @{@"resetCode":code, @"newPassword":newPassword.sha256String};
    }
    [self post:@"/reset_pwd" data:data isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if(successBlock) successBlock();
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue], dict[@"message"]);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1, error.description);
    }];
}

- (void)changePassword:(NSString *)oldPassword newPassword:(NSString *)newPassword success:(void(^)(void))successBlock error:(void(^)(int errCode, NSString *message))errorBlock {
    [self post:@"/change_pwd" data:@{@"oldPassword":oldPassword.sha256String, @"newPassword":newPassword.sha256String} isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if(successBlock) successBlock();
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue], dict[@"message"]);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1, error.description);
    }];
}

- (void)sendLoginCode:(NSString *)phoneNumber success:(void(^)(void))successBlock error:(void(^)(NSString *message))errorBlock {
    
    [self post:@"/send_code" data:@{@"mobile":phoneNumber} isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if(successBlock) successBlock();
        } else {
            if(errorBlock && [dict[@"message"] isKindOfClass:NSString.class]) {
                errorBlock(dict[@"message"]);
            }
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(error.localizedDescription);
    }];
}

- (void)sendResetCode:(NSString *)phoneNumber success:(void(^)(void))successBlock error:(void(^)(NSString *message))errorBlock {
    NSDictionary *data = @{};
    if (phoneNumber.length) {
        data = @{@"mobile":phoneNumber};
    }
    [self post:@"/send_reset_code" data:data isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if(successBlock) successBlock();
        } else {
            if(errorBlock) errorBlock(@"error");
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(error.localizedDescription);
    }];
}

- (void)sendDestroyAccountCode:(void(^)(void))successBlock error:(void(^)(int errorCode, NSString *message))errorBlock {
    [self post:@"/send_destroy_code" data:nil isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if(successBlock) successBlock();
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue], @"error");
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1, error.localizedDescription);
    }];
}

- (void)destroyAccount:(NSString *)code success:(void(^)(void))successBlock error:(void(^)(int errorCode, NSString *message))errorBlock {
    [self post:@"/destroy" data:@{@"code":code} isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if(successBlock) successBlock();
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue], @"error");
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1, error.localizedDescription);
    }];
}

- (void)pcScaned:(NSString *)sessionId success:(void(^)(void))successBlock error:(void(^)(int errorCode, NSString *message))errorBlock {
    NSString *path = [NSString stringWithFormat:@"/scan_pc/%@", sessionId];
    [self post:path data:nil isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if(successBlock) successBlock();
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue], @"Network error");
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1, error.localizedDescription);
    }];
}

- (void)pcConfirmLogin:(NSString *)sessionId success:(void(^)(void))successBlock error:(void(^)(int errorCode, NSString *message))errorBlock {
    NSString *path = @"/confirm_pc";
    NSDictionary *param = @{@"token":sessionId, @"user_id":[WFCCNetworkService sharedInstance].userId, @"quick_login":@(1)};
    [self post:path data:param isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if(successBlock) successBlock();
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue], @"Network error");
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1, error.localizedDescription);
    }];
}

- (void)pcCancelLogin:(NSString *)sessionId success:(void(^)(void))successBlock error:(void(^)(int errorCode, NSString *message))errorBlock {
    NSString *path = @"/cancel_pc";
    NSDictionary *param = @{@"token":sessionId};
    [self post:path data:param isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if(successBlock) successBlock();
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue], @"Network error");
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1, error.localizedDescription);
    }];
}

- (void)getGroupAnnouncement:(NSString *)groupId
                     success:(void(^)(WFCUGroupAnnouncement *))successBlock
                      error:(void(^)(int error_code))errorBlock {
    if (successBlock) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"wfc_group_an_%@", groupId]];
    
        WFCUGroupAnnouncement *an = [[WFCUGroupAnnouncement alloc] init];
        an.data = data;
        an.groupId = groupId;
        
        successBlock(an);
    }
    
    NSString *path = @"/get_group_announcement";
    NSDictionary *param = @{@"groupId":groupId};
    [self post:path data:param isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0 || [dict[@"code"] intValue] == 12) {
            WFCUGroupAnnouncement *an = [[WFCUGroupAnnouncement alloc] init];
            an.groupId = groupId;
            if ([dict[@"code"] intValue] == 0) {
                an.author = dict[@"result"][@"author"];
                an.text = dict[@"result"][@"text"];
                an.timestamp = [dict[@"result"][@"timestamp"] longValue];
            }
            
            [[NSUserDefaults standardUserDefaults] setValue:an.data forKey:[NSString stringWithFormat:@"wfc_group_an_%@", groupId]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if(successBlock) successBlock(an);
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue]);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1);
    }];
}

- (void)updateGroup:(NSString *)groupId
       announcement:(NSString *)announcement
            success:(void(^)(long timestamp))successBlock
              error:(void(^)(int error_code))errorBlock {
    
    NSString *path = @"/put_group_announcement";
    NSDictionary *param = @{@"groupId":groupId, @"author":[WFCCNetworkService sharedInstance].userId, @"text":announcement};
    [self post:path data:param isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            WFCUGroupAnnouncement *an = [[WFCUGroupAnnouncement alloc] init];
            an.groupId = groupId;
            an.author = [WFCCNetworkService sharedInstance].userId;
            an.text = announcement;
            an.timestamp = [dict[@"result"][@"timestamp"] longValue];
            
            
            [[NSUserDefaults standardUserDefaults] setValue:an.data forKey:[NSString stringWithFormat:@"wfc_group_an_%@", groupId]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if(successBlock) successBlock(an.timestamp);
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue]);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1);
    }];
}

- (void)getGroupMembersForPortrait:(NSString *)groupId
                           success:(void(^)(NSArray<NSDictionary<NSString *, NSString *> *> *groupMembers))successBlock
                             error:(void(^)(int error_code))errorBlock {
    NSString *path = @"/group/members_for_portrait";
    [self post:path data:@{@"groupId":groupId} isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if([dict[@"result"] isKindOfClass:NSArray.class]) {
                NSArray *arr = (NSArray *)dict[@"result"];
                if(successBlock) successBlock(arr);
            }
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue]);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1);
    }];
}

- (void)post:(NSString *)path data:(id)data isLogin:(BOOL)isLogin success:(void(^)(NSDictionary *dict))successBlock error:(void(^)(NSError * _Nonnull error))errorBlock {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    [self addCookies:manager];
    
    [manager POST:[APP_SERVER_ADDRESS stringByAppendingPathComponent:path]
       parameters:data
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if(isLogin) { //鉴权信息
                NSString *appToken;
                if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSHTTPURLResponse *r = (NSHTTPURLResponse *)task.response;
                    appToken = [r allHeaderFields][AUTHORIZATION_HEADER];
                }

                if(appToken.length) {
                    [[NSUserDefaults standardUserDefaults] setObject:appToken forKey:WFC_APPSERVER_AUTH_TOKEN];
                } else {
                    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString:APP_SERVER_ADDRESS]];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:WFC_APPSERVER_COOKIES];
                }
            }
        
            NSDictionary *dict = responseObject;
            dispatch_async(dispatch_get_main_queue(), ^{
              successBlock(dict);
            });
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
          }];
}

- (void)get:(NSString *)path data:(id)data success:(void(^)(NSDictionary *dict))successBlock error:(void(^)(NSError * _Nonnull error))errorBlock {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    [self addCookies:manager];
    
    [manager GET:[APP_SERVER_ADDRESS stringByAppendingPathComponent:path] parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (![responseObject isKindOfClass:NSDictionary.class]) {
            successBlock(@{});
            return;
        }
        
        NSDictionary *dict = responseObject;
        successBlock(dict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorBlock(error);
    }];
}

- (void)uploadLogs:(void(^)(void))successBlock error:(void(^)(NSString *errorMsg))errorBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray<NSString *> *logFiles = [[WFCCNetworkService getLogFilesPath]  mutableCopy];
        
        NSMutableArray *uploadedFiles = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"mars_uploaded_files"] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }] mutableCopy];
        
        //日志文件列表需要删除掉已上传记录，避免重复上传。
        //但需要上传最后一条已经上传日志，因为那个日志文件可能在上传之后继续写入了，所以需要继续上传
        if (uploadedFiles.count) {
            [uploadedFiles removeLastObject];
        } else {
            uploadedFiles = [[NSMutableArray alloc] init];
        }
        for (NSString *file in [logFiles copy]) {
            NSString *name = [file componentsSeparatedByString:@"/"].lastObject;
            if ([uploadedFiles containsObject:name]) {
                [logFiles removeObject:file];
            }
        }
        
        
        __block NSString *errorMsg = nil;
        
        for (NSString *logFile in logFiles) {
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
            
            NSString *url = [APP_SERVER_ADDRESS stringByAppendingFormat:@"/logs/%@/upload", [WFCCNetworkService sharedInstance].userId];
            
             dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            
            __block BOOL success = NO;

            [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                NSData *logData = [NSData dataWithContentsOfFile:logFile];
                if (!logData.length) {
                    logData = [@"empty" dataUsingEncoding:NSUTF8StringEncoding];
                }
                
                NSString *fileName = [[NSURL URLWithString:logFile] lastPathComponent];
                [formData appendPartWithFileData:logData name:@"file" fileName:fileName mimeType:@"application/octet-stream"];
            } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dict = (NSDictionary *)responseObject;
                    if([dict[@"code"] intValue] == 0) {
                        NSLog(@"上传成功");
                        success = YES;
                        NSString *name = [logFile componentsSeparatedByString:@"/"].lastObject;
                        [uploadedFiles removeObject:name];
                        [uploadedFiles addObject:name];
                        [[NSUserDefaults standardUserDefaults] setObject:uploadedFiles forKey:@"mars_uploaded_files"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
                if (!success) {
                    errorMsg = @"服务器响应错误";
                }
                dispatch_semaphore_signal(sema);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"上传失败：%@", error);
                dispatch_semaphore_signal(sema);
                errorMsg = error.localizedFailureReason;
            }];
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
            if (!success) {
                errorBlock(errorMsg);
                return;
            }
        }
        
        successBlock();
    });
    
}

- (void)changeName:(NSString *)newName success:(void(^)(void))successBlock error:(void(^)(int errorCode, NSString *message))errorBlock {
    [self post:@"/change_name" data:@{@"newName":newName} isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if(successBlock) successBlock();
        } else {
            NSString *errmsg;
            if ([dict[@"code"] intValue] == 17) {
                errmsg = @"用户名已经存在";
            } else {
                errmsg = @"网络错误";
            }
            if(errorBlock) errorBlock([dict[@"code"] intValue], errmsg);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1, error.localizedDescription);
    }];
}

- (void)showPCSessionViewController:(UIViewController *)baseController pcClient:(WFCCPCOnlineInfo *)clientInfo {
    PCSessionViewController *vc = [[PCSessionViewController alloc] init];
    vc.pcClientInfo = clientInfo;
    [baseController.navigationController pushViewController:vc animated:YES];
}

- (void)addDevice:(NSString *)name
         deviceId:(NSString *)deviceId
            owner:(NSArray<NSString *> *)owners
          success:(void(^)(Device *device))successBlock
            error:(void(^)(int error_code))errorBlock {
    NSString *path = @"/things/add_device";
    
    NSDictionary *extraDict = @{@"name":name};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:extraDict options:0 error:0];
    NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *param = @{@"deviceId":deviceId, @"owners":owners, @"extra":dataStr};
    [self post:path data:param isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            Device *device = [[Device alloc] init];
            device.deviceId = dict[@"deviceId"];
            device.name = name;
            device.token = dict[@"token"];
            device.secret = dict[@"secret"];
            device.owners = owners;
            if(successBlock) successBlock(device);
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue]);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1);
    }];
}

- (void)getMyDevices:(void(^)(NSArray<Device *> *devices))successBlock
               error:(void(^)(int error_code))errorBlock {
    NSString *path = @"/things/list_device";
    [self post:path data:nil isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if ([dict[@"result"] isKindOfClass:[NSArray class]]) {
                NSMutableArray *output = [[NSMutableArray alloc] init];
                NSArray<NSDictionary *> *ds = (NSArray *)dict[@"result"];
                for (NSDictionary *d in ds) {
                    Device *device = [[Device alloc] init];
                    device.deviceId = [d objectForKey:@"deviceId"];
                    device.secret = [d objectForKey:@"secret"];
                    device.token = [d objectForKey:@"token"];
                    device.owners = [d objectForKey:@"owners"];
                    
                    NSString *extra = d[@"extra"];
                    if (extra.length) {
                        NSData *jsonData = [extra dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *err;
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                            options:NSJSONReadingMutableContainers
                                                                              error:&err];
                        if(!err) {
                            device.name = dic[@"name"];
                        }
                    }
                    [output addObject:device];
                }
                if(successBlock) successBlock(output);
            } else {
                if(errorBlock) errorBlock(-1);
            }
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue]);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1);
    }];
}

- (void)delDevice:(NSString *)deviceId
          success:(void(^)(Device *device))successBlock
            error:(void(^)(int error_code))errorBlock {
    NSString *path = @"/things/del_device";
    NSDictionary *param = @{@"deviceId":deviceId};
    [self post:path data:param isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if(successBlock) successBlock(nil);
        } else {
            errorBlock([dict[@"code"] intValue]);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1);
    }];
}

- (void)getFavoriteItems:(int )startId
                   count:(int)count
                 success:(void(^)(NSArray<WFCUFavoriteItem *> *items, BOOL hasMore))successBlock
                   error:(void(^)(int error_code))errorBlock {
    NSString *path = @"/fav/list";
    NSDictionary *param = @{@"id":@(startId), @"count":@(count)};
    [self post:path data:param isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            NSDictionary *result = dict[@"result"];
            BOOL hasMore = [result[@"hasMore"] boolValue];
            NSArray<NSDictionary *> *arrs = (NSArray *)result[@"items"];
            NSMutableArray<WFCUFavoriteItem *> *output = [[NSMutableArray alloc] init];
            for (NSDictionary *d in arrs) {
                WFCUFavoriteItem *item = [[WFCUFavoriteItem alloc] init];
                item.conversation = [WFCCConversation conversationWithType:[d[@"convType"] intValue] target:d[@"convTarget"] line:[d[@"convLine"] intValue]];
                item.favId = [d[@"id"] intValue];
                if(![d[@"messageUid"] isEqual:[NSNull null]])
                    item.messageUid = [d[@"messageUid"] longLongValue];
                item.timestamp = [d[@"timestamp"] longLongValue];
                item.url = d[@"url"];
                item.favType = [d[@"type"] intValue];
                item.title = d[@"title"];
                item.data = d[@"data"];
                item.origin = d[@"origin"];
                item.thumbUrl = d[@"thumbUrl"];
                item.sender = d[@"sender"];
                
                [output addObject:item];
            }
            if(successBlock) successBlock(output, hasMore);
        } else {
            errorBlock([dict[@"code"] intValue]);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1);
    }];
}

- (void)addFavoriteItem:(WFCUFavoriteItem *)item
                success:(void(^)(void))successBlock
                  error:(void(^)(int error_code))errorBlock {
    NSString *path = @"/fav/add";
    NSDictionary *param = @{@"type":@(item.favType),
                            @"messageUid":@(item.messageUid),
                            @"convType":@(item.conversation.type),
                            @"convLine":@(item.conversation.line),
                            @"convTarget":item.conversation.target?item.conversation.target:@"",
                            @"origin":item.origin?item.origin:@"",
                            @"sender":item.sender?item.sender:@"",
                            @"title":item.title?item.title:@"",
                            @"url":item.url?item.url:@"",
                            @"thumbUrl":item.thumbUrl?item.thumbUrl:@"",
                            @"data":item.data?item.data:@""
    };
    
    [self post:path data:param isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if(successBlock) successBlock();
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue]);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1);
    }];
}

- (void)removeFavoriteItem:(int)favId
                   success:(void(^)(void))successBlock
                     error:(void(^)(int error_code))errorBlock {
    NSString *path = [NSString stringWithFormat:@"/fav/del/%d", favId];
    
    [self post:path data:nil isLogin:NO success:^(NSDictionary *dict) {
        if([dict[@"code"] intValue] == 0) {
            if(successBlock) successBlock();
        } else {
            if(errorBlock) errorBlock([dict[@"code"] intValue]);
        }
    } error:^(NSError * _Nonnull error) {
        if(errorBlock) errorBlock(-1);
    }];
}

- (NSData *)getAppServiceCookies {
    return [[NSUserDefaults standardUserDefaults] objectForKey:WFC_APPSERVER_COOKIES];
}

- (NSString *)getAppServiceAuthToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:WFC_APPSERVER_AUTH_TOKEN];
}

- (void)getCustomerServiceURL:(void (^)(NSString * _Nonnull))successBlock error:(void (^ _Nullable)(NSString *))errorBlock{
    [self get:@"/customer/url" data:nil success:^(NSDictionary *dict) {
        if (successBlock == nil) {
            return;
        }
        
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0) {
            if (errorBlock != nil) {
                errorBlock(model.message);
            }
    
            return;
        }
        
        if ([dict[@"result"] isKindOfClass:NSString.class]) {
            successBlock(dict[@"result"]);
        } else {
            successBlock(@"");
        }
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)updateProfileWithModel:(UpdateProfileModel *)model progress:(void (^)(NSProgress * _Nonnull))progress success:(void (^)(void))successBlock error:(void (^)(NSString *))errorBlock {
    NSString *path = [NSString stringWithFormat:@"/info/update/%@", model.flagString];
    NSString *url = [APP_SERVER_ADDRESS stringByAppendingPathComponent:path];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    [self addCookies:manager];
    
    [manager POST:url parameters:model.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (model.avatar != nil) {
            [formData appendPartWithFileData:UIImagePNGRepresentation(model.avatar) name:@"avatar" fileName:@".png" mimeType:@"image/png"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject == nil) {
            if (errorBlock != nil) {
                errorBlock(@"-1");
            }
            
            return;
        }
        
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:responseObject];
        
        if (model.code.integerValue != 0) {
            if (errorBlock != nil) {
                errorBlock(model.message);
            }
            
            return;
        }
        
        successBlock();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }
        
        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)getWalletInfo:(void (^)(WalletInfoModel * _Nonnull))successBlock error:(void (^)(NSString *))errorBlock {
    [self get:@"/info/asserts" data:nil success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0) {
            if (errorBlock != nil) {
                errorBlock(model.message);
                return;
            }
        }
        
        if (![dict[@"result"] isKindOfClass:NSArray.class] && [dict[@"result"] count] == 0) {
            if (errorBlock != nil) {
                errorBlock(@"-1");
            }
            
            return;
        }
        
        WalletInfoModel *walletModel = [WalletInfoModel mj_objectWithKeyValues:dict[@"result"][0]];
        
        if (model == nil) {
            if (errorBlock != nil) {
                errorBlock(@"-1");
            }
            
            return;
        }
        
        successBlock(walletModel);
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)getUserInfo:(NSString *)userId success:(void (^)(UserInfoModel * _Nonnull))successBlock error:(void (^)(NSString *))errorBlock {
    [self get:@"/info" data:@{@"userId":userId} success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0) {
            if (errorBlock != nil) {
                errorBlock(model.message);
            }
            
            return;
        }
        
        UserInfoModel *userModel = [UserInfoModel mj_objectWithKeyValues:dict[@"result"]];
        
        if (userModel == nil) {
            if (errorBlock != nil) {
                errorBlock(@"-1");
            }
            
            return;
        }
        
        
        if (userModel.createGroupEnable != nil && [WFCCNetworkService sharedInstance].userId == userId) {
            [[NSUserDefaults standardUserDefaults] setObject:userModel.createGroupEnable forKey:@"createGroupEnable"];
        }
        
        successBlock(userModel);
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)getWFCCUserInfo:(NSString *)userId success:(void (^)(WFCCUserInfo * _Nonnull))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    [self getUserInfo:userId success:^(UserInfoModel * _Nonnull model) {
        successBlock(model.WFCCUserInfo);
    } error:errorBlock];
}

- (void)changeTradePasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword confirmPassword:(NSString *)confirmPassword success:(void (^)(void))successBlock error:(void (^)(NSString *))errorBlock {
    NSDictionary *parameters = @{@"doubleCheckPwd":confirmPassword.sha256String,
                                 @"newPwd":newPassword.sha256String,
                                 @"oldPwd":oldPassword.sha256String};
    
    [self post:@"/changeTradePassword" data:parameters isLogin:NO success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0 && errorBlock != nil) {
            errorBlock(model.message);
            return;
        }
        
        successBlock();
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }
        
        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)getRechargeChannelWithType:(RechargeChannelType)channel success:(void (^)(NSArray<RechargeChannelModel *> *  _Nonnull))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    [self get:@"/recharge/channel" data:@{@"paymentMethod":@(channel)} success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0) {
            if (errorBlock != nil) {
                errorBlock(model.message);
            }
            
            return;
        }
        
        if (![dict[@"result"] isKindOfClass:NSArray.class] || [(NSArray *)dict[@"result"] count] == 0) {
            if (errorBlock != nil) {
                errorBlock(@"-1");
            }
            
            return;
        }
        
        NSMutableArray *infos = [[NSMutableArray alloc] init];
        
        for (id info in dict[@"result"]) {
            RechargeChannelModel *channelModel = [RechargeChannelModel mj_objectWithKeyValues:info];
            if (info != nil) {
                [infos addObject:channelModel];
            }
        }
        
        successBlock(infos);
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)applyRecharge:(ApplyRechargeRequestModel *)model success:(void (^)(ApplyRechargeModel * _Nonnull))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    [self post:@"/recharge/apply" data:model.parameters isLogin:NO success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0 && errorBlock != nil) {
            errorBlock(model.message);
            return;
        }
        
        ApplyRechargeModel *orderModel = [ApplyRechargeModel mj_objectWithKeyValues:dict[@"result"]];
        if (orderModel == nil) {
            if (errorBlock != nil) {
                errorBlock(@"-1");
            }
        }
        
        successBlock(orderModel);
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }
        
        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)confirmRechargeWithId:(NSString *)orderId image:(UIImage *)image success:(void (^)(void))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [APP_SERVER_ADDRESS stringByAppendingPathComponent:@"/recharge/confirm"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];

    [self addCookies:manager];
    [manager POST:url parameters:@{@"id":orderId} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"payImageFile" fileName:@"payImageFile" mimeType:@"image/png"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject == nil) {
            if (errorBlock != nil) {
                errorBlock(@"-1");
            }

            return;
        }

        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:responseObject];

        if (model.code.integerValue != 0) {
            if (errorBlock != nil) {
                errorBlock(model.message);
            }

            return;
        }

        successBlock();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)getGroupList:(void (^)(GroupListModel * _Nonnull))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    NSDictionary *parameters = @{@"groupType": @(2),
                                 @"pageOfSize": @(100)};
    [self get:@"/group/list" data:parameters success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0 && errorBlock != nil) {
            errorBlock(model.message);
            return;
        }
        
        GroupListModel *listModel = [GroupListModel mj_objectWithKeyValues:dict[@"result"]];
        if (listModel == nil) {
            if (errorBlock != nil) {
                errorBlock(@"-1");
            }
        }
        
        successBlock(listModel);
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)getChatRoomList:(void (^)(NSArray<ChatRoomListModel *> * _Nonnull))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    [self get:@"/chatRoomList" data:nil success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0 && errorBlock != nil) {
            errorBlock(model.message);
            return;
        }
        
        if (![dict[@"result"] isKindOfClass:NSArray.class]) {
            successBlock(@[]);
        }
        
        NSMutableArray *lists = [[NSMutableArray alloc] init];
        for (id room in dict[@"result"]) {
            ChatRoomListModel *roomModel = [ChatRoomListModel mj_objectWithKeyValues:room];
            if (roomModel != nil) {
                [lists addObject:roomModel];
            }
        }
        
        successBlock(lists);
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)getImageDomain {
    [self get:@"/index/getImagePathDomain" data:nil success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0) {
            return;
        }
        
        if (![dict[@"result"] isKindOfClass:NSString.class]) {
            return;
        }
        
        NSString *domain = dict[@"result"];
        
        if (domain != nil) {
            [[NSUserDefaults standardUserDefaults] setObject:domain forKey:@"mediaDomain"];
        }
    } error:^(NSError * _Nonnull error) {
        NSLog(@"取得圖片域名失敗!!!!!!");
    }];
}

- (void)uploadImage:(UIImage *)image progress:(void (^)(NSProgress * _Nonnull))progress success:(void (^)(NSString * _Nonnull))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [APP_SERVER_ADDRESS stringByAppendingPathComponent:@"/group/updatePortrait"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];

    [self addCookies:manager];
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"file" fileName:@"file" mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject == nil) {
            if (errorBlock != nil) {
                errorBlock(@"-1");
            }

            return;
        }

        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:responseObject];

        if (model.code.integerValue != 0) {
            if (errorBlock != nil) {
                errorBlock(model.message);
            }

            return;
        }
        
        if ([model.result isKindOfClass:NSString.class]) {
            successBlock(model.result);
            return;
        }

        successBlock(@"");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)applyWithdraw:(ApplyWithdrawRequestModel *)order success:(void (^)(void))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    [self post:@"/withdraw/apply" data:order.parameters isLogin:NO success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        if (model.code.integerValue != 0) {
            if (errorBlock != nil) {
                errorBlock(model.message);
            }
            
            return;
        }
        
        successBlock();
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)getWithdrawMethod:(void (^)(NSArray<WithdrawMethod *> * _Nonnull))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    [self get:@"/withdraw/payment_method" data:nil success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0 && errorBlock != nil) {
            errorBlock(model.message);
            return;
        }
        
        if (![dict[@"result"] isKindOfClass:NSArray.class]) {
            successBlock(@[]);
        }
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (id info in dict[@"result"]) {
            WithdrawMethod *method = [WithdrawMethod mj_objectWithKeyValues:info];
            if (method != nil) {
                [list addObject:method];
            }
        }
        
        successBlock(list);
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)addWithdrawMethod:(AddWithdrawMethodRequestModel *)method progress:(void (^)(NSProgress * _Nonnull))progress success:(void (^)(void))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [APP_SERVER_ADDRESS stringByAppendingPathComponent:@"/withdraw/payment_method/add"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];

    [self addCookies:manager];
    [manager POST:url parameters:method.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (method.image != nil) {
            [formData appendPartWithFileData:UIImagePNGRepresentation(method.image) name:@"file" fileName:@"file" mimeType:@"image/png"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject == nil) {
            if (errorBlock != nil) {
                errorBlock(@"-1");
            }

            return;
        }

        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:responseObject];

        if (model.code.integerValue != 0) {
            if (errorBlock != nil) {
                errorBlock(model.message);
            }

            return;
        }
        
        successBlock();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)deleteWithdrawMethod:(NSString *)methodId success:(void (^)(void))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    NSString *url = [NSString stringWithFormat:@"/withdraw/payment_method/remove/%@", methodId];
    [self post:url data:nil isLogin:NO success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0 && errorBlock != nil) {
            errorBlock(model.message);
            return;
        }

        successBlock();
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)getOrderList:(void (^)(NSArray<WalletOrderModel *> * _Nonnull))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    [self get:@"/info/orderList" data:nil success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0 && errorBlock != nil) {
            errorBlock(model.message);
            return;
        }
        
        if (![dict[@"result"] isKindOfClass:NSArray.class]) {
            successBlock(@[]);
        }
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (id info in dict[@"result"]) {
            WalletOrderModel *method = [WalletOrderModel mj_objectWithKeyValues:info];
            if (method != nil) {
                [list addObject:method];
            }
        }
        
        successBlock(list);
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)inviteFriendWithModel:(InviteFriendRequestModel *)model success:(void (^)(void))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    [self post:@"/relate/friend/invite" data:model.parameters isLogin:NO success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0 && errorBlock != nil) {
            errorBlock(model.message);
            return;
        }

        successBlock();
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)getFriendRequest:(void (^)(NSArray<FriendRequest *> * _Nonnull))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    [self get:@"/relate/friend/request" data:nil success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0 && errorBlock != nil) {
            errorBlock(model.message);
            return;
        }
        
        if (![dict[@"result"] isKindOfClass:NSArray.class]) {
            successBlock(@[]);
        }
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (id info in dict[@"result"]) {
            FriendRequest *method = [FriendRequest mj_objectWithKeyValues:info];
            if (method != nil) {
                [list addObject:method];
            }
        }
        
        successBlock(list);
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)responseFriendRequestWithUID:(NSString *)uid verifyText:(NSString *)text reply:(NSInteger)reply success:(void (^)(void))successBlock error:(void (^)(NSString * _Nonnull))errorBlock {
    NSDictionary *parameters = @{@"uid": uid,
                                 @"verifyText": text,
                                 @"reply": @(reply)};
    [self post:@"/relate/friend/response" data:parameters isLogin:NO success:^(NSDictionary *dict) {
        ResponseModel *model = [ResponseModel mj_objectWithKeyValues:dict];
        
        if (model.code.integerValue != 0 && errorBlock != nil) {
            if (model.code.integerValue == 1038) {
                errorBlock(@"好友验证失败，请输入正确好友验证码");
            } else {
                errorBlock(model.message);
            }
            
            return;
        }

        successBlock();
    } error:^(NSError * _Nonnull error) {
        if (errorBlock == nil) {
            return;
        }

        errorBlock([NSString stringWithFormat:@"%ld", error.code]);
    }];
}

- (void)addCookies:(AFHTTPSessionManager *)manager {
    //在调用其他接口时需要把cookie传给后台，也就是设置cookie的过程
    NSString *authToken = [self getAppServiceAuthToken];
    if(authToken.length) {
        [manager.requestSerializer setValue:authToken forHTTPHeaderField:AUTHORIZATION_HEADER];
    } else {
        NSData *cookiesdata = [self getAppServiceCookies];//url和登录时传的url 是同一个
        if([cookiesdata length]) {
            NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
            NSHTTPCookie *cookie;
            for (cookie in cookies) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            }
        }
    }
}

- (void)clearAppServiceAuthInfos {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WFC_APPSERVER_COOKIES];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WFC_APPSERVER_AUTH_TOKEN];
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:WFC_SHARE_APP_GROUP_ID];//此处id要与开发者中心创建时一致
        
    [sharedDefaults removeObjectForKey:WFC_SHARE_APPSERVICE_AUTH_TOKEN];
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedCookieStorageForGroupContainerIdentifier:WFC_SHARE_APP_GROUP_ID] cookies];
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSHTTPCookieStorage sharedCookieStorageForGroupContainerIdentifier:WFC_SHARE_APP_GROUP_ID] deleteCookie:obj];
    }];
    

    [[WKWebsiteDataStore defaultDataStore] fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes] completionHandler:^(NSArray * __nonnull records) {
        for (WKWebsiteDataRecord *record in records) {
            [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes forDataRecords:@[record] completionHandler:^{}];
        }
    }];
}

@end
