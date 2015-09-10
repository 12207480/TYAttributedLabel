//
//  AttributedLabelCell.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/9/9.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "AttributedLabelCell.h"

@interface AttributedLabelCell ()
@property (nonatomic, weak) TYAttributedLabel *label;
@end

@implementation AttributedLabelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addAtrribuedLabel];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self addAtrribuedLabel];
    }
    return self;
}

- (void)addAtrribuedLabel
{
    TYAttributedLabel *label = [[TYAttributedLabel alloc]init];
    [self addSubview:label];
    _label = label;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _label.frame = CGRectMake(0, 15, CGRectGetWidth(self.frame), 0);
    [_label sizeToFit];
    
    // or this
    //_label.frame = CGRectMake(0, 15, CGRectGetWidth(self.frame),CGRectGetHeight(self.frame) - 30);
}

@end
