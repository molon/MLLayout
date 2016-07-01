//
//  MLLayout.m
//
//  Created by molon on 16/6/20.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLLayout.h"
#import "Layout.h"
#import "UIView+DeallocCallbackForMLLayout.h"

const CGFloat kMLLayoutUndefined = NAN;
const NSInteger kMLLayoutInvalidTag = -1;

BOOL isMLLayoutUndefined(CGFloat value) {
    return isUndefined((float)value)?YES:NO;
}

CGFloat dimensionClamp(CGFloat min,CGFloat max,CGFloat dimension){
    if (!isnan(min)) {
        dimension = fmax(min, dimension);
    }
    if (!isnan(max)) {
        dimension = fmin(max, dimension);
    }
    return dimension;
}

typedef NS_ENUM(NSUInteger, MLLayoutLifecycle) {
    MLLayoutLifecycleUninitialized = 0,
    MLLayoutLifecycleComputed,
    MLLayoutLifecycleDirtied,
};

/**
 for `updatedLayoutsAfterLayoutCalculationWithFrame:`
 */
typedef struct {
    css_position_type_t position_type;
    float x; //position[CSS_LEFT]
    float y; //position[CSS_TOP]
    float width; //dimensions[CSS_WIDTH]
    float height; //dimensions[CSS_HEIGHT]
} style_frame_record_t;

static inline style_frame_record_t getLayoutFrameRecord(css_node_t *node) {
    return (style_frame_record_t){
        node->style.position_type,
        node->style.position[CSS_LEFT],
        node->style.position[CSS_TOP],
        node->style.dimensions[CSS_WIDTH],
        node->style.dimensions[CSS_HEIGHT],
    };
}

static inline void setLayoutFrameRecord(css_node_t *node,style_frame_record_t *record) {
    node->style.position_type = record->position_type;
    node->style.position[CSS_LEFT] = record->x;
    node->style.position[CSS_TOP] = record->y;
    node->style.dimensions[CSS_WIDTH] = record->width;
    node->style.dimensions[CSS_HEIGHT] = record->height;
}

static inline CGFloat screenScale() {
    static CGFloat screenScale = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([NSThread isMainThread]) {
            screenScale = [[UIScreen mainScreen] scale];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                screenScale = [[UIScreen mainScreen] scale];
            });
        }
    });
    return screenScale;
}

static inline CGFloat roundPixelValue(CGFloat value) {
    CGFloat scale = screenScale();
    return round(value * scale) / scale;
}

static inline CGRect roundPixelRect(CGRect rect) {
    return CGRectMake(roundPixelValue(rect.origin.x),
                      roundPixelValue(rect.origin.y),
                      roundPixelValue(rect.size.width),
                      roundPixelValue(rect.size.height));
}

static inline BOOL isRectEqualToRect (CGRect r1,CGRect r2) {
    if (r1.origin.x!=r2.origin.x&&(!(isnan(r1.origin.x)&&isnan(r2.origin.x)))) {
        return NO;
    }
    if (r1.origin.y!=r2.origin.y&&(!(isnan(r1.origin.y)&&isnan(r2.origin.y)))) {
        return NO;
    }
    if (r1.size.width!=r2.size.width&&(!(isnan(r1.size.width)&&isnan(r2.size.width)))) {
        return NO;
    }
    if (r1.size.height!=r2.size.height&&(!(isnan(r1.size.height)&&isnan(r2.size.height)))) {
        return NO;
    }
    return YES;
}

@interface MLLayout()

@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign) CGRect frame;

@property (nonatomic, assign) CGRect lastMeasureFrame;

@property (nonatomic, assign) MLLayoutLifecycle layoutLifecycle;

//Please dont access the property with _validSublayouts.
//See -(NSArray*)validSublayouts
@property (nonatomic, strong) NSArray<MLLayout*> *validSublayouts;

- (css_node_t *)node;

@end

static void printLayout(void *context) {
    MLLayout *self = (__bridge MLLayout *)context;
    printf("class: '%s(%ld)', ", (self.view?NSStringFromClass(self.view.class):@"MLLayoutHelper").UTF8String,(long)self.tag);
}

static bool isDirty(void *context) {
    MLLayout *self = (__bridge MLLayout *)context;
    return [self isLayoutDirty];
}

static css_node_t *getSubNode(void *context, int i) {
    MLLayout *self = (__bridge MLLayout *)context;
    MLLayout *child = self.validSublayouts[i];
    return [child node];
}

