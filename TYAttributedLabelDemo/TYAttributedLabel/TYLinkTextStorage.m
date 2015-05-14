//
//  TYLinkTextStorage.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYLinkTextStorage.h"

@implementation TYLinkTextStorage

- (instancetype)init
{
    if (self = [super init]) {
        self.underLineStyle = kCTUnderlineStyleSingle;
        self.modifier = kCTUnderlinePatternSolid;
    }
    return self;
}

#pragma mark - protocol

- (void)addTextStorageWithAttributedString:(NSMutableAttributedString *)attributedString
{
    [super addTextStorageWithAttributedString:attributedString];
    [attributedString addAttribute:kTYTextRunAttributedName value:self range:self.range];
    self.text = [attributedString.string substringWithRange:self.range];

}

@end
