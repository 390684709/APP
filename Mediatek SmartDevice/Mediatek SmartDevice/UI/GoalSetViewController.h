//
//  GoalSet.h
//  Mediatek SmartDevice
//
//  Created by Ghero-mac4 on 15/1/20.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoalSetViewController : UIViewController

- (IBAction)backToStep:(UIButton *)sender;
@property (weak ,nonatomic) IBOutlet UITextField *num;
@property (weak ,nonatomic) IBOutlet UITextField *stepLong;
@property (weak ,nonatomic) IBOutlet UITextField *heavy;
@end
