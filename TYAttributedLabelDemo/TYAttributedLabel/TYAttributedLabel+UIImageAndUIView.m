//
//  TYAttributedLabel+ImageAndView.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/11.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYAttributedLabel.h"
#import "TYImageStorage.h"
#import "TYViewStorage.h"

@implementation TYAttributedLabel (UIImageAndUIView)

- (void)addImageWithName:(NSString *)imageName range:(NSRange)range size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    TYImageStorage *imageStorage = [[TYImageStorage alloc]init];
    imageStorage.imageName = imageName;
    imageStorage.drawAlignment = alignment;
    imageStorage.range = range;
    imageStorage.size = size;
    [self addTextStorage:imageStorage];
}

- (void)addImageWithName:(NSString *)imageName range:(NSRange)range size:(CGSize)size
{
    [self addImageWithName:imageName range:range size:size alignment:TYDrawAlignmentTop];
}

- (void)addImageWithName:(NSString *)imageName range:(NSRange)range
{
    [self addImageWithName:imageName range:range size:CGSizeMake(self.font.pointSize, self.font.ascender)];

}

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

- (void)appendImageWithName:(NSString *)imageName size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    TYImageStorage *imageStorage = [[TYImageStorage alloc]init];
    imageStorage.drawAlignment = alignment;
    imageStorage.imageName = imageName;
    imageStorage.size = size;
    
    [self appendTextStorage:imageStorage];
}

- (void)appendImageWithName:(NSString *)imageName size:(CGSize)size
{
    [self appendImageWithName:imageName size:size alignment:TYDrawAlignmentTop];
}

- (void)appendImageWithName:(NSString *)imageName
{
    [self appendImageWithName:imageName size:CGSizeMake(self.font.pointSize, self.font.ascender)];
    
}

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
