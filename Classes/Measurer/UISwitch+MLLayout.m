//
//  UISwitch+MLLayout.m
//  Pods
//
//  Created by molon on 2017/5/10.
//
//

#import "UISwitch+MLLayout.h"
#import "MLLayoutMacro.h"

MLLAYOUT_SYNTH_DUMMY_CLASS(UISwitch_MLLayout)

@implementation UISwitch (MLLayout)

- (CGSize)measureWithMLLayout:(MLLayout*)layout width:(CGFloat)width widthMode:(MLLayoutMeasureMode)widthMode height:(CGFloat)height heightMode:(MLLayoutMeasureMode)heightMode {
    
    CGSize size = CGSizeMake(HUGE, HUGE);
    
    if (!isnan(width)) {
        size.width = width;
    }
    
    if (!isnan(height)) {
        size.height = height;
    }
    
    size.width = dimensionClamp(layout.minWidth,layout.maxWidth,size.width);
    size.height = dimensionClamp(layout.minHeight,layout.maxHeight,size.height);
    
    CGSize fitSize = [self sizeThatFits:size];
    
    //maybe the fit result is bigger than measure size
    fitSize.width = fmin(size.width, fitSize.width);
    fitSize.height = fmin(size.height, fitSize.height);
    
    return fitSize;
}

@end
