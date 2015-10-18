//
//  TYDrawImageStorage.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYImageStorage.h"
#import "TYImageCache.h"

@interface TYImageStorage ()
@property (nonatomic, weak) UIView *ownerView;
@property (nonatomic, assign) BOOL isNeedUpdateFrame;
@end

@implementation TYImageStorage

- (instancetype)init
{
    if (self = [super init]) {
        _cacheImageOnMemory = NO;
    }
    return self;
}

#pragma mark - protocol

- (void)setOwnerView:(UIView *)ownerView
{
    _ownerView = ownerView;
    
    if ([_imageURL isKindOfClass:[NSURL class]]
        && ![[TYImageCache cache] imageIsCacheForURL:_imageURL.absoluteString]) {
        
        [[TYImageCache cache]saveAsyncImageFromURL:_imageURL.absoluteString thumbImageSize:self.size completion:^(BOOL isCache) {
            
            if (_isNeedUpdateFrame) {
                if (ownerView && isCache) {
                    [ownerView setNeedsDisplay];
                }
                _isNeedUpdateFrame = NO;
            }
        }];
    }
}

- (void)drawStorageWithRect:(CGRect)rect
{
    __block UIImage *image = nil;
    
    if (_image) {
        // 本地图片名
        image = _image;
    }else if (_imageName){
        // 图片网址
        image = [UIImage imageNamed:_imageName];
        if (_cacheImageOnMemory) {
            _image = image;
        }
    } else if (_imageURL){
        // 图片数据
        [[TYImageCache cache] imageForURL:_imageURL.absoluteString needThumImage:NO found:^(UIImage *loaceImage) {
            image = loaceImage;
            if (_cacheImageOnMemory) {
                _image = image;
            }
        } notFound:^{
            image = _placeholdImageName ? [UIImage imageNamed:_placeholdImageName] : nil;
            _isNeedUpdateFrame = YES;
        }];
    }
    
    if (image) {
        CGSize size = [self sizeFitOriginSize:image.size bySize:rect.size];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, CGRectMake(rect.origin.x, rect.origin.y, size.width, size.height), image.CGImage);
    }
}

- (CGSize)sizeFitOriginSize:(CGSize)size bySize:(CGSize)bySize{
    if (size.width > bySize.width) {
        CGFloat scale = bySize.width/size.width;
        CGFloat height = size.height * scale;
        return CGSizeMake(bySize.width, height);
    }else if(size.height > bySize.height ) {
        CGFloat scale = bySize.height/size.height;
        CGFloat width = size.width * scale;
        return CGSizeMake(width, bySize.height);
    }
    return size;
}

// override
- (void)didNotDrawRun
{
    
}

@end
