//
//  ARBCascadeDemoHeaderView.m
//  ARBCollectionViewCascadeLayoutDemo
//
//  Created by Adam Becevello on 2013-04-21.
//  Copyright (c) 2013 Adam Becevello. All rights reserved.
//

#import "ARBCascadeDemoHeaderView.h"

CGFloat const ARBCascadeHeaderViewPadding = 10.0f;

@implementation ARBCascadeDemoHeaderView

- (id)initWithFrame:(CGRect)frame
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
	
	_section = 0;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[_addButton sizeToFit];
	[_removeButton sizeToFit];
	
	CGRect bounds = self.bounds;
	CGFloat midY = CGRectGetMidY(bounds);
	_removeButton.frame = CGRectMake(CGRectGetMaxX(bounds) - _removeButton.frame.size.width - ARBCascadeHeaderViewPadding, roundf(midY - _removeButton.frame.size.height * 0.5f), _removeButton.frame.size.width, _removeButton.frame.size.height);
	_addButton.frame = CGRectMake(CGRectGetMinX(_removeButton.frame) - _addButton.frame.size.width - ARBCascadeHeaderViewPadding, CGRectGetMinY(_removeButton.frame), _addButton.frame.size.width, _addButton.frame.size.height);
}

@end
