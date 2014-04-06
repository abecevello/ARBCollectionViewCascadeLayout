//
//  ARBCascadeDemoCell.m
//  ARBCollectionViewCascadeLayoutDemo
//
//  Created by Adam Becevello on 2013-04-21.
//  Copyright (c) 2013 Adam Becevello. All rights reserved.
//

#import "ARBCascadeDemoCell.h"

@implementation ARBCascadeDemoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor greenColor];
		
        _title = [[UILabel alloc] initWithFrame:CGRectZero];
		_title.backgroundColor = [UIColor clearColor];
		_title.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_title];
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
	
	_title.frame = self.contentView.bounds;
}

@end
