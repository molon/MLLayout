//
//  UIView+DeallocCallbackForMLLayout.m
//
//  Created by molon on 16/6/23.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIView+DeallocCallbackForMLLayout.h"
#import <objc/runtime.h>
#import "MLLayout.h"
#import "MLLayoutMacro.h"

MLLAYOUT_SYNTH_DUMMY_CLASS(UIView_DeallocCallbackForMLLayout)

@interface DeallocCallbackObjectForMLLayout : NSObject

@property (nonatomic, weak) MLLayout *layout;
@property (nonatomic, copy) void(^deallocCallback)(MLLayout *layout);

@end

@implementation DeallocCallbackObjectForMLLayout

- (void)dealloc {
    if (_layout&&_deallocCallback) {
        _deallocCallback(_layout);
    }
}

@end

@interface UIView()

@property (nonatomic, strong) NSMutableArray *mlLayout_deallocCallbackObjects;

@end

@implementation UIView (DeallocCallbackForMLLayout)

MLLAYOUT_SYNTH_DYNAMIC_PROPERTY_OBJECT(mlLayout_deallocCallbackObjects, setMlLayout_deallocCallbackObjects:, RETAIN_NONATOMIC, NSMutableArray*)

- (void)mlLayout_setDeallocCallback:(void(^)(MLLayout *l))callback forLayout:(MLLayout*)layout {
    NSParameterAssert(layout);
    NSParameterAssert(callback);
    NSAssert([layout.view isEqual:self], @"`layout.view` must be equal to the callee with `mlLayout_setDeallocCallback:forLayout:` ");
    
    if (!self.mlLayout_deallocCallbackObjects) {
        self.mlLayout_deallocCallbackObjects = [NSMutableArray array];
    }
    
    DeallocCallbackObjectForMLLayout *object = [self mlLayout_deallocCallbackObjectForMLLayout:layout];
    if (!object) {
        object = [DeallocCallbackObjectForMLLayout new];
        object.layout = layout;
    }
    [object setDeallocCallback:callback];
    
    [self.mlLayout_deallocCallbackObjects addObject:object];
}

- (void)mlLayout_removeDeallocCallbackForLayout:(MLLayout *)layout {
    DeallocCallbackObjectForMLLayout *object = [self mlLayout_deallocCallbackObjectForMLLayout:layout];
    object.deallocCallback = nil;
    [self.mlLayout_deallocCallbackObjects removeObject:object];
}

- (DeallocCallbackObjectForMLLayout *)mlLayout_deallocCallbackObjectForMLLayout:(MLLayout*)layout {
    for (DeallocCallbackObjectForMLLayout *object in self.mlLayout_deallocCallbackObjects) {
        if ([object.layout isEqual:layout]) {
            return object;
        }
    }
    return nil;
}

@end