static css_dim_t measureNode(void *context, float width, css_measure_mode_t widthMode, float height, css_measure_mode_t heightMode) {
    MLLayout *self = (__bridge MLLayout *)context;
    CGSize size = CGSizeZero;
    if (self.measure) {
        size = self.measure(self,width,(MLLayoutMeasureMode)widthMode,height,(MLLayoutMeasureMode)heightMode);
    }else if (self.view) {
        if ([self.view respondsToSelector:@selector(measureWithMLLayout:width:widthMode:height:heightMode:)]) {
            size = [(id<MLLayoutMeasure>)(self.view) measureWithMLLayout:self width:width widthMode:(MLLayoutMeasureMode)widthMode height:height heightMode:(MLLayoutMeasureMode)heightMode];
        }
    }
    return (css_dim_t){ size.width, size.height };
}

@implementation MLLayout {
    css_node_t *_node;
}

#pragma mark - life style
- (instancetype)init {
    self = [super init];
    if (self) {
        _tag = kMLLayoutInvalidTag;
        _layoutLifecycle = MLLayoutLifecycleUninitialized;
        
        _node = new_css_node();
        _node->context = (__bridge void *)self;
        _node->is_dirty = isDirty;
        _node->get_child = getSubNode;
        _node->print = printLayout;
    }
    return self;
}

- (instancetype)initWithNoNode {
    self = [super init];
    if (self) {
        _tag = kMLLayoutInvalidTag;
        _layoutLifecycle = MLLayoutLifecycleUninitialized;
    }
    return self;
}

+ (instancetype)layoutWithView:(UIView*)view block:(void (^)(MLLayout *layout))block {
    MLLayout *layout = [MLLayout new];
    layout.view = view;
    if (block) {
        block(layout);
    }
    return layout;
}

+ (instancetype)layoutWithTagView:(nullable UIView*)tagView block:(nullable void (^)(MLLayout *l))block {
    NSAssert(!tagView||(tagView.tag!=0&&tagView.tag!=kMLLayoutInvalidTag), @"\n\n`layoutWithTagView:block:`\nTag of tagView:\n---------\n%@\n--------\nmust be not 0/-1.\n\n",tagView);
    
    //TODO: maybe the view's tag will be changed future. we dont want views must retain mllayout,so we dont use KVO. need another way
    return [self layoutWithView:tagView block:block];
}

- (void)dealloc {
    free_css_node(_node);
}

#pragma mark - dirty
- (BOOL)isLayoutDirty {
    return _layoutLifecycle!=MLLayoutLifecycleComputed;
}

- (void)dirtyLayout {
    //    if (_layoutLifecycle!=MLLayoutLifecycleDirtied) {
    _layoutLifecycle = MLLayoutLifecycleDirtied;
    //    }
    [_superlayout dirtyLayout];
}

- (void)dirtyDescendants {
    for (MLLayout *sublayout in _sublayouts) {
        //        if (sublayout->_layoutLifecycle!=MLLayoutLifecycleDirtied) {
        sublayout->_layoutLifecycle = MLLayoutLifecycleDirtied;
        //        }
        [sublayout dirtyDescendants];
    }
}

- (void)dirtyAllRelatedLayouts {
    [self dirtyLayout];
    [self dirtyDescendants];
}

- (void)dirtyLayoutWithView:(UIView*)view {
    [[self retrieveLayoutWithView:view]dirtyLayout];
}

#pragma mark - helper
- (void)fillChildrenCountForNode {
    _node->children_count = (int)self.validSublayouts.count;
}

- (void)resetValidSublayouts {
    _validSublayouts = nil;
    [self fillChildrenCountForNode];
}

- (MLLayout*)retrieveDescendantWithView:(UIView*)view {
    MLLayout *resultLayout = nil;
    for (MLLayout *sublayout in _sublayouts) {
        if ([sublayout->_view isEqual:view]) {
            return sublayout;
        }else{
            resultLayout = [sublayout retrieveDescendantWithView:view];
            if (resultLayout) {
                return resultLayout;
            }
        }
    }
    return nil;
}

- (MLLayout*)retrieveAncestorWithView:(UIView*)view {
    MLLayout *superlayout = _superlayout;
    while (superlayout) {
        if ([superlayout->_view isEqual:view]) {
            return superlayout;
        }
        superlayout = superlayout->_superlayout;
    }
    
    return nil;
}

- (MLLayout*)retrieveLayoutWithView:(UIView*)view {
    if ([_view isEqual:view]) {
        return self;
    }
    
    MLLayout *resultLayout = [self retrieveDescendantWithView:view];
    if (!resultLayout) {
        return [self retrieveAncestorWithView:view];
    }
    return resultLayout;
}

- (NSArray*)retrieveDescendantsPassingTest:(BOOL (^)(MLLayout *layout))comparator {
    NSMutableArray *layouts = [NSMutableArray array];
    for (MLLayout *sublayout in _sublayouts) {
        if (comparator(sublayout)) {
            [layouts addObject:comparator];
        }
        [layouts addObjectsFromArray:[sublayout retrieveDescendantsPassingTest:comparator]];
    }
    return layouts;
}

