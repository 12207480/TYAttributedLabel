//
//  TYAttributedLabel+ImageAndView.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/11.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYAttributedLabel.h"
#import "TYDrawImageStorage.h"
#import "TYDrawViewStorage.h"

@implementation TYAttributedLabel (UIImageAndUIView)

- (void)addImageWithName:(NSString *)imageName range:(NSRange)range size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    TYDrawImageStorage *imageRun = [[TYDrawImageStorage alloc]init];
    imageRun.imageName = imageName;
    imageRun.drawAlignment = alignment;
    imageRun.range = range;
    imageRun.size = size;
    [self addTextStorage:imageRun];
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
    TYDrawViewStorage *viewRun = [[TYDrawViewStorage alloc]init];
    viewRun.drawAlignment = alignment;
    viewRun.view = view;
    viewRun.range = range;
    
    [self addTextStorage:viewRun];
}

- (void)addView:(UIView *)view range:(NSRange)range
{
    [self addView:view range:range alignment:TYDrawAlignmentTop];
}

- (void)appendImageWithName:(NSString *)imageName size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    TYDrawImageStorage *imageStorage = [[TYDrawImageStorage alloc]init];
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
    TYDrawViewStorage *viewRun = [[TYDrawViewStorage alloc]init];
    viewRun.drawAlignment = alignment;
    viewRun.view = view;
    
    [self appendTextStorage:viewRun];
}

- (void)appendView:(UIView *)view
{
    [self appendView:view alignment:TYDrawAlignmentTop];
}


@end
