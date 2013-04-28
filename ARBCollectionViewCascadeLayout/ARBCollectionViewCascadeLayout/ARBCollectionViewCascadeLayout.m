//
//  ARBCollectionViewCascadeLayout.m
//  ARBCollectionViewCascadeLayout
//
//  Created by Adam Becevello on 2013-04-21.
//  Copyright (c) 2013 Adam Becevello. All rights reserved.
//

#import "ARBCollectionViewCascadeLayout.h"
#import "ARBCollectionViewCascadeLayoutAttributes.h"

NSString *const ARBCollectionViewCascadeLayoutHeaderFooter = @"headerFooter";

NSUInteger const ARBCollectionViewCascadeLayoutHeaderItemNumber = 0;
NSUInteger const ARBCollectionViewCascadeLayoutFooterItemNumber = 1;

@implementation ARBCollectionViewCascadeLayout {
	CGFloat _currentColumnWidth;
	NSInteger _currentNumColumns;
	
	NSMutableArray *_columnXOffsets;
	
	NSInteger _numSections;
	NSMutableArray *_sectionHeaders;
	NSMutableArray *_sectionFooters;
	NSMutableArray *_sectionColumnHeights; //contains an array of arrays, first array is positioned by section number, values are the heights of each column within each section
	NSMutableDictionary *_sectionItems; //key is section number, value is array with position by index, value is ARBCollectionViewCascadeLayoutAttribute objects
	
	BOOL _recalculateLayoutRequired;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		_numColumnsPortrait = 1;
		_numColumnsLandscape = 1;
		
		[self resetLayout];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotate:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
	}
	return self;
}

+ (Class)layoutAttributesClass
{
	return [ARBCollectionViewCascadeLayoutAttributes class];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 * Because invalidateLayout is called whenever an item is added or removed, invalidateLayout doesn't completely erase all layout data.
 * Instead, there is a resetLayout method if the entire layout needs to be recalculated.
 */
- (void)resetLayout
{
	_currentColumnWidth = 0.0f;
	_currentNumColumns = 0;
	
	_columnXOffsets = [NSMutableArray array];
	
	_numSections = 1;
	_sectionHeaders = [NSMutableArray array];
	_sectionFooters = [NSMutableArray array];
	_sectionColumnHeights = [NSMutableArray array];
	_sectionItems = [NSMutableDictionary dictionary];
	
	_recalculateLayoutRequired = YES;
	
	[self invalidateLayout];
}

- (void)invalidateLayout
{
	[super invalidateLayout];
	
	//UICollectionView has an issue where the supplementary views won't be removed from the view if
	//the layout attributes objects aren't recreated every time invalidateLayout is called.
	//This happens when inserting items causes the view to become outside the rect being drawn.
	NSMutableArray *newSectionHeaders = [NSMutableArray arrayWithCapacity:[_sectionHeaders count]];
	for (ARBCollectionViewCascadeLayoutAttributes *headerAttributes in _sectionHeaders) {
		[newSectionHeaders addObject:[headerAttributes copy]];
	}
	_sectionHeaders = newSectionHeaders;
	
	NSMutableArray *newSectionFooters = [NSMutableArray arrayWithCapacity:[_sectionFooters count]];
	for (ARBCollectionViewCascadeLayoutAttributes *footerAttributes in _sectionFooters) {
		[newSectionFooters addObject:[footerAttributes copy]];
	}
	_sectionFooters = newSectionFooters;
}

#pragma mark - Setters

- (void)setNumColumnsLandscape:(NSInteger)numColumnsLandscape
{
	_numColumnsLandscape = numColumnsLandscape;
	[self resetLayout];
}

- (void)setNumColumnsPortrait:(NSInteger)numColumnsPortrait
{
	_numColumnsPortrait = numColumnsPortrait;
	[self resetLayout];
}

- (void)setItemPadding:(CGFloat)itemPadding
{
	_itemPadding = itemPadding;
	[self resetLayout];
}

#pragma mark - Rotation

- (void)willRotate:(NSNotification *)notification
{
	[self resetLayout];
}

#pragma mark - Reset

- (void)resetSectionHeadersFooters
{
	[_sectionHeaders removeAllObjects];
	[_sectionFooters removeAllObjects];
	
	//retrieve the section header and footers
	for (NSInteger section = 0; section < _numSections; section++) {
		NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:ARBCollectionViewCascadeLayoutHeaderItemNumber inSection:section];
		ARBCollectionViewCascadeLayoutAttributes *headerAttributes = [ARBCollectionViewCascadeLayoutAttributes layoutAttributesForSupplementaryViewOfKind:ARBCollectionViewCascadeLayoutHeaderFooter withIndexPath:headerIndexPath];
		[_sectionHeaders addObject:headerAttributes];
		
		NSIndexPath *footerIndexPath = [NSIndexPath indexPathForItem:ARBCollectionViewCascadeLayoutFooterItemNumber inSection:section];
		ARBCollectionViewCascadeLayoutAttributes *footerAttributes = [ARBCollectionViewCascadeLayoutAttributes layoutAttributesForSupplementaryViewOfKind:ARBCollectionViewCascadeLayoutHeaderFooter withIndexPath:footerIndexPath];
		[_sectionFooters addObject:footerAttributes];
	}
	
	_recalculateLayoutRequired = YES;
}

