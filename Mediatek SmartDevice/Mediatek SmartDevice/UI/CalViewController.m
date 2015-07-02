//
//  CalViewController.m
//  Smart Watch
//
//  Created by GHero-Daniel on 15/1/16.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import "CalViewController.h"
#import "KDGoalBar.h"
#import "KDGoalBarTwo.h"
#import "KDGoalBarThree.h"
#import "LWBLEManager.h"
#import "Utils.h"

@interface CalViewController ()

{
    KDGoalBar * firstGoalBar;
    KDGoalBarTwo * secondGoalBar;
    KDGoalBarThree * thirdGoalBar;
    int perflag;
    int perdata;
    int perpercent;
    int perhight;
    int perweight;
    int pertarget;
    int persqlflag;
    int peralertflag;
}

@property BOOL isConnected;
@end

@implementation CalViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:NSLocalizedString(@"Pedometer", @"Pedometer")];
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Setting", @"Setting")];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Setting", @"Setting")
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(clickRightButton)];
    self.navigationItem.rightBarButtonItem=rightButton;
    
    self.isConnected=NO;
    [self toScanBLE];
    peralertflag = 0;
    pertarget = 20000;
    if(h480)
    {
        firstGoalBar = [[KDGoalBar alloc]initWithFrame:CGRectMake(60, 78, 220, 220)];
        secondGoalBar = [[KDGoalBarTwo alloc]initWithFrame:CGRectMake(0 ,278, 140, 140)];
        thirdGoalBar = [[KDGoalBarThree alloc]initWithFrame:CGRectMake(180,278, 140, 140)];
    }
    else
    {
    firstGoalBar = [[KDGoalBar alloc]initWithFrame:CGRectMake(60, 100, 220, 220)];
    secondGoalBar = [[KDGoalBarTwo alloc]initWithFrame:CGRectMake(0 ,300, 140, 140)];
    thirdGoalBar = [[KDGoalBarThree alloc]initWithFrame:CGRectMake(180,300, 140, 140)];
    }
    [self toThreeCircleInit];
    [self toGetSqlite];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)toThreeCircleInit
{
    perflag = 0 ;
    perdata = 0 ;
    perhight = 101;
    perweight = 1;
    persqlflag = 0;
    perpercent=0;
    
    [firstGoalBar setPercent:perflag setData:0 animated:NO];
    [self.view addSubview:firstGoalBar];
    
    [secondGoalBar setPercent:perflag setData:0 animated:NO];
    [self.view addSubview:secondGoalBar];
    
    [thirdGoalBar setPercent:perflag setData:0 animated:NO];
    [self.view addSubview:thirdGoalBar];
}

-(void)toGetSqlite
{
    [firstGoalBar toGetSqlite];
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
                pertarget = sqlite3_column_int(statement, 3);
                persqlflag ++;
            }
        }
    }
    sqlite3_close(db);
    
    if (perweight==1) {
        UINavigationController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"goToSet"];
        [self presentViewController:controller animated:NO completion:nil];
    }
    [NSTimer  scheduledTimerWithTimeInterval:0.5f  target:self  selector:@selector(setupfirstGoalBar) userInfo:nil  repeats:NO];
}


-(void)stepAlert
{
    if(perdata>=pertarget&&peralertflag==0)
    {
        if (zhSP) {
            [Utils alertTitle:@"提示" message:@"您已完成目标" delegate:self cancelBtn:@"确定" otherBtnName:nil];
        }
        else
        {
            [Utils alertTitle:@"Hints" message:@"You reach the goal" delegate:self cancelBtn:@"Done" otherBtnName:nil];
        }
        peralertflag ++;
    }
}

-(void)toSetSqlite:(NSNotification *)aNotification
{
    
    [self toThreeCircleInit];
    [self toGetSqlite];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputWithNote:) name:@"OutputArrayNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleIsConnected:) name:@"BleIsConnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleNotConnected:) name:@"BleNotConnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toSetSqlite:) name:@"ToSetSqlite" object:nil];
    [[LWBLEManager shared] startGetStep];
    [[LWBLEManager shared] scanTheBlue];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OutputArrayNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BleIsConnected" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BleNotConnected" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ToSetSqlite" object:nil];
    [[LWBLEManager shared] stopGetStep];
