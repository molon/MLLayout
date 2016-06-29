//
//  Tweet.h
//  MLLayoutDemo
//
//  Created by molon on 16/6/28.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSURL *avatarURL;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, assign) NSInteger retweetCount;
@property (nonatomic, assign) NSInteger favCount;

@property (nonatomic, strong) NSURL *detailImageURL;

@end