- (void)resetColumnHeights
{
	//during initial setup, sections are assumed to be the same height, this will change as items are added to each section
	_sectionColumnHeights = [NSMutableArray array];
	for (NSInteger section = 0; section < _numSections; section++) {
		[_sectionColumnHeights addObject:[NSMutableArray array]]; //ensure the array has a position for this section, this simplifies the resetColumnHeightsInSection method
		[self resetColumnHeightsInSection:section];
	}
	
	_recalculateLayoutRequired = YES;
}

- (void)resetColumnHeightsInSection:(NSUInteger)section
{
	//during initial setup, sections are assumed to be the same height, this will change as items are added to each sections
	NSNumber *itemPaddingHeight = @(self.itemPadding);
	NSMutableArray *colHeights = [NSMutableArray array];
	for (NSInteger i = 0; i < _currentNumColumns; i++) {
		[colHeights addObject:itemPaddingHeight];
	}
	_sectionColumnHeights[section] = colHeights;
	
	_recalculateLayoutRequired = YES;
}

- (void)invalidateLayoutAttributes:(ARBCollectionViewCascadeLayoutAttributes *)attributes
{
	attributes.valid = NO;
	
	_recalculateLayoutRequired = YES;
}

- (void)invalidateLayoutOfItemsAfterIndexPath:(NSIndexPath *)indexPath
{
	//invalidate all section headers for all subsequent sections
	for (NSInteger section = indexPath.section + 1; section < [_sectionHeaders count]; section++) {
		ARBCollectionViewCascadeLayoutAttributes *sectionHeader = [self sectionHeaderAttributesForSection:section];
		[self invalidateLayoutAttributes:sectionHeader];
	}
	
	for (NSInteger section = 0; section < _numSections; section++) {
		NSMutableArray *itemAttributes = _sectionItems[@(section)];
		if (section > indexPath.section) {
			//invalidate all items in this section
			//the column heights don't need to be invalidated since the section as a whole will be moved
			for (ARBCollectionViewCascadeLayoutAttributes *attributes in itemAttributes) {
				[self invalidateLayoutAttributes:attributes];
			}
			[self resetColumnHeightsInSection:section];
		} else if (indexPath.section == section) {
			//invalidate only items after this item
			for (NSInteger i=indexPath.item; i < [itemAttributes count]; i++) {
				ARBCollectionViewCascadeLayoutAttributes *attributes = itemAttributes[i];
				[self invalidateLayoutAttributes:attributes];
			}
			[self resetColumnHeightsInSection:section];
		}
	}
	
	//get the max Y values from the previous elements in each column (only need to get numCols number of elements)
	//this does not update the content size since that will be done in calculateLayout once all the batched changes are applied
	//calculate until all columns have been updated
	NSMutableIndexSet *completedColumns = [NSMutableIndexSet indexSet];
	NSInteger i = indexPath.item - 1;
	ARBCollectionViewCascadeLayoutAttributes *sectionHeader = [self sectionHeaderAttributesForSection:indexPath.section];
	NSMutableArray *sectionItems = _sectionItems[@(indexPath.section)];
	CGFloat yOffsetOfSection = [self yOffsetForBeginningOfSection:indexPath.section];
	while (i >= 0) {
		ARBCollectionViewCascadeLayoutAttributes *attributes = sectionItems[i];
		if (attributes.valid && [completedColumns containsIndex:attributes.currentColumn] == NO) {
			NSMutableArray *colHeights = _sectionColumnHeights[indexPath.section];
			CGFloat height = CGRectGetMaxY(attributes.frame) - yOffsetOfSection;
			colHeights[attributes.currentColumn] = @(height - CGRectGetHeight(sectionHeader.frame) + self.itemPadding);
			[completedColumns addIndex:attributes.currentColumn];
		}
		//if all columns have been updated, stop checking
		if ([completedColumns count] == _currentNumColumns) {
			break;
		}
		
		i--;
	}
	
	//invalidate all section footers for all sections
	for (NSInteger section = indexPath.section; section < [_sectionFooters count]; section++) {
		ARBCollectionViewCascadeLayoutAttributes *sectionFooter = [self sectionFooterAttributesForSection:section];
		[self invalidateLayoutAttributes:sectionFooter];
	}
	
	_recalculateLayoutRequired = YES;
}

