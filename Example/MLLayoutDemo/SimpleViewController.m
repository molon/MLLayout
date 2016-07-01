//
//  SimpleViewController.m
//  MLLayoutDemo
//
//  Created by molon on 16/6/22.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "SimpleViewController.h"
#import "MLLayout.h"

@interface SimpleViewController ()

@property (nonatomic, strong) UIView *bkgView;
@property (nonatomic, strong) UILabel *firstLabel;
@property (nonatomic, strong) UILabel *secondLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) MLLayout *layout;

@end

@implementation SimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Simple Demo";
    
    //If you want to use `applyTagViewsWithRootView:` method or `exportTagViewFrameRecord` method.
    //You must set different tags to relative views.
    NSInteger tag = 100;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.918 green:0.918 blue:0.875 alpha:1.000];
    self.view.tag = tag++;
    
    _bkgView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor colorWithRed:0.986 green:1.000 blue:0.971 alpha:1.000];
        view.tag = 101;
        [self.view addSubview:view];
        view;
    });
    
    _firstLabel = ({
        UILabel *label = [UILabel new];
        label.textColor = [UIColor colorWithRed:0.933 green:0.208 blue:0.122 alpha:1.000];
        label.backgroundColor = [UIColor colorWithWhite:0.855 alpha:0.000];
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:14.0];
        label.text = @"Inception";
        label.tag = tag++;
        [_bkgView addSubview:label];
        label;
    });
    
    _secondLabel = ({
        UILabel *label = [UILabel new];
        label.textColor = [UIColor colorWithRed:0.239 green:0.204 blue:0.176 alpha:1.000];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:14.0];
        label.text = @"Dom Cobb is a skilled thief, the absolute best in the dangerous art of extraction, stealing valuable secrets from deep within the subconscious during the dream state, when the mind is at its most vulnerable. Cobb's rare ability has made him a coveted player in this treacherous new world of corporate espionage, but it has also made him an international fugitive and cost him everything he has ever loved. Now Cobb is being offered a chance at redemption. One last job could give him his life back but only if he can accomplish the impossible-inception. Instead of the perfect heist, Cobb and his team of specialists have to pull off the reverse: their task is not to steal an idea but to plant one. If they succeed, it could be the perfect crime. But no amount of careful planning or expertise can prepare the team for the dangerous enemy that seems to predict their every move. An enemy that only Cobb could have seen coming.";
        label.tag = tag++;
        [_bkgView addSubview:label];
        label;
    });
    
    
    //change layout button
    _button = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor lightGrayColor];
        [button setTitle:@"Change Layout" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(changeLayoutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        button.tag = tag++;
        [self.view addSubview:button];
        button;
    });
    
    //imageView
    _imageView = ({
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flex"]];
        imageView.tag = tag++;
        [self.view addSubview:imageView];
        imageView;
    });
    
    //display switch button
    UIButton *displaySwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    displaySwitchButton.backgroundColor = [UIColor lightGrayColor];
    [displaySwitchButton setTitle:@"Remove Image" forState:UIControlStateNormal];
    [displaySwitchButton addTarget:self action:@selector(displaySwitchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    displaySwitchButton.tag = tag++;
    [self.view addSubview:displaySwitchButton];
    
    MLLayout *bkgViewLayout = [MLLayout layoutWithTagView:_bkgView block:^(MLLayout * _Nonnull l) {
        l.marginLeft = l.marginRight = 10.0f;
        //test for round pixel
        l.padding = UIEdgeInsetsMake(10.34f, 15.37f, 10.5608f, 15.3567f);
        
        l.flexDirection = MLLayoutFlexDirectionColumn;
        l.alignItems = MLLayoutAlignmentCenter;
        l.alignSelf = MLLayoutAlignmentCenter;
        l.sublayouts = @[
                         [MLLayout layoutWithTagView:_firstLabel block:nil],
                         [MLLayout layoutWithTagView:_secondLabel block:^(MLLayout * _Nonnull l) {
                             l.marginTop = 10.0f; //space
                             l.flex = -1;
                         }],
                         ];
    }];
    
    _layout = [MLLayout layoutWithTagView:self.view block:^(MLLayout * _Nonnull l) {
        l.flexDirection = MLLayoutFlexDirectionColumn;
        l.justifyContent = MLLayoutJustifyContentCenter;
        l.alignItems = MLLayoutAlignmentCenter;
        l.sublayouts = @[
                         [MLLayout layoutWithTagView:nil block:^(MLLayout * _Nonnull l) {
                             //test MLLayoutPositionAbsolute
                             l.position = MLLayoutPositionAbsolute;
                             l.bottom = 20.0f;
                             l.right = 20.0;
                             
                             l.flexDirection = MLLayoutFlexDirectionColumn;
                             l.sublayouts = @[
                                              [MLLayout layoutWithTagView:_button block:nil],
                                              [MLLayout layoutWithTagView:displaySwitchButton block:^(MLLayout * _Nonnull l) {
                                                  l.marginTop = 10.0f;
                                              }]
                                              ];
                         }],
                         [MLLayout layoutWithTagView:_imageView block:^(MLLayout * _Nonnull l) {
                             //test MLLayoutPositionRelative
                             l.position = MLLayoutPositionRelative;
                             l.bottom = 10.0f;
                         }],
                         bkgViewLayout
                         ];
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //just calculate new frames of views and auto set new frames to them
    //same with `[self layoutViewsWithUpdatedLayouts:[self updatedLayoutsAfterLayoutCalculationWithFrame]];`
    [_layout layoutViewsWithFrame:self.view.bounds];
    
    //wo can also set the frame manually or changed the calculated frame here.
    //#define kButtonWidth 120.0f
    //    _button.frame = CGRectMake((self.view.frame.size.width-kButtonWidth)/2, self.view.frame.size.height-150, kButtonWidth, 50);
}

#pragma mark - event
- (void)changeLayoutButtonClicked {
    //change css styles or other properties of layout causes dirtyLayout automatically
    _layout.justifyContent = _layout.justifyContent == MLLayoutJustifyContentFlexEnd?MLLayoutJustifyContentCenter:MLLayoutJustifyContentFlexEnd;
    
    MLLayout *bkgLayout = [_layout retrieveLayoutWithView:_bkgView];
    bkgLayout.height = isMLLayoutUndefined(bkgLayout.height)?150:kMLLayoutUndefined;
    bkgLayout.width = isMLLayoutUndefined(bkgLayout.width)?150:kMLLayoutUndefined;
    bkgLayout.alignSelf = bkgLayout.alignSelf==MLLayoutAlignmentFlexStart?MLLayoutAlignmentCenter:MLLayoutAlignmentFlexStart;
    
    
    _firstLabel.text = [_firstLabel.text isEqualToString:@"Inception"]?@"Description":@"Inception";
    //Because setText method of a label may affect the measure size
    //So we must dirty it's associated layout explicitly
    [[_layout retrieveLayoutWithView:_firstLabel] dirtyLayout];
    
    [self.view setNeedsLayout];
    [UIView animateWithDuration:.25f animations:^{
        [self.view layoutIfNeeded];
    }];
    
    NSLog(@"\n\n%@\n\n",[_layout debugDescriptionWithMode:MLLayoutDebugModeViewLayoutFrame|MLLayoutDebugModeSublayout]);
}

- (void)displaySwitchButtonClicked {
    {
    //Invalidate a layout temporarily
    //Tips: MLLayout'view is a weak property. so please ensure that the associated view doesn't release when it's layout in use.
    _imageView.hidden = !_imageView.hidden;
    [_layout retrieveLayoutWithView:_imageView].invalid = _imageView.hidden;
    
    //A long-winded implementation
//    if (_imageView.superview) {
//        [_imageView removeFromSuperview];
//        [[_layout retrieveLayoutWithView:_imageView]removeFromSuperlayout];
//    }else{
//        [self.view addSubview:_imageView];
//        [_layout insertSublayout:[MLLayout layoutWithTagView:_imageView block:^(MLLayout * _Nonnull l) {
//            //test MLLayoutPositionRelative
//            l.position = MLLayoutPositionRelative;
//            l.bottom = 10.0f;
//        }] atIndex:1];
//    }
    }
    
    //other test
    {
//        _bkgView.hidden = !_bkgView.hidden;
//        [_layout retrieveLayoutWithView:_bkgView].invalid = _bkgView.hidden;
    }
    
    [self.view setNeedsLayout];
    [UIView animateWithDuration:.25f animations:^{
        [self.view layoutIfNeeded];
    }];
    
    NSLog(@"\n\n%@\n\n",[_layout debugDescriptionWithMode:MLLayoutDebugModeViewLayoutFrame|MLLayoutDebugModeSublayout]);
}

@end
