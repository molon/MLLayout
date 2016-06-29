//
//  UILabel+MLLayout.m
//
//  Created by molon on 16/6/23.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UILabel+MLLayout.h"
#import "MLLayout.h"
#import "MLLayoutMacro.h"

MLLAYOUT_SYNTH_DUMMY_CLASS(UILabel_MLLayout)

@implementation UILabel (MLLayout)

- (CGSize)measureWithMLLayout:(MLLayout*)layout width:(CGFloat)width widthMode:(MLLayoutMeasureMode)widthMode height:(CGFloat)height heightMode:(MLLayoutMeasureMode)heightMode {
    
    CGSize size = CGSizeMake(HUGE, HUGE);
    
    if (!isnan(width)) {
        size.width = width;
    }
    
    if (!isnan(height)) {
        size.height = height;
    }
    
//TODO: I think it's a bug of css-layout(min/max), we must fix it ourself now.
    size.width = dimensionClamp(layout.minWidth,layout.maxWidth,size.width);
    size.height = dimensionClamp(layout.minHeight,layout.maxHeight,size.height);
    size = [self sizeThatFits:size];
    //TODO: maybe the size will be narrowed because of `roundPixelValue`
//    size.width = ceil(size.width);
//    size.height = ceil(size.height);
    return size;
}

@end
