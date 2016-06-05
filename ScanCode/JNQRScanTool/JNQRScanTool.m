//
//  JNQRScanTool.m
//  ScanCode
//
//  Created by qianjn on 16/6/5.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "JNQRScanTool.h"

@implementation JNQRScanTool
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
@end