//    [[LWBLEManager shared]cancelPerConnection];
}


- (void)setupfirstGoalBar
{
    if (perflag<perpercent) {
        [firstGoalBar  setPercent:perflag setData:perdata animated:NO];
        [secondGoalBar setPercent:perflag setData:perdata*0.45*perhight/100 animated:NO];
        [thirdGoalBar  setPercent:perflag setData:perdata*0.45*perhight/100000*perweight*1.036 animated:NO];
        [NSTimer  scheduledTimerWithTimeInterval:0.05f  target:self  selector:@selector(setupfirstGoalBar) userInfo:nil  repeats:NO];
    }
    else
    {
        [firstGoalBar  setPercent:perpercent setData:perdata animated:NO];
        [secondGoalBar setPercent:perpercent setData:perdata*0.45*perhight/100 animated:NO];
        [thirdGoalBar  setPercent:perpercent setData:perdata*0.45*perhight/100000*perweight*1.036 animated:NO];
    }
    perflag++;
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


-(void)clickRightButton
{
    UINavigationController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"goToSet"];
    [self presentViewController:controller animated:NO completion:nil];
}

- (IBAction)btnBackToMain:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - BLE ACTION

-(void)bleIsConnected:(NSNotification *)aNotification
{
    self.isConnected=YES;
}

-(void)bleNotConnected:(NSNotification *)aNotification
{
    self.isConnected=NO;
    [self toScanBLE];
}

-(void)toScanBLE
{
    if (!self.isConnected) {
        [[LWBLEManager shared]scanTheBlue];
        [NSTimer  scheduledTimerWithTimeInterval:1.0f  target:self  selector:@selector(toScanBLE) userInfo:nil  repeats:NO];
    }else {//连接成功查询表ZDEVICEINFO所有内容
        [[LWBLEManager shared]renewBleServices];
    }
}

#pragma mark - BLE DATA

- (void)outputWithNote:(NSNotification *)aNotification
{
    NSData *data = [aNotification object];
    NSLog(@"data%@",data);
    if(data.length==7)
    {
        NSString * firstStr = [NSString stringWithFormat:@"%@", [data subdataWithRange:NSMakeRange(0,4)]];
        NSString * lastStr  = [NSString stringWithFormat:@"%@", [data subdataWithRange:NSMakeRange(4,3)]];
        
        if ([lastStr isEqualToString:@"<454f4d>"]) {
            perdata = [self ToTrueShortNumber:firstStr];
            perpercent = perdata*100 / pertarget;
            [NSTimer  scheduledTimerWithTimeInterval:0.5f  target:self  selector:@selector(setupfirstGoalBar) userInfo:nil  repeats:NO];
            [self stepAlert];
        }        
    }
}

-(NSMutableString *) flipByByteOne:(NSString*)String
{
    NSMutableString* tempFlipString  = [[NSMutableString alloc] init];
    for (int i=(int)String.length/2-1; i >= 0 ; i--)
    {
        NSString* tempString = [[NSString alloc]init];
        tempString = [String substringWithRange:NSMakeRange(2*i,2)];
        [tempFlipString appendString:tempString];
    }
    return tempFlipString;
}


-(int) ToTrueShortNumber :(NSString * )DataStr
{
    DataStr = [DataStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    DataStr = [DataStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    DataStr = [self flipByByteOne:DataStr];
    NSScanner* scanner = [NSScanner scannerWithString: DataStr];
    unsigned long long ShortNumber;
    [scanner scanHexLongLong: &ShortNumber];
    NSLog(@"ShortNumber = %llu", ShortNumber);
    return  (int)ShortNumber;
    //    return [self HexToDec:DataStr];
}

@end
