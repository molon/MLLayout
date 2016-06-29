MLLayout
==============
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/molon/MLLayout/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/MLLayout.svg?style=flat)](http://cocoapods.org/?q=MLLayout)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/MLLayout.svg?style=flat)](http://cocoapods.org/?q=MLLayout)&nbsp;
[![Build Status](https://travis-ci.org/molon/MLLayout.svg?branch=master)](https://travis-ci.org/molon/MLLayout)&nbsp;

Flexbox in Objective-C, using Facebook's css-layout.

Inspired by [React Native](https://github.com/facebook/react-native).

Usage
==============
`FlexBox Guide`: [https://css-tricks.com/snippets/css/a-guide-to-flexbox/](https://css-tricks.com/snippets/css/a-guide-to-flexbox/)

`Chinese FlexBox Guide`: [http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html?utm_source=tuicool](http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html?utm_source=tuicool)

Simple demo below: 

![SimpleViewController](https://raw.githubusercontent.com/molon/MLLayout/master/SimpleViewController.gif)

```

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
                         [MLLayout layoutWithTagView:_bkgView block:^(MLLayout * _Nonnull l) {
                             l.marginLeft = l.marginRight = 10.0f;
                             //test for round pixel
                             l.padding = UIEdgeInsetsMake(10.34f, 15.37f, 10.5608f, 15.3567f);
                             
                             l.flexDirection = MLLayoutFlexDirectionColumn;
                             l.alignItems = MLLayoutAlignmentCenter;
                             l.alignSelf = MLLayoutAlignmentCenter;
                             l.sublayouts = @[
                                              [MLLayout layoutWithTagView:_firstLabel block:nil],
                                              //placeholder(nil view) as sapce
                                              //                                              [MLLayout layoutWithTagView:nil block:^(MLLayout * _Nonnull l) {
                                              //                                                  l.height = 10.0f;
                                              //                                              }],
                                              [MLLayout layoutWithTagView:_secondLabel block:^(MLLayout * _Nonnull l) {
                                                  l.marginTop = 10.0f; //space
                                                  l.flex = -1;
                                              }],
                                              ];
                         }],
                         ];
    }];

```

![TweetListViewController](https://raw.githubusercontent.com/molon/MLLayout/master/TweetListViewController.gif)
The demo uses `MLLayout` to layout subviews of cells and `MLTagViewFrameRecord` to record all layout result.

Then we can ensure that never executed layout calculation twice, improve scrolling performance greatly. (Recording .gif with simulator, so the image fails to reflect the effect)


Installation
==============

### CocoaPods

1. Add `pod 'MLLayout'` to your Podfile.
2. Run `pod install` or `pod update`.
3. Import \<MLLayout/MLLayout.h\>.


Requirements
==============
This library requires `iOS 7.0+` and `Xcode 7.0+`.


License
==============
MLLayout is provided under the MIT license. See LICENSE file for details.

