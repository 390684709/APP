//
//  WXJBlueCenter.m
//  blueCenterDemo
//
//  Created by Logan Wang on 13-12-13.
//  Copyright (c) 2013年 __fb__. All rights reserved.
//

#import "LWBLEManager.h"
#import "Utils.h"
#import "MtkAppDelegate.h"
int bletimes;
int bletimeslian;
int bletimesduan;

@implementation LWBLEManager
@synthesize centralManager        = _centralManager;
@synthesize dicDiscoverBlues      = _dicDiscoverBlues;
@synthesize bConnectOnlyOne       = _bConnectOnlyOne;
@synthesize discoverPer           = _discoverPer;
@synthesize arrNotifyUUID         = _arrNotifyUUID;
@synthesize nScanTimeOut          = _nScanTimeOut;
@synthesize bListenRSSI           = _bListenRSSI;
@synthesize nListenInterval       = _nListenInterval;
@synthesize discoverCallback      = _discoverCallback;
@synthesize bAutoConn             = _bAutoConn;
@synthesize stepchara             =_stepchara;
@synthesize sleepchara            =_sleepchara;
@synthesize heartratechara        =_heartratechara;
//@synthesize isGetStep;



+ (LWBLEManager *)sharedOnlyOne:(bool)connectOnlyOne compeletedHandler:(void (^)())compeletedHander
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        [_sharedObject initData:connectOnlyOne];
    });
    return _sharedObject;
}

+ (LWBLEManager *)shared
{
    return [LWBLEManager sharedOnlyOne:true compeletedHandler:^{}];
}

- (void)initData:(bool)onlyOne
{
    _centralManager   = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _dicDiscoverBlues = [[NSMutableDictionary alloc] init];
    _arrNotifyUUID    = [[NSMutableArray alloc] initWithCapacity:1];
    _bConnectOnlyOne  = onlyOne;
    _bListenRSSI      = false;
    _bScaning         = false;
    _bInited          = false;
    _nListenInterval  = 3;
    _discoverCallback = nil;
    _bAutoConn        = true;
    self.isGetStep    = NO;
    self.isGetBLECentralStateOn = YES;
    bletimes = 0;
    bletimeslian = 0;
    bletimesduan = 0;
}

- (void)scanTheBlue
{
    if (self.discoverPer.state != CBPeripheralStateConnected) {
        self.isGetHardWearVersion = NO;
        _bScaning = true;
        self.isGetStepOne    = YES;
        NSMutableArray *services = [NSMutableArray array];
         MtkAppDelegate *delegate=(MtkAppDelegate*)[[UIApplication sharedApplication]delegate];
        for (int i=0;i<[delegate.bleServices count];i++) {
            [services addObject:[delegate.bleServices objectAtIndex:i]];
        }
//        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//        NSString *dbPath = [documentPaths objectAtIndex:0];
//        NSString *database_path = [dbPath stringByAppendingPathComponent:DBNAME];
//        if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
//            sqlite3_close(db);
//            NSLog(@"数据库打开失败");
//        }
//        NSString *query = [NSString stringWithFormat:@"select ZDEVICE_IDENTIFIER from ZDEVICEINFO"];
//        sqlite3_stmt * statement;
//        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
//            while (sqlite3_step(statement) == SQLITE_ROW) {
//                char *temUUID=(char*)sqlite3_column_text(statement, 0);
//                [services addObject:[CBUUID UUIDWithString:[[NSString alloc]initWithUTF8String:temUUID]]];
//            }
//        }
        if([services count] ==0) {
//            [_centralManager scanForPeripheralsWithServices:nil options:nil];
        }
        else
        {
            [services addObject:[CBUUID UUIDWithString:@"00AABBA1-0000-1000-8000-00805F9B34FB"]];
            _knownPeripherals = [_centralManager retrieveConnectedPeripheralsWithServices:services];
            if ([_knownPeripherals count] !=0) {
                [self connectThePer:[_knownPeripherals objectAtIndex:0]];
            }
        }
        
    }
}

