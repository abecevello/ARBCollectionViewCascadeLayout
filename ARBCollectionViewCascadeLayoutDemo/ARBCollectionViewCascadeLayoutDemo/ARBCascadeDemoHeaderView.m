//
//  ARBCascadeDemoHeaderView.m
//  ARBCollectionViewCascadeLayoutDemo
//
//  Created by Adam Becevello on 2013-04-21.
//  Copyright (c) 2013 Adam Becevello. All rights reserved.
//

#import "ARBCascadeDemoHeaderView.h"

@implementation ARBCascadeDemoHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_addButton setTitle:@"Add Items to section" forState:UIControlStateNormal];
		[self addSubview:_addButton];
		
		_removeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_removeButton setTitle:@"Remove Items from section" forState:UIControlStateNormal];
		[self addSubview:_removeButton];
    }
    return self;
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	
	self.section = 0;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect bounds = self.bounds;
	CGFloat midY = CGRectGetMidY(bounds);
	
	[_removeButton sizeToFit];
	CGRect removeButtonFrame = _removeButton.frame;
	removeButtonFrame.origin.x = CGRectGetMaxX(bounds) - removeButtonFrame.size.width - ARBCascadeHeaderViewPadding;
	removeButtonFrame.origin.y = roundf(midY - removeButtonFrame.size.height * 0.5f);
	_removeButton.frame = removeButtonFrame;
	
	[_addButton sizeToFit];
	CGRect addButtonFrame = _addButton.frame;
	addButtonFrame.origin.x = CGRectGetMinX(_removeButton.frame) - addButtonFrame.size.width - ARBCascadeHeaderViewPadding;
	addButtonFrame.origin.y = roundf(midY - addButtonFrame.size.height * 0.5f);
	_addButton.frame = addButtonFrame;
}

@end
