//
//  TYDrawViewRun.m
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/9.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYDrawViewRun.h"

@implementation TYDrawViewRun

- (void)drawRunWithRect:(CGRect)rect
{
    if (_view == nil || _superView == nil) return;

    if (_view.superview == nil) {
        [_superView addSubview:_view];
    }
    
    // 设置frame 注意 转换rect  CoreText context coordinates are the opposite to UIKit so we flip the bounds
    [_view setFrame:CGRectMake(rect.origin.x, _superView.bounds.size.height - rect.origin.y - rect.size.height, rect.size.width, rect.size.height)];
}

- (void)dealloc{
    // 需要去掉supview 的 强引用 否则内存泄露
    if (_view.superview) {
        [_view removeFromSuperview];
    }
}

@end
