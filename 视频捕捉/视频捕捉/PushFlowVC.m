//
//  PushFlowVC.m
//  视频捕捉
//
//  Created by 联创—王增辉 on 2019/5/14.
//  Copyright © 2019年 lcWorld. All rights reserved.
//

#import "PushFlowVC.h"
#import <AVFoundation/AVFoundation.h>
@interface PushFlowVC ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong, nonatomic) AVCaptureDeviceInput * DeviceInput;//摄像头
@property (strong, nonatomic) AVCaptureSession     * session;
@property (strong, nonatomic) AVCaptureVideoDataOutput    * VideoDataOutput;//捕获视频中的帧
@property (strong, nonatomic) AVCaptureVideoPreviewLayer    * PreviewLayer;//视频预览图层

@end

@implementation PushFlowVC
{
    dispatch_queue_t videoDataOutputQueue;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //获取摄像头授权
    [self captureAuthorization:(AVMediaTypeVideo) callStatus:^(BOOL status) {
        if (status) {
            //            [self showAlertWithContent:@"s已授权"];
            //获取设备
            [self createSession];
            if (!self->_session) {
                [self showAlertWithContent:@"session初始化失败"];
            }
            
            //获取设备
            if (![self getCameraDevice]) {
                [self showAlertWithContent:@"获取设备失败"];
            }
            //加人session
            if (![self addCaptureDeviceToSession]) {
                [self showAlertWithContent:@"Device加入sessions失败"];
            }
            //创建输出
            if (![self setVideoOutput]) {
                [self showAlertWithContent:@"创建输出失败"];
            }
            //加人session
            if (![self addVideoOutputToSession]) {
                [self showAlertWithContent:@"VideoOutput加入sessions失败"];
            }
            //加入预览图层
            [self addPreviewLayer];
            
            [self->_session startRunning];
            
        }else{
            [self showAlertWithContent: @"未授权"];
        }
    }];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_session stopRunning];
}
#pragma mark - 步骤七
//加入预览图层
- (void)addPreviewLayer
{
    self.PreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self->_session];
    self.PreviewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.PreviewLayer];
}
#pragma mark - 步骤六
//添加输出
- (BOOL)addVideoOutputToSession
{
    if ([_session canAddOutput:_VideoDataOutput]) {
        [_session addOutput:_VideoDataOutput];
        return YES;
    }
    return NO;
}
#pragma mark - 步骤五
//创建输出
- (BOOL)setVideoOutput
{
    _VideoDataOutput = [[AVCaptureVideoDataOutput alloc]init];
    NSDictionary * newSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    _VideoDataOutput.videoSettings = newSettings;
    
    //如果数据输出队列被阻止则丢弃（因为我们处理静止图像
    [_VideoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    //创建用于样本缓冲区委托的串行调度队列以及捕获静态图像的时间
    //必须使用串行调度队列来保证视频帧按顺序传送
    //有关详细信息，请参阅setSampleBufferDelegate：queue的标头文档
    videoDataOutputQueue = dispatch_queue_create("videoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [_VideoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    return _VideoDataOutput !=nil;
}
#pragma mark - 步骤四
//添加输入设备
- (BOOL)addCaptureDeviceToSession
{
    if ([_session canAddInput:_DeviceInput]) {
        [_session addInput:_DeviceInput];
        return YES;
    }
    return NO;
}
#pragma mark - 步骤三
//获取设备
- (BOOL)getCameraDevice
{
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithDeviceType:( AVCaptureDeviceTypeBuiltInWideAngleCamera) mediaType:( AVMediaTypeVideo) position:(AVCaptureDevicePositionFront)];
    if (device == nil) {
        return NO;
    }
    _DeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (_DeviceInput == nil) {
        return NO;
    }
    return YES;
}
#pragma mark - 步骤二
//创建session
- (void)createSession{
    _session = [[AVCaptureSession alloc]init];
    if ([_session canSetSessionPreset:(AVCaptureSessionPreset640x480)]) {
        [_session setSessionPreset:AVCaptureSessionPreset640x480];
    }
}
#pragma mark - 步骤一
//获取授权
- (void)captureAuthorization:(AVMediaType )type callStatus:(void(^)(BOOL status))callStatus
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:type];
    switch (status) {
        case AVAuthorizationStatusNotDetermined://不确定
        {
            [AVCaptureDevice requestAccessForMediaType:type completionHandler:^(BOOL granted) {
                if (callStatus) {
                    callStatus(granted);
                }
            }];
        }
            break;
        case AVAuthorizationStatusRestricted://未授权，且用户无法更新，如家长控制情况下
        {
            callStatus(NO);
        }
            break;
        case AVAuthorizationStatusDenied://否认
        {
            callStatus(NO);
        }
            break;
        case AVAuthorizationStatusAuthorized://授权
        {
            callStatus(YES);
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
#pragma mark -
#pragma mark 输出新的视频帧时调用
//每当AVCaptureVideoDataOutput实例输出新的视频帧时调用。
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    static int i = 0;
    NSLog(@"%d",i++);
}
- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
}
//提示
- (void)showAlertWithContent:(NSString *)content
{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"" message:content preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
}
- (void)dealloc
{
    NSLog(@"销毁");
}

@end
