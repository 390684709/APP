//
//  WXJBlueCenter.h
//  blueCenterDemo
//
//  Created by Logan Wang on 13-12-13.
//  Copyright (c) 2013年 __fb__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <sqlite3.h>


#define LW_BLES_UUID ((NSArray *)[[LWBLEManager shared].dicDiscoverBlues allKeys])
#define LW_UUID(NUM) ((NSString *)[LW_BLES_UUID objectAtIndex:NUM])
#define LW_BLE(UUID) ((CBPeripheral *)[[LWBLEManager shared].dicDiscoverBlues objectForKey:UUID])

typedef void (^discoverCallbackBlock)();


@interface LWBLEManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager        *_centralManager;
    NSMutableDictionary     *_dicDiscoverBlues;
    
    bool                     _bConnectOnlyOne;
    bool                     _bAutoConn;
    CBPeripheral            *_discoverPer;
    
    NSMutableArray          *_arrNotifyUUID;
    
    int                      _nScanTimeOut;
    
    bool                     _bListenRSSI;
    NSTimeInterval           _nListenInterval;
    
    CBPeripheral             *_stepperipheral;
    CBCharacteristic         *_stepchara;
    CBCharacteristic         *_sleepchara;
    CBCharacteristic         *_heartratechara;
    
@private
    bool                     _bInited;
    bool                     _bScaning;
}

@property (nonatomic, readonly) dispatch_queue_t delegateQueue;


/**
 * @brief 设备中心
 */
@property (nonatomic, retain) CBCentralManager      *centralManager;

/**
 * @brief 扫描到的蓝牙设备(bConnectOnlyOne == false 时 可用)
 */
@property (nonatomic, retain) NSMutableDictionary   *dicDiscoverBlues;

/**
 * @brief 是否支持同时连接多个设备
 *
 * @see   property discoverPer;
 */
@property (nonatomic, assign) bool                   bConnectOnlyOne;

@property (nonatomic, assign) bool                   bAutoConn;

@property  BOOL                                       isGetStep;

@property  BOOL                                       isGetStepOne;

@property  BOOL                                       isGetHardWearVersion;

@property  BOOL                                       isGetBLECentralStateOn;



@property (retain,nonatomic) UIAlertView * pay;

/**
 * @brief 扫描到的蓝牙设备(bConnectOnlyOne == true 时 可用)
 */
@property (nonatomic, retain)CBPeripheral           *discoverPer;

@property (nonatomic, retain)CBCharacteristic           *stepchara;

@property (nonatomic, retain)CBCharacteristic           *sleepchara;

@property (nonatomic, retain)CBCharacteristic           *heartratechara;


/**
 * @brief 监听的UUID [(key:charaUUID value:serviceUUID),(key:charaUUID2 value:serviceUUID),...]
 */
@property (nonatomic, retain) NSMutableArray        *arrNotifyUUID;


/**
 * @brief 扫描超时时间
 * @see   notification WXJBlueCenterScanOverCallbackNot
 */
@property (nonatomic, assign) int                    nScanTimeOut;

/**
 * @brief 是否监听信号强度
 * @see   notification WXJBlueCenterListenRSSICallbackNot
 */
@property (nonatomic, assign) bool                   bListenRSSI;

/**
 * @brief 监听信号强度间隔周期
 *
 * @see  property bListenRSSI
 */
@property (nonatomic, assign) NSTimeInterval         nListenInterval;


/**
 * @brief 检测周围设备block块
 */
@property (atomic,copy) discoverCallbackBlock discoverCallback;


/**
 * @brief 初始化单例
 * @param connectOnlyOne 是否支持同时连接多个蓝牙外设
 */
+ (LWBLEManager *)sharedOnlyOne:(bool)connectOnlyOne compeletedHandler:(void(^)())compeletedHander;

+ (LWBLEManager *)shared;
/**
 * @brief 搜索并尝试连接周围设备
 */
- (void)scanTheBlue;

@property (nonatomic,strong)NSArray *knownPeripherals;


/**
 * @brief 停止扫描蓝牙设备
 */
-(void)stopScan;

-(void)stopGetStep;

