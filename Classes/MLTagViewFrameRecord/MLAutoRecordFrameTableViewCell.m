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
    NSIndexPath *indexPath = nil;
    if ([tableView isKindOfClass:[MLAutoRecordFrameTableView class]]&&self.indexPathForMLAutoRecordFrameBlock) {
        //If no indexPathForMLAutoRecordFrameBlock, indicate dont want to use cache to layout
        indexPath = self.indexPathForMLAutoRecordFrameBlock(self);
        //If indexPathForMLAutoRecordFrameBlock return nil, indicate current `layoutSubviews` is not necessary, just return.
        if (!indexPath) {
            return;
        }
        
        MLTagViewFrameRecord *frameRecord = [((MLAutoRecordFrameTableView*)tableView) cachedMLTagViewFrameRecordForRowAtIndexPath:indexPath];
        if (frameRecord) {
            NSAssert(frameRecord.isDirtyBlock, @"the cached root frame record must have isDirtyBlock");
            if (!frameRecord.isDirtyBlock(@(self.contentView.frame.size.width))) {
                [frameRecord layoutTagViewsWithRootView:self.contentView];
                return;
            }
        }
    }
    
    if (self.contentView.frame.size.width<=0.0f) {
        return;
    }
    
    //layout
    [self layoutSubviewsIfNoFrameRecord];
    
    if (indexPath) {
        //cache
        MLTagViewFrameRecord *frameRecord = [self.contentView exportTagViewFrameRecord];
        //If new width is not equal to calc width, is dirty
        NSInteger calcWidth = self.contentView.frame.size.width;
        [frameRecord setIsDirtyBlock:^BOOL(id _Nonnull userInfo) {
            return [userInfo integerValue]!=calcWidth;
        }];
        [((MLAutoRecordFrameTableView*)tableView) cacheMLTagViewFrameRecord:frameRecord forRowAtIndexPath:indexPath];
    }
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

