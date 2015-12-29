//
//  TYTextContainer.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/6/4.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYTextContainer.h"

#define kTextColor       [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define kLinkColor       [UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1]

// this code quote TTTAttributedLabel
static inline CGSize CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(CTFramesetterRef framesetter, NSAttributedString *attributedString, CGSize size, NSUInteger numberOfLines) {
    CFRange rangeToSize = CFRangeMake(0, (CFIndex)[attributedString length]);
    CGSize constraints = CGSizeMake(size.width, MAXFLOAT);
    
    if (numberOfLines > 0) {
        // If the line count of the label more than 1, limit the range to size to the number of lines that have been set
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, MAXFLOAT));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN((CFIndex)numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        
        CFRelease(frame);
        CFRelease(path);
    }
    
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, rangeToSize, NULL, constraints, NULL);
    
    return CGSizeMake(ceil(suggestedSize.width), ceil(suggestedSize.height));
}

@interface TYTextContainer()
@property (nonatomic, strong) NSMutableArray    *textStorageArray;  // run数组
@property (nonatomic, strong) NSArray *textStorages; // run array copy

@property (nonatomic, strong) NSDictionary  *drawRectDictionary;
@property (nonatomic, strong) NSDictionary  *runRectDictionary;  // runRect字典
@property (nonatomic, strong) NSDictionary  *linkRectDictionary; // linkRect字典

@property (nonatomic, assign) NSInteger         replaceStringNum;   // 图片替换字符数
@property (nonatomic, strong) NSMutableAttributedString *attString;
@property (nonatomic, assign) CTFrameRef  frameRef;
@property (nonatomic, assign) CGFloat     textHeight;
@property (nonatomic, assign) CGFloat     textWidth;

@end

@implementation TYTextContainer

- (instancetype)init
{
    if (self = [super init]) {
        [self setupProperty];
    }
    return self;
}

#pragma mark - getter

- (NSMutableArray *)textStorageArray
{
    if (_textStorageArray == nil) {
        _textStorageArray = [NSMutableArray array];
    }
    return _textStorageArray;
}

- (NSString *)text{
    return _attString.string;
}

- (NSAttributedString *)attributedText
{
    return [_attString copy];
}

- (NSAttributedString *)createAttributedString
{
    [self addTextStoragesWithAtrributedString:_attString];
    if (_attString == nil) {
        _attString = [[NSMutableAttributedString alloc]init];
    }
    return [_attString copy];
}

#pragma mark - setter
- (void)setupProperty
{
    _font = [UIFont systemFontOfSize:15];
    _characterSpacing = 1;
    _linesSpacing = 2;
    _textAlignment = kCTLeftTextAlignment;
    _lineBreakMode = kCTLineBreakByCharWrapping;
    _textColor = kTextColor;
    _linkColor = kLinkColor;
    _replaceStringNum = 0;
}

- (void)resetAllAttributed
{
    [self resetRectDictionary];
    _textStorageArray = nil;
    _textStorages = nil;
    _replaceStringNum = 0;
}

- (void)resetRectDictionary
{
    _drawRectDictionary = nil;
    _linkRectDictionary = nil;
    _runRectDictionary = nil;
}

- (void)resetFrameRef
{
    if (_frameRef) {
        CFRelease(_frameRef);
        _frameRef = nil;
    }
    _textHeight = 0;
}

- (void)setText:(NSString *)text
{
    _attString = [self createTextAttibuteStringWithText:text];
    [self resetAllAttributed];
    [self resetFrameRef];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if (attributedText == nil) {
        _attString = [[NSMutableAttributedString alloc]init];
    }else if ([attributedText isKindOfClass:[NSMutableAttributedString class]]) {
        _attString = (NSMutableAttributedString *)attributedText;
    }else {
        _attString = [[NSMutableAttributedString alloc]initWithAttributedString:attributedText];
    }
    [self resetAllAttributed];
    [self resetFrameRef];
}

