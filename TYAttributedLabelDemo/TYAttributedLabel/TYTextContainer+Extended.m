//
//  TYTextContainer+Extended.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/6/7.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYTextContainer.h"
#import "TYImageStorage.h"
#import "TYViewStorage.h"
#import "TYLinkTextStorage.h"

@implementation TYTextContainer (Link)

#pragma mark - addLink
- (void)addLinkWithLinkData:(id)linkData range:(NSRange)range
{
    [self addLinkWithLinkData:linkData linkColor:nil range:range];
}

- (void)addLinkWithLinkData:(id)linkData linkColor:(UIColor *)linkColor range:(NSRange )range;
{
    [self addLinkWithLinkData:linkData linkColor:linkColor underLineStyle:kCTUnderlineStyleSingle range:range];
}

- (void)addLinkWithLinkData:(id)linkData linkColor:(UIColor *)linkColor underLineStyle:(CTUnderlineStyle)underLineStyle range:(NSRange )range
{
    TYLinkTextStorage *linkTextStorage = [[TYLinkTextStorage alloc]init];
    linkTextStorage.range = range;
    linkTextStorage.textColor = linkColor;
    linkTextStorage.linkData = linkData;
    linkTextStorage.underLineStyle = underLineStyle;
    [self addTextStorage:linkTextStorage];
}

#pragma mark - appendLink
- (void)appendLinkWithText:(NSString *)linkText linkFont:(UIFont *)linkFont linkData:(id)linkData
{
    [self appendLinkWithText:linkText linkFont:linkFont linkColor:nil linkData:linkData];
}

- (void)appendLinkWithText:(NSString *)linkText linkFont:(UIFont *)linkFont linkColor:(UIColor *)linkColor linkData:(id)linkData
{
    [self appendLinkWithText:linkText linkFont:linkFont linkColor:linkColor underLineStyle:kCTUnderlineStyleSingle linkData:linkData];
}

- (void)appendLinkWithText:(NSString *)linkText linkFont:(UIFont *)linkFont linkColor:(UIColor *)linkColor underLineStyle:(CTUnderlineStyle)underLineStyle linkData:(id)linkData
{
    TYLinkTextStorage *linkTextStorage = [[TYLinkTextStorage alloc]init];
    linkTextStorage.text = linkText;
    linkTextStorage.font = linkFont;
    linkTextStorage.textColor = linkColor;
    linkTextStorage.linkData = linkData;
    linkTextStorage.underLineStyle = underLineStyle;
    [self appendTextStorage:linkTextStorage];
}

@end

@implementation TYTextContainer (UIImage)

#pragma mark addImage

- (void)addImageContent:(id)imageContent range:(NSRange)range size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    TYImageStorage *imageStorage = [[TYImageStorage alloc]init];
    if ([imageContent isKindOfClass:[UIImage class]]) {
        imageStorage.image = imageContent;
    }else if ([imageContent isKindOfClass:[NSString class]]){
        imageStorage.imageName = imageContent;
    } else {
        return;
    }
    
    imageStorage.drawAlignment = alignment;
    imageStorage.range = range;
    imageStorage.size = size;
    [self addTextStorage:imageStorage];
}

- (void)addImage:(UIImage *)image range:(NSRange)range size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    [self addImageContent:image range:range size:size alignment:alignment];
}

- (void)addImage:(UIImage *)image range:(NSRange)range size:(CGSize)size
{
    [self addImage:image range:range size:size alignment:TYDrawAlignmentTop];
}

- (void)addImage:(UIImage *)image range:(NSRange)range
{
    [self addImage:image range:range size:image.size];
}

- (void)addImageWithName:(NSString *)imageName range:(NSRange)range size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    [self addImageContent:imageName range:range size:size alignment:alignment];
}

- (void)addImageWithName:(NSString *)imageName range:(NSRange)range size:(CGSize)size
{
    [self addImageWithName:imageName range:range size:size alignment:TYDrawAlignmentTop];
}

- (void)addImageWithName:(NSString *)imageName range:(NSRange)range
{
    [self addImageWithName:imageName range:range size:CGSizeMake(self.font.pointSize, self.font.ascender)];
    
}

#pragma mark - appendImage

- (void)appendImageContent:(id)imageContent size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    TYImageStorage *imageStorage = [[TYImageStorage alloc]init];
    if ([imageContent isKindOfClass:[UIImage class]]) {
        imageStorage.image = imageContent;
    }else if ([imageContent isKindOfClass:[NSString class]]){
        imageStorage.imageName = imageContent;
    } else {
        return;
    }
    
    imageStorage.drawAlignment = alignment;
    imageStorage.size = size;
    [self appendTextStorage:imageStorage];
}

- (void)appendImage:(UIImage *)image size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    [self appendImageContent:image size:size alignment:alignment];
}

- (void)appendImage:(UIImage *)image size:(CGSize)size
{
    [self appendImage:image size:size alignment:TYDrawAlignmentTop];
}

- (void)appendImage:(UIImage *)image
{
    [self appendImage:image size:image.size];
}

- (void)appendImageWithName:(NSString *)imageName size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    [self appendImageContent:imageName size:size alignment:alignment];
}

- (void)appendImageWithName:(NSString *)imageName size:(CGSize)size
{
    [self appendImageWithName:imageName size:size alignment:TYDrawAlignmentTop];
}

- (void)appendImageWithName:(NSString *)imageName
{
    [self appendImageWithName:imageName size:CGSizeMake(self.font.pointSize, self.font.ascender)];
    
}

@end

@implementation TYTextContainer (UIView)

#pragma mark - addView

- (void)addView:(UIView *)view range:(NSRange)range alignment:(TYDrawAlignment)alignment
{
    TYViewStorage *viewStorage = [[TYViewStorage alloc]init];
    viewStorage.drawAlignment = alignment;
    viewStorage.view = view;
    viewStorage.range = range;
    
    [self addTextStorage:viewStorage];
}

- (void)addView:(UIView *)view range:(NSRange)range
{
    [self addView:view range:range alignment:TYDrawAlignmentTop];
}

#pragma mark - appendView

- (void)appendView:(UIView *)view alignment:(TYDrawAlignment)alignment
{
    TYViewStorage *viewStorage = [[TYViewStorage alloc]init];
    viewStorage.drawAlignment = alignment;
    viewStorage.view = view;
    
    [self appendTextStorage:viewStorage];
}

- (void)appendView:(UIView *)view
{
    [self appendView:view alignment:TYDrawAlignmentTop];
}


@end
