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

NSInteger const ARBCascadeDemoSampleDataSizeSection1 = 100;
NSInteger const ARBCascadeDemoSampleDataSizeSection2 = 50;

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
	[_collectionView registerClass:[ARBCascadeDemoHeaderView class] forSupplementaryViewOfKind:ARBCollectionViewCascadeLayoutSupplementaryViewKindHeaderFooter withReuseIdentifier:ARBCascadeDemoHeaderReuseIdentifier];
	[_collectionView registerClass:[ARBCascadeDemoHeaderFooterView class] forSupplementaryViewOfKind:ARBCollectionViewCascadeLayoutSupplementaryViewKindHeaderFooter withReuseIdentifier:ARBCascadeDemoFooterReuseIdentifier];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//generate some sample data to display
	_sampleDataSection1 = [NSMutableArray array];
	_sampleDataSection1Heights = [NSMutableArray array];
//	for (NSInteger i = 0; i < CascadeDemoSampleDataSizeSection1; i++) {
//		[_sampleDataSection1 addObject:[NSString stringWithFormat:@"Section 0, Item %d", i]];
//		[_sampleDataSection1Heights addObject:@([self randomHeight])];
//	}
//	_sampleDataSection2 = [NSMutableArray array];
//	_sampleDataSection2Heights = [NSMutableArray array];
//	for (NSInteger i = 0; i < CascadeDemoSampleDataSizeSection2; i++) {
//		[_sampleDataSection2 addObject:[NSString stringWithFormat:@"Section 1, Item %d", i]];
//		[_sampleDataSection2Heights addObject:@([self randomHeight])];
//	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
//	[self testAddItems];
}

- (void)testAddItems
{
	NSString *itemToAdd = [NSString stringWithFormat:@"Section %d, Item %d", 0, [_sampleDataSection1 count]];
	NSLog(@"Adding item: %@", itemToAdd);
	[_sampleDataSection1 insertObject:itemToAdd atIndex:0];
	[_sampleDataSection1Heights insertObject:@([self randomHeight]) atIndex:0];
	[_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
	
	double delayInSeconds = 2.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self testAddItems];
	});
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
	
	NSMutableArray *sectionData = nil;
	NSMutableArray *sectionDataHeights = nil;
	if (section == 0) {
		sectionData = _sampleDataSection1;
		sectionDataHeights = _sampleDataSection1Heights;
	} else if (section == 1) {
		sectionData = _sampleDataSection2;
		sectionDataHeights = _sampleDataSection2Heights;
	}
	
	//this always adds the item into the 4th position of the section, however items can be added anywhere within the collection view
	NSString *itemToAdd = [NSString stringWithFormat:@"Section %d, Item %d", section, [sectionData count]];
	NSLog(@"Adding item: %@", itemToAdd);
	[sectionData insertObject:itemToAdd atIndex:0];
	[sectionDataHeights insertObject:@([self randomHeight]) atIndex:0];
	[_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:section]]];
}

- (void)removeItems:(id)sender
{
	ARBCascadeDemoHeaderView *headerView = (ARBCascadeDemoHeaderView *)[sender superview];
	NSInteger section = headerView.section;
	
	NSMutableArray *sectionData = nil;
	NSMutableArray *sectionDataHeights = nil;
	if (section == 0) {
		sectionData = _sampleDataSection1;
		sectionDataHeights = _sampleDataSection1Heights;
	} else if (section == 1) {
		sectionData = _sampleDataSection2;
		sectionDataHeights = _sampleDataSection2Heights;
	}
	
	//this always removes an item from the 6th position of the section, however items can be removed anywhere within the collection view
	[sectionData removeObjectAtIndex:6];
	[sectionDataHeights removeObjectAtIndex:6];
	[_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:6 inSection:section]]];
}

#pragma mark - Collection View Delegate/Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	if (section == 0) {
		return [_sampleDataSection1 count];
	} else if (section == 1) {
		return [_sampleDataSection2 count];
	}
	return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	ARBCascadeDemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ARBCascadeDemoCellReuseIdentifier forIndexPath:indexPath];
	
	NSArray *sectionData = nil;
	if (indexPath.section == 0) {
		sectionData = _sampleDataSection1;
	} else if (indexPath.section == 1) {
		sectionData = _sampleDataSection2;
	}
	
	cell.title.text = sectionData[indexPath.item];
	
	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionReusableView *view = nil;
	if (indexPath.item == ARBCollectionViewCascadeLayoutHeaderItemNumber) {
		ARBCascadeDemoHeaderView *headerView = [_collectionView dequeueReusableSupplementaryViewOfKind:ARBCollectionViewCascadeLayoutSupplementaryViewKindHeaderFooter withReuseIdentifier:ARBCascadeDemoHeaderReuseIdentifier forIndexPath:indexPath];
		headerView.title.text = [NSString stringWithFormat:@"Header for section %d", indexPath.section];
		headerView.section = indexPath.section;
		[headerView.addButton addTarget:self action:@selector(addItems:) forControlEvents:UIControlEventTouchUpInside];
		[headerView.removeButton addTarget:self action:@selector(removeItems:) forControlEvents:UIControlEventTouchUpInside];
		view = headerView;
	} else if (indexPath.item == ARBCollectionViewCascadeLayoutFooterItemNumber) {
//		ABCascadeHeaderFooterView *footerView = [_collectionView dequeueReusableSupplementaryViewOfKind:ARBCollectionViewCascadeLayoutSupplementaryViewKindHeaderFooter withReuseIdentifier:ARBCascadeDemoFooterReuseIdentifier forIndexPath:indexPath];
//		footerView.title.text = [NSString stringWithFormat:@"Footer for section %d", indexPath.section];
//		view = footerView;
	}
	return view;
}

#pragma mark - Cascade Layout Delegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ARBCollectionViewCascadeLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
	//calculates a random height for each cell to simulate different height images in each cell
	NSArray *heights = nil;
	if (indexPath.section == 0) {
		heights = _sampleDataSection1Heights;
	} else if (indexPath.section == 1) {
		heights = _sampleDataSection2Heights;
	}
	return [heights[indexPath.item] floatValue];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ARBCollectionViewCascadeLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section
{
	return 75.0f;
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ARBCollectionViewCascadeLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section
//{
//	return 75.0f;
//}


@end
