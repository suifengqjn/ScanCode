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

- (AVCaptureVideoPreviewLayer *)startScan;

- (UIView *)createBgView;

@end
