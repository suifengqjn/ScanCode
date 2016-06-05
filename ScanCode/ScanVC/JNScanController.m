//
//  JNScanController.m
//  ScanCode
//
//  Created by qianjn on 16/6/5.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "JNScanController.h"
#import "JNSacnTool.h"
#import "UIView+Toast.h"
#import "UINavigationBar+Alpha.h"

@interface JNScanController ()<JNSacnToolDelegate>
@property (nonatomic, strong)JNSacnTool *scanTool;

@end

@implementation JNScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    _scanTool = [[JNSacnTool alloc] init];
    _scanTool.delegate = self;
    [self.view.layer addSublayer:[_scanTool startScan]];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar lt_setElementsAlpha:0.1];
    
    [self.view addSubview:[_scanTool createBgView]];
   
}

- (void)scanSuccess:(NSString *)result
{
    
    [self.view makeToast:result];
    
    
}

- (void)scanFailure:(NSString *)error
{
   [self.view makeToast:error];

}
@end