-(void)startGetStep;

-(void)toGetSleep;

-(void)toGetHeartRate;

- (void)connectPer:(NSString *)UUID;

-(void)renewBleServices;

-(BOOL)toGetBLECentralStateOn;

/**
 * @brief 断开指定外设连接
 * @param uuid 外设uuid //ios 7.0停用 By Daniel Li
 */
- (void)cancelPerConnection;

/**
 * @brief 读取数据
 * @param serviceUUID        服务UUID
 * @param characteristicUUID 特征UUID
 * @param per                外设对象
 *
 * @see   notification WXJBlueCenterRecivedCommCallbackNot
 */
- (void)readValue:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per;

/**
 * @brief 发送指令
 * @param serviceUUID        服务UUID
 * @param characteristicUUID 特征UUID
 * @param per                外设对象
 * @param data               指令
 */
- (void)writeValue:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per data:(NSData *)data;

-(void)toThreeSecond;

- (void)writeValueWithoutResponse:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per data:(NSData *)data;

/**
 * @brief receiver static change not
 * @param serviceUUID           服务UUID
 * @param characteristicUUID    特征UUID
 * @param per                   外设对象
 * @param on  true              启用监听
 * @param on  false             关闭监听
 *
 * @see   notification WXJBlueCenterRecivedCommCallbackNot
 */
- (void)notify:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per on:(bool)on;


/**
 * @brief 取出service
 * @param serUUID 待取出service的 uuid
 * @param per     外设对象
 * @retval 取出的CBService 对象
 */
+ (CBService *)findServiceWithUUID:(NSString *)serUUID per:(CBPeripheral *)per;

/**
 * @brief 取出chara 待取出chara的 uuid
 * @param charaUUID
 * @param service CBService对象
 * @retval 取出的CBCharacteristic 对象
 */
+ (CBCharacteristic *) findCharacteristicFromUUID:(NSString *)charaUUID service:(CBService*)service;

/**
 * @brief CFUUIDRef 转换 NSString
 */
+ (NSString *)UUIDToString:(CFUUIDRef)UUID;

/**
 * @brief CFUUIDRef 转换 const char
 */
+ (const char *)UUIDToCString:(CFUUIDRef)UUID;

/**
 * @brief CBUUID 转换 NSString
 */
+ (NSString *)CBUUIDToString:(CBUUID *)UUID;

/**
 * @brief CBUUID 转换 const char
 */
+ (const char *)CBUUIDToCString:(CBUUID *)UUID;


//static int Filter(int chVal)
//{
//    
//#define FIFO_NUM    10
//    int    chMinVal, chMaxVal, chTemp;
//    int    nCnt, nSum;
//    static int    s_chIx = 0, s_chIsFull = FALSE;
//    static int    s_achBuf[FIFO_NUM];
//    /* Save the NEW value, kick out the OLDest one */
//    s_achBuf[s_chIx] = chVal;
//    if (++s_chIx >= FIFO_NUM)
//    {
//        s_chIx = 0;    /* Wrap to 1th unit */
//        s_chIsFull = TRUE;
//    }
//    /* Number of sampled data less than N */
//    if (!s_chIsFull)
//    {
//        nSum = 0;
//        for (nCnt = 0; nCnt < s_chIx; ++nCnt)
//        {
//            nSum += s_achBuf[nCnt];
//        }
//        return (int)(nSum / s_chIx);
//    }
//    
//    /* Get the SUM and Max. and Min. */
//    chMaxVal = chMinVal = nSum = 0;
//    for (nCnt = 0; nCnt < FIFO_NUM; ++nCnt)
//    {
//        chTemp = s_achBuf[nCnt];
//        nSum += chTemp;
//        if (chTemp > chMaxVal)
//        {
//            chMaxVal = chTemp;
//        }
//        else if (chTemp < chMinVal)
//        {
//            chMinVal = chTemp;
//        }
//    }
//    /* Calculate the average */
//    
//    nSum -= (chMaxVal + chMinVal);   /* SUB Max. and Min. */
//    
//    nSum /= (FIFO_NUM - 2);    /* Get average */
//    
//    return (int)nSum;
//    
//}




@end
