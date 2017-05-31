//
//  UIControl+MLLayout.m
//  Pods
//
//  Created by molon on 2017/5/31.
//
//

#import "UIControl+MLLayout.h"
#import "MLLayoutMacro.h"

MLLAYOUT_SYNTH_DUMMY_CLASS(UIControl_MLLayout)

@implementation UIControl (MLLayout)

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
     If self is UIButton
     As it says in the documentation, for `titleEdgeInsets`:
     "The button does not use this property to determine intrinsicContentSize and sizeThatFits:".
     So, setting the `titleEdgeInsets` just moves the title label, but doesn't affect the size of the button.
     If you want the button to have more padding around the content, set the `contentEdgeInsets` as well.
     [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
     [button setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 4)];
     
     see: http://stackoverflow.com/a/28287773/2847401
     */
    CGSize fitSize = [self sizeThatFits:size];
    
    //maybe the fit result is bigger than measure size
    fitSize.width = fmin(size.width, fitSize.width);
    fitSize.height = fmin(size.height, fitSize.height);
    
    return fitSize;
}

@end
