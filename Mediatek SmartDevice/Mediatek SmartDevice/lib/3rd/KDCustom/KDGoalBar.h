
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "KDGoalBarPercentLayer.h"


@interface KDGoalBar : UIView {
    UIImage * thumb;
    
    KDGoalBarPercentLayer *percentLayer;
    CALayer *thumbLayer;
    int pertarget;
          
}

@property (nonatomic, strong) UILabel *percentLabel;
@property (nonatomic, strong) UILabel *targetLabel;
@property (nonatomic, strong) UILabel *calLabel;
@property (nonatomic, strong) UIImageView *stepImg;
@property BOOL isToGetSqlite;

- (void)setPercent:(int)percent setData:(int)data animated:(BOOL)animated;
- (void)toGetSqlite;

@end
