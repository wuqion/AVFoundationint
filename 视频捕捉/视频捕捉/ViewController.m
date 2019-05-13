//
//  ViewController.m
//  视频捕捉
//
//  Created by 联创—王增辉 on 2019/5/13.
//  Copyright © 2019年 lcWorld. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self captureAuthorization:(AVMediaTypeVideo) callStatus:^(BOOL status) {
        if (status) {
            [self showAlertWithContent:@"s已授权"];
        }else{
            [self showAlertWithContent: @"未授权"];
        }
    }];
}
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
//提示
- (void)showAlertWithContent:(NSString *)content
{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"" message:content preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
}


@end
