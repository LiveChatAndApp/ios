//
//  Utilities.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUUtilities.h"
#import "WFCUImage.h"

@implementation WFCUUtilities
+ (CGSize)getTextDrawingSize:(NSString *)text
                        font:(UIFont *)font
             constrainedSize:(CGSize)constrainedSize {
  if (text.length <= 0) {
    return CGSizeZero;
  }
  
  if ([text respondsToSelector:@selector(boundingRectWithSize:
                                         options:
                                         attributes:
                                         context:)]) {
    return [text boundingRectWithSize:constrainedSize
                              options:(NSStringDrawingTruncatesLastVisibleLine |
                                       NSStringDrawingUsesLineFragmentOrigin |
                                       NSStringDrawingUsesFontLeading)
                           attributes:@{
                                        NSFontAttributeName : font
                                        }
                              context:nil]
    .size;
  } else {
    return [text sizeWithFont:font
            constrainedToSize:constrainedSize
                lineBreakMode:NSLineBreakByTruncatingTail];
  }
}

+ (NSString *)formatTimeLabel:(int64_t)timestamp {
    if (timestamp == 0) {
        return nil;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
    NSDate *current = [[NSDate alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger years = [calendar component:NSCalendarUnitYear fromDate:date];
    NSInteger curYears = [calendar component:NSCalendarUnitYear fromDate:current];

    if ([calendar isDateInToday:date]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        return [formatter stringFromDate:date];
    } else if([calendar isDateInYesterday:date]) {
        return @"昨天";
    } else {
        if (years == curYears) {
            NSInteger weeks = [calendar component:NSCalendarUnitWeekOfYear fromDate:date];
            NSInteger curWeeks = [calendar component:NSCalendarUnitWeekOfYear fromDate:current];
            
            NSInteger weekDays = [calendar component:NSCalendarUnitWeekday fromDate:date];
            if (weeks == curWeeks) {
                switch (weekDays) {
                    case 1:
                        return @"周日";
                        break;
                    case 2:
                        return @"周一";
                        break;
                    case 3:
                        return @"周二";
                        break;
                    case 4:
                        return @"周三";
                        break;
                    case 5:
                        return @"周四";
                        break;
                    case 6:
                        return @"周五";
                        break;
                    case 7:
                        return @"周六";
                        break;
                        
                    default:
                        break;
                }
                return [NSString stringWithFormat:@"周%ld", (long)weekDays];
            } else {
                NSInteger month = [calendar component:NSCalendarUnitMonth fromDate:date];
                NSInteger day = [calendar component:NSCalendarUnitDay fromDate:date];
                return [NSString stringWithFormat:@"%d月%d号", (int)month, (int)day];
            }
        } else {
            NSInteger month = [calendar component:NSCalendarUnitMonth fromDate:date];
            NSInteger day = [calendar component:NSCalendarUnitDay fromDate:date];
            return [NSString stringWithFormat:@"%d年%d月%d号",(int)years,(int)month, (int)day];
        }
        
    }
}

+ (NSString *)formatTimeDetailLabel:(int64_t)timestamp {
    if (timestamp == 0) {
        return nil;
    }
    
    NSDate *messageDate = [[NSDate alloc] initWithTimeIntervalSince1970:timestamp / 1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSCalendarUnit unitFlags = NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *breakdownInfo = [NSCalendar.currentCalendar components:unitFlags fromDate:messageDate  toDate:[NSDate date]  options:kNilOptions];
    if (breakdownInfo.year > 0) {
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    } else if (breakdownInfo.day > 7) {
        [dateFormatter setDateFormat:@"MM/dd"];
    } else if (![NSCalendar.currentCalendar isDateInToday:messageDate] && ![NSCalendar.currentCalendar isDateInYesterday:messageDate]) {
        [dateFormatter setDateFormat:@"EEEE"];
    } else if ([NSCalendar.currentCalendar isDateInYesterday:messageDate]) {
        return @"昨天";
    } else {
        [dateFormatter setDateFormat:@"HH:mm"];
    }
    
    return [dateFormatter stringFromDate:messageDate];
}

+ (NSString *)formatWeek:(NSUInteger)weekDays {
    weekDays = weekDays % 7;
    switch (weekDays) {
        case 2:
            return @"星期一";
        case 3:
            return @"星期二";
        case 4:
            return @"星期三";
        case 5:
            return @"星期四";
        case 6:
            return @"星期五";
        case 0:
            return @"星期六";
        case 1:
            return @"星期日";
        default:
            return @"";
            break;
    }
}

+ (UIImage *)thumbnailWithImage:(UIImage *)originalImage maxSize:(CGSize)size {
    CGSize originalsize = [originalImage size];
    //原图长宽均小于标准长宽的，不作处理返回原图
    if (originalsize.width<size.width && originalsize.height<size.height){
        return originalImage;
    }
    //原图长宽均大于标准长宽的，按比例缩小至最大适应值
    else if(originalsize.width>size.width && originalsize.height>size.height){
        CGFloat rate = 1.0;
        CGFloat widthRate = originalsize.width/size.width;
        CGFloat heightRate = originalsize.height/size.height;
        rate = widthRate>heightRate?heightRate:widthRate;
        CGImageRef imageRef = nil;
        if (heightRate>widthRate){
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(0, originalsize.height/2-size.height*rate/2, originalsize.width, size.height*rate));//获取图片整体部分
        }else{
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(originalsize.width/2-size.width*rate/2, 0, size.width*rate, originalsize.height));//获取图片整体部分
        }
        UIGraphicsBeginImageContext(size);//指定要绘画图片的大小
        CGContextRef con = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(con, 0.0, size.height);
        CGContextScaleCTM(con, 1.0, -1.0);
        CGContextDrawImage(con, CGRectMake(0, 0, size.width, size.height), imageRef);
        UIImage *standardImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGImageRelease(imageRef);
        return standardImage;
    }
    //原图长宽有一项大于标准长宽的，对大于标准的那一项进行裁剪，另一项保持不变
    else if(originalsize.height>size.height || originalsize.width>size.width){
        CGImageRef imageRef = nil;
        if(originalsize.height>size.height){
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(0, originalsize.height/2-originalsize.width/2, originalsize.width, originalsize.width));//获取图片整体部分
        }
        else if (originalsize.width>size.width){
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(originalsize.width/2-originalsize.height/2, 0, originalsize.height, originalsize.height));//获取图片整体部分
        }
        UIGraphicsBeginImageContext(size);//指定要绘画图片的大小
        CGContextRef con = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(con, 0.0, size.height);
        CGContextScaleCTM(con, 1.0, -1.0);
        CGContextDrawImage(con, CGRectMake(0, 0, size.width, size.height), imageRef);
        UIImage *standardImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGImageRelease(imageRef);
        return standardImage;
    }
    //原图为标准长宽的，不做处理
    else{
        return originalImage;
    }
}

