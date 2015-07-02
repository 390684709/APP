//
//  Utils.m
//
//
//  Created by Mac on 14-10-23.
//  Copyright (c) 2014年 bin. All rights reserved.
//

#import "Utils.h"
#import "MtkAppDelegate.h"

@implementation Utils

/*
 AppDelegate
 */
+ (AppDelegate *)applicationDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (UIImageView *)imageViewWithFrame:(CGRect)frame withImage:(UIImage *)image{
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = image;
    return imageView;
}

+ (UILabel *)labelWithFrame:(CGRect)frame withTitle:(NSString *)title titleFontSize:(UIFont *)font textColor:(UIColor *)color backgroundColor:(UIColor *)bgColor alignment:(NSTextAlignment)textAlignment{
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = title;
    label.font = font;
    label.textColor = color;
    label.backgroundColor = bgColor;
    label.textAlignment = textAlignment;
    return label;
}


//alertView
+(UIAlertView *)alertTitle:(NSString *)title message:(NSString *)msg delegate:(id)aDeleagte cancelBtn:(NSString *)cancelName otherBtnName:(NSString *)otherbuttonName{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:aDeleagte cancelButtonTitle:cancelName otherButtonTitles:otherbuttonName, nil];
    [alert show];
    return alert;
}

+(UIButton *)createBtnWithType:(UIButtonType)btnType frame:(CGRect)btnFrame backgroundColor:(UIColor*)bgColor{
    UIButton *btn = [UIButton buttonWithType:btnType];
    btn.frame = btnFrame;
    [btn setBackgroundColor:bgColor];
    return btn;
}

//利用正则表达式验证邮箱的合法性
+(BOOL)isValidateEmail:(NSString *)email {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
    
}

+(BOOL)isValidateHight:(NSString *)hight {
    NSString *hightRegex = @"[0-9]{2,3}";
    NSPredicate *hightTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", hightRegex];
    return [hightTest evaluateWithObject:hight];
}

+(BOOL)isValidateTarget:(NSString *)hight {
    NSString *hightRegex = @"[0-9]{1,6}";
    NSPredicate *hightTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", hightRegex];
    return [hightTest evaluateWithObject:hight];
}

+(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(17[0|8|7]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobile];
}

+(NSDate *)stringToDate:(NSString *)formatter dateString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    return [dateFormatter dateFromString:dateString];
}

+(void)execSql:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"数据库操作数据失败!");
    }
}

+(void)openDB
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                 NSUserDomainMask, YES);
    NSString *dbPath = [documentPaths objectAtIndex:0];
    NSString *database_path = [dbPath stringByAppendingPathComponent:DBNAME];
    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"数据库打开失败");
    }
}

+(UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage; 
}

+(void)selfDefineTextField:(UITextField *) textField ImageStringIcon:(NSString *)imageString ImageStringInput:(NSString *)inputString imageV:(UIImageView *) imagev{
    UIImage *image = [UIImage imageNamed:imageString];
    CGSize newSize = CGSizeMake(20, 20);
    UIImageView *imgv=[[UIImageView alloc] initWithImage:[self scaleToSize:image size:newSize]];
    textField.leftView = imgv;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.borderStyle = UITextBorderStyleNone;
    if(imagev != nil) {
    UIImage * inputImage = [UIImage imageNamed:inputString];
    imagev.image = inputImage;
    }
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

@end
