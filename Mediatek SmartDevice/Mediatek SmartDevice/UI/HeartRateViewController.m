//
//  HeartRateViewController.m
//  Mediatek SmartDevice
//
//  Created by GHero-Daniel on 15/3/30.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import "HeartRateViewController.h"
#import "LWBLEManager.h"
#import "NALLabelsMatrix.h"

#import "UUChart.h"


@interface HeartRateViewController ()<UUChartDataSource>
{
//    NSMutableArray * HeartRatearr;
//    NSMutableArray * HeartRateTimearr;
    int isHeartRate1;
    int isHeartRate2;
    int isHeartRate3;
    int isHeartRate4;
    int isHeartRate5;
    int isHeartRate6;
    int isHeartRate7;
    int isHeartRate8;
    int isHeartRate9;
    int isHeartRate10;
    
    NSString * isHeartRateTime1;
    NSString * isHeartRateTime2;
    NSString * isHeartRateTime3;
    NSString * isHeartRateTime4;
    NSString * isHeartRateTime5;
    NSString * isHeartRateTime6;
    NSString * isHeartRateTime7;
    NSString * isHeartRateTime8;
    NSString * isHeartRateTime9;
    NSString * isHeartRateTime10;
    NALLabelsMatrix* matrix;
    UUChart *chartView;
    
    NSArray *tempChartarr;
}

@property BOOL isConnected;
@property (weak, nonatomic) IBOutlet UIView *myView;
@end

@implementation HeartRateViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationItem setTitle:NSLocalizedString(@"HeartRate", @"HeartRate")];
    
    self.isConnected=NO;
    [self toScanBLE];
    [self toGetUserDefaults];
    [self toInitMatrix];
    [self toInitChart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputWithNote:) name:@"OutputHeartRateArrayNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleIsConnected:) name:@"BleIsConnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleNotConnected:) name:@"BleNotConnected" object:nil];
    [[LWBLEManager shared]toGetHeartRate];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OutputHeartRateArrayNotification" object:nil];
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

#pragma mark - Chart

-(void)toInitChart
{
    

    tempChartarr = @[[NSString stringWithFormat:@"%d",isHeartRate1],[NSString stringWithFormat:@"%d",isHeartRate2],[NSString stringWithFormat:@"%d",isHeartRate3],[NSString stringWithFormat:@"%d",isHeartRate4 ], [NSString stringWithFormat:@"%d", isHeartRate5] , [NSString stringWithFormat:@"%d", isHeartRate6 ], [NSString stringWithFormat:@"%d", isHeartRate7] , [NSString stringWithFormat:@"%d", isHeartRate8] ,[NSString stringWithFormat:@"%d",isHeartRate9 ], [NSString stringWithFormat:@"%d",isHeartRate10]];
    if (chartView) {
        [chartView removeFromSuperview];
        chartView = nil;
    }
    chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(0, 0, 260, 230)
                                              withSource:self
                                               withStyle:UUChartLineStyle];
    [chartView showInView:self.myView];
}


- (NSArray *)getXTitles:(int)num
{
    NSMutableArray *xTitles = [NSMutableArray array];
    for (int i=1; i<11; i++) {
        NSString * str = [NSString stringWithFormat:@"%d",i];
        [xTitles addObject:str];
    }
    return xTitles;
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    
    return [self getXTitles:2];
}
//数值多重数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
//    int isHeartRateFlag =(int)[[NSUserDefaults standardUserDefaults]integerForKey:@"isHeartRateFlag"];
//    return @[[tempChartarr subarrayWithRange:NSMakeRange(0, isHeartRateFlag)]];
    return @[tempChartarr];
}

#pragma mark - @optional
//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UULightBlue,UURed,UUGreen];
}
//显示数值范围
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    return CGRangeMake(200, 0);
}

#pragma mark 折线图专享功能
//标记数值区域
- (CGRange)UUChartMarkRangeInLineChart:(UUChart *)chart
{
    return CGRangeMake(100, 60);
}

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

