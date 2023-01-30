#import "UpdateProfileModel.h"

@interface UpdateProfileModel ()

@property(nonatomic, assign)NSInteger flag;
@property(nonatomic, strong)NSMutableDictionary *m_parameters;

@end

@implementation UpdateProfileModel

- (instancetype)init {
    self = [super init];
    
    self.flag = 0;
    self.m_parameters = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void)setNickName:(NSString *)nickName {
    self.flag = self.flag | 1;
    _nickName = nickName;
    self.m_parameters[@"nickName"] = nickName;
}


- (void)setAvatar:(UIImage *)avatar {
    self.flag = self.flag | 1 << 1;
    _avatar = avatar;
}

- (void)setGender:(NSInteger)gender {
    self.flag = self.flag | 1 << 2;
    
    _gender = gender;
    self.m_parameters[@"gender"] = [NSNumber numberWithInteger:gender];
}

- (NSString *)flagString {
    NSMutableString *string = [NSMutableString string];
    NSInteger value = self.flag;
    
    while (value) {
       [string insertString:(value & 1)? @"1": @"0" atIndex:0];
       value /= 2;
    }
    
    return string;
}

- (NSDictionary *)parameters {
    return self.m_parameters;
}

- (void)setValue:(id)value type:(ModifyMyInfoType)type {
    switch (type) {
        case Modify_DisplayName:
            if ([value isKindOfClass:NSString.class]) {
                self.nickName = value;
            }
            break;
        case Modify_Gender:
            if ([value isKindOfClass:NSString.class]) {
                self.gender = [(NSString *)value intValue];
            }
            break;
        case Modify_Portrait:
            if ([value isKindOfClass:UIImage.class]) {
                self.avatar = value;
            }
            break;
        default:
            break;
    }
}

- (NSString *)genderString {
    if (self.gender == 1) {
        return @"保留";
    } else if (self.gender == 2) {
        return @"男";
    } else if (self.gender == 3) {
        return @"女";
    }
    
    return @"";
}

@end
