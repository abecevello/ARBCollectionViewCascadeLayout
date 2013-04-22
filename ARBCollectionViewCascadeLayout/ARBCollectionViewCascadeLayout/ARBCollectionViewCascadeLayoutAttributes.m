//
//  ARBCollectionViewCascadeLayoutAttributes.m
//  ARBCollectionViewCascadeLayout
//
//  Created by Adam Becevello on 2013-04-21.
//  Copyright (c) 2013 Adam Becevello. All rights reserved.
//

#import "ARBCollectionViewCascadeLayoutAttributes.h"

@implementation ARBCollectionViewCascadeLayoutAttributes

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.valid = NO;
		self.currentColumn = 0;
		self.previousFrame = CGRectZero;
	}
	return self;
}

- (void)setPreviousFrame:(CGRect)previousFrame
{
	_previousFrame = previousFrame;
}

- (id)copyWithZone:(NSZone *)zone
{
	ARBCollectionViewCascadeLayoutAttributes *attributes = [super copyWithZone:zone];
	attributes.valid = self.valid;
	attributes.currentColumn = self.currentColumn;
	attributes.previousFrame = self.previousFrame;
	return attributes;
}

@end
