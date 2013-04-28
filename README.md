Overview
---
ARBCollectionViewCascadeLayout is UICollectionView layout for displaying items in a Pinterest-style grid.  Unlike other similar UICollectionView layouts, ARBCollectionViewCascadeLayout supports multiple sections and section header/footer views. In addition, there is full support for the insertItemsAtIndexPaths:, moveItemAtIndexPath:toIndexPath:, and deleteItemsAtIndexPaths: methods of UICollectionView, with animations when adding or removing items.

The layout calculations are designed to be done in an efficient manner. Where possible, layout information is cached and only those items that have been impacted by changes will have their positions recalculated.

ARBCollectionViewCascadeLayout uses ARC and requires iOS 6+.

Installation
---
- Download the source code from the github repository or add it as a git submodule to your project.
- Add the ARBCollectionViewCascadeLayout.xcodeproj project into your own project.
- Go into the Build Phases configuration for your project, and add the ARBCollectionViewCascadeLayout static library to the Target Dependencies section.
- While still in the Build Phases configuration, add the libARBCollectionViewCascadeLayout.a library to the Link Binary With Libraries section.
- In the Build Settings configuration, add the path to the header files to the Header Search Paths entry. This path will depend on where you put the source code in your own project.

Usage
---
A demo project is provided to display the capabilities and show how to use the layout. Simply open ARBCollectionViewCascadeLayoutDemo.xcworkspace in XCode and run the app on either a device or the simulator.

In order to use the layout, an instance must be created and the ARBCollectionViewCascadeLayoutDelegate must be set. Additionally, the cell classes must be registered before the collection view loads its first item.
```objc
	_cascadeLayout = [[ARBCollectionViewCascadeLayout alloc] init];
	_cascadeLayout.delegate = self;
	_cascadeLayout.numColumnsPortrait = 3;
	_cascadeLayout.numColumnsLandscape = 4;
	_cascadeLayout.itemPadding = 10.0f;
	
	_collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:_cascadeLayout];
	_collectionView.delegate = self;
	_collectionView.dataSource = self;
	self.view = _collectionView;
	
	[_collectionView registerClass:[ARBCascadeDemoCell class] forCellWithReuseIdentifier:@"cellReuseIdentifier"];
	[_collectionView registerClass:[ARBCascadeDemoHeaderView class] forSupplementaryViewOfKind:ARBCollectionViewCascadeLayoutHeaderFooter withReuseIdentifier:@"headerReuseIdentifier"];
	[_collectionView registerClass:[ARBCascadeDemoHeaderFooterView class] forSupplementaryViewOfKind:ARBCollectionViewCascadeLayoutHeaderFooter withReuseIdentifier:@"footerReuseIdentifier"];
```

ARBCollectionViewCascadeLayoutDelegate has a single required method.
```objc
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ARBCollectionViewCascadeLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath;
```

If the collection view will display section headers or footers, the optional delegate methods should be implemented.
```objc
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ARBCollectionViewCascadeLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ARBCollectionViewCascadeLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section;
```

Section header/footer view classes should be registered using the supplementary view kind value of ARBCollectionViewCascadeLayoutHeaderFooter. Section headers will have an index path with an item number of ARBCollectionViewCascadeLayoutHeaderItemNumber. Section footers will have an index path with an item number of ARBCollectionViewCascadeLayoutFooterItemNumber.

Customizations
---
There are three options for customizing the display of the UICollectionView with this layout.

* itemPadding: The amount of padding around each item
* numColumnsLandscape: The number of columns the collection view will have when in landscape.
* numColumnsPortrait: The number of columns the collection view will have when in portrait.

Additionally, the background color of the collection view can be modified by changing the backgroundColor property on the UICollectionView.

License
---
ARBCollectionViewCascadeLayout is available under the MIT license. See the LICENSE file for more information.
