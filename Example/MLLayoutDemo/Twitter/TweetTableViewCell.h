//
//  TweetTableViewCell.h
//  MLLayoutDemo
//
//  Created by molon on 16/6/28.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <MLAutoRecordFrameTableViewCell.h>

@class Tweet;
@interface TweetTableViewCell : MLAutoRecordFrameTableViewCell

@property (nonatomic, strong) Tweet *tweet;

@end
