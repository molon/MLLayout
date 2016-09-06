//
//  MLAutoRecordFrameTableViewCell.h
//
//  Created by molon on 16/6/27.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MLAutoRecordFrameTableView;
@class MLLayout;
@interface MLAutoRecordFrameTableViewCell : UITableViewCell

/**
 The mllayout of contentView.
 see warning of `heightForRowUsingPureMLLayoutAtIndexPath:tableView:beforeLayout:` method.
 */
@property (nullable, nonatomic, strong) MLLayout *layoutOfContentView;

/**
 The indexPath which can be autoset with `dequeueReusableCellWithIdentifier:forIndexPath:`
 */
@property (nullable, nonatomic, strong) NSIndexPath *indexPath;

/**
 For override , like `layoutSubviews`, but it's only called when no frame record.
 @warning Must ensure the final frame of `contentView` set. it's height is used for `heightWithTableView:indexPath:beforeLayout:` method. 
 @warning self.contentView.frame.size.height is meaningless at the begin of call.
 
 Example:
 - (void)layoutSubviewsIfNoFrameRecord {
    [_layout dirtyAllRelatedLayoutsAndLayoutViewsWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, kMLLayoutUndefined)]; //kMLLayoutUndefined is important if using MLLayout because of warning 2 upon.
 }
 */
- (void)layoutSubviewsIfNoFrameRecord;

/**
 Get height of indexPath, if cached, return it directly.
 
 @param indexPath    indexPath
 @param tableView    tableView
 @param beforeLayout the prepare block before layout, do set model to cell or others.
 
 @return height of indexPath
 */
+ (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:(nullable void (^)(UITableViewCell *protypeCell))beforeLayout;

/**
 Get height of indexPath, if cached, return it directly.
 @warning The method only support for cells which has a corresponding nib named NSStringFromClass([cell class])
 
 @param indexPath    indexPath
 @param tableView    tableView
 @param beforeLayout the prepare block before layout, do set model to cell or others.
 
 @return height of indexPath
 */
+ (CGFloat)heightForRowFromNibAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:(nullable void (^)(UITableViewCell *protypeCell))beforeLayout;

/**
 Get height of indexPath, if cached, return it directly.
 
 @param indexPath        indexPath
 @param tableView        tableView
 @param protypeCellBlock a block which return a protype cell for calc
 @param beforeLayout     the prepare block before layout, do set model to cell or others.
 
 @return height of indexPath
 */
+ (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView protypeCellBlock:(MLAutoRecordFrameTableViewCell *(^)(Class cellCls))protypeCellBlock beforeLayout:(nullable void (^)(UITableViewCell *protypeCell))beforeLayout;

/**
 Get height of indexPath, if cached, return it directly.
 @warning The method only support for cells whose all subviews'frame can be determined with it's `layoutOfContentView` property.
 
 @param indexPath    indexPath
 @param tableView    tableView
 @param beforeLayout the prepare block before layout, do set model to cell or others.
 
 @return height of indexPath
 */
+ (CGFloat)heightForRowUsingPureMLLayoutAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:(nullable void (^)(UITableViewCell *protypeCell))beforeLayout;

/**
 Get height of indexPath, if cached, return it directly.
 @warning The method only support for cells whose all subviews'frame can be determined with it's `layoutOfContentView` property.
 @warning The method only support for cells which has a corresponding nib named NSStringFromClass([cell class])
 
 @param indexPath    indexPath
 @param tableView    tableView
 @param beforeLayout the prepare block before layout, do set model to cell or others.
 
 @return height of indexPath
 */
+ (CGFloat)heightForRowUsingPureMLLayoutFromNibAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:(nullable void (^)(UITableViewCell *protypeCell))beforeLayout;

/**
 Get height of indexPath, if cached, return it directly.
 @warning The method only support for cells whose all subviews'frame can be determined with it's `layoutOfContentView` property.
 
 @param indexPath        indexPath
 @param tableView        tableView
 @param protypeCellBlock a block which return a protype cell for calc
 @param beforeLayout     the prepare block before layout, do set model to cell or others.
 
 @return height of indexPath
 */
+ (CGFloat)heightForRowUsingPureMLLayoutAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView protypeCellBlock:(MLAutoRecordFrameTableViewCell *(^)(Class cellCls))protypeCellBlock beforeLayout:(nullable void (^)(UITableViewCell *protypeCell))beforeLayout;
@end

NS_ASSUME_NONNULL_END