- (void)removeFromSuperlayout {
    if (!_superlayout) {
        return;
    }
    [self dirtyLayout];
    
    [((NSMutableArray*)_superlayout->_sublayouts) removeObject:self];
    [_superlayout resetValidSublayouts];
    _superlayout = nil;
}

- (void)insertSublayout:(MLLayout*)sublayout atIndex:(NSInteger)index {
    [((NSMutableArray*)_sublayouts) insertObject:sublayout atIndex:index];
    [self resetValidSublayouts];
    sublayout->_superlayout = self;
    
    [sublayout dirtyLayout];
}

- (void)addSublayout:(MLLayout*)sublayout {
    [self insertSublayout:sublayout atIndex:_sublayouts.count];
}

- (void)applyTagViewsWithRootView:(UIView*)rootView {
    if (_tag!=kMLLayoutInvalidTag) {
        NSArray *views = rootView.superview?rootView.superview.subviews:(rootView?@[rootView]:nil);
        __block UIView *view;
        [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (((UIView*)obj).tag==_tag) {
                view = obj;
                *stop = YES;
            }
        }];
        NSAssert(view, @"\n\n`applyTagViewsWithRootView:`\nThe layout:\n-------\n%@\n--------\nmust be accompanied by one corresponding view.\n\n",self);
        
        self.view = view;
    }else{
        self.view = nil;
    }
    
    for (MLLayout *sublayout in _sublayouts) {
        [sublayout applyTagViewsWithRootView:_view==nil?rootView:[_view.subviews firstObject]];
    }
}

#pragma mark - debug description
- (NSString*)debugDescriptionWithMode:(MLLayoutDebugMode)mode depth:(NSInteger)depth {
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@(%ld):",_view?NSStringFromClass(_view.class):@"MLLayoutHelper",(long)_tag];
    if (_invalid) {
        [description insertString:@"Invalid->" atIndex:0];
    }
    if (!_invalid) {
        if (mode & MLLayoutDebugModeViewLayoutFrame) {
            [description appendFormat:@" vframe=%@", NSStringFromCGRect(_frame)];
        }
        if (mode & MLLayoutDebugModeOriginalLayoutFrame) {
            [description appendFormat:@" lframe=%@", NSStringFromCGRect([self layoutFrame])];
        }
    }
    if (mode & MLLayoutDebugModeStyle) {
        [description appendFormat:@" style={%@}",self.style];
    }
    if (_sublayouts.count > 0) {
        if ((mode & MLLayoutDebugModeSublayout)&&!_invalid) {
            NSMutableString *indent = [NSMutableString string];
            for (NSInteger i = 0; i < depth+1; i++) {
                [indent appendFormat:@"\t"];
            }
            
            for (MLLayout *sublayout in _sublayouts) {
                [description appendFormat:@"\n%@%@", indent, [sublayout debugDescriptionWithMode:mode depth:depth+1]];
            }
            return description;
        }else{
            [description appendFormat:@" sublayouts:%lu",(unsigned long)_sublayouts.count];
        }
    }
    if ([description hasSuffix:@":"]) {
        [description deleteCharactersInRange:NSMakeRange(description.length-1, 1)];
    }
    return description;
}

- (NSString*)debugDescriptionWithMode:(MLLayoutDebugMode)mode {
    return [self debugDescriptionWithMode:mode depth:0];
}

#pragma mark - layout
- (NSMutableSet<MLLayout *> *)updatedLayoutsAfterLayoutCalculationWithFrame:(CGRect)frame {
    NSAssert(_superlayout==nil, @"`updatedLayoutsAfterLayoutCalculationWithFrame:` method only support for root layout");
    NSAssert(!_invalid, @"`updatedLayoutsAfterLayoutCalculationWithFrame:` method doesnt support for invalid layout!");
    
    //round pixel
    frame = roundPixelRect(frame);
    
    // Need to restore after layoutNode
    style_frame_record_t record = getLayoutFrameRecord(_node);
    style_frame_record_t *pOrigFrameRecord = &record;
    
    // Ensure the frame record below to layout
    style_frame_record_t newFrameRecord = (style_frame_record_t){CSS_POSITION_ABSOLUTE,frame.origin.x,frame.origin.y,frame.size.width,frame.size.height};
    setLayoutFrameRecord(_node, &newFrameRecord);
    
    if (!isRectEqualToRect(frame, _lastMeasureFrame)) {
        _lastMeasureFrame = frame;
        
        // The method is only for root layout
        // So there's no need to dirty our ancestors by calling dirtyLayout.
        _layoutLifecycle = MLLayoutLifecycleDirtied;
    }
    
    layoutNode(_node, frame.size.width, frame.size.height, CSS_DIRECTION_INHERIT);
    
    NSMutableSet *updatedLayouts = [NSMutableSet set];
    [self applyLayoutWithUpdatedLayouts:updatedLayouts layoutHelperOffset:CGPointZero absolutePosition:CGPointZero];
    
    //restore original frame record
    setLayoutFrameRecord(_node, pOrigFrameRecord);
    
    return updatedLayouts.count>0?updatedLayouts:nil;
}

