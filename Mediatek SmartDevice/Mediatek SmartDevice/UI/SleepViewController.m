//
//  SleepViewController.m
//  Mediatek SmartDevice
//
//  Created by GHero-Daniel on 15/3/30.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import "SleepViewController.h"
#import "KDGoalBarSleep.h"
#import "LWBLEManager.h"
@interface SleepViewController ()
{
    KDGoalBarSleep *SleepGoalBar;
    
    int perpercent;
    int deeptime;
    int sleeptime;
}
@property BOOL isConnected;
@property (weak, nonatomic) IBOutlet UILabel *SleepQualityLable;
@end

@implementation SleepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isConnected=NO;
    [self toScanBLE];
    [self.navigationItem setTitle:NSLocalizedString(@"Sleep", @"Sleep")];

    SleepGoalBar = [[KDGoalBarSleep alloc]initWithFrame:CGRectMake(43, 120, 250, 250)];
    [self toCircleInit];

    [self toThreeSecond];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputWithNote:) name:@"OutputSleepArrayNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleIsConnected:) name:@"BleIsConnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleNotConnected:) name:@"BleNotConnected" object:nil];
    [self toSetData];
    [[LWBLEManager shared]toGetSleep];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OutputSleepArrayNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BleIsConnected" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BleNotConnected" object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)toCircleInit
{
    [self toSetData];
    [self.view addSubview:SleepGoalBar];
}

-(void)toSetData
{
    sleeptime= (int)[[NSUserDefaults standardUserDefaults]integerForKey:@"isSleepTime"];
    deeptime = (int)[[NSUserDefaults standardUserDefaults]integerForKey:@"isDeepSleepTime"];
    if (sleeptime !=0) {
        perpercent = deeptime*100 / sleeptime;
    }
    else
    {
        perpercent = 0 ;
    }
    
    if(deeptime/60>=4)
    {
        self.SleepQualityLable.text=NSLocalizedString(@"SleepQualityVeryGood", @"SleepQualityVeryGood");
    }
    else if (deeptime/60<2)
    {
        self.SleepQualityLable.text=NSLocalizedString(@"SleepQualityGeneral", @"SleepQualityGeneral");
    }
    else
    {
        self.SleepQualityLable.text=NSLocalizedString(@"SleepQualityGood", @"SleepQualityGood");
    }
        
    [SleepGoalBar setPercent:perpercent setData:sleeptime setDeepData:deeptime animated:NO];
}


-(void)toThreeSecond
{
    [NSTimer  scheduledTimerWithTimeInterval:3.0f  target:self  selector:@selector(toThreeSecond) userInfo:nil  repeats:NO];
    [self toSetData];
}

#pragma mark - BLE ACTION

-(void)bleIsConnected:(NSNotification *)aNotification
{
    self.isConnected=YES;
    [[LWBLEManager shared]toGetSleep];
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
    }else {
        [[LWBLEManager shared]renewBleServices];//避免每次搜索都插数据库
    }
}

#pragma mark - BLE DATA

- (void)outputWithNote:(NSNotification *)aNotification
{
    NSData *data = [aNotification object];
    NSLog(@"data%@",data);
    
    [self toSetData];
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
}

@end