#pragma mark - UICollectionViewLayout overridden methods

- (void)calculateLayout
{
	_numSections = [self.collectionView numberOfSections];
	
	//initialize the column metadata
	BOOL landscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
	_currentNumColumns = landscape ? _numColumnsLandscape : _numColumnsPortrait;
	if (_currentColumnWidth == 0.0f || [_columnXOffsets count] != _currentNumColumns) {
		//item width is the total width, minus the padding between columns, divided by the number of columns
		_currentColumnWidth = floorf((CGRectGetWidth(self.collectionView.bounds) - (_currentNumColumns + 1) * self.itemPadding) / _currentNumColumns);
		
		[self resetColumnHeights];
		[self resetSectionHeadersFooters];
		
		if ([_columnXOffsets count] != _currentNumColumns) {
			_columnXOffsets = [NSMutableArray arrayWithCapacity:_currentNumColumns];
			CGFloat left = self.itemPadding;
			for (NSInteger i = 0; i < _currentNumColumns; i++) {
				[_columnXOffsets addObject:@(left)];
				left += _currentColumnWidth + self.itemPadding;
			}
		}
	}
	
	for (NSInteger section = 0; section < _numSections; section++) {
		NSNumber *sectionNumber = @(section);
		
		//layout the section header
		ARBCollectionViewCascadeLayoutAttributes *sectionHeaderAttributes = [self sectionHeaderAttributesForSection:section];
		if (sectionHeaderAttributes.valid == NO && [self.delegate respondsToSelector:@selector(collectionView:layout:heightForHeaderInSection:)]) {
			CGFloat headerHeight = [self.delegate collectionView:self.collectionView layout:self heightForHeaderInSection:section];
			if (headerHeight > 0.0f) {
				CGFloat yOffset = [self yOffsetForBeginningOfSection:section];
				sectionHeaderAttributes.frame = CGRectMake(0, yOffset, self.collectionView.bounds.size.width, headerHeight);
				sectionHeaderAttributes.valid = YES;
			}
		}
		
		//layout the section items
		NSMutableArray *itemAttributes = _sectionItems[sectionNumber];
		NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
		if ([itemAttributes count] != numItems) {
			itemAttributes = [NSMutableArray arrayWithCapacity:numItems];
			for (NSInteger item = 0; item < numItems; item++) {
				[itemAttributes addObject:[ARBCollectionViewCascadeLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:item inSection:section]]];
			}
			_sectionItems[sectionNumber] = itemAttributes;
		}
		for (NSInteger i = 0; i < numItems; i++) {
			ARBCollectionViewCascadeLayoutAttributes *attributes = itemAttributes[i];
			if (attributes.valid == NO) {
				NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
				CGFloat height = [self.delegate collectionView:self.collectionView layout:self heightForItemAtIndexPath:indexPath];
				
				//find the shortest column
				NSInteger shortestColumn = [self shortestColumnInSection:section];
				CGFloat colXOffset = [_columnXOffsets[shortestColumn] floatValue];
				CGFloat yOffset = [self yOffsetForItemInSection:section column:shortestColumn];
				CGRect frame = CGRectMake(colXOffset, yOffset, _currentColumnWidth, height);
				
				attributes.indexPath = [NSIndexPath indexPathForItem:i inSection:section];
				attributes.frame = frame;
				attributes.currentColumn = shortestColumn;
				attributes.valid = YES;
				itemAttributes[i] = attributes;
				
				[self updateHeightOfColumn:shortestColumn inSection:section withAdditionalHeight:height + self.itemPadding];
			}
		}
		
		//layout the section footer
		ARBCollectionViewCascadeLayoutAttributes *sectionFooterAttributes = [self sectionFooterAttributesForSection:section];
		if (sectionFooterAttributes.valid == NO && [self.delegate respondsToSelector:@selector(collectionView:layout:heightForFooterInSection:)]) {
			CGFloat footerHeight = [self.delegate collectionView:self.collectionView layout:self heightForFooterInSection:section];
			if (footerHeight > 0.0f) {
				CGFloat yOffset = [self yOffsetForEndOfSection:section];
				sectionFooterAttributes.frame = CGRectMake(0, yOffset, self.collectionView.bounds.size.width, footerHeight);
				sectionFooterAttributes.valid = YES;
			}
		}
	}
	
	_recalculateLayoutRequired = NO;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
	//for each update that is happening, invalidate the layouts of items after the position
	for (UICollectionViewUpdateItem *updateItem in updateItems) {
		if (updateItem.updateAction == UICollectionUpdateActionInsert) {
			NSIndexPath *indexPath = updateItem.indexPathAfterUpdate;
			NSMutableArray *itemAttributes = _sectionItems[@(indexPath.section)];
			[itemAttributes insertObject:[ARBCollectionViewCascadeLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath] atIndex:indexPath.item];
			[self invalidateLayoutOfItemsAfterIndexPath:indexPath];
		} else if (updateItem.updateAction == UICollectionUpdateActionDelete) {
			NSIndexPath *indexPath = updateItem.indexPathBeforeUpdate;
			NSMutableArray *itemAttributes = _sectionItems[@(indexPath.section)];
			[itemAttributes removeObjectAtIndex:indexPath.item];
			[self invalidateLayoutOfItemsAfterIndexPath:indexPath];
		} else if (updateItem.updateAction == UICollectionUpdateActionMove) {
			//delete the item at its old location
			NSIndexPath *indexPath = updateItem.indexPathBeforeUpdate;
			NSMutableArray *itemAttributes = _sectionItems[@(indexPath.section)];
			[itemAttributes removeObjectAtIndex:indexPath.item];
			[self invalidateLayoutOfItemsAfterIndexPath:indexPath];
			
			//add the item to its new location
			indexPath = updateItem.indexPathAfterUpdate;
			itemAttributes = _sectionItems[@(indexPath.section)];
			[itemAttributes addObject:[ARBCollectionViewCascadeLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath]];
			[self invalidateLayoutOfItemsAfterIndexPath:indexPath];
		} else if (updateItem.updateAction == UICollectionUpdateActionReload) {
			NSMutableArray *itemAttributes = _sectionItems[@(updateItem.indexPathAfterUpdate.section)];
			ARBCollectionViewCascadeLayoutAttributes *attributes = itemAttributes[updateItem.indexPathAfterUpdate.item];
			[self invalidateLayoutAttributes:attributes];
		}
	}
}