// support only rounded values see: https://github.com/facebook/react-native/blob/fe5c0d2d0696b4fc5cdd65f1f2198c4f4363e543/React/Views/RCTShadowView.m#L95-L161
// The absolute stuff is so that we can take into account our absolute position when rounding in order to
// snap to the pixel grid. For example, say you have the following structure:
//
// +--------+---------+--------+
// |        |+-------+|        |
// |        ||       ||        |
// |        |+-------+|        |
// +--------+---------+--------+
//
// Say the screen width is 320 pts so the three big views will get the following x bounds from our layout system:
// {0, 106.667}, {106.667, 213.333}, {213.333, 320}
//
// Assuming screen scale is 2, these numbers must be rounded to the nearest 0.5 to fit the pixel grid:
// {0, 106.5}, {106.5, 213.5}, {213.5, 320}
// You'll notice that the three widths are 106.5, 107, 106.5.
//
// This is great for the parent views but it gets trickier when we consider rounding for the subview.
//
// When we go to round the bounds for the subview in the middle, it's relative bounds are {0, 106.667}
// which gets rounded to {0, 106.5}. This will cause the subview to be one pixel smaller than it should be.
// this is why we need to pass in the absolute position in order to do the rounding relative to the screen's
// grid rather than the view's grid.
//
// After passing in the absolutePosition of {106.667, y}, we do the following calculations:
// absoluteLeft = round(absolutePosition.x + viewPosition.left) = round(106.667 + 0) = 106.5
// absoluteRight = round(absolutePosition.x + viewPosition.left + viewSize.left) + round(106.667 + 0 + 106.667) = 213.5
// width = 213.5 - 106.5 = 107
// You'll notice that this is the same width we calculated for the parent view because we've taken its position into account.
- (void)applyLayoutWithUpdatedLayouts:(NSMutableSet<MLLayout *> *)updatedLayoutsWithNewFrame layoutHelperOffset:(CGPoint)layoutHelperOffset
                     absolutePosition:(CGPoint)absolutePosition {
    if (!_node->layout.should_update&&CGPointEqualToPoint(CGPointZero, layoutHelperOffset)) {
        return;
    }
    _node->layout.should_update = false;
    _layoutLifecycle = MLLayoutLifecycleComputed;
    
    CGPoint absoluteTopLeft = {
        absolutePosition.x + _node->layout.position[CSS_LEFT] + layoutHelperOffset.x,
        absolutePosition.y + _node->layout.position[CSS_TOP] + layoutHelperOffset.y
    };
    
    CGPoint absoluteBottomRight = {
        absolutePosition.x + _node->layout.position[CSS_LEFT] + layoutHelperOffset.x + _node->layout.dimensions[CSS_WIDTH],
        absolutePosition.y + _node->layout.position[CSS_TOP] + layoutHelperOffset.y + _node->layout.dimensions[CSS_HEIGHT]
    };
    
    CGRect frame = {{
        roundPixelValue(_node->layout.position[CSS_LEFT] + layoutHelperOffset.x),
        roundPixelValue(_node->layout.position[CSS_TOP] + layoutHelperOffset.y),
    }, {
        roundPixelValue(absoluteBottomRight.x - absoluteTopLeft.x),
        roundPixelValue(absoluteBottomRight.y - absoluteTopLeft.y)
    }};
    
    _frame = frame;
    
    //_view.frame is not equal indicates update
    if (_view&&!CGRectEqualToRect(_view.frame, _frame)) {
        [updatedLayoutsWithNewFrame addObject:self];
    }
//    if (!CGRectEqualToRect(frame, _frame)) {
//        _frame = frame;
//        if (_view) {
//            [updatedLayoutsWithNewFrame addObject:self];
//        }
//    }
    
    absolutePosition.x += _node->layout.position[CSS_LEFT] + layoutHelperOffset.x;
    absolutePosition.y += _node->layout.position[CSS_TOP] + layoutHelperOffset.y;
    
    //if _view is nil, pass orgin to sublayouts
    layoutHelperOffset = !_view?frame.origin:CGPointZero;
    for (MLLayout *sublayout in self.validSublayouts) {
        [sublayout applyLayoutWithUpdatedLayouts:updatedLayoutsWithNewFrame layoutHelperOffset:layoutHelperOffset absolutePosition:absolutePosition];
    }
}

