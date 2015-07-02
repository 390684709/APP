//
//  MtkViewController.m
//  Mediatek SmartDevice
//
//  Created by user on 14-8-26.
//  Copyright (c) 2014年 Mediatek. All rights reserved.
//

#import "MtkViewController.h"

@interface MtkViewController ()

@end

@implementation MtkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //once
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"onceLaunched"]) {
        NSMutableArray * HeartRateTime = [[NSMutableArray alloc]initWithObjects:@"6:0",@"7:00",@"03:0",@"06:0",@"0:0",@"07:0",@"05:0",@"05:0",@"07:0",@"0:0", nil];
        NSMutableArray * HeartRate = [[NSMutableArray alloc]initWithObjects:@"68",@"55",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0", nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"onceLaunched"];
        [[NSUserDefaults standardUserDefaults]setInteger:10 forKey:@"isSleepTime"];
        [[NSUserDefaults standardUserDefaults]setInteger:8 forKey:@"isDeepSleepTime"];
        [[NSUserDefaults standardUserDefaults]setObject:HeartRate forKey:@"isHeartRate"];
        [[NSUserDefaults standardUserDefaults]setObject:HeartRateTime forKey:@"isHeartRateTime"];
        
        NSString * Heartstr = @"";
        
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"isHeartRate1"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"isHeartRate2"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"isHeartRate3"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"isHeartRate4"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"isHeartRate5"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"isHeartRate6"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"isHeartRate7"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"isHeartRate8"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"isHeartRate9"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"isHeartRate10"];
        
        [[NSUserDefaults standardUserDefaults]setObject:Heartstr forKey:@"isHeartRateTime1"];
        [[NSUserDefaults standardUserDefaults]setObject:Heartstr forKey:@"isHeartRateTime2"];
        [[NSUserDefaults standardUserDefaults]setObject:Heartstr forKey:@"isHeartRateTime3"];
        [[NSUserDefaults standardUserDefaults]setObject:Heartstr forKey:@"isHeartRateTime4"];
        [[NSUserDefaults standardUserDefaults]setObject:Heartstr forKey:@"isHeartRateTime5"];
        [[NSUserDefaults standardUserDefaults]setObject:Heartstr forKey:@"isHeartRateTime6"];
        [[NSUserDefaults standardUserDefaults]setObject:Heartstr forKey:@"isHeartRateTime7"];
        [[NSUserDefaults standardUserDefaults]setObject:Heartstr forKey:@"isHeartRateTime8"];
        [[NSUserDefaults standardUserDefaults]setObject:Heartstr forKey:@"isHeartRateTime9"];
        [[NSUserDefaults standardUserDefaults]setObject:Heartstr forKey:@"isHeartRateTime10"];
        
        [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"isHeartRateFlag"];
        
        [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"isHardware"];
        
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
