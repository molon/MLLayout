//
//  UIImageView+MLLayout.m
//
//  Created by molon on 16/6/23.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIImageView+MLLayout.h"
#import "MLLayout.h"
#import "MLLayoutMacro.h"

MLLAYOUT_SYNTH_DUMMY_CLASS(UIImageView_MLLayout)

@implementation UIImageView (MLLayout)

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
    
    return [self sizeThatFits:size];
}

@end
