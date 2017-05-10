//
//  UISwitch+MLLayout.h
//  Pods
//
//  Created by molon on 2017/5/10.
//
//

#import <UIKit/UIKit.h>
#import "MLLayout.h"

@interface UISwitch (MLLayout)
- (CGSize)measureWithMLLayout:(MLLayout*)layout width:(CGFloat)width widthMode:(MLLayoutMeasureMode)widthMode height:(CGFloat)height heightMode:(MLLayoutMeasureMode)heightMode;
@end