+ (NSString *)formatSizeLable:(int64_t)size {
    if (size < 1024) {
        return [NSString stringWithFormat:@"%lldB", size];
    } else if(size < 1024*1024) {
        return [NSString stringWithFormat:@"%lldK", size/1024];
    } else {
        return [NSString stringWithFormat:@"%.2fM", size/1024.f/1024];
    }
}
+ (UIImage *)imageForExt:(NSString *)extName {
    NSString *fileImage = nil;
    if ([extName isEqualToString:@"doc"] || [extName isEqualToString:@"docx"] || [extName isEqualToString:@"pages"]) {
        fileImage = @"file_type_word";
    } else if ([extName isEqualToString:@"xls"] || [extName isEqualToString:@"xlsx"] || [extName isEqualToString:@"numbers"]) {
        fileImage = @"file_type_xls";
    } else if ([extName isEqualToString:@"ppt"] || [extName isEqualToString:@"pptx"] || [extName isEqualToString:@"keynote"]) {
        fileImage = @"file_type_ppt";
    } else if ([extName isEqualToString:@"pdf"]) {
        fileImage = @"file_type_pdf";
    } else if([extName isEqualToString:@"html"] || [extName isEqualToString:@"htm"]) {
        fileImage = @"file_type_html";
    } else if([extName isEqualToString:@"txt"]) {
        fileImage = @"file_type_text";
    } else if([extName isEqualToString:@"jpg"] || [extName isEqualToString:@"png"] || [extName isEqualToString:@"jpeg"]) {
        fileImage = @"file_type_image";
    } else if([extName isEqualToString:@"mp3"] || [extName isEqualToString:@"amr"] || [extName isEqualToString:@"acm"] || [extName isEqualToString:@"aif"]) {
        fileImage = @"file_type_audio";
    } else if([extName isEqualToString:@"mp4"] || [extName isEqualToString:@"avi"]
              || [extName isEqualToString:@"mov"] || [extName isEqualToString:@"asf"]
              || [extName isEqualToString:@"wmv"] || [extName isEqualToString:@"mpeg"]
              || [extName isEqualToString:@"ogg"] || [extName isEqualToString:@"mkv"]
              || [extName isEqualToString:@"rmvb"] || [extName isEqualToString:@"f4v"]) {
        fileImage = @"file_type_video";
    } else if([extName isEqualToString:@"exe"]) {
        fileImage = @"file_type_exe";
    } else if([extName isEqualToString:@"xml"]) {
        fileImage = @"file_type_xml";
    } else if([extName isEqualToString:@"zip"] || [extName isEqualToString:@"rar"]
              || [extName isEqualToString:@"gzip"] || [extName isEqualToString:@"gz"]) {
        fileImage = @"file_type_zip";
    } else {
        fileImage = @"file_type_unknown";
    }
    return [WFCUImage imageNamed:fileImage];
}

