
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "KDGoalBarPercentLayerThree.h"


@interface KDGoalBarThree : UIView {
    UIImage * thumb;
    
    KDGoalBarPercentLayerThree *percentLayer;
    CALayer *thumbLayer;
          
}

@property (nonatomic, strong) UILabel *percentLabel;
@property (nonatomic, strong) UILabel *targetLabel;
@property (nonatomic, strong) UILabel *calLabel;
@property (nonatomic, strong) UIImageView *calImg;

- (void)setPercent:(int)percent setData:(int)data animated:(BOOL)animated;


@end