- (void)setTextColor:(UIColor *)textColor
{
    if (textColor && _textColor != textColor){
        _textColor = textColor;
        
        [_attString addAttributeTextColor:textColor];
        [self resetFrameRef];
    }
}

- (void)setFont:(UIFont *)font
{
    if (font && _font != font){
        _font = font;
        
        [_attString addAttributeFont:font];
        [self resetFrameRef];
    }
}

- (void)setCharacterSpacing:(unichar)characterSpacing
{
    if (characterSpacing >= 0 && _characterSpacing != characterSpacing) {
        _characterSpacing = characterSpacing;
        
        [_attString addAttributeCharacterSpacing:characterSpacing];
        [self resetFrameRef];
    }
}

- (void)setLinesSpacing:(CGFloat)linesSpacing
{
    if (_linesSpacing != linesSpacing) {
        _linesSpacing = linesSpacing;
        
        [_attString addAttributeAlignmentStyle:_textAlignment lineSpaceStyle:linesSpacing lineBreakStyle:_lineBreakMode];
        [self resetFrameRef];
    }
}

- (void)setTextAlignment:(CTTextAlignment)textAlignment
{
    if (_textAlignment != textAlignment) {
        _textAlignment = textAlignment;
        
        [_attString addAttributeAlignmentStyle:textAlignment lineSpaceStyle:_linesSpacing lineBreakStyle:_lineBreakMode];
        [self resetFrameRef];
    }
}

- (void)setLineBreakMode:(CTLineBreakMode)lineBreakMode
{
    if (_lineBreakMode != lineBreakMode) {
        _lineBreakMode = lineBreakMode;
        if (_lineBreakMode == kCTLineBreakByTruncatingTail)
        {
            lineBreakMode = _numberOfLines == 1 ? kCTLineBreakByCharWrapping : kCTLineBreakByWordWrapping;
        }
        
        [_attString addAttributeAlignmentStyle:_textAlignment lineSpaceStyle:_linesSpacing lineBreakStyle:lineBreakMode];
        [self resetFrameRef];

    }
}

#pragma mark - create text attibuteString
- (NSMutableAttributedString *)createTextAttibuteStringWithText:(NSString *)text
{
    if (text.length <= 0) {
        return [[NSMutableAttributedString alloc]init];
    }
    // 创建属性文本
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:text];
    
    // 添加文本颜色 字体属性
    [self addTextColorAndFontWithAtrributedString:attString];
    
    // 添加文本段落样式
    [self addTextParaphStyleWithAtrributedString:attString];
    
    return attString;
}

// 添加文本颜色 字体属性
- (void)addTextColorAndFontWithAtrributedString:(NSMutableAttributedString *)attString
{
    // 添加文本字体
    [attString addAttributeFont:_font];
    
    // 添加文本颜色
    [attString addAttributeTextColor:_textColor];
    
}

// 添加文本段落样式
- (void)addTextParaphStyleWithAtrributedString:(NSMutableAttributedString *)attString
{
    // 字体间距
    if (_characterSpacing)
    {
        [attString addAttributeCharacterSpacing:_characterSpacing];
    }
    
    // 添加文本段落样式
    [attString addAttributeAlignmentStyle:_textAlignment lineSpaceStyle:_linesSpacing lineBreakStyle:_lineBreakMode];
}

