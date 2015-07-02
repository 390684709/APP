
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "KDGoalBarPercentLayerSleep.h"


@interface KDGoalBarSleep : UIView {
    UIImage * thumb;
    
    KDGoalBarPercentLayerSleep *percentLayer;
    CALayer *thumbLayer;
          
}

@property (nonatomic, strong) UILabel *percentLabel;
@property (nonatomic, strong) UILabel *targetLabel;
@property (nonatomic, strong) UILabel *calLabel;
@property (nonatomic, strong) UIImageView *calImg;

- (void)setPercent:(int)percent setData:(int)data setDeepData:(int)deepdata animated:(BOOL)animated;


@end
