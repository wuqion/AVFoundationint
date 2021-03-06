//
//  faceVC.m
//  视频捕捉
//
//  Created by 联创—王增辉 on 2019/5/13.
//  Copyright © 2019年 lcWorld. All rights reserved.
//

#import "faceVC.h"
#import <AVFoundation/AVFoundation.h>
@interface faceVC ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureDeviceInput * DeviceInput;//摄像头
@property (strong, nonatomic) AVCaptureSession     * session;
@property (strong, nonatomic) AVCaptureMetadataOutput       * metadataOutput;//捕获视频中的帧
@property (strong, nonatomic) AVCaptureVideoPreviewLayer    * PreviewLayer;//视频预览图层
@property (strong, nonatomic) UILabel               * laber;//
@property (strong, nonatomic) CALayer               * boxLayer;//识别位置

@end

@implementation faceVC
{
    dispatch_queue_t metadataOutputQueue;
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
            if (![self setFace]) {
                [self showAlertWithContent:@"不支持人脸识别"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            //加入预览图层
            [self addPreviewLayer];
            
            [self->_session startRunning];
            
            self.boxLayer = [[CALayer alloc]init];
            self.boxLayer.borderColor = [UIColor yellowColor].CGColor;
            self.boxLayer.borderWidth = 1;
            [self.view.layer addSublayer:self.boxLayer];
            self.boxLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"1.jpg"].CGImage);
            self.laber = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 80, 1000, 80)];
            self.laber.textColor = [UIColor blackColor];
            [self.view addSubview:self.laber];
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
#pragma mark - 步骤八
//设置人脸识别
- (BOOL) setFace
{
    if ([_metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeFace]) {
        [_metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
        return YES;
    }
    return NO;
    
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
    if ([_session canAddOutput:_metadataOutput]) {
        [_session addOutput:_metadataOutput];
        return YES;
    }
    return NO;
}
#pragma mark - 步骤五
//创建输出
- (BOOL)setVideoOutput
{
    _metadataOutput = [[AVCaptureMetadataOutput alloc]init];
    

    
    metadataOutputQueue = dispatch_queue_create("videoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [_metadataOutput setMetadataObjectsDelegate:self queue:metadataOutputQueue];
    return _metadataOutput !=nil;
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
//每当AVCaptureMetadataOutput实例通过连接发出新对象时调用。
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection;
{
//    static int i = 0;
//    NSLog(@"%d",i++);
    for (AVMetadataFaceObject * objc in metadataObjects) {
        
        dispatch_async( dispatch_get_main_queue(), ^{
            AVMetadataFaceObject * face = [self.PreviewLayer transformedMetadataObjectForMetadataObject:objc];
            self.boxLayer.frame = face.bounds;
            self.boxLayer.transform = CATransform3DIdentity;
            if(face.hasYawAngle){
                self.boxLayer.transform = CATransform3DConcat(self.boxLayer.transform, [self transformFromYawAngle:face.yawAngle * M_PI/180]);
            }
            if (face.hasRollAngle) {
                self.boxLayer.transform =CATransform3DMakeRotation(face.rollAngle * M_PI /180, 0.0f, 0.0f, 1.0f);
            }
            NSLog(@"%lf",face.rollAngle);
            self.laber.text = [NSString stringWithFormat:@"%lf-%lf-",face.rollAngle * M_PI/180,face.yawAngle * M_PI/180];
        });
    }
}
-(CATransform3D)transformFromYawAngle:(CGFloat)angle
{
    CATransform3D t = CATransform3DMakeRotation(angle * M_PI/180, 0.0f, -1.0f, 0.0f);
    return CATransform3DConcat(t, [self orientationTransform]);
}
-(CATransform3D)orientationTransform
{
    CGFloat angle  = 0.0f;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI/2.0;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI/2.0;
            break;
        default:
            angle  = 0.0f;
            break;
    }
    return CATransform3DMakeRotation(angle, 0.0f, 0.0f, 1.0f);
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