#pragma mark -  add text storage atrributed
- (void)addTextStoragesWithAtrributedString:(NSMutableAttributedString *)attString
{
    if (attString && _textStorageArray.count > 0) {
        
        // 排序range
        [self sortTextStorageArray:_textStorageArray];
        
        for (id<TYTextStorageProtocol> textStorage in _textStorageArray) {
            
            // 修正图片替换字符来的误差
            if ([textStorage conformsToProtocol:@protocol(TYDrawStorageProtocol) ]) {
                continue;
            }
            
            if ([textStorage conformsToProtocol:@protocol(TYLinkStorageProtocol)]) {
                if (!((id<TYLinkStorageProtocol>)textStorage).textColor) {
                    ((id<TYLinkStorageProtocol>)textStorage).textColor = _linkColor;
                }
            }
            
            // 验证范围
            if (NSMaxRange(textStorage.range) <= attString.length) {
                [textStorage addTextStorageWithAttributedString:attString];
            }
            
        }
        
        for (id<TYTextStorageProtocol> textStorage in _textStorageArray) {
            textStorage.realRange = NSMakeRange(textStorage.range.location-_replaceStringNum, textStorage.range.length);
            if ([textStorage conformsToProtocol:@protocol(TYDrawStorageProtocol)]) {
                id<TYDrawStorageProtocol> drawStorage = (id<TYDrawStorageProtocol>)textStorage;
                NSInteger currentLenght = attString.length;
                [drawStorage setTextfontAscent:_font.ascender descent:_font.descender];
                [drawStorage currentReplacedStringNum:_replaceStringNum];
                [drawStorage addTextStorageWithAttributedString:attString];
                _replaceStringNum += currentLenght - attString.length;
            }
        }
        _textStorages = [_textStorageArray copy];
        [_textStorageArray removeAllObjects];
    }
}

- (void)sortTextStorageArray:(NSMutableArray *)textStorageArray
{
    [textStorageArray sortUsingComparator:^NSComparisonResult(id<TYTextStorageProtocol> obj1, id<TYTextStorageProtocol> obj2) {
        if (obj1.range.location < obj2.range.location) {
            return NSOrderedAscending;
        } else if (obj1.range.location > obj2.range.location){
            return NSOrderedDescending;
        }else {
            return obj1.range.length > obj2.range.length ? NSOrderedAscending:NSOrderedDescending;
        }
    }];
}

- (void)saveTextStorageRectWithFrame:(CTFrameRef)frame
{
    // 获取每行
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    CGFloat viewWidth = _textWidth;
    
    NSInteger numberOfLines = _numberOfLines > 0 ? MIN(_numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
    NSMutableDictionary *runRectDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *linkRectDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *drawRectDictionary = [NSMutableDictionary dictionary];
    // 获取每行有多少run
    for (int i = 0; i < numberOfLines; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        // 获得每行的run
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[i];
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            // run的属性字典
            NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
            id<TYTextStorageProtocol> textStorage = [attributes objectForKey:kTYTextRunAttributedName];
            
            if (textStorage) {
                CGFloat runWidth  = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                
                if (viewWidth > 0 && runWidth > viewWidth) {
                    runWidth  = viewWidth;
                }
                CGRect runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runWidth, runAscent + runDescent);
                
                if ([textStorage conformsToProtocol:@protocol(TYDrawStorageProtocol)]) {
                    [drawRectDictionary setObject:textStorage forKey:[NSValue valueWithCGRect:runRect]];
                } else if ([textStorage conformsToProtocol:@protocol(TYLinkStorageProtocol)]) {
                    [linkRectDictionary setObject:textStorage forKey:[NSValue valueWithCGRect:runRect]];
                }
                
                [runRectDictionary setObject:textStorage forKey:[NSValue valueWithCGRect:runRect]];
            }
        }
    }
    
    if (drawRectDictionary.count > 0) {
        _drawRectDictionary = [drawRectDictionary copy];
    }else {
        _drawRectDictionary = nil;
    }
    
    if (runRectDictionary.count > 0) {
        // 添加响应点击rect
        [self addRunRectDictionary:[runRectDictionary copy]];
    }
    
    if (linkRectDictionary.count > 0) {
        _linkRectDictionary = [linkRectDictionary copy];
    }else {
        _linkRectDictionary = nil;
    }
}

