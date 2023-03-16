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
    
    _superView = ownerView;
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
    
    //iOS 9 以上系统兼容 RTL 排版方向
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        if (UIUserInterfaceLayoutDirectionRightToLeft == [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:_superView.semanticContentAttribute]) {
            rect.origin.x = rect.origin.x - rect.size.width;
        }
    }
    
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