- (void)finalizeCollectionViewUpdates
{
	for (NSInteger section = 0; section < _numSections; section++) {
		NSNumber *sectionNumber = @(section);
		
		NSMutableArray *itemAttributes = _sectionItems[sectionNumber];
		for (ARBCollectionViewCascadeLayoutAttributes *attributes in itemAttributes) {
			if (attributes.valid) {
				attributes.previousFrame = attributes.frame;
			}
		}
	}
}

- (CGSize)collectionViewContentSize
{
	if (_recalculateLayoutRequired) {
		[self calculateLayout];
	}
	
	//calculate the height of all combined sections
	CGFloat totalHeight = 0.0f;
	
	//heights of all sections
	for (NSInteger i = 0; i < _numSections; i++) {
		totalHeight += [self heightOfSection:i];
	}
	
	CGFloat frameHeight = self.collectionView.bounds.size.height;
	if (totalHeight < frameHeight) {
		totalHeight = frameHeight;
	}
	return CGSizeMake(self.collectionView.bounds.size.width, totalHeight);
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
	if (_recalculateLayoutRequired) {
		[self calculateLayout];
	}
	
	ARBCollectionViewCascadeLayoutAttributes *attributes = nil;
	if (indexPath.item == ARBCollectionViewCascadeLayoutHeaderItemNumber) {
		attributes = [self sectionHeaderAttributesForSection:indexPath.section];
	} else if (indexPath.item == ARBCollectionViewCascadeLayoutFooterItemNumber) {
		attributes = [self sectionFooterAttributesForSection:indexPath.section];
	}
	return attributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (_recalculateLayoutRequired) {
		[self calculateLayout];
	}
	
	if ([_sectionItems count] < indexPath.section) {
		return nil;
	}
	
	NSArray *itemAttributes = _sectionItems[@(indexPath.section)];
	if ([itemAttributes count] < indexPath.item) {
		return nil;
	}
	
	//a copy of the attributes must be made to ensure the animations work properly
	ARBCollectionViewCascadeLayoutAttributes *attributes = [itemAttributes[indexPath.item] copy];
	if (CGRectEqualToRect(CGRectZero, attributes.previousFrame) == NO) {
		attributes.frame = attributes.previousFrame;
	}
	attributes.alpha = 0.0f;
	return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (_recalculateLayoutRequired) {
		[self calculateLayout];
	}
	
	if ([_sectionItems count] < indexPath.section) {
		return nil;
	}
	
	NSArray *itemAttributes = _sectionItems[@(indexPath.section)];
	if ([itemAttributes count] < indexPath.item) {
		return nil;
	}
	
	ARBCollectionViewCascadeLayoutAttributes *attributes = itemAttributes[indexPath.item];
	attributes.alpha = 1.0f;
	return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	ARBCollectionViewCascadeLayoutAttributes *attributes = nil;
	if (indexPath.item == ARBCollectionViewCascadeLayoutHeaderItemNumber) {
		attributes = [self sectionHeaderAttributesForSection:indexPath.section];
	} else if (indexPath.item == ARBCollectionViewCascadeLayoutFooterItemNumber) {
		attributes = [self sectionFooterAttributesForSection:indexPath.section];
	}
	return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	if (_recalculateLayoutRequired) {
		[self calculateLayout];
	}
	
	NSMutableArray *elementsInRect = [NSMutableArray array];
	
	//section headers
	for (ARBCollectionViewCascadeLayoutAttributes *headerAttributes in _sectionHeaders) {
		if (headerAttributes.valid && CGRectIntersectsRect(rect, headerAttributes.frame)) {
			[elementsInRect addObject:headerAttributes];
		}
	}
	
	//items
	NSArray *sections = [_sectionItems allValues];
	for (NSArray *sectionItems in sections) {
		for (ARBCollectionViewCascadeLayoutAttributes *itemAttributes in sectionItems) {
			if (itemAttributes.valid && CGRectIntersectsRect(rect, itemAttributes.frame)) {
				[elementsInRect addObject:itemAttributes];
			}
		}
	}
	
	//section footers
	for (ARBCollectionViewCascadeLayoutAttributes *footerAttributes in _sectionFooters) {
		if (footerAttributes.valid && CGRectIntersectsRect(rect, footerAttributes.frame)) {
			[elementsInRect addObject:footerAttributes];
		}
	}
	
	return elementsInRect;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	return YES;
}

