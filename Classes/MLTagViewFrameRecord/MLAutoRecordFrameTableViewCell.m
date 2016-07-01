//
//  MLAutoRecordFrameTableViewCell.m
//
//  Created by molon on 16/6/27.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLAutoRecordFrameTableViewCell.h"
#import "MLTagViewFrameRecord.h"
#import "MLAutoRecordFrameTableView.h"
#import "MLLayout.h"

@implementation MLAutoRecordFrameTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UITableView *tableView = [self currentTableView];
    if ([tableView isKindOfClass:[MLAutoRecordFrameTableView class]]) {
        NSIndexPath *indexPath = [tableView indexPathForCell:self];
        if (!indexPath) {
            return;
        }
        
        MLTagViewFrameRecord *frameRecord = [((MLAutoRecordFrameTableView*)tableView) cachedMLTagViewFrameRecordForRowAtIndexPath:indexPath];
        if (frameRecord) {
            [frameRecord layoutTagViewsWithRootView:self.contentView];
            return;
        }
    }
    
    if (self.contentView.frame.size.width<=0.0f) {
        return;
    }
    
    //layout
    [self layoutSubviewsIfNoFrameRecord];
}

- (void)layoutSubviewsIfNoFrameRecord {
    
}

- (UITableView*)currentTableView {
    UIView *view = self.superview;
    while (view&&![view isKindOfClass:[UITableView class]]) {
        view = view.superview;
    }
    return (UITableView*)view;
}

static inline MLAutoRecordFrameTableViewCell *kProtypeAutoRecordFrameTableViewCell(Class cls) {
    NSCAssert([cls isSubclassOfClass:[MLAutoRecordFrameTableViewCell class]], @"cls must be subclass of `MLAutoRecordFrameTableViewCell` class");
    
    static NSMutableDictionary *protypeCells = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protypeCells = [NSMutableDictionary dictionary];
    });
    
    NSString *clsName = NSStringFromClass(cls);
    MLAutoRecordFrameTableViewCell *protypeCell = protypeCells[clsName];
    if (!protypeCell) {
        protypeCell = [cls new];
        protypeCells[clsName] = protypeCell;
    }
    return protypeCell;
}


+ (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:(nullable void (^)(UITableViewCell *protypeCell))beforeLayout {
    
    if (tableView.frame.size.width<=0.0f) {
        return 0.0f;
    }
    
    //find the cache
    MLTagViewFrameRecord *frameRecord = [((MLAutoRecordFrameTableView*)tableView) cachedMLTagViewFrameRecordForRowAtIndexPath:indexPath];
    if (frameRecord) {
        return frameRecord.frame.size.height;
    }
    
    MLAutoRecordFrameTableViewCell *protypeCell = kProtypeAutoRecordFrameTableViewCell([self class]);
    
    if (protypeCell.frame.size.width!=tableView.frame.size.width) {
        CGRect frame = protypeCell.frame;
        frame.size.width = tableView.frame.size.width;
        protypeCell.frame = frame;
    }
    
    if (beforeLayout) {
        beforeLayout(protypeCell);
    }
    
    //because `layoutIfNeeded` will set new frames to all updated subviews.
    //so the performance is bad.
    [protypeCell setNeedsLayout];
    [protypeCell layoutIfNeeded];
    
    //cache
    frameRecord = [protypeCell.contentView exportTagViewFrameRecord];
    [tableView cacheMLTagViewFrameRecord:frameRecord forRowAtIndexPath:indexPath];
    
    return frameRecord.frame.size.height;
}

+ (CGFloat)heightForRowUsingPureMLLayoutAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:(nullable void (^)(UITableViewCell *protypeCell))beforeLayout {
    
    if (tableView.frame.size.width<=0.0f) {
        return 0.0f;
    }
    
    //find the cache
    MLTagViewFrameRecord *frameRecord = [((MLAutoRecordFrameTableView*)tableView) cachedMLTagViewFrameRecordForRowAtIndexPath:indexPath];
    if (frameRecord) {
        return frameRecord.frame.size.height;
    }
    
    MLAutoRecordFrameTableViewCell *protypeCell = kProtypeAutoRecordFrameTableViewCell([self class]);
    
    if (beforeLayout) {
        beforeLayout(protypeCell);
    }
    
    [protypeCell.layoutOfContentView dirtyAllRelatedLayouts];
    [protypeCell.layoutOfContentView updatedLayoutsAfterLayoutCalculationWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kMLLayoutUndefined)];
    
    //cache
    frameRecord = [protypeCell.layoutOfContentView exportTagViewFrameRecord];
    [tableView cacheMLTagViewFrameRecord:frameRecord forRowAtIndexPath:indexPath];
    
    return frameRecord.frame.size.height;
}

@end
