
#import "KDGoalBarThree.h"

@implementation KDGoalBarThree
@synthesize    percentLabel;
@synthesize    targetLabel;
@synthesize    calLabel;

#pragma Init & Setup
- (id)init
{
	if ((self = [super init]))
	{
		[self setup];
	}
    
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self setup];
	}
    
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self setup];
	}
    
	return self;
}


-(void)layoutSubviews {
    CGRect frame = self.frame;
    int percent = percentLayer.percent * 100;
    int perdata = percentLayer.bleData;
    [percentLabel setText:[NSString stringWithFormat:@"%dcal",perdata]];
    NSString * target=@"目标";
    NSString * haddone=@"已完成";
//    if(!zhSP){
//        target=@"target";
//        haddone=@"completed";
//    }
//    [targetLabel setText:[NSString stringWithFormat:@"%@: %i%", target,2080]];
    [calLabel setText:[NSString stringWithFormat:@"%@: %i%%", haddone,percent]];
    CGRect labeltFrame = targetLabel.frame;
    labeltFrame.origin.x = frame.size.width / 2 - targetLabel.frame.size.width / 2;
    labeltFrame.origin.y = frame.size.width / 2 - targetLabel.frame.size.height / 1.5;
    targetLabel.frame = labeltFrame;
    CGRect labelcFrame = calLabel.frame;
    labelcFrame.origin.x = frame.size.width / 2 - calLabel.frame.size.width / 2;
    labelcFrame.origin.y = frame.size.width / 2 - calLabel.frame.size.height / 2.8;
    calLabel.frame = labelcFrame;
    CGRect labelFrame = percentLabel.frame;
    labelFrame.origin.x = frame.size.width / 2 - percentLabel.frame.size.width / 2;
    labelFrame.origin.y = frame.size.height / 2 - percentLabel.frame.size.height / 2;
    percentLabel.frame = labelFrame;
    
    [super layoutSubviews];
}

-(void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;

    
    percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125, 125)];
    [percentLabel setFont:[UIFont systemFontOfSize:25]];
    [percentLabel setTextColor:[UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1.0]];
//    [percentLabel setTextColor:[UIColor blackColor]];
    [percentLabel setTextAlignment:UITextAlignmentCenter];
    [percentLabel setBackgroundColor:[UIColor clearColor]];
    percentLabel.adjustsFontSizeToFitWidth = YES;
    percentLabel.minimumFontSize = 10;
    
    targetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125, 125)];
    [targetLabel setFont:[UIFont systemFontOfSize:11]];
    [percentLabel setTextColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]];
//    [targetLabel setTextColor:[UIColor lightGrayColor]];
    [targetLabel setTextAlignment:UITextAlignmentCenter];
    [targetLabel setBackgroundColor:[UIColor clearColor]];
    targetLabel.adjustsFontSizeToFitWidth = YES;
    targetLabel.minimumFontSize = 10;
    
    calLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125, 125)];
    [calLabel setFont:[UIFont systemFontOfSize:11]];
    [percentLabel setTextColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]];
//    [calLabel setTextColor:[UIColor lightGrayColor]];
    [calLabel setTextAlignment:UITextAlignmentCenter];
    [calLabel setBackgroundColor:[UIColor clearColor]];
    calLabel.adjustsFontSizeToFitWidth = YES;
    calLabel.minimumFontSize = 10;
    
    [self addSubview:calLabel];
    [self addSubview:targetLabel];
    [self addSubview:percentLabel];
    
    thumbLayer = [CALayer layer];
    thumbLayer.contentsScale = [UIScreen mainScreen].scale;
    thumbLayer.contents = (id) thumb.CGImage;
    thumbLayer.frame = CGRectMake(self.frame.size.width / 2 - thumb.size.width/2, 0, thumb.size.width, thumb.size.height);
    thumbLayer.hidden = YES;

   
    
    percentLayer = [KDGoalBarPercentLayerThree layer];
    percentLayer.contentsScale = [UIScreen mainScreen].scale;
    percentLayer.percent = 0;
    percentLayer.frame = self.bounds;
    percentLayer.masksToBounds = NO;
    [percentLayer setNeedsDisplay];
    
    [self.layer addSublayer:percentLayer];
    [self.layer addSublayer:thumbLayer];
     
    
}


#pragma mark - Touch Events
- (void)moveThumbToPosition:(CGFloat)angle {
    CGRect rect = thumbLayer.frame;
    NSLog(@"%@",NSStringFromCGRect(rect));
    CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    angle -= (M_PI/2);
    NSLog(@"%f",angle);

    rect.origin.x = center.x + 50 * cosf(angle) - (rect.size.width/2);
    rect.origin.y = center.y + 50 * sinf(angle) - (rect.size.height/2);
    
    NSLog(@"%@",NSStringFromCGRect(rect));

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    thumbLayer.frame = rect;
    
    [CATransaction commit];
}
#pragma mark - Custom Getters/Setters
- (void)setPercent:(int)percent setData:(int)data animated:(BOOL)animated {
    
    CGFloat floatPercent = percent / 100.0;
    floatPercent = MIN(1, MAX(0, floatPercent));
    
    percentLayer.percent = floatPercent;
    percentLayer.bleData = data;
    [self setNeedsLayout];
    [percentLayer setNeedsDisplay];
    
    [self moveThumbToPosition:floatPercent * (2 * M_PI) - (M_PI/2)];
    
}


@end
