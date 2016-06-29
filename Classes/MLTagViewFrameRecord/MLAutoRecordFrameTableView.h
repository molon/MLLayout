//
//  MLAutoRecordFrameTableView.h
//
//  Created by molon on 16/6/27.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MLTagViewFrameRecord;
@interface MLAutoRecordFrameTableView : UITableView

/**
 Get the cached frame record for row at indexPath
 
 @param indexPath indexPath
 
 @return cached frame record or nil
 */
- (nullable MLTagViewFrameRecord*)cachedMLTagViewFrameRecordForRowAtIndexPath:(NSIndexPath*)indexPath;

/**
 Cache frame record for row at indexPath
 
 @param frameRecord frameRecord
 @param indexPath   indexPath
 */
- (void)cacheMLTagViewFrameRecord:(MLTagViewFrameRecord *)frameRecord forRowAtIndexPath:(NSIndexPath*)indexPath;

/**
 Delete cached frame record for row at indexPath
 
 @param indexPath indexPath
 */
- (void)deleteCachedMLTagViewFrameRecordForRowAtIndexPath:(NSIndexPath*)indexPath;

@end

NS_ASSUME_NONNULL_END