- (void)layoutViewsWithUpdatedLayouts:(NSMutableSet<MLLayout *> *)updatedLayouts {
    for (MLLayout *layout in updatedLayouts) {
        if (!layout->_invalid) {
            layout->_view.frame = layout->_frame;
        }
    }
}

- (void)layoutViewsWithFrame:(CGRect)frame {
    [self layoutViewsWithUpdatedLayouts:[self updatedLayoutsAfterLayoutCalculationWithFrame:frame]];
}

- (void)dirtyAllRelatedLayoutsAndLayoutViewsWithFrame:(CGRect)frame {
    [self dirtyAllRelatedLayouts];
    [self layoutViewsWithFrame:frame];
}

#pragma mark - getter
- (css_node_t *)node
{
    return _node;
}

- (BOOL)hasMeasure {
    return _measure||[_view respondsToSelector:@selector(measureWithMLLayout:width:widthMode:height:heightMode:)];
}

- (NSArray<MLLayout*>*)validSublayouts {
    if (_validSublayouts) {
        return _validSublayouts;
    }
    
    NSMutableArray<MLLayout*> *subs = [NSMutableArray array];
    for (MLLayout *sublayout in _sublayouts) {
        if (!sublayout.invalid) {
            [subs addObject:sublayout];
        }
    }
    _validSublayouts = subs;
    return subs;
}

//- (MLLayout*)rootLayout {
//    MLLayout *superlayout = self;
//    while (superlayout->_superlayout) {
//        superlayout = superlayout->_superlayout;
//    }
//    return superlayout;
//}

// the original frame after layout calculation without treating with layout helper offset,see `applyLayoutWithUpdatedLayouts:layoutHelperOffset:`
- (CGRect)layoutFrame {
    return (CGRect){{
        _node->layout.position[CSS_LEFT],
        _node->layout.position[CSS_TOP],
    }, {
        _node->layout.dimensions[CSS_WIDTH],
        _node->layout.dimensions[CSS_HEIGHT],
    }};
}