-(void) renewBleServices
{
    MtkAppDelegate *delegate=(MtkAppDelegate*)[[UIApplication sharedApplication]delegate];
    if(delegate.bleServices == nil) {
        delegate.bleServices = [NSMutableArray array];
    }else {
        if([delegate.bleServices count] != 0) {
            [delegate.bleServices removeAllObjects];
        }
    }
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *dbPath = [documentPaths objectAtIndex:0];
    NSString *database_path = [dbPath stringByAppendingPathComponent:DBNAME];
    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"数据库打开失败");
    }
    NSString *query = [NSString stringWithFormat:@"select ZDEVICE_IDENTIFIER from ZDEVICEINFO"];
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *temUUID=(char*)sqlite3_column_text(statement, 0);
            [delegate.bleServices addObject:[CBUUID UUIDWithString:[[NSString alloc]initWithUTF8String:temUUID]]];
        }
    }
    sqlite3_close(db);
}

- (void)stopScan
{
//    if (_bScaning) {
//        _bScaning = false;
//        [_centralManager stopScan];
//    }
}

- (void)connectPer:(NSString *)UUID
{
    CBPeripheral *per = [_dicDiscoverBlues objectForKey:UUID];
    if (self.discoverPer.state != CBPeripheralStateConnected) {
        [_centralManager connectPeripheral:per options:nil];
    }
}

- (void)cancelPerConnection
{
    if (_bConnectOnlyOne) {
        if (self.discoverPer.state != CBPeripheralStateConnected) {
            return;
        }
        [_centralManager cancelPeripheralConnection:_discoverPer];
        [self cleanUpWithWithPer:_discoverPer];
    }
}

- (void)readValue:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per
{
    CBService *ser= [LWBLEManager findServiceWithUUID:serviceUUID per:per];
    if (!ser) {
        return;
    }
    CBCharacteristic *chara = [LWBLEManager findCharacteristicFromUUID:characteristicUUID service:ser];
    if (!chara) {
        return;
    }
    [per readValueForCharacteristic:chara];
}


-(void)toThreeSecond
{
    [NSTimer  scheduledTimerWithTimeInterval:1.0f  target:self  selector:@selector(threeSecond) userInfo:nil  repeats:NO];
}

-(void)threeSecond
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ToSetSqlite" object:nil];
}

- (void)writeValue:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per data:(NSData *)data
{
    CBService *service = [LWBLEManager findServiceWithUUID:serviceUUID per:per];
    if (!service) {
        return;
    }
    CBCharacteristic *chara = [LWBLEManager findCharacteristicFromUUID:characteristicUUID service:service];
    if (!chara) {
        return;
    }
    [per writeValue:data forCharacteristic:chara type:CBCharacteristicWriteWithResponse];
}

- (void)writeValueWithoutResponse:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per data:(NSData *)data
{
    CBService *service = [LWBLEManager findServiceWithUUID:serviceUUID per:per];
    if (!service) {
        return;
    }
    CBCharacteristic *chara = [LWBLEManager findCharacteristicFromUUID:characteristicUUID service:service];
    if (!chara) {
        return;
    }
    [per writeValue:data forCharacteristic:chara type:CBCharacteristicWriteWithoutResponse];
}


- (void)notify:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per on:(bool)on
{
    CBService *ser = [LWBLEManager findServiceWithUUID:serviceUUID per:per];
    if (!ser) {
        return;
    }
    CBCharacteristic *chara = [LWBLEManager findCharacteristicFromUUID:characteristicUUID service:ser];
    if (!chara) {
        return;
    }
    [per setNotifyValue:on forCharacteristic:chara];
}

- (void)connectThePer:(CBPeripheral *)per
{
    [_centralManager connectPeripheral:per options:nil];
}


- (void)cleanUpWithWithPer:(CBPeripheral *)per
{
    
    if (self.discoverPer.state != CBPeripheralStateConnected) {
        return;
    }
    if (per.services != nil) {
        for (CBService *service in per.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *charc in service.characteristics) {
                    if (charc.isNotifying) {
                        [per setNotifyValue:NO forCharacteristic:charc];
                        return;
                    }
                }
            }
        }
    }
    [self stopGetStep];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (!central) {
        central = self.centralManager;
    }
    if (central.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"蓝牙开了");
        self.isGetBLECentralStateOn = YES;
    }
    else
    {
        self.isGetBLECentralStateOn = NO;
        self.isGetHardWearVersion   = NO;
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered \"%@\" RSSI: %@  UUID: %@", peripheral.name, RSSI,peripheral.identifier);
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    if (_bConnectOnlyOne) {
        self.discoverPer = peripheral;
    }
