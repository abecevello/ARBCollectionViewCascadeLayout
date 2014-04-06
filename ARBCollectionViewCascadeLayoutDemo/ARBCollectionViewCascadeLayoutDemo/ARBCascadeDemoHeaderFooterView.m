//
//  ARBCascadeDemoHeaderFooterView.m
//  ARBCollectionViewCascadeLayoutDemo
//
//  Created by Adam Becevello on 2013-04-21.
//  Copyright (c) 2013 Adam Becevello. All rights reserved.
//

#import "ARBCascadeDemoHeaderFooterView.h"

CGFloat const ARBCascadeDemoHeaderSeparatorHeight = 1.0f;
CGFloat const ARBCascadeHeaderViewPadding = 10.0f;

@implementation ARBCascadeDemoHeaderFooterView {
	UIView *_topSeparator;
	UIView *_bottomSeparator;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
		
		_topSeparator = [[UIView alloc] initWithFrame:CGRectZero];
		_topSeparator.backgroundColor = [UIColor blackColor];
		[self addSubview:_topSeparator];
		
        _title = [[UILabel alloc] initWithFrame:CGRectZero];
		_title.backgroundColor = [UIColor clearColor];
		_title.textAlignment = NSTextAlignmentLeft;
		[self addSubview:_title];
		
		_bottomSeparator = [[UIView alloc] initWithFrame:CGRectZero];
		_bottomSeparator.backgroundColor = [UIColor blackColor];
		[self addSubview:_bottomSeparator];
    }
    return self;
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	
	_title.text = nil;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect bounds = self.bounds;
	CGFloat xOffset = CGRectGetMinX(bounds);
	CGFloat width = CGRectGetWidth(bounds);
	
	_topSeparator.frame = CGRectMake(xOffset, CGRectGetMinY(bounds), width, ARBCascadeDemoHeaderSeparatorHeight);
	_title.frame = CGRectInset(bounds, ARBCascadeHeaderViewPadding, 0.0f);
	_bottomSeparator.frame = CGRectMake(xOffset, CGRectGetMaxY(bounds) - ARBCascadeDemoHeaderSeparatorHeight, width, ARBCascadeDemoHeaderSeparatorHeight);
}

@end