// 添加响应点击rect
- (void)addRunRectDictionary:(NSDictionary *)runRectDictionary
{
    if (runRectDictionary.count < _runRectDictionary.count) {
        NSMutableArray *drawStorageArray = [[_runRectDictionary allValues]mutableCopy];
        // 剔除已经画出来的
        [drawStorageArray removeObjectsInArray:[runRectDictionary allValues]];
        
        // 遍历不会画出来的
        for (id<TYTextStorageProtocol>drawStorage in drawStorageArray) {
            if ([drawStorage conformsToProtocol:@protocol(TYViewStorageProtocol)]) {
                [(id<TYViewStorageProtocol>)drawStorage didNotDrawRun];
            }
        }
    }
    _runRectDictionary = runRectDictionary;
}

- (int)getHeightWithFramesetter:(CTFramesetterRef)framesetter width:(CGFloat)width
{
    if (_attString == nil || width <= 0) {
        return 0;
    }
    
    if (_textHeight > 0) {
        return _textHeight;
    }
    
    // 是否需要更新frame
    if (framesetter == nil) {
        
        framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)[self createAttributedString]);
    }else {
        CFRetain(framesetter);
    }
    
    // 获得建议的size
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(framesetter, _attString, CGSizeMake(width,MAXFLOAT), _numberOfLines);
    
    CFRelease(framesetter);
    
    return suggestedSize.height+1;
}

-  (CTFrameRef)createFrameRefWithFramesetter:(CTFramesetterRef)framesetter textHeight:(CGFloat)textHeight
{
    // 这里你需要创建一个用于绘制文本的路径区域,通过 self.bounds 使用整个视图矩形区域创建 CGPath 引用。
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, _textWidth, textHeight));
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [_attString length]), path, NULL);
    CFRelease(path);
    return frameRef;
}

- (instancetype)createTextContainerWithTextWidth:(CGFloat)textWidth
{
    return [self createTextContainerWithContentSize:CGSizeMake(textWidth, 0)];
}

- (instancetype)createTextContainerWithContentSize:(CGSize)contentSize
{
    if (_frameRef) {
        return self;
    }
    _textWidth = contentSize.width;
    
    // 创建CTFramesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)[self createAttributedString]);
    
    // 获得建议的size
    CGFloat textHeight = [self getHeightWithFramesetter:framesetter width:_textWidth];
    
    // 创建CTFrameRef
    _frameRef = [self createFrameRefWithFramesetter:framesetter textHeight: contentSize.height > 0 ?contentSize.height : textHeight];
    _textHeight = textHeight;
    
    // 释放内存
    CFRelease(framesetter);
    
    // 保存run rect
    [self saveTextStorageRectWithFrame:_frameRef];
    
    return self;
}

#pragma mark - enumerate runRect

- (BOOL)existRunRectDictionary
{
    return _runRectDictionary.count != 0;
}

- (BOOL)existLinkRectDictionary
{
    return _linkRectDictionary.count != 0;
}

- (BOOL)existDrawRectDictionary
{
    return _drawRectDictionary.count != 0;
}

- (void)enumerateDrawRectDictionaryUsingBlock:(void (^)(id<TYDrawStorageProtocol> drawStorage, CGRect rect))block
{
    [_drawRectDictionary enumerateKeysAndObjectsUsingBlock:^(NSValue *rectValue, id<TYDrawStorageProtocol> drawStorage, BOOL * stop) {
        if (block) {
            block(drawStorage,[rectValue CGRectValue]);
        }
    }];
}

- (BOOL)enumerateRunRectContainPoint:(CGPoint)point viewHeight:(CGFloat)viewHeight successBlock:(void (^)(id<TYTextStorageProtocol> textStorage))successBlock
{
    return [self enumerateRunRect:_runRectDictionary ContainPoint:point viewHeight:viewHeight successBlock:successBlock];
}

- (BOOL)enumerateLinkRectContainPoint:(CGPoint)point viewHeight:(CGFloat)viewHeight successBlock:(void (^)(id<TYLinkStorageProtocol> textStorage))successBlock
{
    return [self enumerateRunRect:_linkRectDictionary ContainPoint:point viewHeight:viewHeight successBlock:successBlock];
}

