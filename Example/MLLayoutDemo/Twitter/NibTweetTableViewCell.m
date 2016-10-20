//
//  NibTweetTableViewCell.m
//  MLLayoutDemo
//
//  Created by molon on 2016/10/9.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "NibTweetTableViewCell.h"

#import "Tweet.h"
#import <MLLayout.h>
#import <UIImageView+WebCache.h>

#define kImageSide 48.0f
#define kImageCornerRadius 4.0f
#define kDetailImageHeight 166.0f

@interface NibTweetTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@end

@implementation NibTweetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    NSInteger tag = 100;
    self.contentView.tag = tag++;
    for (UIView *subview in self.contentView.subviews) {
        subview.tag = tag++;
    }
    
    _avatarImageView.layer.borderWidth = 1.0f/[UIScreen mainScreen].scale;
    _avatarImageView.layer.borderColor = [UIColor colorWithWhite:0.837 alpha:1.000].CGColor;
    
    _timeLabel.textColor = [UIColor colorWithRed:0.482 green:0.549 blue:0.608 alpha:1.000];
    
    MLLayout *titleLayout = [MLLayout layoutWithTagView:nil block:^(MLLayout * _Nonnull l) {
        l.flexDirection = MLLayoutFlexDirectionRow;
        l.alignItems = MLLayoutAlignmentCenter;
        l.sublayouts = @[
                         [MLLayout layoutWithTagView:_nameLabel block:^(MLLayout * _Nonnull l) {
                             l.flex = -1;
                         }],
                         [MLLayout layoutWithTagView:nil block:^(MLLayout * _Nonnull l) {
                             l.flex = 1;
                             l.minWidth = 5.0f;
                         }],
                         [MLLayout layoutWithTagView:_timeLabel block:nil],
                         ];
    }];
    
#define kButtonMinWidth 50.0f
#define kButtonMinHeight 20.0f
    MLLayout *buttonsLayout = [MLLayout layoutWithTagView:nil block:^(MLLayout * _Nonnull l) {
        l.flexDirection = MLLayoutFlexDirectionRow;
        l.alignItems = MLLayoutAlignmentCenter;
        l.justifyContent = MLLayoutJustifyContentSpaceBetween;
        l.margin = UIEdgeInsetsMake(5.0f, 0, 0, 30.0f);
        l.sublayouts = @[
                         [MLLayout layoutWithTagView:_replyButton block:^(MLLayout * _Nonnull l) {
                             l.minWidth = 50.0f;
                             l.minHeight = 20.0f;
                         }],
                         [MLLayout layoutWithTagView:_retweetButton block:^(MLLayout * _Nonnull l) {
                             l.minWidth = 50.0f;
                             l.minHeight = 20.0f;
                         }],
                         [MLLayout layoutWithTagView:_favButton block:^(MLLayout * _Nonnull l) {
                             l.minWidth = 50.0f;
                             l.minHeight = 20.0f;
                         }],
                         ];
    }];
    
    self.layoutOfContentView = [MLLayout layoutWithTagView:self.contentView block:^(MLLayout * _Nonnull l) {
        l.flexDirection = MLLayoutFlexDirectionRow;
        l.alignItems = MLLayoutAlignmentFlexStart;
        l.padding = UIEdgeInsetsMake(12, 12, 8, 12);
        l.sublayouts = @[
                         [MLLayout layoutWithTagView:_avatarImageView block:^(MLLayout * _Nonnull l) {
                             l.width = l.height = kImageSide;
                         }],
                         [MLLayout layoutWithTagView:nil block:^(MLLayout * _Nonnull l) {
                             l.marginLeft = 10.0f;
                             l.flexDirection = MLLayoutFlexDirectionColumn;
                             l.flex = 1;
                             l.sublayouts = @[
                                              titleLayout,
                                              [MLLayout layoutWithTagView:_contentLabel block:^(MLLayout * _Nonnull l) {
                                                  l.marginTop = 5.0f;
                                              }],
                                              [MLLayout layoutWithTagView:_detailImageView block:^(MLLayout * _Nonnull l) {
                                                  l.marginTop = 5.0f;
                                                  l.height = kDetailImageHeight;
                                              }],
                                              buttonsLayout,
                                              ];
                         }],
                         ];
    }];

}


- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    
    [_avatarImageView sd_setImageWithURL:tweet.avatarURL];
    
    [_detailImageView sd_setImageWithURL:tweet.detailImageURL];
    
    {
        _detailImageView.hidden = tweet.detailImageURL==nil;
        
        //Invalidate a layout temporarily
        [self.layoutOfContentView retrieveLayoutWithView:_detailImageView].invalid = _detailImageView.hidden;
        
        //A long-winded implementation
        //    MLLayout *layoutOfDetailImageView = [self.layoutOfContentView retrieveLayoutWithView:_detailImageView];
        //    layoutOfDetailImageView.height = _detailImageView.hidden?0.0f:kDetailImageHeight;
        //    layoutOfDetailImageView.marginTop = _detailImageView.hidden?0.0f:5.0f;
    }
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:tweet.nickname];
    NSAttributedString *nameAttr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" @%@",tweet.name] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f],NSForegroundColorAttributeName:[UIColor colorWithRed:0.482 green:0.549 blue:0.608 alpha:1.000]}];
    [attr appendAttributedString:nameAttr];
    _nameLabel.attributedText = attr;
    
    _timeLabel.text = tweet.time?:@"";
    
    _contentLabel.text = tweet.content;
    
    [_retweetButton setTitle:tweet.retweetCount>0?[NSString stringWithFormat:@"%ld",(long)tweet.retweetCount]:@"" forState:UIControlStateNormal];
    [_favButton setTitle:tweet.favCount>0?[NSString stringWithFormat:@"%ld",(long)tweet.favCount]:@"" forState:UIControlStateNormal];
    
    [self setNeedsLayout];
}

- (void)layoutSubviewsIfNoFrameRecord {
    [self.layoutOfContentView dirtyAllRelatedLayoutsAndLayoutViewsWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, kMLLayoutUndefined)];
//        NSLog(@"\n\n%@\n\n",[self.layoutOfContentView debugDescriptionWithMode:MLLayoutDebugModeViewLayoutFrame|MLLayoutDebugModeSublayout]);
}

@end
