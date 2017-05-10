//
//  UIButton+MLLayout.h
//
//  Created by molon on 16/6/23.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLLayout.h"

@interface UIButton (MLLayout)
- (CGSize)measureWithMLLayout:(MLLayout*)layout width:(CGFloat)width widthMode:(MLLayoutMeasureMode)widthMode height:(CGFloat)height heightMode:(MLLayoutMeasureMode)heightMode;
@end
