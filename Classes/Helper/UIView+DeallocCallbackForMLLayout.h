//
//  UIView+DeallocCallbackForMLLayout.h
//
//  Created by molon on 16/6/23.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MLLayout;
@interface UIView (DeallocCallbackForMLLayout)

- (void)mlLayout_setDeallocCallback:(void(^)(MLLayout *l))callback forLayout:(MLLayout*)layout;
- (void)mlLayout_removeDeallocCallbackForLayout:(MLLayout *)layout;

@end

NS_ASSUME_NONNULL_END