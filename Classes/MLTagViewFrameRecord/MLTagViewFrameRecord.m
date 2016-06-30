//
//  MLTagViewFrameRecord.m
//
//  Created by molon on 16/6/27.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLTagViewFrameRecord.h"

@interface MLTagViewFrameRecord ()

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) NSArray<MLTagViewFrameRecord*> *subrecords;

@end

@implementation MLTagViewFrameRecord

- (void)layoutTagViewsWithRootView:(UIView*)rootView {
    __block UIView *view;
    if (_tag!=kMLLayoutInvalidTag) {
        NSArray *views = rootView.superview?rootView.superview.subviews:(rootView?@[rootView]:nil);
        [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (((UIView*)obj).tag==_tag) {
                view = obj;
                *stop = YES;
            }
        }];
        NSAssert(view, @"\n\n`layoutTagViewsWithRootView:`\nThe record:\n-------\n%@\n--------\nmust be accompanied by one corresponding view.\n\n",self);
        
        if (!CGRectEqualToRect(view.frame, self.frame)) {
            view.frame = self.frame;
        }
    }
    
    for (MLTagViewFrameRecord *subrecord in _subrecords) {
        [subrecord layoutTagViewsWithRootView:view==nil?rootView:[view.subviews firstObject]];
    }
}

- (NSArray*)realSubrecords {
    if (!_subrecords) {
        return nil;
    }
    
    NSMutableArray *subrecords = [NSMutableArray array];
    for (MLTagViewFrameRecord *record in _subrecords) {
        if (record.tag==kMLLayoutInvalidTag) {
            [subrecords addObjectsFromArray:[record realSubrecords]];
        }else{
            [subrecords addObject:record];
        }
    }
    
    return subrecords;
}

- (NSInteger)ambiguityTag {
    NSMutableSet *tags = [NSMutableSet set];
    for (MLTagViewFrameRecord *record in [self realSubrecords]) {
        if ([tags containsObject:@(record.tag)]) {
            return record.tag;
        }
        [tags addObject:@(record.tag)];
        
        NSInteger tag = [record ambiguityTag];
        if (tag!=NSNotFound) {
            return tag;
        }
    }
    
    return NSNotFound;
}

- (NSString*)description {
    return [self debugDescriptionWithSub:NO];
}

- (NSString*)debugDescriptionWithSub:(BOOL)sub {
    return [self debugDescriptionWithSub:sub depth:0];
}

- (NSString*)debugDescriptionWithSub:(BOOL)sub depth:(NSInteger)depth {
    NSMutableString *description = [NSMutableString stringWithFormat:@"tag(%ld):",(long)_tag];
    [description appendFormat:@" frame=%@", NSStringFromCGRect(_frame)];
    
    if (_subrecords.count > 0) {
        if (sub) {
            NSMutableString *indent = [NSMutableString string];
            for (NSInteger i = 0; i < depth+1; i++) {
                [indent appendFormat:@"\t"];
            }
            
            for (MLTagViewFrameRecord *subrecord in _subrecords) {
                [description appendFormat:@"\n%@%@", indent, [subrecord debugDescriptionWithSub:sub depth:depth+1]];
            }
            return description;
        }else{
            [description appendFormat:@" subrecords:%lu",(unsigned long)_subrecords.count];
        }
    }
    return description;
}

@end

@implementation UIView (MLTagViewFrameRecord)

- (MLTagViewFrameRecord*)exportTagViewFrameRecord {
    NSAssert(self.tag!=kMLLayoutInvalidTag&&self.tag!=0, @"`exportTagViewFrameRecord` method of `UIView` only supports for view whose tag is not -1/0");
    
    MLTagViewFrameRecord *record = [MLTagViewFrameRecord new];
    record.tag = self.tag;
    record.frame = self.frame;
    
    if (self.subviews) {
        NSMutableArray *subrecords = [NSMutableArray arrayWithCapacity:self.subviews.count];
        for (UIView *subview in self.subviews) {
            if (subview.tag==0) {//tag==0 will be ignore
                continue;
            }
            [subrecords addObject:[subview exportTagViewFrameRecord]];
        }
        record.subrecords = subrecords;
    }
    
    NSAssert([record ambiguityTag]==NSNotFound, @"\n\nSEL: %@\nMulti views cant sign same tag\n%ld\nat same-level!\n\n",NSStringFromSelector(_cmd),(long)[record ambiguityTag]);
    
    return record;
}

@end

@interface MLLayout(Private)

@property (nonatomic, strong) NSArray<MLLayout*> *validSublayouts;

@end

@implementation MLLayout (MLTagViewFrameRecord)

- (MLTagViewFrameRecord*)exportTagViewFrameRecord {
    NSAssert(!self.invalid, @"`exportTagViewFrameRecord:` method doesnt support for invalid layout!");
    
    MLTagViewFrameRecord *record = [MLTagViewFrameRecord new];
    record.tag = self.tag;
    record.frame = self.frame;
    
    if (self.validSublayouts) {
        NSMutableArray *subrecords = [NSMutableArray arrayWithCapacity:self.validSublayouts.count];
        for (MLLayout *sublayout in self.validSublayouts) {
            [subrecords addObject:[sublayout exportTagViewFrameRecord]];
        }
        record.subrecords = subrecords;
    }
    
    NSAssert([record ambiguityTag]==NSNotFound, @"\n\nSEL: %@\nMulti views cant sign same tag\n%ld\nat same-level!\n\n",NSStringFromSelector(_cmd),(long)[record ambiguityTag]);
    
    return record;
}

@end
