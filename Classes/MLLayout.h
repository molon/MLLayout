//
//  MLLayout.h
//
//  Created by molon on 16/6/20.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat kMLLayoutUndefined;
extern const NSInteger kMLLayoutInvalidTag;

BOOL isMLLayoutUndefined(CGFloat value);

CGFloat dimensionClamp(CGFloat min,CGFloat max,CGFloat dimension);

/**
 css: 'flexDirection'
 */
typedef NS_ENUM(NSUInteger, MLLayoutFlexDirection) {
    /**
     'column'
     */
    MLLayoutFlexDirectionColumn = 0,
    /**
     'column-reverse'
     */
    MLLayoutFlexDirectionColumnReverse,
    /**
     'row'
     */
    MLLayoutFlexDirectionRow,
    /**
     'row-reverse'
     */
    MLLayoutFlexDirectionRowReverse,
};

/**
 css:'justifyContent'
 */
typedef NS_ENUM(NSUInteger, MLLayoutJustifyContent) {
    /**
     'flex-start'
     */
    MLLayoutJustifyContentFlexStart = 0,
    /**
     'center'
     */
    MLLayoutJustifyContentCenter,
    /**
     'flex-end'
     */
    MLLayoutJustifyContentFlexEnd,
    /**
     space-between'
     */
    MLLayoutJustifyContentSpaceBetween,
    /**
     'space-around'
     */
    MLLayoutJustifyContentSpaceAround
};

/**
 css: 'alignItems', 'alignSelf', 'alignContent'
 */
typedef NS_ENUM(NSUInteger, MLLayoutAlignment) {
    /**
     Note: auto is only a valid value for `alignSelf`.
     It means `alignSelf` is equal to superlayout's `alignItems`
     */
    MLLayoutAlignmentAuto = 0,
    /**
     'flex-start'
     */
    MLLayoutAlignmentFlexStart,
    /**
     'center'
     */
    MLLayoutAlignmentCenter,
    /**
     'flex-end'
     */
    MLLayoutAlignmentFlexEnd,
    /**
     'stretch'
     */
    MLLayoutAlignmentStretch
};

/**
 css: 'flexWrap'
 */
typedef NS_ENUM(NSUInteger, MLLayoutFlexWrap) {
    /**
     'nowrap'
     */
    MLLayoutFlexWrapNo = 0,
    /**
     'wrap'
     */
    MLLayoutFlexWrapYES,
};

/**
 css: 'position'
 */
typedef NS_ENUM(NSUInteger, MLLayoutPosition) {
    /**
     'relative'
     */
    MLLayoutPositionRelative = 0,
    /**
     'absolute'
     */
    MLLayoutPositionAbsolute,
};

/**
 measure mode
 */
typedef NS_ENUM(NSUInteger, MLLayoutMeasureMode) {
    /**
     max content
     */
    MLLayoutMeasureModeUndefined = 0,
    /**
     fill available
     */
    MLLayoutMeasureModeExactly,
    /**
     fit content
     */
    MLLayoutMeasureModeAtMost,
};

/**
 for `debugDescriptionWithMode:`
 */
typedef NS_OPTIONS(NSUInteger, MLLayoutDebugMode) {
    /**
     contains view's frame after treat
     */
    MLLayoutDebugModeViewLayoutFrame      = 1 << 0,
    /**
     contains original layout frame before appying offset of layout helpers
     (layout.view==nil indicates it's a layout helper)
     */
    MLLayoutDebugModeOriginalLayoutFrame  = 1 << 1,
    /**
     contains css style
     */
    MLLayoutDebugModeStyle                = 1 << 2,
    /**
     contains sublayouts's description
     */
    MLLayoutDebugModeSublayout            = 1 << 3,
    /**
     all
     */
    MLLayoutDebugModeAll = MLLayoutDebugModeViewLayoutFrame|MLLayoutDebugModeOriginalLayoutFrame|MLLayoutDebugModeStyle|MLLayoutDebugModeSublayout,
};

