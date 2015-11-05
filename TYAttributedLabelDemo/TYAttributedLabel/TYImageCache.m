//
//  DBImageViewCache.m
//  DBImageView
//
//  Created by iBo on 25/08/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import "TYImageCache.h"
#import <CommonCrypto/CommonDigest.h>

@interface TYImageCache (){
    NSFileManager *_fileManager;
}

@end

@implementation TYImageCache

static TYImageCache *_instance;

+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)cache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - md5加密
+ (NSString *) md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    if (cStr == NULL) {
        cStr = "";
    }
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (id) init
{
    self= [super init];
    
    if ( self ) {
        _fileManager = [NSFileManager new];
        [self createLocalDirectory];
    }
    
    return self;
}

#pragma mark - 创建缓存图片文件目录
- (void) createLocalDirectory
{
    if ( ![_fileManager fileExistsAtPath:self.localDirectory] ) {
        NSError *error;
        
        if ( ![[NSFileManager defaultManager] createDirectoryAtPath:self.localDirectory withIntermediateDirectories:YES attributes:nil error:&error] ) {
            NSLog(@"[%@] ERROR: attempting to write create MyFolder directory", [self class]);
            NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
        }
    }
}

#pragma mark - 存放image的文件夹路径
- (NSString *) localDirectory
{
    if (_localDirectory == nil) {
        _localDirectory = [NSString stringWithFormat:@"%@/ImageCache", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]];
    }
    
    return _localDirectory;
}

#pragma mark - image名字MD5加密后的路径
- (NSString *) pathOnDiskForName:(NSString *)imageName
{
    return [self.localDirectory stringByAppendingPathComponent:[TYImageCache md5:imageName]];
}

#pragma mark - 保存image和缩略图
- (BOOL) saveImageFromURL:(NSString *)imageName thumbImageSize:(CGSize)thumbImageSize data:(NSData *)imageData
{
    // 转换gif 到 image
    UIImage *image = [UIImage imageWithData:imageData];
    BOOL succeed = [self saveImageFromName:imageName image:image];
    
    if (!CGSizeEqualToSize(thumbImageSize,CGSizeZero)) {
        // 保存thumbImage
        image = [self scaleImage:image ToSize:thumbImageSize];
        succeed = [self saveImageFromName:[NSString stringWithFormat:@"Thumb%@",imageName] image:image];
    }
    return succeed;
}

- (BOOL)saveImageFromURL:(NSString *)imageName data:(NSData *)imageData
{
    return [self saveImageFromURL:imageName thumbImageSize:CGSizeZero data:imageData];
}

#pragma mark - 保存image根据UImage
- (BOOL)saveImageFromName:(NSString *)imageName image:(UIImage *)image
{
    if (!image) {
        return NO;
    }
    if ([imageName hasSuffix:@".png"] || [imageName hasSuffix:@".bmp"]) {
        // png图片
        [UIImagePNGRepresentation(image) writeToFile:[self pathOnDiskForName:imageName] options:NSAtomicWrite error:nil];
        return YES;
    } else if ([imageName hasSuffix:@".jpg"] || [imageName hasSuffix:@".jpeg"] || [imageName hasSuffix:@".gif"])
    {
        //jpg图片
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[self pathOnDiskForName:imageName] options:NSAtomicWrite error:nil];
        return YES;
    } else {
        // 未知图片类型
        NSLog(@"文件后缀名未知! CTImageCache ");
        return NO;
    }
}

#pragma mark - 从网络下载缓存image
// 同步下载保存image
- (BOOL)saveImageFromURL:(NSString *)imageName thumbImageSize:(CGSize)thumbImageSize
{
    // 从网络上加载图片
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageName]];
    if (!data) {
        return NO;
    }
    // 缓存图片
    return [self saveImageFromURL:imageName thumbImageSize:thumbImageSize data:data];
}

// 异步下载保存image
- (void)saveAsyncImageFromURL:(NSString *)imageURL thumbImageSize:(CGSize)thumbImageSize completion:(void(^)(BOOL isCache))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 异步操作
        // 从网络上 缓存图片
        BOOL isCached = [self saveImageFromURL:imageURL thumbImageSize:thumbImageSize];
        
        if (!completionBlock) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // 主线程更新
            completionBlock(isCached);
            
        });
    });
}

- (void)saveAsyncImagesFromURLArray:(NSArray *)imageURLArray thumbImageSize:(CGSize)thumbImageSize completion:(void (^)(BOOL))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 异步操作
        // 从网络上 缓存图片
        __block BOOL isCached = NO;
        [imageURLArray enumerateObjectsUsingBlock:^(NSString *imageURL, NSUInteger idx, BOOL *stop) {
            isCached = [self saveImageFromURL:imageURL thumbImageSize:thumbImageSize];
        }];
        
        if (!completionBlock) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // 主线程更新
            completionBlock(isCached);
            
        });
    });

}

// 同步获取image
- (UIImage *)imageForURL:(NSString *)imageURL
{
    NSString *path = [self pathOnDiskForName:imageURL];
    return [[UIImage alloc] initWithContentsOfFile:path];
}

#pragma mark - image是否存在
- (void) imageForURL:(NSString *)imageURL found:(void(^)(UIImage* image))found notFound:(void(^)())notFound
{
    [self imageForURL:imageURL needThumImage:NO found:found notFound:notFound];
}

#pragma mark - image是否存在,是否需要缩略图,如果知道返回缩略图 否则返回原图
- (void) imageForURL:(NSString *)imageURL needThumImage:(BOOL)needThumImage found:(void(^)(UIImage* image))found notFound:(void(^)())notFound
{
    if ( !imageURL ) {
        return;
    }
    
    NSString *imageName = imageURL;
    if (needThumImage ) {
        imageName = [NSString stringWithFormat:@"Thumb%@",imageURL];
    }
    
    // 图片路径
    UIImage* image = [self imageForURL:imageName];
    
    if (!image && needThumImage) {
        image = [self imageForURL:imageURL];
    }
    
    if (image) {
        found(image);
    }else {
        notFound();
    }
}

#pragma mark - 是否缓存图片
- (BOOL) imageIsCacheForURL:(NSString *)imageURL {

    return [_fileManager fileExistsAtPath:[self pathOnDiskForName:imageURL]];
}

#pragma mark - 清除内存
- (void) clearCache
{
	NSError *error;
    
    [_fileManager removeItemAtPath:self.localDirectory error:&error];
	
	if ( ![_fileManager createDirectoryAtPath:self.localDirectory withIntermediateDirectories:NO attributes:nil error:&error] )
		return;
}

#pragma mark - scale image

// 返回适应到targetSize的合适图片image
- (UIImage *)scaleImage:(UIImage *)sourceImage ToSize:(CGSize)targetSize
{
    CGFloat width = sourceImage.size.width;
    CGFloat height = sourceImage.size.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(sourceImage.size, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor < heightFactor) {
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    // this is actually the interesting part:
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    return newImage ;
}

@end