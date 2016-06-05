//
//  JNSacnTool.m
//  ScanCode
//
//  Created by qianjn on 16/6/5.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "JNSacnTool.h"
#import <UIKit/UIKit.h>
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
@interface JNSacnTool ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;


@end

@implementation JNSacnTool



// 设置输出对象解析数据时感兴趣的范围
// 默认值是 CGRect(x: 0, y: 0, width: 1, height: 1)
// 通过对这个值的观察, 我们发现传入的是比例
// 注意: 参照是以横屏的左上角作为, 而不是以竖屏
//        out.rectOfInterest = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
- (AVCaptureVideoPreviewLayer *)startScan;
{
    //1.创建捕捉会话
    _session = [[AVCaptureSession alloc] init];

    //2.添加输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]; //二维码类型
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    NSLog(@"--%@", error);
    if (self.delegate && [self.delegate respondsToSelector:@selector(scanFailure:)]) {
        [self.delegate scanFailure:[error.userInfo description]];
    }
    [_session addInput:deviceInput];
    //3.添加输出数据
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:output];
    
    // 3.1.设置输入元数据的类型(类型是二维码数据)
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // 3.2.获取扫描容器的frame
    CGRect containerRect = CGRectMake((kScreenWidth - 200)/2, (kScreenHeight-64- 200)/2, 200, 200);
    
    CGFloat x = containerRect.origin.y / kScreenHeight;
    CGFloat y = containerRect.origin.x / kScreenWidth;
    CGFloat width = containerRect.size.height / kScreenHeight;
    CGFloat height = containerRect.size.width / kScreenWidth;
    output.rectOfInterest = CGRectMake(x, y, width, height);
    
    
    
    
    // 4.添加扫描图层
    _layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _layer.videoGravity =AVLayerVideoGravityResizeAspectFill;
    _layer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-64);
    
    // 5.开始扫描
    [_session startRunning];
    
    return _layer;
}

#pragma mark - 实现output的回调方法
// 当扫描到数据时就会执行该方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
        NSLog(@"%@", object.stringValue);
        
        // 停止扫描
        [self.session stopRunning];
        if (self.delegate && [self.delegate respondsToSelector:@selector(scanSuccess:)]) {
            [self.delegate scanSuccess:object.stringValue];
        }
        
        // 将预览图层移除
        [self.layer removeFromSuperlayer];
    } else {
        NSLog(@"没有扫描到数据");
        if (self.delegate && [self.delegate respondsToSelector:@selector(scanFailure:)]) {
            [self.delegate scanFailure:@"nil"];
        }
    }
}

//可重写view的drawrect方法直接画，这里因为懒，所以直接从古早项目中粘贴过来。
- (UIView *)createBgView{
    
    UIView *bgView = [[UIView alloc]initWithFrame:_layer.frame];
    
    CGFloat topViewHeight = (kScreenHeight-64- 200)/2;
    CGFloat leftViewWidth = (kScreenWidth - 200)/2;

    //上部
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, topViewHeight)];
    upView.alpha = 0.4;
    upView.backgroundColor = [UIColor blackColor];
    [bgView addSubview:upView];
    //说明
    UILabel * labIntroudction= [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.frame=CGRectMake(kScreenWidth/20, kScreenHeight/24, kScreenWidth/10*9, 50);
    labIntroudction.numberOfLines=2;
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.text=@"将二维码置于矩形方框内，离手机摄像头10CM左右，系统会自动识别。";
    [upView addSubview:labIntroudction];
    //左侧
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, topViewHeight, leftViewWidth, 200)];
    leftView.alpha = 0.4;
    leftView.backgroundColor = [UIColor blackColor];
    [bgView addSubview:leftView];
    //右侧
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(leftViewWidth+ 200, topViewHeight, leftViewWidth, 200)];
    rightView.alpha = 0.4;
    rightView.backgroundColor = [UIColor blackColor];
    [bgView addSubview:rightView];
    //底部
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - topViewHeight - 64, kScreenWidth, topViewHeight)];
    downView.alpha = 0.4;
    downView.backgroundColor = [UIColor blackColor];
    [bgView addSubview:downView];
    
    return bgView;
}
@end
