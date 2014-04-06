//
//  ARBCascadeDemoViewController.m
//  ARBCollectionViewCascadeLayoutDemo
//
//  Created by Adam Becevello on 2013-04-21.
//  Copyright (c) 2013 Adam Becevello. All rights reserved.
//

#import "ARBCascadeDemoViewController.h"
#import "ARBCollectionViewCascadeLayout.h"

#import "ARBCascadeDemoCell.h"
#import "ARBCascadeDemoHeaderFooterView.h"
#import "ARBCascadeDemoHeaderView.h"

NSInteger const ARBCascadeDemoSampleDataSizeSection1 = 25;
NSInteger const ARBCascadeDemoSampleDataSizeSection2 = 10;

NSString *const ARBCascadeDemoCellReuseIdentifier = @"ARBCascadeDemoCell";
NSString *const ARBCascadeDemoHeaderReuseIdentifier = @"ARBCascadeDemoHeader";
NSString *const ARBCascadeDemoFooterReuseIdentifier = @"ARBCascadeDemoFooter";

@interface ARBCascadeDemoViewController () <ARBCollectionViewCascadeLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation ARBCascadeDemoViewController {
	UICollectionView *_collectionView;
	ARBCollectionViewCascadeLayout *_cascadeLayout;
	
	NSMutableArray *_sampleDataSection1;
	NSMutableArray *_sampleDataSection1Heights;
	NSMutableArray *_sampleDataSection2;
	NSMutableArray *_sampleDataSection2Heights;
}

- (void)loadView
{
	[super loadView];
	
	_cascadeLayout = [[ARBCollectionViewCascadeLayout alloc] init];
	_cascadeLayout.delegate = self;
	_cascadeLayout.numColumnsPortrait = 3;
	_cascadeLayout.numColumnsLandscape = 4;
	_cascadeLayout.itemPadding = 10.0f;
	
	_collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:_cascadeLayout];
	_collectionView.delegate = self;
	_collectionView.dataSource = self;
	_collectionView.backgroundColor = [UIColor whiteColor];
	self.view = _collectionView;
	
	[_collectionView registerClass:[ARBCascadeDemoCell class] forCellWithReuseIdentifier:ARBCascadeDemoCellReuseIdentifier];
	[_collectionView registerClass:[ARBCascadeDemoHeaderView class] forSupplementaryViewOfKind:ARBCollectionViewCascadeLayoutHeaderFooter withReuseIdentifier:ARBCascadeDemoHeaderReuseIdentifier];
	[_collectionView registerClass:[ARBCascadeDemoHeaderFooterView class] forSupplementaryViewOfKind:ARBCollectionViewCascadeLayoutHeaderFooter withReuseIdentifier:ARBCascadeDemoFooterReuseIdentifier];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//generate some sample data to display
	_sampleDataSection1 = [NSMutableArray array];
	_sampleDataSection1Heights = [NSMutableArray array];
	for (NSInteger i = 0; i < ARBCascadeDemoSampleDataSizeSection1; i++) {
		[_sampleDataSection1 addObject:[NSString stringWithFormat:@"Section 0, Item %zd", i]];
		[_sampleDataSection1Heights addObject:@([self randomHeight])];
	}
	_sampleDataSection2 = [NSMutableArray array];
	_sampleDataSection2Heights = [NSMutableArray array];
	for (NSInteger i = 0; i < ARBCascadeDemoSampleDataSizeSection2; i++) {
		[_sampleDataSection2 addObject:[NSString stringWithFormat:@"Section 1, Item %zd", i]];
		[_sampleDataSection2Heights addObject:@([self randomHeight])];
	}
}

- (CGFloat)randomHeight
{
	//calculates a random height for each cell to simulate different height images in each cell
	return 100.0f + arc4random_uniform(250);
}

#pragma mark - Actions

