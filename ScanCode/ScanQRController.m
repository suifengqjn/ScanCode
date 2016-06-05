//
//  ScanQRController.m
//  ScanCode
//
//  Created by qianjn on 16/6/4.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "ScanQRController.h"
#import "JNScanController.h"
#import "UIView+Toast.h"
#import "JNSacnTool.h"
@interface ScanQRController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation ScanQRController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)scanQR:(id)sender {
    
    JNScanController *vc = [[JNScanController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)scanQRFormAsset:(id)sender {
    
    UIImagePickerController *photo = [[UIImagePickerController alloc] init];
    photo.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photo.delegate = self;
   // photo.allowsEditing = YES;
    [self presentViewController:photo animated:YES completion:nil];
    
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{

    //取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];


    __weak typeof(self) weakSelf = self;
    
    
    //选中图片后先返回扫描页面，然后跳转到新页面进行展示
    [picker dismissViewControllerAnimated:NO completion:^{
    
            
    [weakSelf.view makeToast:[JNSacnTool readQRCodeFromImage:pickImage]];

    }];
}

////允许编辑后的截图回调
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
//{
//    
//    [picker dismissViewControllerAnimated:YES completion:nil];
//
//}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
