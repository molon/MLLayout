//
//  UIImage+CornerAndAspectFill.h
//  MLLayoutDemo
//
//  Created by molon on 16/6/28.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 source of YYKit
 */
@interface UIImage (CornerAndAspectFill)

- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius;
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth;

- (UIImage *)imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;

@end