/**
 deep copy
 */
@interface MLLayout : NSObject<NSCopying>

/**
 the associated view, if nil, the layout becomes a layout helper
 */
@property (nullable, nonatomic, weak, readonly) UIView *view;

/**
 tag
 */
@property (nonatomic, assign, readonly) NSInteger tag;

/**
 frame after layout calculation
 */
@property (nonatomic, assign, readonly) CGRect frame;

/**
 superlayout
 */
@property (nullable, nonatomic, weak, readonly) MLLayout *superlayout;

/**
 sublayouts
 */
@property (nullable, nonatomic, copy) NSArray<MLLayout *> *sublayouts;

/**
 measure block if no fixed size
 */
@property (nullable, nonatomic, copy) CGSize (^measure)(MLLayout *l, CGFloat width, MLLayoutMeasureMode widthMode, CGFloat height, MLLayoutMeasureMode heightMode);

/**
 Layout calculation and layouting views will ignores invalid MLLayout.
 */
@property (nonatomic, assign) BOOL invalid;

#pragma mark - css style(flex)
/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat width;
/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat height;

/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat minWidth;

/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat minHeight;

/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat maxWidth;

/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat maxHeight;

/**
 default: MLLayoutPositionRelative
 */
@property (nonatomic, assign) MLLayoutPosition position;

/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat left;

/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat right;

/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat top;

/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat bottom;

/**
 default: UIEdgeInsetsZero
 */
@property (nonatomic, assign) UIEdgeInsets margin;

/**
 default: 0
 */
@property (nonatomic, assign) CGFloat marginTop;
/**
 default: 0
 */
@property (nonatomic, assign) CGFloat marginLeft;
/**
 default: 0
 */
@property (nonatomic, assign) CGFloat marginBottom;
/**
 default: 0
 */
@property (nonatomic, assign) CGFloat marginRight;

/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat marginStart;

/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat marginEnd;

/**
 default: UIEdgeInsetsZero
 */
@property (nonatomic, assign) UIEdgeInsets padding;

/**
 default: 0
 */
@property (nonatomic, assign) CGFloat paddingTop;
/**
 default: 0
 */
@property (nonatomic, assign) CGFloat paddingLeft;
/**
 default: 0
 */
@property (nonatomic, assign) CGFloat paddingBottom;
/**
 default: 0
 */
@property (nonatomic, assign) CGFloat paddingRight;

/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat paddingStart;

/**
 default: kMLLayoutUndefined
 */
@property (nonatomic, assign) CGFloat paddingEnd;

/**
 default: MLLayoutFlexDirectionColumn
 */
@property (nonatomic, assign) MLLayoutFlexDirection flexDirection;

/**
 default: MLLayoutJustifyContentFlexStart
 */
@property (nonatomic, assign) MLLayoutJustifyContent justifyContent;

/**
 default: MLLayoutAlignmentStretch
 */
@property (nonatomic, assign) MLLayoutAlignment alignItems;

/**
 default: MLLayoutAlignmentAuto
 */
@property (nonatomic, assign) MLLayoutAlignment alignSelf;

/**
 default: MLLayoutAlignmentFlexStart
 */
@property (nonatomic, assign) MLLayoutAlignment alignContent;

/**
 default: MLLayoutFlexWrapNO
 */
@property (nonatomic, assign) MLLayoutFlexWrap flexWrap;

/**
 default: 0
 Rather than allowing arbitrary combinations of flex-grow, flex-shrink, and flex-basis the implementation only supports a few common combinations expressed as a single number using the flex attribute:
 
 css-layout flex value  |	W3C flex short-hand equivalent
 n (where n > 0)        |	n 0 0
 0                      |   0 0 auto
 -1                     |   0 1 auto
 */
@property (nonatomic, assign) CGFloat flex;

#pragma mark - init methods

/**
 create layout with associated view, if view is nil, just returns a layout helper.
 
 @param view  view
 @param block block to set property conveniently
 
 @return instance
 */
