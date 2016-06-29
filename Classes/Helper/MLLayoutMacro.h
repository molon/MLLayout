//
//  MLLayoutMacro.h
//
//  Created by molon on 16/6/24.
//  Copyright © 2016年 molon. All rights reserved.
//

#ifndef MLLayoutMacro_h
#define MLLayoutMacro_h

#define MLLAYOUT_SYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
return objc_getAssociatedObject(self, @selector(_setter_)); \
}

#define MLLAYOUT_SYNTH_DUMMY_CLASS(_name_) \
@interface SYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation SYNTH_DUMMY_CLASS_ ## _name_ @end

#endif /* MLLayoutMacro_h */
