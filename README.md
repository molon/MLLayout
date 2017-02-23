MLLayout
==============
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/molon/MLLayout/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/MLLayout.svg?style=flat)](http://cocoapods.org/?q=MLLayout)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/MLLayout.svg?style=flat)](http://cocoapods.org/?q=MLLayout)&nbsp;
[![Build Status](https://travis-ci.org/molon/MLLayout.svg?branch=master)](https://travis-ci.org/molon/MLLayout)&nbsp;

Flexbox in Objective-C, using Facebook's css-layout.

Inspired by [React Native](https://github.com/facebook/react-native).

- Flexbox is the best way to layout in mobile platform. So many popular libraries use it, eg: [componentkit](https://github.com/facebook/componentkit), [AsyncDisplayKit](https://github.com/facebook/AsyncDisplayKit), [React Native](https://github.com/facebook/react-native), [weex](https://github.com/alibaba/weex) and so on.
- [React Native](https://github.com/facebook/react-native),[weex](https://github.com/alibaba/weex) and `MLLayout` are based on the C implementation of [facebook/css-layout](https://github.com/facebook/css-layout).
- Some code references from [React Native](https://github.com/facebook/react-native), eg: snapping to the pixel grid(No misaligned images to improve drawing performance]).
- `MLLayout` also can be used for layout calculation only. Every layout associated with a view usually, the calculation updates frames of layouts. You can use the frames directly or change them. with your mind.
- `MLTagViewFrameRecord` can preserve current topology of layouts or views. A prerequisite is that each has a valid tag.
- Using `MLTagViewFrameRecord` related TableView and TableViewCell can ensure the layout calculation for one row would not be excuted twice unless reloading it explicitly. The feather can improve scrolling performance greatly.

`FlexBox Guide`: [https://css-tricks.com/snippets/css/a-guide-to-flexbox/](https://css-tricks.com/snippets/css/a-guide-to-flexbox/)

##中文介绍

- Flexbox是现今移动端最优的布局方式，像[componentkit](https://github.com/facebook/componentkit), [AsyncDisplayKit](https://github.com/facebook/AsyncDisplayKit), [React Native](https://github.com/facebook/react-native), [weex](https://github.com/alibaba/weex)等等优秀的开源库都在使用此种布局方式。
- [React Native](https://github.com/facebook/react-native)和[weex](https://github.com/alibaba/weex)以及`MLLayout`都一样是基于facebook开源[facebook/css-layout](https://github.com/facebook/css-layout)的c实现。
- `MLLayout`的一些代码实现是借鉴于[React Native](https://github.com/facebook/react-native)，例如布局计算结果进行默认像素对齐，提升渲染性能。
- `MLLayout`也可以只作为以语义化的形式快速计算布局的工具来用，最终计算出的结果使用与否，随心而定。
- `MLTagViewFrameRecord`可以记录当前的布局结构，但是前提是需要缓存frame的view需要有独特的tag，这样后续才能将记录应用到对应的view上。
- `MLTagViewFrameRecord`相关的TableView和TableViewCell呢，提供了自动缓存cell布局(当然顺带也有高度啦)的实现，这样的话能保证同一行的布局只会计算一次，除非显式reload。这个能大大的提高列表的滚动性能。

花丁点时间学习一下就会发现使用此库写布局代码量很少，并且会让以后维护成本特别的低，代码结构也利索。大言不惭的说，OC原生下最爽的布局库即为本库，不过暂时demo里没有把各个点说全，细节有点多，随着各位兴趣度我再努力添加吧。

`FlexBox教程`: [http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html?utm_source=tuicool](http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html?utm_source=tuicool)

Usage
==============

Simple demo below: 

![SimpleViewController](https://github.com/molon/MLLayout/blob/master/SimpleViewController.gif?raw=true)

```

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
    
```

![TweetListViewController](https://github.com/molon/MLLayout/blob/master/TweetListViewController.gif?raw=true)

The demo uses `MLLayout` to layout subviews of cells and `MLTagViewFrameRecord` to preserve all layout result. Ensure that the layout calculation for one row would not be excuted twice unless reloading it explicitly. The feather can improve scrolling performance greatly.


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