#pragma mark - Helpers

- (ARBCollectionViewCascadeLayoutAttributes *)sectionHeaderAttributesForSection:(NSUInteger)section
{
	if (section < [_sectionHeaders count]) {
		return _sectionHeaders[section];
	}
	return nil;
}

- (ARBCollectionViewCascadeLayoutAttributes *)sectionFooterAttributesForSection:(NSUInteger)section
{
	if (section < [_sectionFooters count]) {
		return _sectionFooters[section];
	}
	return nil;
}

- (CGFloat)heightOfSection:(NSInteger)section
{
	CGFloat height = 0.0f;
	
	ARBCollectionViewCascadeLayoutAttributes *header = [self sectionHeaderAttributesForSection:section];
	if (header.valid) {
		height += CGRectGetHeight(header.frame);
	}
	
	height += [self heightOfLongestColumnInSection:section];
	
	ARBCollectionViewCascadeLayoutAttributes *footer = [self sectionFooterAttributesForSection:section];
	if (footer.valid) {
		height += CGRectGetHeight(footer.frame);
	}
	
	return height;
}

- (CGFloat)yOffsetForBeginningOfSection:(NSInteger)section
{
	//the yoffset is the height of all previous sections, plus the height of the column in the current section
	CGFloat height = 0.0f;
	
	//add the heights of all previous sections
	if (section > 0) {
		for (NSInteger i = 0; i < section; i++) {
			height += [self heightOfSection:i];
		}
	}
	
	return height;
}

