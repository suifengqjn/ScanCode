//
//  JNSacnTool.h
//  ScanCode
//
//  Created by qianjn on 16/6/5.
//  Copyright © 2016年 SF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@protocol JNSacnToolDelegate <NSObject>

- (void)scanSuccess:(NSString *)result;
- (void)scanFailure:(NSString *)error;

@end

@interface JNSacnTool : NSObject

@property (nonatomic, weak) id<JNSacnToolDelegate>delegate;

/**
 *  扫描二维码
 *
 *  @return layer
 */
- (AVCaptureVideoPreviewLayer *)startScan;
/**
 *
 *
 *  @return 扫描的框
 */
- (UIView *)createBgView;

//======================================================

/**
 *  生成二维码图片
 *
 *  @param QRString  二维码内容
 *  @param sizeWidth 图片size（正方形）
 *
 *  @return  二维码图片
 */
+(UIImage *)createQRimageString:(NSString *)QRString sizeWidth:(CGFloat)sizeWidth;


/**
 *  读取图片中二维码信息
 *
 *  @param image 图片
 *
 *  @return 二维码内容
 */
+(NSString *)readQRCodeFromImage:(UIImage *)image;
@end
