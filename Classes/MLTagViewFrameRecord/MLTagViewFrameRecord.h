//
//  MLTagViewFrameRecord.h
//
//  Created by molon on 16/6/27.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLTagViewFrameRecord : NSObject

@property (nonatomic, assign, readonly) NSInteger tag;
@property (nonatomic, assign, readonly) CGRect frame;
@property (nonatomic, strong, readonly) NSArray<MLTagViewFrameRecord*> *subrecords;

/**
 layout views with frame record by these tags.
 @warning One record which has valid tag must be accompanied by one corresponding view.
 
 @param rootView the top-level view which has a valid tag
 */
- (void)layoutTagViewsWithRootView:(UIView*)rootView;

/**
 Return description
 
 Example:
 tag(1000): frame={{0, 0}, {320, 138}}
	tag(1001): frame={{12, 12}, {48, 48}}
	tag(1002): frame={{70, 12}, {146, 17}}
	tag(1003): frame={{262.5, 13.5}, {45.5, 14.5}}
	tag(1004): frame={{70, 34}, {238, 67}}
 
 @param sub whether returns sub's description
 
 @return description
 */
- (NSString*)debugDescriptionWithSub:(BOOL)sub;

@end

@interface UIView (MLTagViewFrameRecord)

/**
 Export frame records of self and descendants
 @warning views with tag==0 will be ignored!!!!!
 
 @return record
 */
- (MLTagViewFrameRecord*)exportTagViewFrameRecord;

@end

@interface MLLayout (MLTagViewFrameRecord)

/**
 Export frame records of self and descendants
 
 @return record
 */
- (MLTagViewFrameRecord*)exportTagViewFrameRecord;

@end

NS_ASSUME_NONNULL_END