- (CGFloat)yOffsetForEndOfSection:(NSInteger)section
{
	//the yoffset is the height of all sections up to and including this one
	CGFloat height = 0.0f;
	
	for (NSInteger i = 0; i <= section; i++) {
		height += [self heightOfSection:i];
	}
	
	return height;
}

- (CGFloat)yOffsetForItemInSection:(NSInteger)section column:(NSInteger)column
{
	//the yoffset is the height of all previous sections, plus the height of the column in the current section
	CGFloat height = [self yOffsetForBeginningOfSection:section];
	
	//section header height
	ARBCollectionViewCascadeLayoutAttributes *sectionHeaderAttributes = [self sectionHeaderAttributesForSection:section];
	if (sectionHeaderAttributes.valid) {
		height += CGRectGetHeight(sectionHeaderAttributes.frame);
	}
	
	NSArray *columnHeights = _sectionColumnHeights[section];
	height += [columnHeights[column] floatValue];
	return height;
}

- (void)updateHeightOfColumn:(NSInteger)column inSection:(NSInteger)section withAdditionalHeight:(CGFloat)height
{
	NSMutableArray *columnHeights = _sectionColumnHeights[section];
	NSNumber *currentHeight = columnHeights[column];
	columnHeights[column] = @([currentHeight floatValue] + height);
}

- (NSInteger)shortestColumnInSection:(NSInteger)section
{
	NSInteger column = 0;
	NSMutableArray *columnHeights = _sectionColumnHeights[section];
	CGFloat minHeight = [columnHeights[column] floatValue];
	for (NSInteger i = 1; i < [columnHeights count]; i++) {
		CGFloat columnHeight = [columnHeights[i] floatValue];
		if (columnHeight < minHeight) {
			column = i;
			minHeight = columnHeight;
		}
	}
	return column;
}

- (NSInteger)longestColumnInSection:(NSInteger)section
{
	NSInteger column = 0;
	NSMutableArray *columnHeights = _sectionColumnHeights[section];
	CGFloat maxHeight = [columnHeights[column] floatValue];
	for (NSInteger i = 1; i < [columnHeights count]; i++) {
		CGFloat columnHeight = [columnHeights[i] floatValue];
		if (columnHeight > maxHeight) {
			column = i;
			maxHeight = columnHeight;
		}
	}
	return column;
}

- (CGFloat)heightOfLongestColumnInSection:(NSInteger)section
{
	NSInteger longestColumn = [self longestColumnInSection:section];
	return [_sectionColumnHeights[section][longestColumn] floatValue];
}

@end