//    [peripheral discoverServices:nil];
    [self toDiscoverServers];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BleIsConnected" object:nil];
    if (deBugLog) {
        bletimeslian++;
        self.pay = [[UIAlertView alloc] initWithTitle:@"提示"
                                              message:[NSString stringWithFormat:@"连%d辣",bletimeslian]
                                             delegate:nil
                                    cancelButtonTitle:@"确定"
                                    otherButtonTitles:nil];
        [self.pay show];
        NSLog(@"连%d",bletimeslian);
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.isGetHardWearVersion   = NO;
    NSLog(@"连失败断");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BleNotConnected" object:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.isGetHardWearVersion   = NO;
    NSLog(@"连后断");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BleNotConnected" object:nil];
    if (deBugLog) {
        bletimesduan++;
        self.pay = [[UIAlertView alloc] initWithTitle:@"提示"
                                              message:[NSString stringWithFormat:@"断%d辣",bletimesduan]
                                             delegate:nil
                                    cancelButtonTitle:@"确定"
                                    otherButtonTitles:nil];
        [self.pay show];
        NSLog(@"断%d",bletimesduan);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        [self cleanUpWithWithPer:peripheral];
        return;
    }
    peripheral.delegate = self;
    self.discoverPer = peripheral;
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        [self cleanUpWithWithPer:peripheral];
        return;
    }
    peripheral.delegate = self;
    self.discoverPer = peripheral;
    int n = 0;
    for (CBCharacteristic *chara in service.characteristics) {
        NSLog(@"UUID%@",[LWBLEManager CBUUIDToString:chara.UUID]);
        if ([[LWBLEManager CBUUIDToString:chara.UUID] isEqual:@"0000fb20-0000-1000-8000-00805f9b34fb" ]) {
            self.stepchara = chara;
            if(self.isGetStep&&self.isGetStepOne)
            {
                [self toGetStep];
            }
        }
        else if([[LWBLEManager CBUUIDToString:chara.UUID] isEqual:@"0000fb50-0000-1000-8000-00805f9b34fb" ])
        {
            self.sleepchara = chara;
            [self toGetSleep];
        }
        else if([[LWBLEManager CBUUIDToString:chara.UUID] isEqual:@"0000fb30-0000-1000-8000-00805f9b34fb" ])
        {
            self.heartratechara = chara ;
            NSLog(@"I Get Hardware Version!");
            self.isGetHardWearVersion =YES;
            [[NSUserDefaults standardUserDefaults]setInteger:1 forKey:@"isHardware"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"toGetHardwareVersion" object:nil];
            [self toGetHeartRate];
        }
        n++;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"%@",characteristic);
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData *data = [NSData dataWithData:characteristic.value];
    NSLog(@"datainBLE%@",data);
    if (data.length == 15)
    {
//        NSMutableArray * HeartRateTemp=[NSMutableArray alloc];
//        NSMutableArray * HeartRateTimeTemp=[NSMutableArray alloc];
        int isHeartRate1;
        int isHeartRate2;
        int isHeartRate3;
        int isHeartRate4;
        int isHeartRate5;
        int isHeartRate6;
        int isHeartRate7;
        int isHeartRate8;
        int isHeartRate9;
        int isHeartRate10;
        
        NSString * isHeartRateTime1;
        NSString * isHeartRateTime2;
        NSString * isHeartRateTime3;
        NSString * isHeartRateTime4;
        NSString * isHeartRateTime5;
        NSString * isHeartRateTime6;
        NSString * isHeartRateTime7;
        NSString * isHeartRateTime8;
        NSString * isHeartRateTime9;
        NSString * isHeartRateTime10;
        
        NSString * firstStr = [NSString stringWithFormat:@"%@", [data subdataWithRange:NSMakeRange(0,4)]];
        NSString * middleHourStr   = [NSString stringWithFormat:@"%@", [data subdataWithRange:NSMakeRange(8,1)]];
        NSString * middleMinStr   = [NSString stringWithFormat:@"%@", [data subdataWithRange:NSMakeRange(9,1)]];
        NSString * lastStr  = [NSString stringWithFormat:@"%@", [data subdataWithRange:NSMakeRange(12,3)]];
        
//        HeartRateTemp= [[NSUserDefaults standardUserDefaults]objectForKey:@"isHeartRate"];
//        HeartRateTimeTemp= [[NSUserDefaults standardUserDefaults]objectForKey:@"isHeartRateTime"];
        
        if ([lastStr isEqualToString:@"<454f4d>"]) {
            int isHeartRateFlag =(int)[[NSUserDefaults standardUserDefaults]integerForKey:@"isHeartRateFlag"];
            if (isHeartRateFlag < 1) {
                isHeartRateFlag ++ ;
//                [HeartRateTemp removeAllObjects];
//                [HeartRateTimeTemp removeAllObjects];
                
//                for (int i=0; i<10; i++) {
//                    [HeartRateTemp addObject:[NSString stringWithFormat:@"%d",[self ToTrueShortNumber:firstStr]]];
//                    [HeartRateTimeTemp addObject:[NSString stringWithFormat:@"%d:%d",[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]]];
                
                isHeartRate1 =[self ToTrueShortNumber:firstStr];
                isHeartRate2 = [self ToTrueShortNumber:firstStr];
                isHeartRate3 = [self ToTrueShortNumber:firstStr];
                isHeartRate4 = [self ToTrueShortNumber:firstStr];
                isHeartRate5 = [self ToTrueShortNumber:firstStr];
                isHeartRate6 = [self ToTrueShortNumber:firstStr];
                isHeartRate7 = [self ToTrueShortNumber:firstStr];
                isHeartRate8 = [self ToTrueShortNumber:firstStr];
                isHeartRate9 = [self ToTrueShortNumber:firstStr];
                isHeartRate10 = [self ToTrueShortNumber:firstStr];
                
                isHeartRateTime1 = [NSString stringWithFormat:@"%d:%d",[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]];
                isHeartRateTime2 = [NSString stringWithFormat:@"%d:%d",[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]];
                isHeartRateTime3 = [NSString stringWithFormat:@"%d:%d",[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]];
                isHeartRateTime4 = [NSString stringWithFormat:@"%d:%d",[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]];
                isHeartRateTime5 = [NSString stringWithFormat:@"%d:%d",[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]];
                isHeartRateTime6 = [NSString stringWithFormat:@"%d:%d",[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]];
                isHeartRateTime7 = [NSString stringWithFormat:@"%d:%d",[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]];
                isHeartRateTime8 = [NSString stringWithFormat:@"%d:%d",[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]];
                isHeartRateTime9 = [NSString stringWithFormat:@"%d:%d",[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]];
                isHeartRateTime10 = [NSString stringWithFormat:@"%d:%d",[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]];
                             
                
                if (deBugLog) {
                    self.pay = [[UIAlertView alloc] initWithTitle:@"1"
                                                          message:[NSString stringWithFormat:@"获取%d,%d:%d",[self ToTrueShortNumber:firstStr],[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]]
                                                         delegate:nil
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil];
                    [self.pay show];
                    [NSTimer scheduledTimerWithTimeInterval:3.0f  target:self  selector:@selector(stopStep) userInfo:nil  repeats:NO];
                }
            }
            else
            {
//                [HeartRateTemp removeObjectAtIndex:0];
//                [HeartRateTemp addObject:[NSString stringWithFormat:@"%d",[self ToTrueShortNumber:firstStr]]];
//                [HeartRateTimeTemp removeObjectAtIndex:0];
//                [HeartRateTimeTemp addObject:[NSString stringWithFormat:@"%d:%d",[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]]];
                
                
                
                isHeartRate1= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate1"];
                isHeartRate2= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate2"];
                isHeartRate3= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate3"];
                isHeartRate4= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate4"];
                isHeartRate5= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate5"];
                isHeartRate6= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate6"];
                isHeartRate7= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate7"];
                isHeartRate8= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate8"];
                isHeartRate9= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate9"];
                isHeartRate10= (int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"isHeartRate10"];
                
                isHeartRateTime1=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime1"];
                isHeartRateTime2=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime2"];
                isHeartRateTime3=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime3"];
                isHeartRateTime4=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime4"];
                isHeartRateTime5=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime5"];
                isHeartRateTime6=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime6"];
                isHeartRateTime7=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime7"];
                isHeartRateTime8=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime8"];
                isHeartRateTime9=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime9"];
                isHeartRateTime10=[[NSUserDefaults standardUserDefaults]stringForKey:@"isHeartRateTime10"];
                
                isHeartRate1 = isHeartRate2;
                isHeartRate2 = isHeartRate3;
                isHeartRate3 = isHeartRate4;
                isHeartRate4 = isHeartRate5;
                isHeartRate5 = isHeartRate6;
                isHeartRate6 = isHeartRate7;
                isHeartRate7 = isHeartRate8;
                isHeartRate8 = isHeartRate9;
                isHeartRate9 = isHeartRate10;
                isHeartRate10 = [self ToTrueShortNumber:firstStr];
                
                isHeartRateTime1 = isHeartRateTime2;
                isHeartRateTime2 = isHeartRateTime3;
                isHeartRateTime3 = isHeartRateTime4;
                isHeartRateTime4 = isHeartRateTime5;
                isHeartRateTime5 = isHeartRateTime6;
                isHeartRateTime6 = isHeartRateTime7;
                isHeartRateTime7 = isHeartRateTime8;
                isHeartRateTime8 = isHeartRateTime9;
                isHeartRateTime9 = isHeartRateTime10;
                isHeartRateTime10 = [NSString stringWithFormat:@"%d:%d",[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]];
                
                
                

                
                
                if (deBugLog) {
                    self.pay = [[UIAlertView alloc] initWithTitle:@"2"
                                                          message:[NSString stringWithFormat:@"获取%d,%d:%d",[self ToTrueShortNumber:firstStr],[self ToTrueShortNumber:middleHourStr],[self ToTrueShortNumber:middleMinStr]]
                                                         delegate:nil
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil];
                    [self.pay show];
                    [NSTimer scheduledTimerWithTimeInterval:3.0f  target:self  selector:@selector(stopStep) userInfo:nil  repeats:NO];
                }
            }
            
//            [[NSUserDefaults standardUserDefaults]setObject:HeartRateTemp forKey:@"isHeartRate"];
//            [[NSUserDefaults standardUserDefaults]setObject:HeartRateTimeTemp forKey:@"isHeartRateTime"];
            
            [[NSUserDefaults standardUserDefaults]setInteger:isHeartRate1 forKey:@"isHeartRate1"];
            [[NSUserDefaults standardUserDefaults]setInteger:isHeartRate2 forKey:@"isHeartRate2"];
            [[NSUserDefaults standardUserDefaults]setInteger:isHeartRate3 forKey:@"isHeartRate3"];
            [[NSUserDefaults standardUserDefaults]setInteger:isHeartRate4 forKey:@"isHeartRate4"];
            [[NSUserDefaults standardUserDefaults]setInteger:isHeartRate5 forKey:@"isHeartRate5"];
            [[NSUserDefaults standardUserDefaults]setInteger:isHeartRate6 forKey:@"isHeartRate6"];
            [[NSUserDefaults standardUserDefaults]setInteger:isHeartRate7 forKey:@"isHeartRate7"];
            [[NSUserDefaults standardUserDefaults]setInteger:isHeartRate8 forKey:@"isHeartRate8"];
            [[NSUserDefaults standardUserDefaults]setInteger:isHeartRate9 forKey:@"isHeartRate9"];
            [[NSUserDefaults standardUserDefaults]setInteger:isHeartRate10 forKey:@"isHeartRate10"];
            
            [[NSUserDefaults standardUserDefaults]setObject:isHeartRateTime1 forKey:@"isHeartRateTime1"];
            [[NSUserDefaults standardUserDefaults]setObject:isHeartRateTime2 forKey:@"isHeartRateTime2"];
            [[NSUserDefaults standardUserDefaults]setObject:isHeartRateTime3 forKey:@"isHeartRateTime3"];
            [[NSUserDefaults standardUserDefaults]setObject:isHeartRateTime4 forKey:@"isHeartRateTime4"];
            [[NSUserDefaults standardUserDefaults]setObject:isHeartRateTime5 forKey:@"isHeartRateTime5"];
            [[NSUserDefaults standardUserDefaults]setObject:isHeartRateTime6 forKey:@"isHeartRateTime6"];
            [[NSUserDefaults standardUserDefaults]setObject:isHeartRateTime7 forKey:@"isHeartRateTime7"];
            [[NSUserDefaults standardUserDefaults]setObject:isHeartRateTime8 forKey:@"isHeartRateTime8"];
            [[NSUserDefaults standardUserDefaults]setObject:isHeartRateTime9 forKey:@"isHeartRateTime9"];
            [[NSUserDefaults standardUserDefaults]setObject:isHeartRateTime10 forKey:@"isHeartRateTime10"];
            
            [[NSUserDefaults standardUserDefaults]setInteger:isHeartRateFlag forKey:@"isHeartRateFlag"];
            
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OutputHeartRateArrayNotification" object:data];
    }
    else if (data.length ==11)
    {
        NSString * firstStr = [NSString stringWithFormat:@"%@", [data subdataWithRange:NSMakeRange(0,4)]];
        NSString * middleStr   = [NSString stringWithFormat:@"%@", [data subdataWithRange:NSMakeRange(4,4)]];
        NSString * lastStr  = [NSString stringWithFormat:@"%@", [data subdataWithRange:NSMakeRange(8,3)]];
        
        if ([lastStr isEqualToString:@"<454f4d>"]) {
//            deeptime = [self ToTrueShortNumber:firstStr];
//            sleeptime = [self ToTrueShortNumber:middleStr];
            [[NSUserDefaults standardUserDefaults]setInteger:[self ToTrueShortNumber:firstStr] forKey:@"isDeepSleepTime"];
            [[NSUserDefaults standardUserDefaults]setInteger:[self ToTrueShortNumber:middleStr] forKey:@"isSleepTime"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
        if (deBugLog) {
            self.pay = [[UIAlertView alloc] initWithTitle:@"提示"
                                                  message:[NSString stringWithFormat:@"我获取%@",data]
                                                 delegate:nil
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil];
            [self.pay show];
            [NSTimer scheduledTimerWithTimeInterval:3.0f  target:self  selector:@selector(stopStep) userInfo:nil  repeats:NO];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OutputSleepArrayNotification" object:data];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OutputArrayNotification" object:data];
        [self toGetStep];
    }
}




- (void)toGetStep
{
//    [_stepperipheral readValueForCharacteristic:_stepchara];
//    [self.discoverPer discoverServices:nil];
    if (self.discoverPer.state == CBPeripheralStateConnected&&self.discoverPer!=nil&&self.stepchara!=nil) {
        if (self.isGetStep) {
            [self.discoverPer readValueForCharacteristic:self.stepchara];
//            [NSTimer scheduledTimerWithTimeInterval:3.0f  target:self  selector:@selector(toGetStep) userInfo:nil  repeats:NO];
            bletimes++;
            if (bletimes%50==0)
            {
                if (deBugLog) {
                    self.pay = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:[NSString stringWithFormat:@"我获取%d次步数辣",bletimes]
                                                         delegate:nil
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil];
                    [self.pay show];
                    [NSTimer scheduledTimerWithTimeInterval:1.0f  target:self  selector:@selector(stopStep) userInfo:nil  repeats:NO];
                }
            }
        }
        NSLog(@"次数%d",bletimes);
    }
}

-(void)toGetSleep
{
    if (self.discoverPer.state == CBPeripheralStateConnected&&self.discoverPer!=nil&&self.sleepchara!=nil) {
        [self.discoverPer readValueForCharacteristic:self.sleepchara];
        if (deBugLog) {
            self.pay = [[UIAlertView alloc] initWithTitle:@"提示"
                                                  message:[NSString stringWithFormat:@"我来获取睡眠辣"]
                                                 delegate:nil
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil];
            [self.pay show];
            [NSTimer scheduledTimerWithTimeInterval:1.0f  target:self  selector:@selector(stopStep) userInfo:nil  repeats:NO];
        }
    }
}

-(void)toGetHeartRate
{
    if (self.discoverPer.state == CBPeripheralStateConnected&&self.discoverPer!=nil&&self.heartratechara!=nil) {
        [self.discoverPer readValueForCharacteristic:self.heartratechara];
        if (deBugLog) {
            self.pay = [[UIAlertView alloc] initWithTitle:@"提示"
                                                  message:[NSString stringWithFormat:@"我来获取心率辣"]
                                                 delegate:nil
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil];
            [self.pay show];
            [NSTimer scheduledTimerWithTimeInterval:1.0f  target:self  selector:@selector(stopStep) userInfo:nil  repeats:NO];
        }
    }
}

-(void)stopStep
{
    [self.pay dismissWithClickedButtonIndex:0 animated:YES ];
}
-(void)stopGetStep
{
    self.isGetStep=NO;
    self.isGetStepOne=NO;
}

-(void)startGetStep
{
    self.isGetStep=YES;
    [self toGetStep];
}

-(void)toDiscoverServers
{
    NSLog(@"DiscoverServers");
    if (self.discoverPer.state == CBPeripheralStateConnected&&self.discoverPer!=nil&&self.isGetHardWearVersion==NO) {
        [self.discoverPer discoverServices:nil];
        [NSTimer scheduledTimerWithTimeInterval:3.0f  target:self  selector:@selector(toDiscoverServers) userInfo:nil  repeats:NO];
    }
}

-(NSMutableString *) flipByByteOne:(NSString*)String
{
    NSMutableString* tempFlipString  = [[NSMutableString alloc] init];
    for (int i=(int)String.length/2-1; i >= 0 ; i--)
    {
        NSString* tempString = [[NSString alloc]init];
        tempString = [String substringWithRange:NSMakeRange(2*i,2)];
        [tempFlipString appendString:tempString];
    }
    return tempFlipString;
}


-(int) ToTrueShortNumber :(NSString * )DataStr
{
    DataStr = [DataStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    DataStr = [DataStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    DataStr = [self flipByByteOne:DataStr];
    NSScanner* scanner = [NSScanner scannerWithString: DataStr];
    unsigned long long ShortNumber;
    [scanner scanHexLongLong: &ShortNumber];
    NSLog(@"ShortNumber = %llu", ShortNumber);
    return  (int)ShortNumber;
}


-(BOOL)toGetBLECentralStateOn
{
    return self.isGetBLECentralStateOn;
}

+ (CBService *)findServiceWithUUID:(NSString *)serUUID per:(CBPeripheral *)per
{
    const char *cSerUUID = [serUUID cStringUsingEncoding:NSUTF8StringEncoding];
    for (CBService *ser in per.services) {
        if (strcmp([LWBLEManager CBUUIDToCString:ser.UUID], cSerUUID) == 0) {
            return ser;
        }
    }
    return nil;
}

+ (CBCharacteristic *) findCharacteristicFromUUID:(NSString *)charaUUID service:(CBService*)service
{
    const char *cChara = [charaUUID cStringUsingEncoding:NSUTF8StringEncoding];
    for (CBCharacteristic *chara in service.characteristics) {
        if (strcmp([LWBLEManager CBUUIDToCString:chara.UUID], cChara) == 0) {
            return chara;
        }
    }
    return nil;
}

+ (NSString *)UUIDToString:(CFUUIDRef)UUID
{
    const char *cUUID = [LWBLEManager UUIDToCString:UUID];
    NSString *UUIDString = [NSString stringWithCString:cUUID encoding:NSUTF8StringEncoding];
    return UUIDString;
}

+ (const char *)UUIDToCString:(CFUUIDRef)UUID
{
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
}

+ (NSString *)CBUUIDToString:(CBUUID *)UUID
{
    NSData *data = UUID.data;
    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:[outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]]; break;
            default:[outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
    }
    return outputString;
}

+ (const char *)CBUUIDToCString:(CBUUID *)UUID
{
    return [[LWBLEManager CBUUIDToString:UUID] cStringUsingEncoding:NSUTF8StringEncoding];
}

//#pragma mark - BLECOMMAND
//NSMutableData * hexStringToSerialData(NSString *hexString)
//{
//    // the first byte starts at 0x80 and increments by 0x20 each successive call
//    // after 0xE0, reset back to 0x80 - not sure why it be like it is, but it do
//    //    static const unsigned char initialVal = 0x80, maxVal = 0xE0, incVal = 0x20;
//    //    static unsigned char first_byte = initialVal;
//    hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSMutableData *serialData = [[NSMutableData alloc] init];
//    //    [serialData appendBytes:&first_byte length:1];
//    //    first_byte = first_byte >= maxVal ? initialVal : first_byte + incVal;
//    unsigned char whole_byte;
//    char byte_chars[3] = {'\0','\0','\0'};
//    int i;
//    for (i=0; i < [hexString length]/2; i++) {
//        byte_chars[0] = [hexString characterAtIndex:i*2];
//        byte_chars[1] = [hexString characterAtIndex:i*2+1];
//        whole_byte = strtol(byte_chars, NULL, 16);
//        [serialData appendBytes:&whole_byte length:1];
//    }
//    NSLog(@"111%@", serialData);
//    return serialData;
//}
//
//-(NSMutableString *) flipByByte:(NSString*)String
//{
//    NSMutableString* tempFlipString  = [[NSMutableString alloc] init];
//    for (int i=String.length/2-1; i >= 0 ; i--)
//    {
//        NSString* tempString = [[NSString alloc]init];
//        tempString = [String substringWithRange:NSMakeRange(2*i,2)];
//        [tempFlipString appendString:tempString];
//    }
//    return tempFlipString;
//
//}


@end
