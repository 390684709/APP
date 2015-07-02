//
//  MainTableViewController.m
//  BLEManager
//
//  Created by ken on 14-7-14.
//  Copyright (c) 2014年 com.mediatek. All rights reserved.
//

#import "MainTableViewController.h"
#import "CachedBLEDevice.h"
#import "MTKDeviceParameterRecorder.h"
#import "BackgroundManager.h"
#import "AlertService.h"
#import "CalViewController.h"
#import "LWBLEManager.h"

//NSString *btn_findDevice = NSLocalizedString(@"Find Device", @"Find Device");

@interface MainTableViewController () <CachedBLEDeviceDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mRingingImage;
@property (weak, nonatomic) IBOutlet UILabel *mDeviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mConnectionStateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mSignalImage;
@property (weak, nonatomic) IBOutlet UILabel *mAlertSwitchState;
- (IBAction)findAndConnectAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *mFindButton;
@property (weak, nonatomic) IBOutlet UIButton *mConnectButton;

@property (weak, nonatomic) MTKBleManager* mManager;
@property (weak, nonatomic) CachedBLEDevice *mDevice;
@property BOOL isConnected;
@end

@implementation MainTableViewController

@synthesize mDevice;
@synthesize mManager;

@synthesize mDeviceNameLabel;
@synthesize mConnectionStateLabel;
@synthesize mAlertSwitchState;

@synthesize mConnectButton;
@synthesize mFindButton;

@synthesize mSignalImage;

@synthesize mRingingImage;

//@synthesize mNoSignalImage;
//@synthesize mOneSignalImage;
//@synthesize mThreeSignalImage;
//@synthesize mTwoSignalImage;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[LWBLEManager shared]renewBleServices];//先加载表数据
    mManager = [MTKBleManager sharedInstance];
    mDevice = [CachedBLEDevice defaultInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(didEnterBackgroundNotification:) name: kEnterBackgroundNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(didEnterForegroundNotification:) name: kEnterForegroundNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(didFinishLaunchNotification:) name: kFinishLaunchNotification object: nil];
    
    [mManager updatePxpSetting:mDevice.mDeviceIdentifier alertEnabler:mDevice.mAlertEnabled range:mDevice.mRangeAlertEnabled rangeType:mDevice.mRangeType alertDistance:mDevice.mRangeValue disconnectAlertEnabler:mDevice.mDisconnectEnabled];
    
//    self.isConnected=NO;
//    [self toScanBLE];
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([MTKDeviceParameterRecorder getDeviceParameters].count == 0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}




-(void)viewDidDisappear:(BOOL)animated
{
    [mDevice unregisterAttributeChangedListener:self];
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BleIsConnected" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BleNotConnected" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [mDevice registerAttributeChangedListener:self];
    [self updateUxState];
    self.tableView.scrollEnabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleIsConnected:) name:@"BleIsConnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleNotConnected:) name:@"BleNotConnected" object:nil];
}



#pragma mark - BLE ACTION

-(void)bleIsConnected:(NSNotification *)aNotification
{
    self.isConnected=YES;
}

-(void)bleNotConnected:(NSNotification *)aNotification
{
    self.isConnected=NO;
//    [self toScanBLE];
}

-(void)toScanBLE
{
    if (!self.isConnected) {
        [[LWBLEManager shared]scanTheBlue];
        [NSTimer  scheduledTimerWithTimeInterval:1.0f  target:self  selector:@selector(toScanBLE) userInfo:nil  repeats:NO];
    }else {
        [[LWBLEManager shared]renewBleServices];
    }
}

/********************************************************************************************/
/* update the UX connection state, ringing state, device name state                         */
/********************************************************************************************/
-(void)updateUxState {

    [mDeviceNameLabel setText:mDevice.mDeviceName];
    
    [self updateConnectionStateLabel];
    [self updateFindConnectButtonState];
    [self updateSignalStrength];
    [self updateRingingState];
    if (mDevice != nil)
    {
        if (mDevice.mAlertEnabled)
        {
            mAlertSwitchState.text = NSLocalizedString(@"On", @"On");
        }
        else
        {
            mAlertSwitchState.text = NSLocalizedString(@"Off", @"Off");
        }
    }
}