+ (instancetype)layoutWithView:(nullable UIView*)view block:(nullable void (^)(MLLayout *l))block;

/**
 create layout with associated view which has a valid tag, if view is nil, just returns a layout helper.
 
 @param tagView  view which has a valid tag, not 0/-1
 @param block block to set property conveniently
 
 @return instance
 */
+ (instancetype)layoutWithTagView:(nullable UIView*)tagView block:(nullable void (^)(MLLayout *l))block;

/**
 because some peoperties is readonly ,like `view`
 
 @return instance
 */
- (instancetype)init NS_UNAVAILABLE;


#pragma mark - dirty
/**
 Return whether the layout is dirty
 
 @return bool
 */
- (BOOL)isLayoutDirty;

/**
 dirty self and ancestors
 */
- (void)dirtyLayout;

/**
 dirty all related layouts, ancestors and self and descendants
 */
- (void)dirtyAllRelatedLayouts;

/**
 dirty layout and ancestors with its view
 
 @param view associated view
 */
- (void)dirtyLayoutWithView:(UIView*)view;

#pragma mark - helper
/**
 get the associated layout of view
 
 @param view associated view
 
 @return associated layout
 */
- (MLLayout*)retrieveLayoutWithView:(UIView*)view;

/**
 remove layout from super
 */
- (void)removeFromSuperlayout;

/**
 insert a sublayout at index
 
 @param sublayout sublayout
 @param index     index
 */
- (void)insertSublayout:(MLLayout*)sublayout atIndex:(NSInteger)index;

/**
 add a sublayout
 
 @param sublayout sublayout
 */
- (void)addSublayout:(MLLayout*)sublayout;

/**
 Returns debug description with modes
 
 @param mode mode
 
 @return description
 */
- (NSString*)debugDescriptionWithMode:(MLLayoutDebugMode)mode;

/**
 Change views of layouts by these tags.
 @warning One layout which has valid tag must be accompanied by one corresponding view.
 
 @param rootView the top-level view which has a valid tag
 */
- (void)applyTagViewsWithRootView:(UIView*)rootView;

/**
 measure setter
 
 @param measure measure block
 */
- (void)setMeasure:(CGSize (^ _Nullable)(MLLayout *l, CGFloat width, MLLayoutMeasureMode widthMode, CGFloat height, MLLayoutMeasureMode heightMode))measure;

//TODO: maybe we need json converter methods to implement dynamic layout

#pragma mark - layout

/**
 Calculate layouts to fit frame and return updated layouts
 
 @param frame frame
 
 @return updated layouts
 */
- (nullable NSMutableSet<MLLayout *> *)updatedLayoutsAfterLayoutCalculationWithFrame:(CGRect)frame;

/**
 apply frames to views with layouts
 
 @param updatedLayouts updatedLayouts
 */
- (void)layoutViewsWithUpdatedLayouts:(nullable NSMutableSet<MLLayout *> *)updatedLayouts;

/**
 Calculate layouts to fit frame and apply frames to views
 @note same with `[self layoutViewsWithUpdatedLayouts:[self updatedLayoutsAfterLayoutCalculationWithFrame]];`
 
 @param frame frame
 */
- (void)layoutViewsWithFrame:(CGRect)frame;


/**
 same with
 [self dirtyAllRelatedLayouts];
 [self layoutViewsWithFrame:frame];
 
 @param frame frame
 */
- (void)dirtyAllRelatedLayoutsAndLayoutViewsWithFrame:(CGRect)frame;

@end

/**
 If one view(like UILabel) has common measure block, implement the protocol method.
 There's no need to add '<MLLayoutMeasure>' to your class header.
 */
@protocol MLLayoutMeasure <NSObject>

- (CGSize)measureWithMLLayout:(MLLayout*)layout width:(CGFloat)width widthMode:(MLLayoutMeasureMode)widthMode height:(CGFloat)height heightMode:(MLLayoutMeasureMode)heightMode;

@end

NS_ASSUME_NONNULL_END







