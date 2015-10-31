//
//  AutoLayoutAttributedLabelCell.m
//  TYAttributedLabelDemo
//
//  Created by zhangxinzheng on 10/31/15.
//  Copyright © 2015 tanyang. All rights reserved.
//

#import "AutoLayoutAttributedLabelCell.h"

@interface AutoLayoutAttributedLabelCell ()
@property (nonatomic, weak) TYAttributedLabel *label;
@end

@implementation AutoLayoutAttributedLabelCell

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
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:label];
    _label = label;
    [NSLayoutConstraint activateConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[label]-15-|" options:0 metrics:nil views:@{@"label":_label}]];
    [NSLayoutConstraint activateConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[label]-5-|" options:0 metrics:nil views:@{@"label":_label}]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
