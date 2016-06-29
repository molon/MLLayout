//
//  MLAutoRecordFrameTableView.m
//
//  Created by molon on 16/6/27.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLAutoRecordFrameTableView.h"
#import "MLTagViewFrameRecord.h"

static inline void insertIndexToDictionary(NSInteger index, NSMutableDictionary *dictionary) {
    if (!dictionary) {
        return;
    }
    NSArray *reversedSections = [[dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSNumber *sKey in [reversedSections reverseObjectEnumerator]) {
        NSInteger s = [sKey integerValue];
        if (s>=index) {
            dictionary[@(s+1)] = dictionary[sKey];
            dictionary[sKey] = nil;
        }
        if (s==index) {
            dictionary[sKey] = nil;
        }
    }
}

static inline void deleteIndexFromDictionary(NSInteger index, NSMutableDictionary *dictionary) {
    if (!dictionary) {
        return;
    }
    NSArray *sections = [[dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSNumber *sKey in sections) {
        NSInteger s = [sKey integerValue];
        if (s==index) {
            dictionary[sKey] = nil;
        }else if (s>index) {
            dictionary[@(s-1)] = dictionary[sKey];
            dictionary[sKey] = nil;
        }
    }
}

@interface MLTagViewFrameRecordForCellManager : NSObject

/**
 {
 @(0):{
 @(1):MLTagViewFrameRecord
 @(3):MLTagViewFrameRecord
 },
 @(3):{
 @(1):MLTagViewFrameRecord
 @(3):MLTagViewFrameRecord
 },
 }
 */
@property (nonatomic, strong) NSMutableDictionary *records;

@end

@implementation MLTagViewFrameRecordForCellManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _records = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)cachedCellRecordForRowAtIndexPath:(NSIndexPath*)indexPath {
    NSMutableDictionary *dict = _records[@(indexPath.section)];
    if (!dict) {
        return nil;
    }
    id record = dict[@(indexPath.row)];
    return record;
}

- (void)cacheCellRecord:(id)record forRowAtIndexPath:(NSIndexPath*)indexPath {
    NSMutableDictionary *dict = _records[@(indexPath.section)];
    if (!dict) {
        _records[@(indexPath.section)] = dict = [NSMutableDictionary dictionary];
    }
    dict[@(indexPath.row)] = record;
}

@end

@interface MLAutoRecordFrameTableView()

@property (nonatomic, strong) MLTagViewFrameRecordForCellManager *tagViewFrameRecordForCellManager;

@end

@implementation MLAutoRecordFrameTableView

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.tagViewFrameRecordForCellManager) {
        NSMutableArray* unsortedIndexes = [NSMutableArray arrayWithCapacity:sections.count];
        [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
            [unsortedIndexes addObject:@(idx)];
        }];
        NSArray *indexes = [unsortedIndexes sortedArrayUsingSelector:@selector(compare:)];
        for (NSNumber *index in indexes) {
            insertIndexToDictionary([index integerValue], self.tagViewFrameRecordForCellManager.records);
        }
    }
    
    [super insertSections:sections withRowAnimation:animation];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.tagViewFrameRecordForCellManager) {
        NSMutableArray* unsortedIndexes = [NSMutableArray arrayWithCapacity:sections.count];
        [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
            [unsortedIndexes addObject:@(idx)];
        }];
        NSArray *indexes = [unsortedIndexes sortedArrayUsingSelector:@selector(compare:)];
        for (NSNumber *index in [indexes reverseObjectEnumerator]) {
            deleteIndexFromDictionary([index integerValue], self.tagViewFrameRecordForCellManager.records);
        };
    }
    
    [super deleteSections:sections withRowAnimation:animation];
}

- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.tagViewFrameRecordForCellManager) {
        NSMutableArray *keys=[NSMutableArray array];
        [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [keys addObject:@(idx)];
        }];
        [self.tagViewFrameRecordForCellManager.records removeObjectsForKeys:keys];
    }
    [super reloadSections:sections withRowAnimation:animation];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.tagViewFrameRecordForCellManager) {
        NSMutableDictionary *sectionDict = self.tagViewFrameRecordForCellManager.records[@(section)];
        NSMutableDictionary *newSectionDict = self.tagViewFrameRecordForCellManager.records[@(newSection)];
        self.tagViewFrameRecordForCellManager.records[@(newSection)] = sectionDict;
        self.tagViewFrameRecordForCellManager.records[@(section)] = newSectionDict;
    }
    
    [super moveSection:section toSection:newSection];
}

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.tagViewFrameRecordForCellManager) {
        /*
         @{
         @(1):@[@(3),@(4)],
         @(2):@[@(3),@(4)],
         @(5):@[@(3),@(4)],
         }
         */
        NSMutableDictionary *indexes = [NSMutableDictionary dictionary];
        for (NSIndexPath *indexPath in indexPaths) {
            if (!indexes[@(indexPath.section)]) {
                indexes[@(indexPath.section)] = [NSMutableArray array];
            }
            if (![indexes[@(indexPath.section)] containsObject:@(indexPath.row)]) {
                [indexes[@(indexPath.section)] addObject:@(indexPath.row)];
            }
        }
        
        NSArray *sortedSections = [[indexes allKeys]sortedArrayUsingSelector:@selector(compare:)];
        for (NSNumber *section in sortedSections) {
            NSMutableDictionary *rowDict = self.tagViewFrameRecordForCellManager.records[section];
            if (rowDict) {
                NSArray *sortedRows = [indexes[section]sortedArrayUsingSelector:@selector(compare:)];
                for (NSNumber *row in sortedRows) {
                    insertIndexToDictionary([row integerValue], rowDict);
                }
            }
        }
        
        for (NSNumber *section in sortedSections) {
            insertIndexToDictionary([section integerValue], self.tagViewFrameRecordForCellManager.records);
        }
    }
    
    [super insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.tagViewFrameRecordForCellManager) {
        /*
         @{
         @(1):@[@(3),@(4)],
         @(2):@[@(3),@(4)],
         @(5):@[@(3),@(4)],
         }
         */
        NSMutableDictionary *indexes = [NSMutableDictionary dictionary];
        for (NSIndexPath *indexPath in indexPaths) {
            if (!indexes[@(indexPath.section)]) {
                indexes[@(indexPath.section)] = [NSMutableArray array];
            }
            if (![indexes[@(indexPath.section)] containsObject:@(indexPath.row)]) {
                [indexes[@(indexPath.section)] addObject:@(indexPath.row)];
            }
        }
        
        NSArray *sortedSections = [[indexes allKeys]sortedArrayUsingSelector:@selector(compare:)];
        for (NSNumber *section in sortedSections) {
            NSMutableDictionary *rowDict = self.tagViewFrameRecordForCellManager.records[section];
            if (rowDict) {
                NSArray *sortedRows = [indexes[section]sortedArrayUsingSelector:@selector(compare:)];
                for (NSNumber *row in [sortedRows reverseObjectEnumerator]) {
                    deleteIndexFromDictionary([row integerValue], rowDict);
                }
            }
        }
        
        for (NSNumber *section in [sortedSections reverseObjectEnumerator]) {
            deleteIndexFromDictionary([section integerValue], self.tagViewFrameRecordForCellManager.records);
        }
    }
    
    [super deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.tagViewFrameRecordForCellManager) {
        for (NSIndexPath *indexPath in indexPaths) {
            [self.tagViewFrameRecordForCellManager cacheCellRecord:nil forRowAtIndexPath:indexPath];
        }
    }
    
    [super reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    if (self.tagViewFrameRecordForCellManager) {
        id a = [self.tagViewFrameRecordForCellManager cachedCellRecordForRowAtIndexPath:indexPath];
        id b = [self.tagViewFrameRecordForCellManager cachedCellRecordForRowAtIndexPath:newIndexPath];
        [self.tagViewFrameRecordForCellManager cacheCellRecord:b forRowAtIndexPath:indexPath];
        [self.tagViewFrameRecordForCellManager cacheCellRecord:a forRowAtIndexPath:newIndexPath];
    }
    
    [super moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)reloadData {
    [self.tagViewFrameRecordForCellManager.records removeAllObjects];
    
    [super reloadData];
}

- (void)setFrame:(CGRect)frame {
    if ((NSInteger)(frame.size.width)!=(NSInteger)(self.frame.size.width)) {
        [self.tagViewFrameRecordForCellManager.records removeAllObjects];
    }
    
    [super setFrame:frame];
}

#pragma mark - cache
- (nullable MLTagViewFrameRecord*)cachedMLTagViewFrameRecordForRowAtIndexPath:(NSIndexPath*)indexPath {
    return [self.tagViewFrameRecordForCellManager cachedCellRecordForRowAtIndexPath:indexPath];
}

- (void)cacheMLTagViewFrameRecord:(MLTagViewFrameRecord *)frameRecord forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (!self.tagViewFrameRecordForCellManager) {
        self.tagViewFrameRecordForCellManager = [MLTagViewFrameRecordForCellManager new];
    }
    [self.tagViewFrameRecordForCellManager cacheCellRecord:frameRecord forRowAtIndexPath:indexPath];
}

- (void)deleteCachedMLTagViewFrameRecordForRowAtIndexPath:(NSIndexPath*)indexPath {
    [self.tagViewFrameRecordForCellManager cacheCellRecord:nil forRowAtIndexPath:indexPath];
}

@end
