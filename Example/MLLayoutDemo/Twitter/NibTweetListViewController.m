//
//  NibTweetListViewController.m
//  MLLayoutDemo
//
//  Created by molon on 2016/10/9.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "NibTweetListViewController.h"
#import <MLAutoRecordFrameTableView.h>
#import "Tweet.h"
#import "NibTweetTableViewCell.h"

@interface NibTweetListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) MLAutoRecordFrameTableView *tableView;

@property (nonatomic, strong) NSArray<Tweet*> *tweets;

@end

@implementation NibTweetListViewController


- (instancetype)init {
    self = [super init];
    if (self) {
        _tableView = ({
            MLAutoRecordFrameTableView *tableView = [[MLAutoRecordFrameTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([NibTweetTableViewCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([NibTweetTableViewCell class])];
            tableView;
        });
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Nib Twitter Demo";
    [self.view addSubview:_tableView];
    
    NSMutableArray *tweets = [NSMutableArray array];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"twitter" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *ts = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M/d/yy";
    [formatter setLocale:[NSLocale currentLocale]];
    
    for (NSDictionary *dict in ts) {
        //just for test
        Tweet *t = [Tweet new];
        t.name = dict[@"name"];
        t.nickname = dict[@"nickname"];
        t.avatarURL = [NSURL URLWithString:dict[@"avatarURL"]];
        t.content = dict[@"content"];
        t.time = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[dict[@"time"] doubleValue]]];
        t.favCount = [dict[@"favCount"] integerValue];
        t.retweetCount = [dict[@"retweetCount"] integerValue];
        t.detailImageURL = [NSURL URLWithString:dict[@"detailImageURL"]];
        [tweets addObject:t];
    }
    _tweets = tweets;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NibTweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NibTweetTableViewCell class]) forIndexPath:indexPath];

    if (!cell.indexPathForMLAutoRecordFrameBlock) {
        __weak __typeof__(self) wSelf = self;
        [cell setIndexPathForMLAutoRecordFrameBlock:^NSIndexPath * _Nullable(MLAutoRecordFrameTableViewCell * _Nonnull cell) {
            __strong __typeof__(wSelf) sSelf = wSelf;
            NSInteger index = [sSelf.tweets indexOfObject:((NibTweetTableViewCell*)cell).tweet];
            if (index==NSNotFound) {
                return nil;
            }
            
            return [NSIndexPath indexPathForRow:index inSection:0];
        }];
    }
    
    cell.tweet = _tweets[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NibTweetTableViewCell heightForRowUsingPureMLLayoutFromNibAtIndexPath:indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:^(MLAutoRecordFrameTableViewCell * _Nonnull protypeCell) {
        ((NibTweetTableViewCell*)protypeCell).tweet = _tweets[indexPath.row];
    }];
}

@end
