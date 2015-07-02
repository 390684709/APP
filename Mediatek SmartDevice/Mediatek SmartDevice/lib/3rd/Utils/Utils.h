//
//  Utils.h
//
//
//  Created by Mac on 14-10-23.
//  Copyright (c) 2014年 bin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#define DBNAME    @"BLEManagerModel.sqlite"
sqlite3 *db;
/***************************************************************************
 *
 * 工具类
 *
 ***************************************************************************/

@class AppDelegate;
@class UserInfo;

@interface Utils : NSObject

/*
 AppDelegate
 */

+(AppDelegate *)applicationDelegate;

+ (UIImageView *)imageViewWithFrame:(CGRect)frame withImage:(UIImage *)image;

+ (UILabel *)labelWithFrame:(CGRect)frame withTitle:(NSString *)title titleFontSize:(UIFont *)font textColor:(UIColor *)color backgroundColor:(UIColor *)bgColor alignment:(NSTextAlignment)textAlignment;


#pragma mark - alertView提示框
+(UIAlertView *)alertTitle:(NSString *)title message:(NSString *)msg delegate:(id)aDeleagte cancelBtn:(NSString *)cancelName otherBtnName:(NSString *)otherbuttonName;
#pragma mark - btnCreate
+(UIButton *)createBtnWithType:(UIButtonType)btnType frame:(CGRect)btnFrame backgroundColor:(UIColor*)bgColor;

#pragma mark isValidateEmail
+(BOOL)isValidateEmail:(NSString *)email;
+(BOOL)isValidateMobile:(NSString *)email;
+(BOOL)isValidateHight:(NSString *)hight;
+(BOOL)isValidateTarget:(NSString *)hight;
+(NSDate *)stringToDate:(NSString *)formatter dateString:(NSString *)dateString;
+(void)execSql:(NSString *)sql;
+(void)openDB;
+(UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;
+(void)selfDefineTextField:(UITextField *) textField ImageStringIcon:(NSString *)imageString ImageStringInput:(NSString *)inputString imageV:(UIImageView *) imagev;
@end
