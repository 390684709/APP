//
//  StepSetViewController.m
//  Mediatek SmartDevice
//
//  Created by GHero-Daniel on 15/1/30.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import "StepSetViewController.h"
#import "Utils.h"
#import "LWBLEManager.h"

@interface StepSetViewController ()
{
    int perhight;
    int perweight;
    int pertarget;
    int persqlflag;
}

@end

@implementation StepSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_mubiao1 setText:NSLocalizedString(@"Target", @"Target")];
    [_shengao2 setText:NSLocalizedString(@"Height", @"Height")];
    [_tizhong3 setText:NSLocalizedString(@"Weight", @"Weight")];
    [self.navigationItem setTitle:NSLocalizedString(@"Step Count Set", @"Step Count Set")];
    [self.navigationItem.leftBarButtonItem setTitle:NSLocalizedString(@"< Back", @"< Back")];
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Done >", @"Done >")];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"< Back", @"< Back")
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(clickLeftButton)];
    self.navigationItem.leftBarButtonItem=leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done >", @"Done >")
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(clickRightButton)];
    self.navigationItem.rightBarButtonItem=rightButton;
    
    perhight = 175;
    perweight = 50;
    pertarget = 20000;
    persqlflag = 0;
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *dbPath = [documentPaths objectAtIndex:0];
    NSString *database_path = [dbPath stringByAppendingPathComponent:DBNAME];
    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"数据库打开失败");
    }
    
    NSString *query = [NSString stringWithFormat:@"select * from STEPINFO order by ID desc"];
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            if (persqlflag == 0) {
                perhight = sqlite3_column_int(statement,1);
                perweight = sqlite3_column_int(statement,2);
                pertarget = sqlite3_column_int(statement,3);
                persqlflag ++;
                break;
            }
        }
    }
    sqlite3_close(db);
    self.hight.text  = [NSString stringWithFormat:@"%d",perhight];
    self.weight.text = [NSString stringWithFormat:@"%d",perweight];
    self.target.text = [NSString stringWithFormat:@"%d",pertarget];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)clickLeftButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)clickRightButton
{
    if([self checkValidityTextField]){
        
        
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *dbPath = [documentPaths objectAtIndex:0];
        NSString *database_path = [dbPath stringByAppendingPathComponent:DBNAME];
        if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
            sqlite3_close(db);
            NSLog(@"数据库打开失败");
        }
        NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS STEPINFO (ID INTEGER PRIMARY KEY AUTOINCREMENT, stephight int, stepweight int, steptarget int)";
        [Utils execSql:sqlCreateTable];
        
        NSString *sql1 = [NSString stringWithFormat:@"INSERT INTO 'STEPINFO' ('stephight', 'stepweight' ,'steptarget') VALUES (%d, %d, %d)", [self.hight.text intValue] ,[self.weight.text intValue],[self.target.text intValue]];
        [Utils execSql:sql1];

        sqlite3_close(db);
        [[LWBLEManager shared]toThreeSecond];

        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (BOOL)checkValidityTextField
{
    //    NSString * str1 = @"";
    //    NSString * str2 = @"";
    
    if (![Utils isValidateHight:self.hight.text] )
    {
        if(zhSP){
            [Utils alertTitle:@"提示" message:@"请输入有效的身高数字" delegate:self cancelBtn:@"确定" otherBtnName:nil];
        }
        else
        {
            [Utils alertTitle:@"Hints" message:@"Please enter a hight number" delegate:self cancelBtn:@"Done" otherBtnName:nil];
        }
        return NO;
    }
    
    if ((![self.hight.text intValue])>30&&(![self.hight.text intValue]<250)) {
        if (zhSP) {
            [Utils alertTitle:@"提示" message:@"请输入有效的身高范围" delegate:self cancelBtn:@"确定" otherBtnName:nil];
        }
        else
        {
            [Utils alertTitle:@"Hints" message:@"Please enter a real hight number" delegate:self cancelBtn:@"Done" otherBtnName:nil];
        }
        return NO;
    }
    
    
    if (![Utils isValidateHight:self.weight.text] )
    {
        if(zhSP){
            [Utils alertTitle:@"提示" message:@"请输入有效的体重数字" delegate:self cancelBtn:@"确定" otherBtnName:nil];
        }
        else
        {
            [Utils alertTitle:@"Hints" message:@"Please enter a real number" delegate:self cancelBtn:@"Done" otherBtnName:nil];
        }
        return NO;
    }
    
    if ((![self.weight.text intValue])>30&&(![self.weight.text intValue]<250)) {
        if(zhSP){
            [Utils alertTitle:@"提示" message:@"请输入有效的体重范围" delegate:self cancelBtn:@"确定" otherBtnName:nil];
        }
        else
        {
            [Utils alertTitle:@"Hints" message:@"Please enter a real weight number" delegate:self cancelBtn:@"Done" otherBtnName:nil];
        }
        return NO;
    }
    
    if (![Utils isValidateTarget:self.target.text] )
    {
        if(zhSP){
            [Utils alertTitle:@"提示" message:@"目标请输入数字" delegate:self cancelBtn:@"确定" otherBtnName:nil];
        }
        else
        {
            [Utils alertTitle:@"Hints" message:@"Please enter a target number" delegate:self cancelBtn:@"Done" otherBtnName:nil];
        }
        return NO;
    }
    return YES;
}




@end
