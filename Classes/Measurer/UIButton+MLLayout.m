//
//  UIButton+MLLayout.m
//
//  Created by molon on 16/6/23.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIButton+MLLayout.h"
#import "MLLayout.h"
#import "MLLayoutMacro.h"

MLLAYOUT_SYNTH_DUMMY_CLASS(UIButton_MLLayout)

@implementation UIButton (MLLayout)

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
    
    /*
     As it says in the documentation, for `titleEdgeInsets`: 
     "The button does not use this property to determine intrinsicContentSize and sizeThatFits:". 
     So, setting the `titleEdgeInsets` just moves the title label, but doesn't affect the size of the button.
     If you want the button to have more padding around the content, set the `contentEdgeInsets` as well.
     [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
     [button setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 4)];
     
     see: http://stackoverflow.com/a/28287773/2847401
     */
    size = [self sizeThatFits:size];
    //TODO: maybe the size will be narrowed because of `roundPixelValue`
    //    size.width = ceil(size.width);
    //    size.height = ceil(size.height);
    return size;
}

@end
