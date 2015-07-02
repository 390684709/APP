//
//  GoalSet.m
//  Mediatek SmartDevice
//
//  Created by Ghero-mac4 on 15/1/20.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import "GoalSetViewController.h"
#import "CalViewController.h"
#import "MtkAppDelegate.h"
@interface GoalSetViewController ()

@end

@implementation GoalSetViewController
//@synthesize *num;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    MtkAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.temp = _num;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backToStep:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