+ (NSString *)getUnduplicatedPath:(NSString *)path {
    int count = 1;
    NSString *fileName = [path stringByDeletingPathExtension];
    NSString *fileExt = [path pathExtension];
    while ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [[NSString stringWithFormat:@"%@(%d)", fileName, count++] stringByAppendingPathExtension:fileExt];
    }
    
    return path;
}

+ (BOOL)isFileExist:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (BOOL)isBroadcastGroup:(NSString *)extra {
    if (extra == nil) {
        return NO;
    }
    
    NSData *jsonData = [extra dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error != nil) {
        return NO;
    }

    if ([json objectForKey:@"groupType"] == nil) {
        return NO;
    }
    
    if (![[json objectForKey:@"groupType"] isKindOfClass:NSNumber.class]) {
        return NO;
    }
    
    NSNumber *number = (NSNumber *)[json objectForKey:@"groupType"];
    if (number.integerValue == 2){
        return YES;
    }
    
    return NO;
}

+ (void)addAndTruncateStringWithLabel:(UILabel *)label resevedString:(NSString *)resevedString {
    NSString *originalString = label.text;
    
    label.text = [label.text stringByAppendingString:resevedString];
    if (label.intrinsicContentSize.width < label.frame.size.width) {
        return;
    }
    
    resevedString = [NSString stringWithFormat:@"...%@", resevedString];
    label.text = resevedString;
    CGFloat resevedStringLength = label.intrinsicContentSize.width;
    label.text = originalString;
    if (label.intrinsicContentSize.width > label.frame.size.width) {
        while (label.frame.size.width - label.intrinsicContentSize.width < resevedStringLength && label.text.length != 0) {
            label.text = [label.text substringToIndex:label.text.length - 1];
        }
    }

    label.text = [label.text stringByAppendingString:resevedString];
}

+ (BOOL)containEmoji:(NSString *)string {
    NSMutableArray<NSString *> *patternArray = [[NSMutableArray alloc] init];
    [patternArray addObject:@"[\\p{Emoji_Presentation}\\u26F1]"]; //Code Points with default emoji representation
    [patternArray addObject:@"\\p{Emoji}\\uFE0F"]; //Characters with emoji variation selector
    [patternArray addObject:@"\\p{Emoji_Modifier_Base}\\p{Emoji_Modifier}"]; //Characters with emoji modifier
    [patternArray addObject:@"[\\U0001F1E6-\\U0001F1FF][\\U0001F1E6-\\U0001F1FF]"]; //2-letter flags
    [patternArray addObject:@"\\p{extended_pictographic}"]; //extended_pictographic
    NSString *pattern = @"";
    
    for (NSString *p in patternArray) {
        pattern = [pattern stringByAppendingFormat:@"%@|", p];
        if (patternArray.lastObject == p) {
            pattern = [pattern substringToIndex:pattern.length - 1];
        }
    }
    
    NSString *combinedPattern = [NSString stringWithFormat:@"(?:%@)(?:\\u200D(?:%@))*", pattern, pattern];
    NSRegularExpression *rexExp = [NSRegularExpression regularExpressionWithPattern:combinedPattern options:0 error:NULL];
    NSRange range = [rexExp rangeOfFirstMatchInString:string options:kNilOptions range:NSMakeRange(0, string.length)];
    
    return range.location != NSNotFound;
}

@end