- (BOOL)enumerateRunRect:(NSDictionary *)runRectDic ContainPoint:(CGPoint)point viewHeight:(CGFloat)viewHeight successBlock:(void (^)(id<TYTextStorageProtocol> textStorage))successBlock
{
    if (runRectDic.count == 0) {
        return NO;
    }
    // CoreText context coordinates are the opposite to UIKit so we flip the bounds
    CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, viewHeight), 1.f, -1.f);
    
    __block BOOL find = NO;
    // 遍历run位置字典
    [runRectDic enumerateKeysAndObjectsUsingBlock:^(NSValue *keyRectValue, id<TYTextStorageProtocol> textStorage, BOOL *stop) {
        
        CGRect imgRect = [keyRectValue CGRectValue];
        CGRect rect = CGRectApplyAffineTransform(imgRect, transform);
        
        if ([textStorage conformsToProtocol:@protocol(TYDrawStorageProtocol) ]) {
            rect = UIEdgeInsetsInsetRect(rect,((id<TYDrawStorageProtocol>)textStorage).margin);
        }
        
        // point 是否在rect里
        if(CGRectContainsPoint(rect, point)){
            find = YES;
            *stop = YES;
            if (successBlock) {
                successBlock(textStorage);
            }
        }
    }];
    return find;
}

- (void)dealloc{
    [self resetFrameRef];
}

@end

#pragma mark - add textStorage
@implementation TYTextContainer (Add)

- (void)addTextStorage:(id<TYTextStorageProtocol>)textStorage
{
    if (textStorage) {
        [self.textStorageArray addObject:textStorage];
        [self resetFrameRef];
    }
}

- (void)addTextStorageArray:(NSArray *)textStorageArray
{
    if (textStorageArray) {
        for (id<TYTextStorageProtocol> textStorage in textStorageArray) {
            if ([textStorage conformsToProtocol:@protocol(TYTextStorageProtocol)]) {
                [self addTextStorage:textStorage];
            }
        }
    }
}
@end

#pragma mark - append textStorage
@implementation TYTextContainer (Append)

- (void)appendText:(NSString *)text
{
    NSAttributedString *attributedText = [self createTextAttibuteStringWithText:text];
    [self appendTextAttributedString:attributedText];
    [self resetFrameRef];
}

- (void)appendTextAttributedString:(NSAttributedString *)attributedText
{
    if (attributedText == nil) {
        return;
    }
    if (_attString == nil) {
        _attString = [[NSMutableAttributedString alloc]init];
    }
    
    if ([attributedText isKindOfClass:[NSMutableAttributedString class]]) {
        [self addTextParaphStyleWithAtrributedString:(NSMutableAttributedString *)attributedText];
    }
    
    [_attString appendAttributedString:attributedText];
    [self resetFrameRef];
}

- (void)appendTextStorage:(id<TYAppendTextStorageProtocol>)textStorage
{
    if (textStorage) {
        if ([textStorage conformsToProtocol:@protocol(TYDrawStorageProtocol)]) {
            [(id<TYDrawStorageProtocol>)textStorage setTextfontAscent:_font.ascender descent:_font.descender];
        } else if ([textStorage conformsToProtocol:@protocol(TYLinkStorageProtocol)]) {
            if (!((id<TYLinkStorageProtocol>)textStorage).textColor) {
                ((id<TYLinkStorageProtocol>)textStorage).textColor = _linkColor;
            }
        }
        
        NSAttributedString *attAppendString = [textStorage appendTextStorageAttributedString];
        textStorage.realRange = NSMakeRange(_attString.length, attAppendString.length);
        [self appendTextAttributedString:attAppendString];
        [self resetFrameRef];
    }
}

- (void)appendTextStorageArray:(NSArray *)textStorageArray
{
    if (textStorageArray) {
        for (id<TYAppendTextStorageProtocol> textStorage in textStorageArray) {
            if ([textStorage conformsToProtocol:@protocol(TYAppendTextStorageProtocol)]) {
                [self appendTextStorage:textStorage];
            }
        }
    }
}

@end