- (NSString*)style {
    NSMutableString *style = [@"" mutableCopy];
    
    void (^append_string)(const char* str) = ^(const char* str) {
        [style appendFormat:@"%s",str];
    };
    
    void (^append_number_nan)(const char* str, float number) = ^(const char* str, float number) {
        if (!isnan(number)) {
            [style appendFormat:@"%s: %g, ",str,number];
        }
    };
    
    bool (^eq)(float a, float b) = ^(float a, float b) {
        if (isUndefined(a)) {
            return isUndefined(b);
        }
        return (bool)(fabs(a - b) < 0.0001);
    };
    
    void (^append_number_0)(const char* str, float number) = ^(const char* str, float number) {
        if (!eq(number, 0)) {
            [style appendFormat:@"%s: %g, ",str,number];
        }
    };
    
    bool (^four_equal)(float four[4]) = ^(float four[4]) {
        return
        (bool)(eq(four[0], four[1]) &&
               eq(four[0], four[2]) &&
               eq(four[0], four[3]));
    };
    
    if (_node->style.flex_direction == CSS_FLEX_DIRECTION_COLUMN) {
        append_string("flexDirection: 'column', ");
    } else if (_node->style.flex_direction == CSS_FLEX_DIRECTION_COLUMN_REVERSE) {
        append_string("flexDirection: 'column-reverse', ");
    } else if (_node->style.flex_direction == CSS_FLEX_DIRECTION_ROW) {
        append_string("flexDirection: 'row', ");
    } else if (_node->style.flex_direction == CSS_FLEX_DIRECTION_ROW_REVERSE) {
        append_string("flexDirection: 'row-reverse', ");
    }
    
    if (_node->style.justify_content == CSS_JUSTIFY_CENTER) {
        append_string("justifyContent: 'center', ");
    } else if (_node->style.justify_content == CSS_JUSTIFY_FLEX_END) {
        append_string("justifyContent: 'flex-end', ");
    } else if (_node->style.justify_content == CSS_JUSTIFY_SPACE_AROUND) {
        append_string("justifyContent: 'space-around', ");
    } else if (_node->style.justify_content == CSS_JUSTIFY_SPACE_BETWEEN) {
        append_string("justifyContent: 'space-between', ");
    }
    
    if (_node->style.align_items == CSS_ALIGN_CENTER) {
        append_string("alignItems: 'center', ");
    } else if (_node->style.align_items == CSS_ALIGN_FLEX_END) {
        append_string("alignItems: 'flex-end', ");
    } else if (_node->style.align_items == CSS_ALIGN_STRETCH) {
        append_string("alignItems: 'stretch', ");
    }
    
    if (_node->style.align_content == CSS_ALIGN_CENTER) {
        append_string("alignContent: 'center', ");
    } else if (_node->style.align_content == CSS_ALIGN_FLEX_END) {
        append_string("alignContent: 'flex-end', ");
    } else if (_node->style.align_content == CSS_ALIGN_STRETCH) {
        append_string("alignContent: 'stretch', ");
    }
    
    if (_node->style.align_self == CSS_ALIGN_FLEX_START) {
        append_string("alignSelf: 'flex-start', ");
    } else if (_node->style.align_self == CSS_ALIGN_CENTER) {
        append_string("alignSelf: 'center', ");
    } else if (_node->style.align_self == CSS_ALIGN_FLEX_END) {
        append_string("alignSelf: 'flex-end', ");
    } else if (_node->style.align_self == CSS_ALIGN_STRETCH) {
        append_string("alignSelf: 'stretch', ");
    }
    
    append_number_nan("flex", _node->style.flex);
    
    //    if (_node->style.overflow == CSS_OVERFLOW_HIDDEN) {
    //        append_string("overflow: 'hidden', ");
    //    } else if (_node->style.overflow == CSS_OVERFLOW_VISIBLE) {
    //        append_string("overflow: 'visible', ");
    //    }
    
    append_number_nan("marginStart", _node->style.margin[CSS_START]);
    append_number_nan("marginEnd", _node->style.margin[CSS_END]);
    if (four_equal(_node->style.margin)) {
        append_number_0("margin", _node->style.margin[CSS_LEFT]);
    } else {
        append_number_0("marginLeft", _node->style.margin[CSS_LEFT]);
        append_number_0("marginRight", _node->style.margin[CSS_RIGHT]);
        append_number_0("marginTop", _node->style.margin[CSS_TOP]);
        append_number_0("marginBottom", _node->style.margin[CSS_BOTTOM]);
    }
    
    append_number_nan("paddingStart", _node->style.padding[CSS_START]);
    append_number_nan("paddingEnd", _node->style.padding[CSS_END]);
    if (four_equal(_node->style.padding)) {
        append_number_0("padding", _node->style.padding[CSS_LEFT]);
    } else {
        append_number_0("paddingLeft", _node->style.padding[CSS_LEFT]);
        append_number_0("paddingRight", _node->style.padding[CSS_RIGHT]);
        append_number_0("paddingTop", _node->style.padding[CSS_TOP]);
        append_number_0("paddingBottom", _node->style.padding[CSS_BOTTOM]);
    }
    
    //    if (four_equal(_node->style.border)) {
    //        append_number_0("borderWidth", _node->style.border[CSS_LEFT]);
    //    } else {
    //        append_number_0("borderLeftWidth", _node->style.border[CSS_LEFT]);
    //        append_number_0("borderRightWidth", _node->style.border[CSS_RIGHT]);
    //        append_number_0("borderTopWidth", _node->style.border[CSS_TOP]);
    //        append_number_0("borderBottomWidth", _node->style.border[CSS_BOTTOM]);
    //        append_number_nan("borderStartWidth", _node->style.border[CSS_START]);
    //        append_number_nan("borderEndWidth", _node->style.border[CSS_END]);
    //    }
    
    append_number_nan("width", _node->style.dimensions[CSS_WIDTH]);
    append_number_nan("height", _node->style.dimensions[CSS_HEIGHT]);
    append_number_nan("maxWidth", _node->style.maxDimensions[CSS_WIDTH]);
    append_number_nan("maxHeight", _node->style.maxDimensions[CSS_HEIGHT]);
    append_number_nan("minWidth", _node->style.minDimensions[CSS_WIDTH]);
    append_number_nan("minHeight", _node->style.minDimensions[CSS_HEIGHT]);
    
    if (_node->style.position_type == CSS_POSITION_ABSOLUTE) {
        append_string("position: 'absolute', ");
    }
    
    append_number_nan("left", _node->style.position[CSS_LEFT]);
    append_number_nan("right", _node->style.position[CSS_RIGHT]);
    append_number_nan("top", _node->style.position[CSS_TOP]);
    append_number_nan("bottom", _node->style.position[CSS_BOTTOM]);
    
    if ([style hasSuffix:@", "]) {
        [style deleteCharactersInRange:NSMakeRange(style.length-2, 2)];
    }
    return style;
}

- (NSString*)description {
    return [self debugDescriptionWithMode:MLLayoutDebugModeViewLayoutFrame|MLLayoutDebugModeOriginalLayoutFrame|MLLayoutDebugModeStyle];
}

#pragma mark - setter

