
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "KDGoalBarPercentLayerTwo.h"


@interface KDGoalBarTwo : UIView {
    UIImage * thumb;
    
    KDGoalBarPercentLayerTwo *percentLayer;
    CALayer *thumbLayer;
          
}

@property (nonatomic, strong) UILabel *percentLabel;
@property (nonatomic, strong) UILabel *targetLabel;
@property (nonatomic, strong) UILabel *calLabel;

- (void)setPercent:(int)percent setData:(int)data animated:(BOOL)animated;


@end
