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
#define kScanEara CGRectMake((kScreenWidth - 200)/2, (kScreenHeight-64- 200)/2, 200, 200)
@interface JNSacnTool ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession           *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;

@property (nonatomic, strong) AVCaptureDeviceInput       *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput    *output;
@property (nonatomic, strong) NSTimer                    *timer;
@property (nonatomic, strong) UIImageView                *line;
@end

@implementation JNSacnTool

- (AVCaptureDeviceInput *)deviceInput
{
    if (!_deviceInput) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]; //二维码类型
        NSError *error;
        _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        NSLog(@"--%@", error);
        if (self.delegate && [self.delegate respondsToSelector:@selector(scanFailure:)]) {
            [self.delegate scanFailure:[error.userInfo description]];
        }
    }
    return _deviceInput;
}

// 设置输出对象解析数据时感兴趣的范围
// 默认值是 CGRect(x: 0, y: 0, width: 1, height: 1)
// 通过对这个值的观察, 我们发现传入的是比例
// 注意: 参照是以横屏的左上角作为, 而不是以竖屏
//        out.rectOfInterest = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
- (AVCaptureMetadataOutput *)output
{
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        // 3.2.获取扫描容器的frame
        CGRect containerRect = kScanEara;
        
        CGFloat x = containerRect.origin.y / kScreenHeight;
        CGFloat y = containerRect.origin.x / kScreenWidth;
        CGFloat width = containerRect.size.height / kScreenHeight;
        CGFloat height = containerRect.size.width / kScreenWidth;
        _output.rectOfInterest = CGRectMake(x, y, width, height);
    }
    return _output;
}
- (AVCaptureVideoPreviewLayer *)startScan;
{
    //1.创建捕捉会话
    _session = [[AVCaptureSession alloc] init];

    //2.添加输入设备
    // 1.判断输入能否添加到会话中
    if (![_session canAddInput:self.deviceInput]) return nil;
    [self.session addInput:self.deviceInput];
    

    //3.添加输出数据
    if (![_session canAddOutput:self.output]) return nil;
    [_session addOutput:self.output];
    
    // 3.1.设置输入元数据的类型(类型是二维码数据)
    //扫码类型，需要先将输出流添加到捕捉会话后再进行设置
    [_output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // 4.添加扫描图层
    _layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _layer.videoGravity =AVLayerVideoGravityResizeAspectFill;
    _layer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-64);
    
    // 5.开始扫描
    [_session startRunning];
    
    
    //创建定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(saomiaoAct) userInfo:nil repeats:YES];
    
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
        //[self.layer removeFromSuperlayer];
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
    
    
    // 添加四个角
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"qrcode_border"];
    imageView.frame = kScanEara;
    imageView.contentMode = UIViewContentModeScaleToFill;
    [bgView addSubview:imageView];
    
    //扫描线条
    _line = [[UIImageView alloc] init];
    _line.image = [UIImage imageNamed:@"line"];
    CGRect frame = kScanEara;
    frame.size.height = 3;
    _line.frame = frame;
    [bgView addSubview:_line];
    
    return bgView;
}

- (void)saomiaoAct
{
    
    
    [UIView animateWithDuration:2.0 animations:^{
        CGRect frame = kScanEara;
        frame.size.height = 3;
        frame.origin.y += 197;
        _line.frame = frame;
    } completion:^(BOOL finished) {
        CGRect frame = kScanEara;
        frame.size.height = 3;
        _line.frame = frame;
    }];
}



//=============================
/**
 *  生成二维码图片
 *
 *  @param QRString  二维码内容
 *  @param sizeWidth 图片size（正方形）
 *
 *  @return  二维码图片
 */
+ (UIImage *)createQRimageString:(NSString *)QRString sizeWidth:(CGFloat)sizeWidth
{
    CIImage *ciimage = [self createQRForString:QRString];
    UIImage *qrImage = [self createNonInterpolatedUIImageFormCIImage:ciimage withSize:sizeWidth];
    return qrImage;
}
#pragma mark - QRCodeGenerator
+ (CIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    //1.创建过滤器
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //2.恢复默认设置
    [qrFilter setDefaults];
    //3.给过滤器添加数据
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    //4.设置精确度
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // Send the image back
    return qrFilter.outputImage;
}

/**
 *  根据CIImage生成指定大小的高清UIImage
 *
 *  @param image CIImage
 *  @param size  图片宽度
 */
#pragma mark - InterpolatedUIImage
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}




#pragma mark 读取图片二维码
/**
 *  读取图片中二维码信息
 *
 *  @param image 图片
 *
 *  @return 二维码内容
 */
+(NSString *)readQRCodeFromImage:(UIImage *)image{
    NSData *data = UIImagePNGRepresentation(image);
    CIImage *ciimage = [CIImage imageWithData:data];
    if (ciimage) {
        CIDetector *qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:[CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}] options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
        NSArray *resultArr = [qrDetector featuresInImage:ciimage];
        if (resultArr.count >0) {
            CIFeature *feature = resultArr[0];
            CIQRCodeFeature *qrFeature = (CIQRCodeFeature *)feature;
            NSString *result = qrFeature.messageString;
            
            return result;
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}


- (void)dealloc
{
    [_timer invalidate];
    [_session stopRunning];
}
@end
