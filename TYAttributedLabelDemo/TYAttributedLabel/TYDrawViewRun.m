//
//  TYDrawViewRun.m
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/9.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYDrawViewRun.h"

@implementation TYDrawViewRun

- (void)setView:(UIView *)view
{
    _view = view;
    
    if (CGSizeEqualToSize(self.size, CGSizeZero)) {
        self.size = view.frame.size;
    }
}

- (void)setSuperView:(UIView *)superView
{
    if (!_view.superview) {
        [superView addSubview:_view];
        return;
    }
    
    if (_view.superview && _view.superview != superView) {
        [_view removeFromSuperview];
        [superView addSubview:_view];
    }
}

- (void)drawRunWithRect:(CGRect)rect
{
    if (_view == nil || _view.superview == nil) return;

    // 设置frame 注意 转换rect  CoreText context coordinates are the opposite to UIKit so we flip the bounds
    [_view setFrame:CGRectMake(rect.origin.x, _view.superview.bounds.size.height - rect.origin.y - rect.size.height, rect.size.width, rect.size.height)];
}



- (void)dealloc{
    // 需要去掉supview 的 强引用 否则内存泄露
    if (_view.superview) {
        [_view removeFromSuperview];
    }
}

@end
