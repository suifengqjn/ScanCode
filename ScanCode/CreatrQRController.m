//
//  CreatrQRController.m
//  ScanCode
//
//  Created by qianjn on 16/6/4.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "CreatrQRController.h"

#import "JNQRScanTool.h"
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
@interface CreatrQRController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UITextField *twxtfeild;

@end

@implementation CreatrQRController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}





- (IBAction)clickAction:(id)sender {
    if (_twxtfeild.text) {
        self.imageView.image  = [JNQRScanTool createQRimageString:_twxtfeild.text sizeWidth:200];
    }
    
    
}






@end