/********************************************************************************************/
/* update the device signal strength indentifier                                            */
/********************************************************************************************/
-(void)updateSignalStrength
{
    NSLog(@"[MainTableViewController][updateSignalStrength] device connection state : %d", mDevice.mConnectionState);
    NSLog(@"[MainTableViewController][updateSignalStrength] device current signal strength: %d", mDevice.mCurrentSignalStrength);
    if (mDevice.mConnectionState == CONNECTION_STATE_DISCONNECTED) {
        [mSignalImage setHidden:YES];
        NSLog(@"[MainTableViewController][updateSignalStrength] device connection state is disconnected, hide the signal");
        return;
    }
    if (mDevice.mConnectionState == CONNECTION_STATE_CONNECTED) {
        [mSignalImage setHidden:NO];
        UIImage* image = nil;
        switch(mDevice.mCurrentSignalStrength)
        {
            case SIGNAL_STRENGTH_NULL:
//                NSString * path =;
//                UIImage *image = [
//                [stepImg setImage:image];
                image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle]pathForResource:@"ic_signal_0" ofType:@"png"]];
                break;
            
            case SIGNAL_STRENGTH_ONE:
                image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle]pathForResource:@"ic_signal_1" ofType:@"png"]];
                break;
            
            case SIGNAL_STRENGTH_TWO:
                image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle]pathForResource:@"ic_signal_2" ofType:@"png"]];
                break;
            
            case SIGNAL_STRENGTH_THREE:
                image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle]pathForResource:@"ic_signal_3" ofType:@"png"]];
                break;
                
            case SIGNAL_STRENGTH_FOUR:
                image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle]pathForResource:@"ic_signal_4" ofType:@"png"]];
                break;
                
            default:
                image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle]pathForResource:@"ic_signal_0" ofType:@"png"]];
                break;
        }
        if (image != nil)
        {
            [mSignalImage setImage:image];
        }
    }
}

/********************************************************************************************/
/* update find & connect button state                                                       */
/* if the device is connected, find button is enabled & visible, hide the connect button    */
/* if the device is connecting or disconnecting, find button is invisible, connect button   */
/* visible, but un-clickable                                                                */
/* if the device is disconnected, the find button invisible, the connect button is clickable*/
/* and visible                                                                              */
/********************************************************************************************/
-(void)updateFindConnectButtonState
{
    [mFindButton setHidden:true];
    [mConnectButton setHidden:true];
    if (mDevice.mConnectionState == CONNECTION_STATE_CONNECTED)
    {
        [mFindButton setHidden:false];
        [mFindButton setEnabled:true];
        NSLog(@"[MainTableViewController] [updateFindConnectButtonState] findingState : %d, alert state : %d", mDevice.mFindingState, mDevice.mAlertState);
        if (mDevice.mFindingState == FINDING_STATE_ON || mDevice.mAlertState == ALERT_STATE_ON)
        {
            [mFindButton setTitle:NSLocalizedString(@"Stop", @"Stop") forState:UIControlStateNormal];
        }
        else
        {
            [mFindButton setTitle: NSLocalizedString(@"Find Device", @"Find Device") forState:UIControlStateNormal];
        }
    }
    else if ((mDevice.mConnectionState == CONNECTION_STATE_CONNECTING)
             || (mDevice.mConnectionState == CONNECTION_STATE_DISCONNECTING))
    {
        [mConnectButton setHidden:false];
        [mConnectButton setEnabled:false];
    }
    else if (mDevice.mConnectionState == CONNECTION_STATE_DISCONNECTED)
    {
        [mConnectButton setHidden:false];
        [mConnectButton setEnabled:true];
    }
}

/********************************************************************************************/
/* if the device is finding state, show the finding state action                            */
/********************************************************************************************/
-(void)updateRingingState
{
    if (mDevice.mFindingState == FINDING_STATE_ON || mDevice.mAlertState == ALERT_STATE_ON)
    {
        [mRingingImage setHidden:false];
    }
    else
    {
        [mRingingImage setHidden:true];
    }
}

/********************************************************************************************/
/* update the alert state, which will show a ringing... in the UX                           */
/********************************************************************************************/
//-(void)updateAlertState
//{
//    if (mDevice.mAlertState == ALERT_STATE_ON)
//    {
//        [mRingStateLabel setHidden:false];
//    }
//    else if (mDevice.mAlertState == ALERT_STATE_OFF)
//    {
//        [mRingStateLabel setHidden:true];
//    }
//}

