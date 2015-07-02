
#import "KDGoalBar.h"
#import "Utils.h"

@implementation KDGoalBar
@synthesize    percentLabel;
@synthesize    targetLabel;
@synthesize    calLabel;
@synthesize stepImg;

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
    
    int persqlflag;
    
    persqlflag = 0;
    
    if (self.isToGetSqlite) {
        pertarget = 20000;
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *dbPath = [documentPaths objectAtIndex:0];
        NSString *database_path = [dbPath stringByAppendingPathComponent:DBNAME];
        if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
            sqlite3_close(db);
            NSLog(@"数据库打开失败");
        }
        
        NSString *query = [NSString stringWithFormat:@"select * from STEPINFO order by ID desc"];
        sqlite3_stmt * statement;
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                if (persqlflag == 0) {
                    pertarget = sqlite3_column_int(statement,3);
                    persqlflag ++;
                    break;
                }
            }
        }
        sqlite3_close(db);
        [self toNotGetSqlite];
    }
    
    NSString * target=@"目标";
    NSString * haddone=@"步";
    if(!zhSP){
        if (!sen) {
            target=@"Objetivo";
            haddone=@" pasos";
        }else{
        target=@"target";
        haddone=@"step";
        }
    }
    
    [percentLabel setText:[NSString stringWithFormat:@"%d%@",perdata,haddone]];
    
    [targetLabel setText:[NSString stringWithFormat:@"%@: %i%@", target,pertarget,haddone]];
    [calLabel setText:[NSString stringWithFormat:@"%i%%",percent]];
    
    
    
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

    
    stepImg = [[UIImageView alloc] initWithFrame:CGRectMake(90,45, 40, 40)];
    NSString * path = [[NSBundle mainBundle]pathForResource:@"icon_12" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    [stepImg setImage:image];
    
    percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125, 125)];
    [percentLabel setFont:[UIFont systemFontOfSize:20]];
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
    
    [self addSubview:stepImg];
    [self addSubview:calLabel];
    [self addSubview:targetLabel];
    [self addSubview:percentLabel];
    
    thumbLayer = [CALayer layer];
    thumbLayer.contentsScale = [UIScreen mainScreen].scale;
    thumbLayer.contents = (id) thumb.CGImage;
    thumbLayer.frame = CGRectMake(self.frame.size.width / 2 - thumb.size.width/2, 0, thumb.size.width, thumb.size.height);
    thumbLayer.hidden = YES;
   
    percentLayer = [KDGoalBarPercentLayer layer];
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
//    NSLog(@"%@",NSStringFromCGRect(rect));
    CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    angle -= (M_PI/2);
//    NSLog(@"%f",angle);

    rect.origin.x = center.x + 75 * cosf(angle) - (rect.size.width/2);
    rect.origin.y = center.y + 75 * sinf(angle) - (rect.size.height/2);
    
//    NSLog(@"%@",NSStringFromCGRect(rect));

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

-(void)toGetSqlite
{
    self.isToGetSqlite = YES;
}
-(void) toNotGetSqlite
{
    self.isToGetSqlite = NO;
}

@end