- (void)addItems:(id)sender
{
	ARBCascadeDemoHeaderView *headerView = (ARBCascadeDemoHeaderView *)[sender superview];
	NSInteger section = headerView.section;
	
	NSMutableArray *sectionData = [self dataForSection:section];
	NSMutableArray *sectionDataHeights = [self heightsForSection:section];
	
	//this always adds the item at the beginning of the section, however items can be added anywhere within the collection view
	NSString *itemToAdd = [NSString stringWithFormat:@"Section %zd, Item %zd", section, [sectionData count]];
	[sectionData insertObject:itemToAdd atIndex:0];
	[sectionDataHeights insertObject:@([self randomHeight]) atIndex:0];
	[_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:section]]];
}

- (void)removeItems:(id)sender
{
	ARBCascadeDemoHeaderView *headerView = (ARBCascadeDemoHeaderView *)[sender superview];
	NSInteger section = headerView.section;
	
	NSMutableArray *sectionData = [self dataForSection:section];
	NSMutableArray *sectionDataHeights = [self heightsForSection:section];
	
	//this always removes an item from the 6th position of the section, however items can be removed anywhere within the collection view
	if ([sectionData count] > 6) {
		[sectionData removeObjectAtIndex:6];
		[sectionDataHeights removeObjectAtIndex:6];
		[_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:6 inSection:section]]];
	}
}

#pragma mark - Collection View Delegate/Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	NSArray *sectionData = [self dataForSection:section];
	return [sectionData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	ARBCascadeDemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ARBCascadeDemoCellReuseIdentifier forIndexPath:indexPath];
	
	NSArray *sectionData = [self dataForSection:indexPath.section];
	cell.title.text = sectionData[indexPath.item];
	
	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionReusableView *view = nil;
	if (indexPath.item == ARBCollectionViewCascadeLayoutHeaderItemNumber) {
		ARBCascadeDemoHeaderView *headerView = [_collectionView dequeueReusableSupplementaryViewOfKind:ARBCollectionViewCascadeLayoutHeaderFooter withReuseIdentifier:ARBCascadeDemoHeaderReuseIdentifier forIndexPath:indexPath];
		headerView.title.text = [NSString stringWithFormat:@"Header for section %zd", indexPath.section];
		headerView.section = indexPath.section;
		[headerView.addButton addTarget:self action:@selector(addItems:) forControlEvents:UIControlEventTouchUpInside];
		[headerView.removeButton addTarget:self action:@selector(removeItems:) forControlEvents:UIControlEventTouchUpInside];
		view = headerView;
	} else if (indexPath.item == ARBCollectionViewCascadeLayoutFooterItemNumber) {
		ARBCascadeDemoHeaderFooterView *footerView = [_collectionView dequeueReusableSupplementaryViewOfKind:ARBCollectionViewCascadeLayoutHeaderFooter withReuseIdentifier:ARBCascadeDemoFooterReuseIdentifier forIndexPath:indexPath];
		footerView.title.text = [NSString stringWithFormat:@"Footer for section %zd", indexPath.section];
		view = footerView;
	}
	return view;
}

#pragma mark - Cascade Layout Delegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ARBCollectionViewCascadeLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
	//calculates a random height for each cell to simulate different height images in each cell
	NSArray *heights = [self heightsForSection:indexPath.section];
	return [heights[indexPath.item] floatValue];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ARBCollectionViewCascadeLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section
{
	return 75.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ARBCollectionViewCascadeLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section
{
	return 75.0f;
}

#pragma mark - Helpers

- (NSMutableArray *)dataForSection:(NSInteger)section
{
	NSMutableArray *sectionData = nil;
	if (section == 0) {
		sectionData = _sampleDataSection1;
	} else if (section == 1) {
		sectionData = _sampleDataSection2;
	}
	return sectionData;
}

- (NSMutableArray *)heightsForSection:(NSInteger)section
{
	NSMutableArray *heights = nil;
	if (section == 0) {
		heights = _sampleDataSection1Heights;
	} else if (section == 1) {
		heights = _sampleDataSection2Heights;
	}
	return heights;
}

@end
