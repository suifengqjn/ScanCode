//
//  UINavigationBar+Alpha.h
//  LTNavigationBar
//
//  Created by qianjn on 16/5/28.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Alpha)
- (void)lt_setBackgroundColor:(UIColor *)backgroundColor;
- (void)lt_setElementsAlpha:(CGFloat)alpha;
- (void)lt_setTranslationY:(CGFloat)translationY;
- (void)lt_reset;
@end