/********************************************************************************************/
/* convert the connection int state to be a string, which will showed in the UX             */
/********************************************************************************************/
-(void)updateConnectionStateLabel
{
    [mConnectionStateLabel setTextColor: [UIColor blackColor]];
    if (mDevice.mConnectionState == CONNECTION_STATE_CONNECTED)
    {
        if (mDevice.mRangeStatus == RANGE_STATUS_OUT_OF_RANGE)
        {
            [mConnectionStateLabel setText: NSLocalizedString(@"Out of range", @"Out of range")];
            [mConnectionStateLabel setTextColor: [UIColor redColor]];
        }
        else if (mDevice.mRangeStatus == RANGE_STATUS_IN_RANGE)
        {
            [mConnectionStateLabel setText: NSLocalizedString(@"In range", @"In range")];
            [mConnectionStateLabel setTextColor: [UIColor redColor]];
        }
        else
        {
            [mConnectionStateLabel setText:NSLocalizedString(@"Connected", @"Connected")];
        }
    }
    else if (mDevice.mConnectionState == CONNECTION_STATE_CONNECTING)
    {
        [mConnectionStateLabel setText: NSLocalizedString(@"Connecting", @"Connecting")];
    }
    else
    {
        [mConnectionStateLabel setText: NSLocalizedString(@"Disconnected", @"Disconnected")];
        [mConnectionStateLabel setTextColor:[UIColor grayColor]];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 2;
    }
    if (section == 1)
    {
        return 1;
    }
    if (section == 2)
    {
        return 1;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 30;
    }
    if (section == 2)
    {
        if (iPhone5 == YES)
        {
            return 231;
        }
        else
        {
            return 145;
        }
    }
    return 20;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/********************************************************************************************/
/* if the device attribute has changed, call this method to notify user                     */
/********************************************************************************************/
-(void)onDeviceAttributeChanged:(int)which
{
    if (which == DEVICE_CONNECTION_STATE_CHANGE
        || which == DEVICE_NAME_CHANGE
        || which == DEVICE_PERIPHERAL_CHANGE
        || which == DEVICE_SIGNAL_STRENGTH_CHANGE
        || which == DEVICE_RANGE_STATE_CHANGE)
    {
        [self updateUxState];
        if (which == DEVICE_CONNECTION_STATE_CHANGE)
        {
//            [self stopTimer];
            [[BackgroundManager sharedInstance] stopConnectTimer];
        }
    }
    else if (which == DEVICE_FINDING_STATE_CHANGE || which == DEVICE_ALERT_STATE_CHANGE)
    {
        [self updateRingingState];
    }
}

/********************************************************************************************/
/* if the device attribute has changed, call this method to notify user                     */
/********************************************************************************************/
- (IBAction)findAndConnectAction:(UIButton *)sender {
    
    if (mDevice.mConnectionState == CONNECTION_STATE_CONNECTED)
    {
        if (mDevice.mFindingState == FINDING_STATE_ON || mDevice.mAlertState == ALERT_STATE_ON)
        {
            if (mDevice.mFindingState == FINDING_STATE_ON)
            {
                BOOL b = [mManager findTarget:0];
                if (b == YES)
                {
                    NSLog(@"[MainTableViewController] [findAndConnectAction] do stop find action");
                    [mDevice setDeviceFindingState:FINDING_STATE_OFF];
                }
                else
                {
                    NSLog(@"[MainTableViewController] [findAndConnectAction] stop action failed");
                }
            }
            if (mDevice.mAlertState == ALERT_STATE_ON)
            {
                NSLog(@"[MainTableViewController] [findAndConnectAction] do send stop remote alert action");
                [mDevice updateAlertState:ALERT_STATE_OFF];
            }
            [self updateFindConnectButtonState];
        }
        else
        {
            BOOL b = [mManager findTarget:2];
            if (b == YES)
            {
                NSLog(@"[MainTableViewController] [findAndConnectAction] do find action");
                [mDevice setDeviceFindingState:FINDING_STATE_ON];
                [self updateFindConnectButtonState];
            }
            else
            {
                NSLog(@"[MainTableViewController] [findAndConnectAction] start find action failed");
            }
        }
    }
    else if (mDevice.mConnectionState == CONNECTION_STATE_DISCONNECTED)
    {
        NSLog(@"[MainTableViewController] [findAndConnectAction] do connect action");
        BOOL b = [[BackgroundManager sharedInstance] connectDevice:[mDevice getDevicePeripheral]];
        if (b == YES) {
            mDevice.mConnectionState = CONNECTION_STATE_CONNECTING;
            [self updateFindConnectButtonState];
        
            [self updateConnectionStateLabel];
        }
    }

}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    NSLog(@"Entered background notification called.");
    [mManager enteredBackground];
}

- (void)didEnterForegroundNotification:(NSNotification*)notification
{
    NSLog(@"Entered foreground notification called.");
    
    [mManager enteredForeground];
}

- (void)didFinishLaunchNotification: (NSNotification *)notification
{
    NSLog(@"did finish launch called.");
    [mManager finishLaunch];
}

@end
