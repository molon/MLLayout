//
//  UIControl+MLLayout.h
//  Pods
//
//  Created by molon on 2017/5/31.
//
//

#import <UIKit/UIKit.h>
#import "MLLayout.h"

@interface UIControl (MLLayout)

- (CGSize)measureWithMLLayout:(MLLayout*)layout width:(CGFloat)width widthMode:(MLLayoutMeasureMode)widthMode height:(CGFloat)height heightMode:(MLLayoutMeasureMode)heightMode;

@end