+ (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView protypeCellBlock:(MLAutoRecordFrameTableViewCell *(^)(Class cellCls))protypeCellBlock beforeLayout:(nullable void (^)(MLAutoRecordFrameTableViewCell *protypeCell))beforeLayout {
    NSParameterAssert(protypeCellBlock);
    NSAssert([tableView isKindOfClass:[MLAutoRecordFrameTableView class]], @"tableView must be `MLAutoRecordFrameTableView`");
    
    if (tableView.frame.size.width<=0.0f) {
        return 0.0f;
    }
    
    //find the cache
    MLTagViewFrameRecord *frameRecord = [((MLAutoRecordFrameTableView*)tableView) cachedMLTagViewFrameRecordForRowAtIndexPath:indexPath];
    if (frameRecord) {
        return frameRecord.frame.size.height;
    }
    
    MLAutoRecordFrameTableViewCell *protypeCell = protypeCellBlock([self class]);
    
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
    
    //If new width is not equal to calc width, is dirty
    NSInteger calcWidth = protypeCell.contentView.frame.size.width;
    [frameRecord setIsDirtyBlock:^BOOL(id _Nonnull userInfo) {
        return [userInfo integerValue]!=calcWidth;
    }];
    
    [tableView cacheMLTagViewFrameRecord:frameRecord forRowAtIndexPath:indexPath];
    
    return frameRecord.frame.size.height;
}

+ (CGFloat)heightForRowUsingPureMLLayoutAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView protypeCellBlock:(MLAutoRecordFrameTableViewCell *(^)(Class cellCls))protypeCellBlock beforeLayout:(nullable void (^)(MLAutoRecordFrameTableViewCell *protypeCell))beforeLayout {
    NSParameterAssert(protypeCellBlock);
    NSAssert([tableView isKindOfClass:[MLAutoRecordFrameTableView class]], @"tableView must be `MLAutoRecordFrameTableView`");
    
    if (tableView.frame.size.width<=0.0f) {
        return 0.0f;
    }
    
    //find the cache
    MLTagViewFrameRecord *frameRecord = [((MLAutoRecordFrameTableView*)tableView) cachedMLTagViewFrameRecordForRowAtIndexPath:indexPath];
    if (frameRecord) {
        return frameRecord.frame.size.height;
    }
    
    MLAutoRecordFrameTableViewCell *protypeCell = protypeCellBlock([self class]);
    
    if (beforeLayout) {
        beforeLayout(protypeCell);
    }
    
    [protypeCell.layoutOfContentView dirtyAllRelatedLayouts];
    [protypeCell.layoutOfContentView updatedLayoutsAfterLayoutCalculationWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kMLLayoutUndefined)];
    
    //cache
    frameRecord = [protypeCell.layoutOfContentView exportTagViewFrameRecord];
    
    //If new width is not equal to calc width, is dirty
    NSInteger calcWidth = tableView.frame.size.width;
    [frameRecord setIsDirtyBlock:^BOOL(id _Nonnull userInfo) {
        return [userInfo integerValue]!=calcWidth;
    }];
    
    [tableView cacheMLTagViewFrameRecord:frameRecord forRowAtIndexPath:indexPath];
    
    return frameRecord.frame.size.height;
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

+ (CGFloat)heightForRowAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:(nullable void (^)(MLAutoRecordFrameTableViewCell *protypeCell))beforeLayout {
    return [self heightForRowAtIndexPath:indexPath tableView:tableView protypeCellBlock:^MLAutoRecordFrameTableViewCell *(__unsafe_unretained Class cellCls) {
        return kProtypeAutoRecordFrameTableViewCell(cellCls);
    } beforeLayout:beforeLayout];
}

+ (CGFloat)heightForRowUsingPureMLLayoutAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:(nullable void (^)(MLAutoRecordFrameTableViewCell *protypeCell))beforeLayout {
    return [self heightForRowUsingPureMLLayoutAtIndexPath:indexPath tableView:tableView protypeCellBlock:^MLAutoRecordFrameTableViewCell *(__unsafe_unretained Class cellCls) {
        return kProtypeAutoRecordFrameTableViewCell(cellCls);
    } beforeLayout:beforeLayout];
}

static inline MLAutoRecordFrameTableViewCell *kProtypeAutoRecordFrameTableViewCellFromNib(Class cls) {
    NSCAssert([cls isSubclassOfClass:[MLAutoRecordFrameTableViewCell class]], @"cls must be subclass of `MLAutoRecordFrameTableViewCell` class");
    
    static NSMutableDictionary *protypeCells = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protypeCells = [NSMutableDictionary dictionary];
    });
    
    NSString *clsName = NSStringFromClass(cls);
    MLAutoRecordFrameTableViewCell *protypeCell = protypeCells[clsName];
    if (!protypeCell) {
        protypeCell = [[[NSBundle mainBundle]loadNibNamed:clsName owner:nil options:nil]lastObject];
        NSCAssert(protypeCell, @"Cant find a valid tableViewCell from nib named %@",clsName);
        protypeCells[clsName] = protypeCell;
    }
    return protypeCell;
}

+ (CGFloat)heightForRowFromNibAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:(nullable void (^)(MLAutoRecordFrameTableViewCell *protypeCell))beforeLayout {
    return [self heightForRowAtIndexPath:indexPath tableView:tableView protypeCellBlock:^MLAutoRecordFrameTableViewCell *(__unsafe_unretained Class cellCls) {
        return kProtypeAutoRecordFrameTableViewCellFromNib(cellCls);
    } beforeLayout:beforeLayout];
}

+ (CGFloat)heightForRowUsingPureMLLayoutFromNibAtIndexPath:(NSIndexPath*)indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:(nullable void (^)(MLAutoRecordFrameTableViewCell *protypeCell))beforeLayout {
    return [self heightForRowUsingPureMLLayoutAtIndexPath:indexPath tableView:tableView protypeCellBlock:^MLAutoRecordFrameTableViewCell *(__unsafe_unretained Class cellCls) {
        return kProtypeAutoRecordFrameTableViewCellFromNib(cellCls);
    } beforeLayout:beforeLayout];
}
@end
