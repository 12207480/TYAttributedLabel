//
//  TYDrawImageStorage.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYImageStorage.h"

@interface TYImageStorage ()
@property (nonatomic, weak) UIView *ownerView;
@end

@implementation TYImageStorage

#pragma mark - protocol

- (void)setOwnerView:(UIView *)ownerView
{
    _ownerView = ownerView;
}

- (void)drawStorageWithRect:(CGRect)rect
{
    UIImage *image = nil;
    
    if (_image) {
        // 本地图片名
        image = _image;
    }else if (_imageName){
        // 图片网址
        image = [UIImage imageNamed:_imageName];
    } else if (_imageURL){
        // 图片数据
        [self imageForUrl:_imageURL];
    }
    
    if (image) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, rect, image.CGImage);
    }
}

- (void)didNotDrawRun
{
    
}

#pragma mark - private

// 从网络获取图片
- (void)imageForUrl:(NSURL *)imageUrl
{
    // 异步下载图片
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
        
        // 回到主线程显示图片
        dispatch_async(dispatch_get_main_queue(), ^{
            _image = image;
            if (_ownerView) {
                [_ownerView setNeedsDisplay];
            }
        });  
    });
}

@end