- (void)setView:(UIView *)view {
    NSAssert(view.tag!=kMLLayoutInvalidTag, @"\n\n`setView:`\nTag of view:\n---------\n%@\n--------\nmust be not -1.\n\n",view);
    
    if (_view) {
        [_view mlLayout_removeDeallocCallbackForLayout:self];
    }
    
    _view = view;
    
    if (view) {
        _tag = view.tag;
        
        //dealloc notification (because _view is a weak property)
        [view mlLayout_setDeallocCallback:^(MLLayout *l) {
            l.view = nil;
        } forLayout:self];
    }
    //`view` is readonly, the last view tag is always valid, dont need to reset to invalid
    //    else{
    //        _tag = kMLLayoutInvalidTag;
    //    }
    
    _node->measure = [self hasMeasure]?measureNode:NULL;
    
    [self dirtyLayout];
}

- (void)setMeasure:(CGSize (^)(MLLayout * _Nonnull, CGFloat, MLLayoutMeasureMode, CGFloat, MLLayoutMeasureMode))measure
{
    _measure = [measure copy];
    
    _node->measure = [self hasMeasure]?measureNode:NULL;
    
    [self dirtyLayout];
}

- (void)setSublayouts:(NSArray * _Nullable)sublayouts {
#ifdef DEBUG
    // whether the sublayout's views is descendant of ancestors'view
    MLLayout *closeAncestor = self;
    while (closeAncestor&&closeAncestor->_view==nil) {
        closeAncestor = closeAncestor->_superlayout;
    }
    
    if (closeAncestor) {
        for (MLLayout *sublayout in sublayouts) {
            NSAssert(!sublayout->_view||(sublayout->_view!=closeAncestor->_view&&[sublayout->_view isDescendantOfView:closeAncestor->_view]), @"\n\n`setSublayouts:`\nA sublayout's view(%@):----------------\n%@\n----------------\nmust be descendant of close ancestor'view(%@):----------------\n%@\n----------------\nor nil\n\n",NSStringFromClass(sublayout->_view.class),sublayout->_view,NSStringFromClass(closeAncestor->_view.class),closeAncestor->_view);
        }
    }
    
    NSMutableArray *views = [NSMutableArray array];
    // whether sublayout already has its own superlayout.
    // whether multi sublayouts associate same view
    for (MLLayout *sublayout in sublayouts) {
        NSAssert(!sublayout->_superlayout, @"\n\n`setSublayouts:`\nA sublayout already has its own superlayout.\n\n");
        if (sublayout->_view) {
            NSAssert(![views containsObject:sublayout->_view], @"\n\n`setSublayouts:`\nThe view(%@):\n-------\n%@\n--------\nhas been associated to multi layouts.\n\n",NSStringFromClass(sublayout->_view.class),sublayout->_view);
            [views addObject:sublayout->_view];
        }
    }
    views = nil;
#endif
    _sublayouts = [sublayouts mutableCopy];
    for (MLLayout *sublayout in _sublayouts) {
        sublayout->_superlayout = self;
        //dirty directly
        sublayout->_layoutLifecycle = MLLayoutLifecycleDirtied;
    }
    
    [self resetValidSublayouts];
    
    [self dirtyLayout];
}

- (void)setInvalid:(BOOL)invalid {
    _invalid = invalid;
    
    [_superlayout resetValidSublayouts];
    
    [self dirtyLayout];
}

#pragma mark - css getter and setter

