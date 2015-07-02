//
//  TabBarViewController.m
//  Mediatek SmartDevice
//
//  Created by GHero-Daniel on 15/2/9.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()
@property (weak, nonatomic) IBOutlet UITabBarItem *step;

@property (weak, nonatomic) IBOutlet UITabBar *tabbarstep;
@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    if (deBugLog) {
//        UIAlertView * pay = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                       message:[NSString stringWithFormat:@"我是TabBar，摩擦摩擦更时尚"]
//                                                      delegate:nil
//                                             cancelButtonTitle:@"确定"
//                                             otherButtonTitles:nil];
//        [pay show];
//    }
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

@end
