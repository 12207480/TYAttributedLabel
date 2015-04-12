//
//  TYDrawViewRun.m
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/9.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYDrawViewRun.h"

@interface TYDrawViewRun ()
@property (nonatomic, weak) UIView *superView;
@end

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
    if (_view.superview) {
        [_view removeFromSuperview];
    }
    
    if (superView) {
        _superView = superView;
    }
}

- (void)didNotDrawRun
{
    [_view removeFromSuperview];
}

- (void)drawRunWithRect:(CGRect)rect
{
    if (_view == nil || _superView == nil) return;
    
    // 设置frame 注意 转换rect  CoreText context coordinates are the opposite to UIKit so we flip the bounds
    CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, _superView.bounds.size.height), 1.f, -1.f);
    rect = CGRectApplyAffineTransform(rect, transform);
    [_view setFrame:CGRectMake(rect.origin.x,rect.origin.y, rect.size.width, rect.size.height)];
    [_superView addSubview:_view];
    //[_view setFrame:CGRectMake(rect.origin.x, _view.superview.bounds.size.height - rect.origin.y - rect.size.height, rect.size.width, rect.size.height)];
}



- (void)dealloc{
    // 需要去掉supview 的 强引用 否则内存泄露
    if (_view.superview) {
        [_view removeFromSuperview];
    }
}

@end