#define ARRAY_FLOAT_PROPERTY(styleProp, setProp, getProp, cssProp) \
- (void)set##setProp:(CGFloat)value { \
_node->style.styleProp[CSS_##cssProp] = value; \
[self dirtyLayout];                                    \
}                                                        \
- (CGFloat)getProp  {  \
return _node->style.styleProp[CSS_##cssProp];        \
}

ARRAY_FLOAT_PROPERTY(dimensions, Width, width, WIDTH)
ARRAY_FLOAT_PROPERTY(dimensions, Height, height, HEIGHT)

ARRAY_FLOAT_PROPERTY(minDimensions, MinWidth, minWidth, WIDTH)
ARRAY_FLOAT_PROPERTY(minDimensions, MinHeight, minHeight, HEIGHT)

ARRAY_FLOAT_PROPERTY(maxDimensions, MaxWidth, maxWidth, WIDTH)
ARRAY_FLOAT_PROPERTY(maxDimensions, MaxHeight, maxHeight, HEIGHT)

ARRAY_FLOAT_PROPERTY(position, Left, left, LEFT)
ARRAY_FLOAT_PROPERTY(position, Right, right, RIGHT)
ARRAY_FLOAT_PROPERTY(position, Top, top, TOP)
ARRAY_FLOAT_PROPERTY(position, Bottom, bottom, BOTTOM)

ARRAY_FLOAT_PROPERTY(margin, MarginTop, marginTop, TOP)
ARRAY_FLOAT_PROPERTY(margin, MarginLeft, marginLeft, LEFT)
ARRAY_FLOAT_PROPERTY(margin, MarginBottom, marginBottom, BOTTOM)
ARRAY_FLOAT_PROPERTY(margin, MarginRight, marginRight, RIGHT)

ARRAY_FLOAT_PROPERTY(margin, MarginStart, marginStart, START)
ARRAY_FLOAT_PROPERTY(margin, MarginEnd, marginEnd, END)

ARRAY_FLOAT_PROPERTY(padding, PaddingTop, paddingTop, TOP)
ARRAY_FLOAT_PROPERTY(padding, PaddingLeft, paddingLeft, LEFT)
ARRAY_FLOAT_PROPERTY(padding, PaddingBottom, paddingBottom, BOTTOM)
ARRAY_FLOAT_PROPERTY(padding, PaddingRight, paddingRight, RIGHT)

ARRAY_FLOAT_PROPERTY(padding, PaddingStart, paddingStart, START)
ARRAY_FLOAT_PROPERTY(padding, PaddingEnd, paddingEnd, END)

#define EDGE_INSETS_PROPERTY(setProp, getProp)\
- (void)set##setProp:(UIEdgeInsets)value {\
NSAssert(!isMLLayoutUndefined(value.left),@"%s.left must not be NaN",#getProp);\
NSAssert(!isMLLayoutUndefined(value.right),@"%s.right must not be NaN",#getProp);\
NSAssert(!isMLLayoutUndefined(value.top),@"%s.top must not be NaN",#getProp);\
NSAssert(!isMLLayoutUndefined(value.bottom),@"%s.bottom must not be NaN",#getProp);\
_node->style.getProp[CSS_LEFT] = value.left;\
_node->style.getProp[CSS_RIGHT] = value.right;\
_node->style.getProp[CSS_TOP] = value.top;\
_node->style.getProp[CSS_BOTTOM] = value.bottom;\
[self dirtyLayout];\
}\
- (UIEdgeInsets)getProp {\
return UIEdgeInsetsMake(_node->style.getProp[CSS_TOP],\
_node->style.getProp[CSS_LEFT],\
_node->style.getProp[CSS_BOTTOM],\
_node->style.getProp[CSS_RIGHT]);\
}

EDGE_INSETS_PROPERTY(Margin, margin)
EDGE_INSETS_PROPERTY(Padding, padding)

#define CSS_PROPERTY(styleProp, setProp, getProp, valueType, cssType) \
- (void)set##setProp:(valueType)value {     \
_node->style.styleProp = (cssType)value;       \
[self dirtyLayout];                                    \
}                                                        \
- (valueType)getProp {                     \
return (valueType)(_node->style.styleProp);        \
}

CSS_PROPERTY(flex_direction, FlexDirection, flexDirection, MLLayoutFlexDirection, css_flex_direction_t)
CSS_PROPERTY(justify_content, JustifyContent, justifyContent, MLLayoutJustifyContent, css_justify_t)
CSS_PROPERTY(align_items, AlignItems, alignItems, MLLayoutAlignment, css_align_t)
CSS_PROPERTY(align_self, AlignSelf, alignSelf, MLLayoutAlignment, css_align_t)
CSS_PROPERTY(align_content, AlignContent, alignContent, MLLayoutAlignment, css_align_t)
CSS_PROPERTY(flex_wrap, FlexWrap, flexWrap, MLLayoutFlexWrap, css_wrap_type_t)
CSS_PROPERTY(position_type, Position, position, MLLayoutPosition, css_position_type_t)
CSS_PROPERTY(flex, Flex, flex, CGFloat, float)

#pragma mark - deep copy
- (id)copyWithZone:(nullable NSZone *)zone {
    MLLayout *layout = [[[self class] allocWithZone:zone]initWithNoNode];
    
    //node
    css_node_t *node = new_css_node();
    //copy node
    memcpy(node, _node, sizeof(css_node_t));
    node->next_child = NULL;
    
    node->context = (__bridge void *)layout;
//    node->is_dirty = isDirty;
//    node->get_child = getSubNode;
//    node->print = printLayout;
    layout->_node = node;
    
    //other
    layout.view = _view; //must setter to add dealloc callback ang set tag
    layout.measure = _measure; //copy setter
    
    layout->_frame = _frame;
    layout->_lastMeasureFrame = _lastMeasureFrame;
    
    layout->_invalid = _invalid;
    
    //sub
    if (_sublayouts) {
        layout->_sublayouts = [[NSMutableArray alloc] initWithArray:_sublayouts copyItems:YES];
        //setter will dirty sublayout after copy, so we cant use it.
        for (MLLayout *sublayout in layout->_sublayouts) {
            sublayout->_superlayout = layout;
        }
    }
    [layout resetValidSublayouts];
    layout->_layoutLifecycle = _layoutLifecycle;
    
    return layout;
}

@end
