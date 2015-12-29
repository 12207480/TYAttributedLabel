//
//  TYDrawViewStorage.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/9.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYViewStorage.h"

@interface TYViewStorage ()
@property (nonatomic, weak) UIView *superView;
@end

@implementation TYViewStorage

#pragma mark - protocol

- (void)setView:(UIView *)view
{
    _view = view;

    if (CGSizeEqualToSize(self.size, CGSizeZero)) {
        self.size = view.frame.size;
    }
}

- (void)setOwnerView:(UIView *)ownerView
{
    if (_view.superview) {
        [_view removeFromSuperview];
    }
    
    if (ownerView) {
        _superView = ownerView;
    }
}

- (void)didNotDrawRun
{
    [_view removeFromSuperview];
}

- (void)drawStorageWithRect:(CGRect)rect
{
    if (_view == nil || _superView == nil) return;
    // 设置frame 注意 转换rect  CoreText context coordinates are the opposite to UIKit so we flip the bounds
    CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, _superView.bounds.size.height), 1.f, -1.f);
    rect = CGRectApplyAffineTransform(rect, transform);
    [_view setFrame:rect];
    [_superView addSubview:_view];
}

- (void)dealloc{
    // 需要去掉supview 的 强引用 否则内存泄露
    if (_view.superview) {
        [_view removeFromSuperview];
    }
}

@end
