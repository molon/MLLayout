//
//  TweetTableViewCell.m
//  MLLayoutDemo
//
//  Created by molon on 16/6/28.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "TweetTableViewCell.h"
#import "Tweet.h"
#import <MLLayout.h>
#import <UIImageView+WebCache.h>
#import "UIImage+CornerAndAspectFill.h"

#define kImageSide 48.0f
#define kImageCornerRadius 4.0f
#define kDetailImageHeight 166.0f

#define kBaseTag 1000
@interface TweetTableViewCell()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *detailImageView;
@property (nonatomic, strong) UIButton *retweetButton;
@property (nonatomic, strong) UIButton *replayButton;
@property (nonatomic, strong) UIButton *favButton;

@end

@implementation TweetTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        
        __block NSInteger tag = 1000;
        self.contentView.tag = tag++;
        
        _avatarImageView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.backgroundColor = [UIColor colorWithWhite:0.886 alpha:1.000].CGColor;
            imageView.layer.cornerRadius = kImageCornerRadius;
            imageView.layer.borderWidth = 1.0f/[UIScreen mainScreen].scale;
            imageView.layer.borderColor = [UIColor colorWithWhite:0.837 alpha:1.000].CGColor;
            imageView.tag = tag++;
            [self.contentView addSubview:imageView];
            imageView;
        });
        _nameLabel = ({
            UILabel *label = [UILabel new];
            label.numberOfLines = 1;
            label.font = [UIFont systemFontOfSize:14.0];
            label.textColor = [UIColor darkTextColor];
            label.tag = tag++;
            [self.contentView addSubview:label];
            label;
        });
        _timeLabel = ({
            UILabel *label = [UILabel new];
            label.numberOfLines = 1;
            label.font = [UIFont systemFontOfSize:12.0];
            label.textColor = [UIColor colorWithRed:0.482 green:0.549 blue:0.608 alpha:1.000];
            label.tag = tag++;
            [self.contentView addSubview:label];
            label;
        });
        _contentLabel = ({
            UILabel *label = [UILabel new];
            label.numberOfLines = 0;
            label.font = [UIFont systemFontOfSize:14.0];
            label.textColor = [UIColor darkTextColor];
            label.tag = tag++;
            [self.contentView addSubview:label];
            label;
        });
        _detailImageView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.backgroundColor = [UIColor colorWithWhite:0.886 alpha:1.000].CGColor;
            //just for test ,performance of <imageView> is not what the library need to consider
            imageView.clipsToBounds = YES;
            imageView.tag = tag++;
            [self.contentView addSubview:imageView];
            imageView;
        });
        
        
        UIButton *(^buttonBlock)(NSString *imageName) = ^(NSString *imageName) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12.0f];
            [button setTitleColor:[UIColor colorWithRed:0.537 green:0.596 blue:0.647 alpha:1.000] forState:UIControlStateNormal];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
            [button setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 4)];
            button.tag = tag++;
            [self.contentView addSubview:button];
            return button;
        };
        _replayButton = buttonBlock(@"reply");
        _retweetButton = buttonBlock(@"retweet");
        _favButton = buttonBlock(@"fav");
        
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
                             [MLLayout layoutWithTagView:_replayButton block:^(MLLayout * _Nonnull l) {
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
    return self;
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    
    //poor implementation , just for test
    __weak __typeof(self)wself = self;
    [_avatarImageView sd_setImageWithURL:tweet.avatarURL placeholderImage:nil options:SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __block UIImage *result = image;
        CGFloat lineWeight = wself.avatarImageView.layer.borderWidth;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            result = [image imageByResizeToSize:CGSizeMake(kImageSide, kImageSide) contentMode:UIViewContentModeScaleAspectFill];
            result = [result imageByRoundCornerRadius:kImageCornerRadius corners:UIRectCornerAllCorners borderWidth:lineWeight];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![imageURL isEqual:wself.avatarImageView.sd_imageURL]) {
                    return;
                }
                
                wself.avatarImageView.image = result;
                [wself.avatarImageView setNeedsLayout];
            });
        });
    }];
    
    [_detailImageView sd_setImageWithURL:tweet.detailImageURL placeholderImage:nil];
    
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
    [self.layoutOfContentView dirtyAllRelativeLayoutsAndLayoutViewsWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, kMLLayoutUndefined)];
    //    NSLog(@"\n\n%@\n\n",[_layout debugDescriptionWithMode:MLLayoutDebugModeViewLayoutFrame|MLLayoutDebugModeSublayout]);
}

@end