//判断显示最大最小值
- (BOOL)UUChart:(UUChart *)chart ShowMaxMinAtIndex:(NSInteger)index
{
    return YES;
}


-(void)toGetUserDefaults
{
    isHeartRate1= (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"isHeartRate1"];
    isHeartRate2= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate2"];
    isHeartRate3= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate3"];
    isHeartRate4= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate4"];
    isHeartRate5= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate5"];
    isHeartRate6= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate6"];
    isHeartRate7= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate7"];
    isHeartRate8= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate8"];
    isHeartRate9= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate9"];
    isHeartRate10= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate10"];
    
    isHeartRateTime1=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime1"];
    isHeartRateTime2=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime2"];
    isHeartRateTime3=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime3"];
    isHeartRateTime4=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime4"];
    isHeartRateTime5=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime5"];
    isHeartRateTime6=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime6"];
    isHeartRateTime7=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime7"];
    isHeartRateTime8=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime8"];
    isHeartRateTime9=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime9"];
    isHeartRateTime10=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime10"];
}

-(void)toInitMatrix
{
    if (matrix) {
        [matrix removeFromSuperview];
        matrix = nil;
    }
    if(h480)
    {
        matrix = [[NALLabelsMatrix alloc] initWithFrame:CGRectMake(5, 340, 320, 60) andColumnsWidths:[[NSArray alloc] initWithObjects:@30,@29,@29,@29,@29,@29,@29,@29,@29,@29,@29, nil]];
    }
    else
    {
        matrix = [[NALLabelsMatrix alloc] initWithFrame:CGRectMake(5, 380, 320, 60) andColumnsWidths:[[NSArray alloc] initWithObjects:@30,@29,@29,@29,@29,@29,@29,@29,@29,@29,@29, nil]];
    }
    [matrix addRecord:[[NSArray alloc] initWithObjects:NSLocalizedString(@"Times", @"Times"), @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil]];
    [matrix addRecord:[[NSArray alloc] initWithObjects:NSLocalizedString(@"Time", @"Time"), isHeartRateTime1, isHeartRateTime2,  isHeartRateTime3,isHeartRateTime4,isHeartRateTime5,isHeartRateTime6,isHeartRateTime7,isHeartRateTime8,isHeartRateTime9,isHeartRateTime10, nil]];
    [matrix addRecord:[[NSArray alloc] initWithObjects:NSLocalizedString(@"BMP", @"BMP"),[NSString stringWithFormat:@"%d",isHeartRate1],[NSString stringWithFormat:@"%d",isHeartRate2],[NSString stringWithFormat:@"%d",isHeartRate3],[NSString stringWithFormat:@"%d",isHeartRate4 ], [NSString stringWithFormat:@"%d", isHeartRate5] , [NSString stringWithFormat:@"%d", isHeartRate6 ], [NSString stringWithFormat:@"%d", isHeartRate7] , [NSString stringWithFormat:@"%d", isHeartRate8] ,[NSString stringWithFormat:@"%d",isHeartRate9 ], [NSString stringWithFormat:@"%d",isHeartRate10], nil ]];
    [self.view addSubview:matrix];
}

#pragma mark - BLE ACTION

-(void)bleIsConnected:(NSNotification *)aNotification
{
    self.isConnected=YES;
}

-(void)bleNotConnected:(NSNotification *)aNotification
{
    self.isConnected=NO;
}

-(void)toScanBLE
{
    if (!self.isConnected) {
        [[LWBLEManager shared]scanTheBlue];
        [NSTimer  scheduledTimerWithTimeInterval:1.0f  target:self  selector:@selector(toScanBLE) userInfo:nil  repeats:NO];
    }else {
        [[LWBLEManager shared]renewBleServices];
    }
}

#pragma mark - BLE DATA

- (void)outputWithNote:(NSNotification *)aNotification
{
    NSData *data = [aNotification object];
    NSLog(@"data%@",data);
    
    [self toGetUserDefaults];
    [self toInitChart];
    [self toInitMatrix];
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
