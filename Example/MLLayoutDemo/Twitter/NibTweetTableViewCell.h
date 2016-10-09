//
//  NibTweetTableViewCell.h
//  MLLayoutDemo
//
//  Created by molon on 2016/10/9.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <MLAutoRecordFrameTableViewCell.h>

@class Tweet;
@interface NibTweetTableViewCell : MLAutoRecordFrameTableViewCell

@property (nonatomic, strong) Tweet *tweet;

@end
